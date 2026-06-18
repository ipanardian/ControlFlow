---
name: cf-intake
description: Orchestrates the ControlFlow human-gated delivery workflow from request through launch readiness. Use when starting or coordinating feature work, bug fixes, or multi-step AI-assisted delivery that must follow risk classification, specs, test plans, TDD, review gates, MR flow, and production readiness.
---

# ControlFlow Workflow

Default ControlFlow entry point and orchestrator. Use this skill to classify
incoming work, choose the smallest safe path, and keep AI-assisted work on
the human-gated path from request to production readiness.

## Overview

ControlFlow is a workflow state machine, not a skill collection. This
skill owns request routing and the handoffs between risk classification,
spec, test plan, execution plan, implementation, review, MR, and
production readiness.

Installed templates live in `~/.agents/controlflow/`. If missing, use this
repository's `templates/` files as fallback. Human-facing docs in `docs/`
are reference material, not required agent context.

## When To Use This Skill

Use this skill when the user asks to run the ControlFlow workflow, start
controlled AI delivery, or coordinate feature/bug work through human
gates.

For ControlFlow delivery work, this is the human-facing entry point. The
user should not need to choose `cf-spec-brainstorming`, `cf-spec`,
`cf-debugging`, `cf-build`, or later-stage skills up front. Start here, then
route inside this skill.

## When NOT To Use This Skill

Do not use this skill when:

- The user explicitly asks only for review feedback; use `cf-review`.
- The user explicitly asks only for MR text after Gate 2; use `cf-mr`.
- The user explicitly asks only for launch readiness after MR approval;
  use `cf-ship`.

Tiny obvious edits may be routed by this skill to direct edit, but they do
not require the full gated workflow.

## Process

Follow `cf-state-machine` as the detailed state-machine source of
truth. Keep user-facing handoffs in ControlFlow terms.

1. Start with `REQUEST_ROUTING` inside this skill unless the user
   explicitly asks only for a later-stage skill.
2. Classify the request and choose direct edit, mini-spec, full workflow,
   brainstorming, cf-debugging, review, MR, or ship path.
3. Confirm lane and verifiability before spec design or implementation.
4. Use `cf-spec` for spec design when formal scope is needed.
5. Create or update test plan before implementation, including validation
   scenarios for every feature addition, bug fix, or behavior change.
6. Stop for Gate 1: spec and test plan approval.
7. Produce visible execution plan.
8. Stop for Gate 1.5 when required.
9. Use `cf-build` for manual or subagent implementation.
10. Use `cf-review` before Gate 2 and for feedback.
11. Confirm required validation scenario results are present before MR
    summary or creation; human-owned scenarios require a human run result.
12. Use `cf-mr` after Gate 2 approval.
13. Use `cf-ship` for production readiness and launch approval.

Use `references/stage-handoff.md` at stage boundaries when continuing in
the same session would carry old brainstorming, large tool output, or
irrelevant prior-stage context. Default to a pasteable handoff block; do
not create handoff files unless the user asks or durable release/audit
handoff is needed.

## Request Routing

Choose the smallest safe path before work begins:

If the user invokes `cf-intake` or `/cf-intake` with no goal, problem,
or context, do not route yet. Ask for the missing intake fields:

```text
ControlFlow cf-intake is loaded. Please provide:

Goal: What should change?
Problem: What is broken, missing, risky, or unclear?
Context: Links, files, user report, constraints, or non-goals.
```

Routing is owned by this skill. Do not treat `cf-spec-brainstorming` as a
competing top-level entry point for ControlFlow delivery work unless the
user explicitly asks to brainstorm only. If brainstorming is needed,
invoke it as the `SPEC_BRAINSTORMING` pre-state and return here after
human direction approval.

- Direct edit: tiny, obvious, non-behavioral or trivially verifiable change
  with no Lane B trigger and no cross-file design decision. Feature
  additions, bug fixes, and behavior changes require at least a mini-spec
  with validation scenarios.
- Mini-spec: small bounded work where behavior, tests, or acceptance
  criteria need agreement before code.
- Full workflow: new behavior, unclear root cause, major refactor,
  API/schema/public contract change, security/auth/billing/permissions,
  data integrity, external integration, production rollout, or reviewer
  alignment before coding.
