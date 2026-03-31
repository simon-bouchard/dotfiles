---
description: Scan target for refactor opportunities — redundancies, structure issues, improvements
allowed-tools: Task, Read, Grep, Glob
---

Scan the following for refactor opportunities: $ARGUMENTS

## Step 1 — Explore
Use Task (Explore subagent) to map the target:
- Read all relevant files
- Trace call sites, dependencies, and data flow
- Look for: redundancy, duplication, unclear naming, structural issues,
  over-coupling, dead code, type annotation gaps, missing error handling

## Step 2 — Analyze
Based on the exploration, produce a prioritized list of findings:
- What the issue is
- Where it is (file + line range)
- Why it matters
- Suggested approach to fix it

Group by priority: High / Medium / Low

Do not make any changes to source files.
