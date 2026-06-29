---
name: cf-build
description: Executes an approved ControlFlow plan with TDD and review gates. Use after spec, test plan, and visible execution plan are approved, when implementing manually or dispatching subagents under Lane A or Lane B eligibility rules.
---

# ControlFlow Build

Implementation stage for an approved ControlFlow plan.

## Overview

Execute only approved scope. Choose manual mode or subagent mode based on
lane, coupling, and verifiability, then preserve test and validation
scenario evidence for Gate 2.

## When To Use This Skill

Use this skill after Gate 1 and the visible execution plan are complete.
For non-trivial Lane A or eligible Lane B work, use it after Gate 1.5 is
approved.

## When NOT To Use This Skill

Do not use this skill when:

- Spec and test plan are not approved.
- Required validation scenarios for a feature addition, bug fix, or
  behavior change are missing.
- Required Gate 1.5 approval is missing.
- Lane B heavy trigger is being proposed for subagent mode.
- The request is still unclear; return to `cf-spec` or
  `cf-spec-brainstorming`.

## Process

Follow `cf-state-machine` for manual mode.

Before writing failing tests or implementation, run a lean-change check:

- Existing behavior, configuration, or docs are insufficient.
- Existing repo pattern/helper cannot satisfy the acceptance criteria.
- Stdlib, framework, native platform feature, or installed dependency cannot
  safely solve it alone.
- New dependency, schema, config, public API, abstraction, or service boundary
  has explicit rationale if proposed.

After targeted tests pass, load `cf-code-simplification` for a post-green
simplification pass unless the diff is documentation-only or already contains
no implementation change. Preserve tests and required safety guards.

Use `references/testing-patterns.md` when designing or validating test
evidence.

Use `references/stage-handoff.md` when Gate 1 or Gate 1.5 approval will
be resumed in a fresh session, or when build output is ready for Gate 2
and old planning history should not carry forward.

Prefer manual mode for Lane A work with 1-2 acceptance criteria unless
the work is unusually risky, large, or review isolation clearly outweighs
subagent overhead.

Load and follow `cf-subagent-orchestration` when all eligibility rules are
met:

- 3+ mostly independent acceptance criteria, OR estimated effort is 45+
  minutes, OR explicit rationale that isolated implementation/review will
  reduce rework more than it repeats context
- Approved visible execution plan
- Lane A, or Lane B without heavy trigger
- Total estimated effort justifies subagent overhead

Use `references/subagent-dispatch-checklist.md` before dispatch.

If the work is Lane B with heavy trigger, use manual mode and external
reviewer requirements from `cf-state-machine`.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I can add tests after code." | ControlFlow requires failing tests first unless explicit exception applies. |
| "Subagent mode is faster." | Eligibility controls subagent use, not speed. |
| "Small implementation changes do not need Gate 2 evidence." | Gate 2 needs test evidence and review notes. |
| "Manual validation can wait until after MR creation." | MR creation is blocked until required validation scenario results exist. |
| "Spec already says approved, so open questions are fine." | Approval is invalid while the spec or test plan has unresolved open questions. The agent re-checks Gate 1 here, blocks, and waits for decisions before any TDD work. |
| "The new abstraction keeps things clean." | Add abstraction only when acceptance criteria, repeated real callers, or invariants justify it. |

## Open Question Blocker

This skill runs after Gate 1. The agent must re-verify Gate 1
prerequisites before any TDD or commit work, even when an earlier
session produced an `approved` reply. The check is local to this skill
because subagent or manual mode may load this skill without reloading
`cf-intake` or `cf-spec`.

Before writing failing tests:

- Scan every `Open Questions` section in the spec and test plan.
- `None`, `decided`, and `out-of-scope` are valid only when explicit.
- `unresolved`, blank, or decision-less items block this stage.

If unresolved open questions remain, the agent must not start TDD or
implementation. It responds:

```text
Gate 1 blocked. Open questions remain: <list>. Please answer them, convert them to decisions, or mark them out-of-scope before approval.
```

This also applies to Gate 1.5, manual commit preview, and the
subagent-mode aggregate commit review. The agent must not create commits
or dispatch subagents on a spec with unresolved open questions, even if
the human already typed `approved` in chat.

## Red Flags

- Code changes appear before failing tests for behavior work.
- Subagent task does not map to approved execution plan.
- Lane B heavy trigger enters subagent mode.
- Test failure is environmental but treated as expected red phase.
- Required validation scenario is missing, `FAIL`, or `BLOCKED` and work
  proceeds to Gate 2 or MR creation.
- TDD or commit work starts while the spec `Open Questions` section
  still has `unresolved`, blank, or decision-less items.
- New dependency, schema, config, public API, abstraction, or service boundary
  appears without lean-change rationale.
- Post-green simplification removes validation, security, observability,
  accessibility, rollback, or acceptance-criteria tests.

## Verification

Before leaving this skill, confirm:

- [ ] Gate prerequisites are satisfied.
- [ ] Lean-change check completed before implementation.
- [ ] Manual or subagent mode is justified.
- [ ] Failing tests were observed first when required.
- [ ] Targeted tests pass after implementation.
- [ ] Post-green simplification pass completed or explicitly not applicable.
- [ ] Required validation scenarios were run by AI or collected from human
      runner, with result and evidence recorded.
- [ ] Manual mode has pending commit preview and evidence ready for Gate 2.
- [ ] Subagent mode has planned commit split and evidence ready for Gate 2.
- [ ] Pasteable stage handoff is produced when the next stage should start
      fresh.

## Integration With Other Skills

This skill is called by `cf-intake` between approved planning gates and
Gate 2. Use `cf-subagent-orchestration` only when eligibility rules are met.
