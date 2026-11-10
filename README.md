# Personal Skills & Rules

Personal collection of custom skills and rules for Google Antigravity / Gemini CLI.

## Structure

- `.agents/rules/`: Global rule files (e.g. `output.md`).
- `.agents/skills/`: Custom skills (e.g. `fixing-bugs`, `github-actions-versioning`).

## Global Synchronization (`sync.ps1`)

Syncs skills and rules between this repository and your global configuration (`~/.gemini/config/`).

```powershell
# Push skills & rules to global config (~/.gemini/config)
.\sync.ps1

# Attempt NTFS directory junctions / symlinks first (falls back to copy)
.\sync.ps1 -Link

# Watch repository and sync automatically whenever a file is saved
.\sync.ps1 -Watch

# Pull skills & rules from ~/.gemini/config into this repository
.\sync.ps1 -Pull

# Preview changes without copying or writing any files
.\sync.ps1 -DryRun
```

### Automatic Git Hook (Optional)

To automatically sync on every `git commit`, add a post-commit hook:

```powershell
Set-Content -Path .git/hooks/post-commit -Value "powershell -ExecutionPolicy Bypass -File .\sync.ps1"
```
