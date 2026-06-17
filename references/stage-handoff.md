# Stage Handoff Reference

Use pasteable stage handoffs to continue ControlFlow work in a fresh
session without carrying old chat history.

## Default Mode

Default to a pasteable handoff block. Do not create handoff files unless
the user asks, work spans multiple days, Lane B auditability requires it,
or production/release coordination needs a durable artifact.

## When To Produce A Handoff

Produce a compact handoff at stage boundaries when continuing in the same
session would carry unnecessary history:

- Gate 1 approved: spec and test plan are ready for build planning.
- Gate 1.5 approved: execution plan is ready for implementation.
- Build complete: implementation is ready for Gate 2 review.
- Gate 2 approved: commits are ready for MR summary.
- MR approved or release in scope: launch planning is ready for `cf-ship`.

Also produce a handoff when the user may respond asynchronously, the
session has accumulated large tool output, or the next stage no longer
needs brainstorming or earlier discussion history.

## Required Properties

A stage handoff must be sufficient for a new session to resume safely.
Include:

- Resume command.
- Current gate and next stage.
- Lane and verifiability.
- Branch and base/head SHA when relevant.
- Artifact paths: spec, test plan, execution plan, review handoff, MR.
- Scope summary by acceptance criterion or release item.
- Constraints, non-goals, risks, and unverified areas.
- Evidence: tests, reviews, approvals, and known failures.
- Next action.

Do not include old brainstorming, superseded options, long transcripts,
or repeated rationale. If something is unresolved, include it explicitly.

## Resume Behavior

When starting from a pasted handoff, the agent must:

1. Read the handoff first.
2. Read listed artifact paths before acting.
3. Verify branch and worktree status before code, commit, MR, or launch
   actions.
4. Confirm the declared gate state from artifacts or repo state when
   possible.
5. Continue only from the stated next action.

The handoff is a map. The repository and artifacts are source of truth.

## Pasteable Template

```text
Use ControlFlow. Continue from this handoff. Do not rely on previous chat.

State:
- Gate: <Gate 1 approved | Gate 1.5 approved | Gate 2 approved | MR approved | launch plan approved>
- Next stage: <execution plan | build | Gate 2 review | MR summary | production readiness | launch>
- Lane: <A | B | n/a>
- Verifiability: <cheap | expensive | n/a>
- Branch: <branch-name>
- Base/Head SHA: <sha or n/a>

Artifacts:
- Spec: `<path or n/a>`
- Test plan: `<path or n/a>`
- Execution plan: `<inline summary or path or n/a>`
- Review/Gate handoff: `<path or inline summary or n/a>`
- MR: `<url or n/a>`

Scope:
- AC1/release item: <one line>
- AC2/release item: <one line>

Constraints:
- Non-goals: <one line or none>
- Risk notes: <one line or none>
- Unverified areas: <one line or none>
- Stop conditions: <one line or none>

Evidence:
- Tests: `<command>` <PASS | FAIL | not run, reason>
- Reviews: <self-review/subagent/human/external review status>
- Approvals: <approved gates and approver if known>

Next action:
- <single next action for the new session>
```

## Optional File Mode

If durable handoff is needed, ask before writing a file. Suggested path:

```text
docs/handoffs/<slug>-<stage>.md
```

Default remains pasteable handoff to avoid repository noise.
