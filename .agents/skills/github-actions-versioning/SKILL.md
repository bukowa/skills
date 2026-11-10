---
name: github-actions-versioning
description: Query and resolve the latest real GitHub Action tags and releases using git ls-remote before creating or modifying GitHub Actions workflows. Prevents using outdated major versions (e.g., checkout@v3/v4) caused by LLM training cutoff.
---

# GitHub Actions Versioning & Tag Discovery

## Core Mandate

**Never hardcode or guess GitHub Action versions from training memory.**

LLMs suffer from training cutoffs and will naturally suggest years-old action versions (such as `actions/checkout@v3` or `v4`, `setup-python@v4`, or `setup-node@v3`) which may rely on deprecated Node.js runtimes (Node 12/16/20) or miss critical security features.

Before creating or editing any file under `.github/workflows/`, query the upstream repositories via `git ls-remote` to retrieve the current, real release tags.

---

## When to Use This Skill

- Creating a new GitHub Actions workflow file (`.github/workflows/*.yml`).
- Upgrading or maintaining existing CI/CD pipelines.
- Verifying whether action versions in a repository are current or deprecated.
- Pinning actions by exact release tag or by immutable commit SHA.

---

## Execution: Resolving Latest Tags via `git ls-remote`

Run this standard Python script (requires only Python standard library and `git`) to resolve the latest tags and commit SHAs for target actions:

```python
import subprocess
import re

repos = [
    "actions/checkout",
    "actions/setup-python",
    "actions/setup-node",
    "actions/cache",
    "actions/upload-artifact",
    "actions/download-artifact",
    "softprops/action-gh-release",
]

print(f"{'Repository':<30} {'Latest Tag':<15} {'Major':<8} {'Commit SHA'}")
print("-" * 80)

for repo in repos:
    try:
        raw = subprocess.check_output(
            ["git", "ls-remote", "--tags", "--refs", f"https://github.com/{repo}.git"],
            text=True,
            timeout=15,
        )
    except Exception as err:
        print(f"{repo:<30} ERROR: {err}")
        continue

    tag_map = {}
    for line in raw.strip().splitlines():
        parts = line.split()
        if len(parts) == 2:
            sha, ref = parts
            tag = ref.replace("refs/tags/", "")
            tag_map[tag] = sha

    # Filter semver tags: vX.Y.Z or X.Y.Z (excluding prereleases/alphas/betas)
    semver_tags = [
        t for t in tag_map.keys()
        if re.match(r"^v?\d+(\.\d+)+$", t) and not re.search(r"-(alpha|beta|rc|test)", t, re.I)
    ]

    if not semver_tags:
        # Fallback to any numeric tag (e.g., v1, v2)
        semver_tags = [t for t in tag_map.keys() if re.match(r"^v?\d+", t)]

    if semver_tags:
        # Sort numerically by semver components
        semver_tags.sort(key=lambda t: [int(x) for x in re.sub(r"^[^\d]*", "", t).split(".")])
        latest_tag = semver_tags[-1]
        major_tag = latest_tag.split(".")[0]
        sha = tag_map[latest_tag][:12]
        print(f"{repo:<30} {latest_tag:<15} {major_tag:<8} {sha}")
    else:
        print(f"{repo:<30} No semver tags found")
```

---

## Quick Shell / PowerShell One-Liner

If only checking a single action quickly:

```bash
# Git Bash / Linux / macOS
git ls-remote --tags --refs https://github.com/actions/checkout.git | tail -n 10
```

```powershell
# PowerShell
(git ls-remote --tags --refs https://github.com/actions/checkout.git) | Select-Object -Last 10
```

---

## Pinning Policy Guidelines

1. **Tag Pinning (Standard)**:
   - When the user prefers clean, standard tags: use the latest exact tag (e.g., `actions/checkout@v7.0.1`) or the floating major tag (`actions/checkout@v7`).
2. **SHA Pinning (Hardened Security / OpenSSF)**:
   - When the user requires immutable commit SHAs for supply-chain security: obtain the exact 40-character commit SHA corresponding to the latest release tag from the `git ls-remote` output and append the version comment:
     ```yaml
     uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
     ```