- Brainstorming: vague, creative, multi-path, or too large for one spec;
  invoke `cf-spec-brainstorming`, collect the Brainstorming Handoff, get
  human direction approval, then return to `cf-intake` and route toward
  mini-spec, `cf-spec`, or split specs.
- Debugging: unexpected behavior, failing tests, panics, races,
  performance regressions, or integration failures; use `cf-debugging`.
- Review/MR/ship: use `cf-review`, `cf-mr`, or `cf-ship` when the user is
  already in that stage.

When routing is non-obvious, output:

```md
## ControlFlow Routing
- Path: direct edit | mini-spec | full workflow | brainstorming | cf-debugging | review | MR | ship
- Lane: A | B | n/a
- Verifiability: cheap | expensive | n/a
- Recommended next skill: <skill-name or none>
- Return path: <for brainstorming/cf-debugging, where control returns next>
- Required gates: none | mini-spec approval | Gate 1 | Gate 1.5 | Gate 2 | Gate 3 | launch approval
- Worktree suggestion: yes | no
- Production readiness needed: yes | no
- Reason: <short factual reason>
```

Preserve ControlFlow identity in user-facing handoffs:

- Human-gated delivery workflow, not generic skill pack
- Risk classification before implementation
- Spec and test plan before TDD work
- Visible execution plan before code changes
- Explicit gates before risky transitions
- MR and production-readiness handoffs before launch
- Pasteable stage handoffs when fresh sessions reduce context drag

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The user asked for code, so skip spec." | ControlFlow requires spec/test-plan approval for risky or ambiguous work. |
| "This is Lane A, so no plan is needed." | Non-trivial Lane A still needs visible execution plan. |
| "Subagents make approval unnecessary." | Subagents execute approved work; they do not approve scope. |
| "MR created means delivery is done." | Production readiness and launch gates remain when release is in scope. |
| "Approved means approved, even with open questions." | Approval is invalid while the spec or test plan has `unresolved`, blank, or decision-less `Open Questions`. The agent blocks Gate 1 until they are resolved, not silently treats them as answered. |

## Open Question Blocker

Gate 1 approval is invalid while the spec or test plan contains unresolved
open questions. The router (this skill) is the first stage that sees the
human reply, so the check runs here even when other skills are not
loaded. Before accepting `approved` for Gate 1, Gate 1.5, or any later
stage that depends on a spec, the agent must scan every `Open Questions`
section in the spec and test plan.

- `None` means approval can proceed if the rest of the gate is valid.
- `decided` means approval can proceed if the decision is explicit.
- `out-of-scope` means approval can proceed if the boundary is explicit.
- `unresolved`, blank answers, or questions without an explicit
  `Decision:` line block Gate 1.

If unresolved open questions remain, the agent must not continue. It
responds:

```text
Gate 1 blocked. Open questions remain: <list>. Please answer them, convert them to decisions, or mark them out-of-scope before approval.
```

A bare `approved` reply does not override this blocker. The agent must
not load `cf-spec`, `cf-build`, or `cf-subagent-orchestration` until the
spec and test plan have no unresolved open questions.

## Red Flags

- Implementation starts before approved spec and test plan.
- Lane B trigger appears after routing but lane is not escalated.
- Execution plan changes silently after approval.
- Gate handoff lacks test evidence or unverified-area notes.
- Production action is proposed without launch approval.
- `approved` is accepted while `Open Questions` contains `unresolved`,
  blank, or decision-less items.

## Verification

Before leaving this skill, confirm:

- [ ] Lane and verifiability are recorded or not applicable.
- [ ] Current state and next gate are explicit.
- [ ] Required approvals are not skipped.
- [ ] Test evidence or planned evidence is named.
- [ ] Validation scenarios are present for feature additions, bug fixes,
      and behavior changes, including mini-spec work.
- [ ] Production-readiness need is marked.
- [ ] Pasteable stage handoff is produced when context should not carry
      into the next stage.

## Integration With Other Skills

This skill coordinates `cf-spec`, `cf-build`, `cf-review`, `cf-mr`,
`cf-ship`, and peer skills such as `cf-testing`, `cf-debugging`,
`cf-integration-testing`, and `cf-golang-engineer`.
