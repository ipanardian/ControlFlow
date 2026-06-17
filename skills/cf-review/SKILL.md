---
name: cf-review
description: Runs ControlFlow review handling and quality gates. Use before Gate 2, after AI or human review findings, or when reviewer comments need classification into required fixes, test gaps, nits, questions, follow-ups, and out-of-scope items.
---

# ControlFlow Review

Review and feedback stage for ControlFlow.

## Overview

Prepare Gate 2 and process review feedback without random patching. Review
must preserve spec compliance, test evidence, and lane-specific safety
requirements.

## When To Use This Skill

Use this skill for ControlFlow Gate 2 preparation, review feedback, or
post-review fixes.

## When NOT To Use This Skill

Do not use this skill when:

- There is no diff, review finding, or Gate 2 handoff to process.
- Feedback conflicts with the approved spec and the user has not chosen
  which source wins.
- The request is MR text only; use `cf-mr`.

## Process

For review feedback, load and follow `cf-post-review-fix`.

Use `references/review-checklist.md` for Gate 2 review coverage.
Use `references/security-checklist.md` when the diff touches security,
auth, secrets, user input, storage, or external boundaries.

Route specialized reviews to root reviewer personas when risk applies:

- `agents/security-auditor.md` for auth, secrets, security boundaries, or
  user input.
- `agents/test-engineer.md` for coverage gaps or expensive verification.
- `agents/api-contract-reviewer.md` for public API, proto, schema, or
  external contracts.
- `agents/performance-auditor.md` for performance-sensitive changes.

Before Gate 2, verify:

- Spec acceptance criteria are satisfied
- Required tests were run and evidence is recorded
- Required validation scenarios were run or collected, with result and evidence recorded
- Required review findings are fixed or escalated
- Lane B independent review requirements are met
- Remaining risks and unverified areas are explicit

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Reviewer comment is only a nit." | Classify first; some nits hide correctness or test gaps. |
| "Spec compliance was checked during build." | Gate 2 needs fresh review of actual diff and evidence. |
| "Unverified areas are obvious." | Unverified areas must be explicit for reviewer trust. |
| "Human manual checks can happen after MR is opened." | Human-owned required validation scenarios must be collected before MR creation. |

## Red Flags

- Required fixes mixed with optional follow-ups.
- Behavior changes without spec or test update.
- Review summary omits commands run.
- Validation scenario results are missing for feature, bug fix, or behavior
  change.
- Lane B lacks independent verification notes.

## Verification

Before leaving this skill, confirm:

- [ ] Findings are classified.
- [ ] Required and test-gap items are fixed or escalated.
- [ ] Tests rerun after fixes.
- [ ] Required validation scenarios are `PASS` or explicitly `N/A` with an
      approved reason.
- [ ] Gate 2 handoff includes risks and unverified areas.
- [ ] Lane B reviewer requirement is satisfied or blocked.
- [ ] Specialized reviewer persona is used when risk calls for it.

## Integration With Other Skills

This skill is called by `cf-intake` before commit preview and after MR
review feedback. Use `cf-post-review-fix` for detailed feedback handling.
