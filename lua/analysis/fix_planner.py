def build_plan(issues):
    plan = {
        "meta": {
            "version": "2.0"
        },
        "issues": []
    }

    for i in issues:
        fix = {
            "action": "dynamic_eq",
            "freq": 2800,
            "q": 1.0,
            "depth": min(i["severity"], 0.6),
            "mode": "mid"
        }

        plan["issues"].append({
            **i,
            "fix": fix
        })

    return plan
