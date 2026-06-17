# MR Body Template

Use this template for the GitLab MR or GitHub PR description. Smaller Lane A
changes can use a trimmed version (Summary + Test Evidence + Risks).

> **Workflow reference:** see `docs/state-machine.md` for human-readable MR
> evidence and Gate 3 semantics. Agent execution rules live in
> `skills/cf-state-machine/SKILL.md`.

## Summary

- Main behavior change in one line.
- Supporting change in one line (omit if there is only one change).

## Why

The problem this solves or the user impact it creates. One to three
sentences. Reference the linked spec for full context.

## Lane

- **Lane:** A or B
- **Verifiability:** cheap or expensive
- **Risk:** low or high
- **Linked spec:** `docs/specs/<feature-slug>.md`
- **Linked test plan:** `docs/specs/<feature-slug>-tests.md` (or "embedded
  in spec")
- **Independent reviewer (Lane B only):** name, or "see linked test
  plan"

## Changes

- Code / API / data change, with `file:line` references where useful.
- Test change (new tests, modified tests, deleted tests).
- Spec or test plan change if behavior changed.

## Test Evidence

- `<command>`: pass / fail / notes
- `<command>`: pass / fail / notes

Quote the actual command and result, not a paraphrase. If a test was
skipped, say so and why.

## Validation Scenario Results

Required for any feature addition, bug fix, or behavior change, including
mini-spec work. MR creation is blocked while any required validation
scenario is missing, `FAIL`, or `BLOCKED` unless the spec and test plan are
updated and approved again.

| ID | Linked AC | Type | Actor | Environment | Result | Evidence |
|---|---|---|---|---|---|---|
| VS-1 | AC-1 | unit / integration / manual | AI / human | local / staging / sandbox | PASS / FAIL / BLOCKED / N/A | `<command/log/screenshot/link/note>` |

## Risks

State the risk level (Low, Medium, High) and the specific concern.
"Nothing significant" is acceptable only for tiny Lane A changes.

## Rollback

How to undo this change. Include the git revert command if it is
straightforward, or the operational rollback steps if it is not.

## Production Readiness

- **Production impact:** yes / no
- **Launch handoff required:** yes / no
- **Rollout notes:** feature flag, staged rollout, deployment order, or
  "n/a"
- **Monitoring notes:** logs, metrics, alerts, dashboards, or "n/a"
- **Post-launch validation:** smoke, API/UI, data, job, downstream checks,
  or "n/a"
- **Stop conditions:** pause, rollback, escalation conditions, or "n/a"

## Notes

- Any migration, configuration, or manual step required.
- Links to related issues, incidents, or follow-up items.
- Anything the reviewer should know that does not fit the sections
  above.
