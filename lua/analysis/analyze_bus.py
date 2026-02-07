#!/usr/bin/env python3
# =========================================================
# MCP Auto Mix Engine
# Bus Analysis (Essentia Offline)
#
# Purpose:
#   Analyze rendered BUS audio (vocal / music)
#   and output *responsibility-ready* JSON.
#
# Design rules:
# - BUS level only (not stem / track)
# - Stable, interpretable features
# - No ML, no training, no magic
# =========================================================

import sys
import json
import os
import numpy as np

import essentia
import essentia.standard as es


# ---------------------------------------------------------
# Utilities
# ---------------------------------------------------------

def safe_mean(x):
    if x is None or len(x) == 0:
        return 0.0
    return float(np.mean(x))


def clamp(v, lo=0.0, hi=1.0):
    return max(lo, min(hi, v))


# ---------------------------------------------------------
# Core analysis
# ---------------------------------------------------------

def analyze_bus(wav_path: str) -> dict:
    if not os.path.exists(wav_path):
        raise FileNotFoundError(wav_path)

    # ---------- Load ----------
    audio, sr = es.MonoLoader(filename=wav_path)()

    # Safety
    if len(audio) < sr:
        raise RuntimeError("Audio too short for analysis")

    # ---------- Loudness (LUFS approx) ----------
    loudness = es.LoudnessEBUR128()(audio)
    integrated_lufs = float(loudness[2])  # LUFS-I

    # ---------- Spectrum ----------
    windowing = es.Windowing(type="hann")
    spectrum = es.Spectrum()
    mfcc = es.MFCC(numberCoefficients=13)

    frame_size = 2048
    hop_size = 512

    spectra = []
    mfccs = []

    for frame in es.FrameGenerator(audio,
                                   frameSize=frame_size,
                                   hopSize=hop_size,
                                   startFromZero=True):
        spec = spectrum(windowing(frame))
        spectra.append(spec)
        _, mf = mfcc(spec)
        mfccs.append(mf)

    spectra = np.array(spectra)
    mfccs = np.array(mfccs)

    # ---------- Presence (2k–5k energy ratio) ----------
    freqs = np.linspace(0, sr / 2, spectra.shape[1])
    pres_band = np.logical_and(freqs >= 2000, freqs <= 5000)
    presence_energy = safe_mean(np.mean(spectra[:, pres_band], axis=1))
    total_energy = safe_mean(np.mean(spectra, axis=1))
    presence = clamp(presence_energy / (total_energy + 1e-9))

    # ---------- Sibilance proxy (6k–10k, HF instability) ----------
    sib_band = np.logical_and(freqs >= 6000, freqs <= 10000)
    sib_energy = np.mean(spectra[:, sib_band], axis=1)
    sibilance = clamp(np.std(sib_energy) / (np.mean(sib_energy) + 1e-9))

    # ---------- Low-mid density (150–400 Hz) ----------
    lowmid_band = np.logical_and(freqs >= 150, freqs <= 400)
    lowmid_energy = safe_mean(np.mean(spectra[:, lowmid_band], axis=1))
    lowmid = clamp(lowmid_energy / (total_energy + 1e-9))

    # ---------- Stereo spread (if stereo file slipped in) ----------
    try:
        stereo, _ = es.EasyLoader(filename=wav_path, replayGain=False)()
        if stereo.ndim == 2 and stereo.shape[1] == 2:
            left = stereo[:, 0]
            right = stereo[:, 1]
            corr = np.corrcoef(left, right)[0, 1]
            stereo_spread = clamp(1.0 - abs(corr))
        else:
            stereo_spread = 0.0
    except Exception:
        stereo_spread = 0.0

    # ---------- Dynamic complexity ----------
    rms = es.RMS()(audio)
    dynamic_complexity = clamp(np.std(rms) / (np.mean(rms) + 1e-9))

    # -------------------------------------------------
    # Output (RESPONSIBILITY-READY)
    # -------------------------------------------------

    return {
        "loudness": integrated_lufs,          # LUFS-I
        "presence": presence,                 # 0..1
        "sibilance": sibilance,               # 0..1
        "low_mid": lowmid,                    # 0..1
        "stereo_spread": stereo_spread,       # 0..1
        "dynamic_complexity": dynamic_complexity
    }


# ---------------------------------------------------------
# CLI
# ---------------------------------------------------------

def main():
    if len(sys.argv) < 3:
        print("Usage: analyze_bus.py <input.wav> <output.json>")
        sys.exit(1)

    wav_path = sys.argv[1]
    out_path = sys.argv[2]

    try:
        result = analyze_bus(wav_path)
    except Exception as e:
        print(f"[ERROR] Analysis failed: {e}")
        sys.exit(2)

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2)

    print(f"[OK] Analysis written to {out_path}")


if __name__ == "__main__":
    main()