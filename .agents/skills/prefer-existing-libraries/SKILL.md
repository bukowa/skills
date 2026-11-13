---
name: prefer-existing-libraries
description: Check whether the standard library or a well-known, proven library already solves a problem before writing custom plumbing, parsers, OS hacks, or helper utilities. Propose the standard option to the user and get approval before implementing.
---

# Prefer Standard & Proven Libraries

Never hand-roll custom plumbing, parsers, protocols, OS workarounds, or low-level helpers when a clean built-in feature or popular library already exists.

## Workflow

1. **Search before coding:** Whenever a task needs non-trivial infrastructure (filesystem, archives, terminal/UI, concurrency, data formats, networking, crypto, CLI, etc.), check in order:
   - the language's **standard library** (including recent features available in the project's version),
   - official companion modules (such as `golang.org/x/*`),
   - widely used, well-maintained ecosystem packages.
2. **Verify, don't guess:** Check the project's manifest (`go.mod`, `package.json`, `pyproject.toml`, `Cargo.toml`) and verify the exact API from real docs or sources before suggesting it.
3. **Propose first, build after approval:** Briefly show the user the standard/library option — what custom code it avoids and any trade-off with repo rules. Wait for the user's agreement before adding a dependency or implementing it.
4. **Keep it lean:** Prefer small, focused, mainstream libraries over heavy frameworks, and respect project limits (minimal deps, no CGo, offline/portable builds).
