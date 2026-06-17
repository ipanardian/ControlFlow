---
name: cf-spec
description: Guides ControlFlow spec design for human-gated delivery. Use when turning a request, bug report, or brainstorming handoff into an approved spec with lane classification, verifiability, scope, invariants, risks, and acceptance criteria.
---

# ControlFlow Spec

Spec design stage for ControlFlow.

## Overview

Turn an approved direction or rough request into a bounded spec that can
be reviewed before tests and implementation begin.

Use `~/.agents/controlflow/spec-template.md` when installed. If missing,
use `templates/spec-template.md` from this repository.

## When To Use This Skill

Use this skill during ControlFlow spec design, before test planning and
before implementation.

## When NOT To Use This Skill

Do not use this skill when:

- The request needs brainstorming first; use `cf-spec-brainstorming`.
- The work is already approved and ready to implement; use `cf-build`.
- The change is non-behavioral direct edit only. Feature additions, bug
  fixes, and behavior changes still require at least a mini-spec with
  validation scenarios.
- The user only needs MR or launch readiness.

## Process

Follow `cf-spec-planning` as the detailed spec-writing protocol.

Use `references/lane-classification.md` when classifying risk and
verifiability.

Ensure the spec records:

- Lane A or Lane B classification
- Verifiability: cheap or expensive
- Risk level and heavy-trigger rationale
- Scope and non-goals
- Invariants and edge cases
- Acceptance criteria
- Validation scenarios mapped to acceptance criteria for every feature
  addition, bug fix, or behavior change, including mini-spec work
- Production-readiness implications when relevant

Use `references/production-readiness-checklist.md` when launch, rollout,
rollback, migration, or monitoring can affect scope.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Acceptance criteria are obvious." | If two engineers could differ, criteria must be written. |
| "Mini-spec is small enough to skip validation scenarios." | Any feature addition, bug fix, or behavior change needs at least one validation scenario before implementation. |
| "Risk can be classified later." | Lane determines gates, reviewers, and execution mode. |
| "Production impact is only for launch." | Rollout and rollback constraints can shape the spec. |
| "Open questions can be answered during implementation." | Only topics that do not change scope, acceptance criteria, test expectations, risk, or rollout belong in Risks or the execution plan. Anything else must be answered before Gate 1 approval, or marked `out-of-scope` with an explicit boundary. |

## Open Question Blocker

This skill is the one that produces the spec handed off at Gate 1. It
must enforce the open-question rule at handoff time, not delegate it to
later skills that may not be loaded.

Before the Gate 1 handoff:

- Every item in the spec `Open Questions` must be `decided`,
  `out-of-scope`, or `None`. Items with status `unresolved`, blank, or
  missing an explicit `Decision:` line are blockers.
- Topics resolvable during implementation without changing scope,
  acceptance criteria, test expectations, risk, or rollout behavior go
  to Risks or the execution plan, not Open Questions.

If the spec still has unresolved open questions, the agent must not
hand it off for approval. It responds:

```text
Gate 1 blocked. Open questions remain: <list>. Please answer them, convert them to decisions, or mark them out-of-scope before approval.
```

A bare `approved` reply on a spec with unresolved open questions is
treated as invalid. The agent re-checks the spec, re-emits the blocker
message, and waits.

## Red Flags

- Spec has scope but no non-goals.
- Lane B trigger exists but spec says Lane A.
- Acceptance criteria are implementation tasks, not observable outcomes.
- Feature addition, bug fix, or behavior change lacks validation scenarios.
- Risks or rollback are omitted for Lane B.
- `Open Questions` section is missing, contains `None` with no
  justification, or has items without `Status:` and `Decision:` lines.

## Verification

Before leaving this skill, confirm:

- [ ] Lane and verifiability are recorded.
- [ ] Scope and non-goals are explicit.
- [ ] Invariants and edge cases are covered.
- [ ] Acceptance criteria are testable.
- [ ] Validation scenarios exist when behavior changes and map to
      acceptance criteria.
- [ ] Production-readiness implications are noted or marked none.

## Integration With Other Skills

This skill is called by `cf-intake` after intake and before test-plan
approval. Use `cf-spec-brainstorming` first when the request is vague.
