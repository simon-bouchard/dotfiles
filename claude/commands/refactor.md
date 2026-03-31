---
description: Execute a refactor using scan findings and/or explicit instructions
allowed-tools: Task, Read, Write, Edit, Bash, Grep, Glob
---

Instructions: $ARGUMENTS

## Step 1 — Confirm scope
Use Task (Explore subagent) to verify current state of the files in scope.
Check nothing has changed since the scan that would affect the plan.

## Step 2 — Implement
Apply the refactor. Follow existing code conventions.

For tests:
- Update test structure to match the new design — don't preserve tests that test
  implementation details that no longer exist
- Do not add or remove test cases (don't change what behaviour is covered)
- Do not add workarounds to make old tests pass with new code

## Step 3 — Verify
Run the test suite: `python -m pytest`
If tests fail, fix the root cause — not the test.

## Step 4 — Summary
Report:
- What was changed and why
- Every test file modified (list each one)
- Any findings from the scan that were intentionally skipped, and why
