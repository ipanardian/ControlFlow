---
name: cf-mr
description: Prepares ControlFlow merge request or pull request handoff. Use after Gate 2 approval when generating review title/body, test evidence, risk notes, rollback notes, and final approval before creating the MR or PR.
---

# ControlFlow MR

Merge request or pull request stage for ControlFlow.

## Overview

Prepare review-ready MR or PR content after Gate 2. Creation is a separate
action and requires Gate 3 approval.

Use `~/.agents/controlflow/mr-template.md` when installed. If missing, use
`templates/mr-template.md` from this repository.

## When To Use This Skill

Use this skill after Gate 2 approval, before creating a GitLab MR or GitHub
PR.

## When NOT To Use This Skill

Do not use this skill when:

- Gate 2 is not approved.
- Test evidence is missing.
- Required validation scenario results are missing, `FAIL`, or `BLOCKED`.
- The user wants production launch readiness; use `cf-ship` after MR
  review readiness.

Never create an MR until Gate 3 approval is explicit.

## Process

Load and follow `cf-mr-summary` to prepare the MR title and body.

Use `references/review-checklist.md` to confirm the MR includes evidence,
risk, rollback, and unverified areas.

Use `references/stage-handoff.md` when moving from Gate 2 approval into
MR summary or from MR approval into production readiness. Keep the MR body
structure unchanged; the handoff only helps a fresh session resume.

After the user approves the MR/PR summary, inspect `git remote -v` and choose
the creation skill:

- GitLab remote: load and follow `cf-glab-mr-create`.
- GitHub remote: load and follow `cf-gh-pr-create`.
- Ambiguous or multiple forge remotes: ask which forge to use before loading
  a creation skill.

Include:

- Summary and why
- Changes
- Test evidence
- Validation scenario results for feature additions, bug fixes, or behavior
  changes, including human-run results before creation
- Risks and rollback
- Production-readiness notes when relevant

Use `references/production-readiness-checklist.md` for release-impacting
changes.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The MR body can be brief because commits explain it." | Reviewers need summary, risk, test evidence, and rollback in one place. |
| "Approval to summarize means approval to create." | Gate 3 separately approves MR creation. |
| "Manual validation can be added after opening the MR." | Required validation scenarios must be complete before MR creation. |
| "Production notes can wait." | Release-impacting changes need readiness notes before launch planning. |

## Red Flags

- MR body lacks test evidence.
- MR body lacks required validation scenario results.
- Rollback says "revert" despite migrations or config changes.
- Risks are marked low without rationale.
- MR is created before explicit Gate 3 approval.

## Verification

Before leaving this skill, confirm:

- [ ] Gate 2 approval exists.
- [ ] MR title and body are previewed.
- [ ] Test evidence is included.
- [ ] Required validation scenario results are included and none are
      missing, `FAIL`, or `BLOCKED`.
- [ ] Risks and rollback are included.
- [ ] Gate 3 approval is requested before creation.
- [ ] Pasteable stage handoff is produced when MR or ship work should
      continue in a fresh session.

## Integration With Other Skills

This skill is called by `cf-intake` after Gate 2 and before external review.
Use `cf-mr-summary` for text generation and `cf-glab-mr-create` or
`cf-gh-pr-create` only after approval.
