---
name: cf-mr-summary
description: Creates concise merge request or pull request titles and bodies from spec, diff, commits, and test evidence. Use before creating an MR/PR or when user asks for MR summary, PR summary, change summary, or review-ready description.
---

# MR Summary

Prepare review-ready MR or PR text. Do not create an MR/PR unless user explicitly asks and approval gate is passed.

## Inputs

Inspect:

- spec or issue notes when available
- git diff against target branch
- recent commits on branch
- test commands and results
- validation scenario results, including human-run evidence when required
- migration/API/config changes

## Title

Use concise action-oriented title:

```text
<type>: <what changed>
```

Examples:

- `feat: add idempotent order creation`
- `fix: prevent duplicate event publishing`
- `test: cover data ingestion failure paths`

## Body Template

```md
## Summary
- <main behavior change>
- <supporting change>

## Why
- <problem solved or user impact>

## Changes
- <code/API/data change>
- <test change>

## Test Evidence
- `<command>`: <pass/fail/notes>

## Validation Scenario Results
- `<VS-ID>`: <PASS/FAIL/BLOCKED/N/A> — <actor, environment, evidence>

## Risks
- <risk or "Low">

## Rollback
- <rollback note>

## Notes
- <migration/config/manual step if any>
```

## Rules

- Keep summary factual.
- Do not overclaim untested behavior.
- Include failed tests if unresolved, with reason.
- Mention unverified areas.
- Mention breaking API/data/schema changes clearly.
- If no tests were run, state `Not run` and why.
- Include validation scenario results for every feature addition, bug fix,
  or behavior change.
- Do not prepare MR creation as unblocked while any required validation
  scenario is missing, `FAIL`, or `BLOCKED`.

## Output

Return:

- MR/PR title
- MR/PR body
- suggested target branch if known
- open questions before MR creation
