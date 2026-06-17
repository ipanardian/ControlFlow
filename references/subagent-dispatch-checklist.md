# Subagent Dispatch Checklist Reference

Use this reference before dispatching subagents from `cf-build` or
`cf-subagent-orchestration`.

## Eligibility

All must be true:

- Gate 1 approved.
- Required Gate 1.5 approved.
- Visible execution plan exists.
- 3+ mostly independent acceptance criteria, OR estimated effort is 45+
  minutes or more, OR explicit rationale shows review isolation reduces
  rework more than repeated context costs.
- Lane A, or Lane B without heavy trigger.
- Estimated effort justifies subagent overhead.

Do not dispatch when:

- One acceptance criterion.
- Lane A has 2 isolated acceptance criteria and no special review value.
- Tightly coupled criteria.
- Lane B heavy trigger.
- Required approval is missing.
- Task split would change approved plan.

## Prompt Inputs

Each subagent prompt must include:

- Exact criterion text.
- Approved scope and non-goals.
- Relevant file refs.
- Test plan refs.
- Constraints and forbidden changes.
- Expected output format.

## Review Chain

For each criterion:

- Implementer reports files changed, tests run, evidence, risks.
- Lane A isolated criteria may use one combined reviewer for acceptance
  criteria, scope, quality, safety, tests, and maintainability.
- Lane B no-heavy and coupled Lane A use two-stage review: spec reviewer
  checks acceptance criteria and scope; code reviewer checks quality,
  safety, tests, and maintainability.
- Required fixes go back to implementer.

After all criteria:

- Run final cross-criterion review when Lane B no-heavy, shared files,
  shared interfaces, config/runtime coupling, or reviewer-raised
  cross-criterion risk exists.
- If final review is skipped for isolated Lane A, record the rationale.
- Aggregate commits and evidence for Gate 2.

## Red Flags

- Subagent receives vague task summary instead of exact criterion.
- Subagent changes shared interface without escalation.
- Reviewer skips test evidence.
- Final cross-criterion review is omitted without an allowed skip
  rationale.
