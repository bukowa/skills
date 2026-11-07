---
name: fixing-bugs
description: Find, diagnose and fix bugs without getting stuck in loops. Use when the user reports something broken, failing, wrong, hanging or slow, or asks to debug, diagnose, investigate or fix a bug.
---

# Fixing Bugs

Three ideas run through every step:

1. **Cheapest evidence first.** Reading code and running tests come before live probes and scripts.
2. **Real data beats theories.** A guess stays a guess until real output confirms it.
3. **Stop when stuck.** A short, honest status report beats 50 more tool calls.

Redact secrets (tokens, keys, credentials) in everything you show: write `<REDACTED>`.

## Step 1: Pin the symptom

Write one sentence: **"When I do X, I expect Y, but get Z."** Use the user's exact words, logs or screenshots.

If you can't fill in X, Y and Z, ask the user before doing anything else.

## Step 2: Check what is already known

- `git log` / `git diff` for the affected area. Did it work before? What changed?
- Docs, notes, ADRs, earlier investigation reports.
- Don't redo an investigation that already reached a conclusion. Don't quietly reverse an earlier decision: if you think it was wrong, say why.
- Docs, research notes and comments are **claims, not facts**. That includes your own earlier statements in this conversation.

## Step 3: Read the code path once

Trace from the entry point (command, request, click) to where the symptom appears. Look for these common causes first:

- [ ] Errors swallowed, or the program exits without a message
- [ ] Success decided by a status code or a "no exception" check, without looking at the response body
- [ ] Hardcoded values (IDs, names, model or version strings, URLs) that differ per user, plan or environment
- [ ] Wrong fallback order or precedence (`a or b` where `b` should win)
- [ ] Inverted conditions, off-by-one errors, wrong comparisons
- [ ] Cached or stale data shown as if it were live
- [ ] Sleeps, retries or timeouts that make the program look frozen
- [ ] Tests whose mocks don't match the real data shape, so they pass while the code is wrong

Anything you find is a **suspect**, not a proven cause. Take it to Step 4.

## Step 4: Get one real signal

Pick the cheapest option that can answer your question:

1. Run the existing tests, or write a unit test with a realistic fixture.
2. Run the user's actual command with the user's input.
3. Write a tiny script that prints **only the fields that matter**.
4. **Ask the user** to run one command and paste the output. Do this whenever you lack access (sandbox, credentials, production, their machine).

Rules for each probe:

- **Before running it, write down what you expect to see** and what each possible result would mean. If no result would change your next step, don't run it.
- One probe answers one question.
- Keep output small. Never dump bulk data (every record, every account, full JSON, whole logs) into the conversation: filter it first.
- If access is blocked, ask the user **once** for exactly what you need, then wait. Don't build workarounds around a sandbox or permission check.
- Don't poll background tasks. Wait for the notification.

## Step 5: Narrow down the cause

- List 2–4 possible causes, each in the form **"If X is the cause, then Y will happen."**
- Test the cheapest check that tells them apart.
- If a result contradicts a cause, drop it. Don't stretch the theory to fit.
- If the user says your conclusion looks wrong, treat that as evidence. Re-check your assumptions instead of defending them.

For bugs that only happen sometimes, run the trigger many times until it reproduces often enough to debug. For slowness, measure a baseline before changing anything.

## Step 6: Fix

1. Write a test that fails because of the bug. Use real data shapes from Step 4, not invented ones.
2. Watch it fail.
3. Make the **smallest change** that fixes the proven cause.
4. Watch it pass, then re-check the original symptom from Step 1.
5. If Step 3 found problems that hide bugs (swallowed errors, unchecked responses), fix them too, but list them separately from the main fix.

Fix the cause. Don't hide it behind extra fallbacks, retries or special cases that no evidence asked for.

## Step 7: Clean up and report

- Delete throwaway scripts, temporary files and debug output.
- Run the project's usual checks (tests, linter, type checker).
- Report briefly:
  - **Cause:** what was wrong, and the evidence for it.
  - **Fix:** what you changed.
  - **Still assumed:** anything you didn't verify.
- Put the cause in the commit message or project notes so the next person or agent doesn't investigate it again.

## Tripwire: stop and report

Check this after every few tool calls. **Stop immediately** and report to the user if any of these is true:

- You've made 3 attempts at the same goal without learning anything new.
- You're about to write a second throwaway script for the same question.
- You're about to argue with the user instead of re-checking.
- You can't say in one sentence what your last 5 tool calls taught you.
- An output was too large to read properly.

Report in this format, then wait:

```text
Verified:    <facts confirmed by real output>
Assumed:     <beliefs not yet checked>
Need from you: <the one command, file, output or decision that would unblock me>
```

