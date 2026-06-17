---
name: cf-post-review-fix
description: Processes human or AI code review feedback into required fixes, nits, questions, tests, and follow-ups. Use after reviewer comments, MR review findings, or human review requests revisions.
---

# Post Review Fix

Handle review feedback systematically without random patching.

## Workflow

1. Collect feedback.
2. Classify each item.
3. Decide action.
4. Update tests/spec when behavior changes.
5. Apply minimal fix.
6. Re-run relevant tests.
7. Summarize what changed and what remains.

## Classification

Use these labels:

- `required`: correctness, safety, security, broken behavior, missing acceptance criteria
- `test-gap`: missing unit/integration coverage
- `nit`: style, naming, small readability issue
- `question`: needs reviewer/product clarification
- `follow-up`: valid but out of current scope
- `wont-fix`: rejected with reason

## Rules

- Fix `required` and `test-gap` items first.
- Ask one direct question for unclear `question` items.
- Do not expand scope for `follow-up` items.
- Do not change behavior without updating tests.
- If reviewer feedback conflicts with spec, ask user which source wins.
- Preserve unrelated user changes.

## Response Format

```md
## Review Feedback Handling
- `required`: <item> -> fixed in <file>
- `test-gap`: <item> -> covered by <test>
- `nit`: <item> -> fixed/skipped
- `question`: <item> -> needs answer
- `follow-up`: <item> -> deferred

## Tests
- `<command>`: <result>

## Remaining
- <open item or none>
```
