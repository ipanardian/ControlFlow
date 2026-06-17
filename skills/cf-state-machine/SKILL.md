---
name: cf-state-machine
description: Provides the detailed ControlFlow state-machine protocol with TDD, two-lane classification, human approval gates, AI review, cf-testing evidence, commits, MR flow, and production-readiness gates. Use when `cf-intake` needs the full canonical state and gate details.
---

# ControlFlow State Machine

## Overview

Run feature and bug-fix work as a controlled state machine. Do not skip
gates. This orchestrator delegates to sub-skills at each state; the user
only calls this one skill.

`cf-intake` is the canonical user-facing entry point. This skill is the
detailed state-machine reference that `cf-intake` follows.

This skill is the agent execution source of truth. Human-facing workflow
docs live in `docs/` and are not required agent context.

Installed templates:
`~/.agents/controlflow/spec-template.md`
`~/.agents/controlflow/test-plan-template.md`
`~/.agents/controlflow/mr-template.md`

If installed templates are missing, use `templates/` from this repository.

Reusable references:
`references/lane-classification.md`
`references/testing-patterns.md`
`references/review-checklist.md`
`references/security-checklist.md`
`references/production-readiness-checklist.md`
`references/subagent-dispatch-checklist.md`
`references/stage-handoff.md`

## When To Use This Skill

Use this skill when `cf-intake` needs the detailed state outputs,
gate requirements, or state transition rules.

## When NOT To Use This Skill

Do not use this skill as the default user-facing entry point; use
`cf-intake` instead. Do not use it to bypass `cf-spec`, `cf-build`,
`cf-review`, `cf-mr`, or `cf-ship` when those stage-specific skills are
more precise.

## Core Rule

No implementation before approved spec and failing tests, unless task is
documentation, formatting, config-only, or user explicitly asks to skip
TDD.

## Two-Lane Classification

Every change must be classified **before spec design**. The orchestrator
suggests a lane; the human confirms or escalates.

### Lane A — Light Lane

- Docs, lint, small UI tweaks, well-understood refactors.
- Mechanical checks are sufficient evidence.
- Same-model AI self-review is acceptable.
- Eligible for the Autonomous rung (see Promotion Ladder).

### Lane B — Heavy Lane

- New features, behavioral changes, API/schema changes.
- Any Lane B trigger (see below). One trigger = Lane B, no negotiation.
- Full spec with evidence, test plan with `file:line` evidence.
- Independent reviewer required (human or different-model + tool).
- Never Autonomous. Capped at Assisted.

### Lane B Triggers

Any single trigger forces Lane B. Escalation is one-way.

- Auth, authorization, session, or token changes.
- Irreversible migrations or destructive data operations.
- Security boundaries, secrets handling, cryptographic code.
- Changes to public API or proto contracts.
- Data integrity: any change that could cause incorrect data to be
  persisted, published, signed, attested, or consumed externally.
  This includes data pipelines, published events, signed/attested
  outputs, consensus handling, and aggregation logic — anything
  where downstream consumers or external systems depend on the
  correctness of what this service produces.

> This workflow is a development methodology, not a money-handling
> service. Direct money movement is out of scope for Lane B trigger;
> the relevant trigger is data integrity. If a change could cause
> incorrect data to be persisted, published, or consumed externally,
> it is Lane B.

Record the lane in the spec frontmatter. The human reviewer confirms
before approving the spec.

## Verifiability Axis

A second question alongside risk: how cheaply can we confirm the result
is correct? Record in the spec frontmatter as `verifiability: cheap |
expensive`.

- Cheap to verify → delegate with confidence.
- Expensive to verify → stronger gates, smaller slices, human eyes,
  regardless of how simple the diff looks.

A typo fix is cheap (read the file). A new aggregation formula is
expensive (integration test, manual validation).

## Optional Pre-State

During `REQUEST_ROUTING`, `cf-intake` decides whether
`SPEC_BRAINSTORMING` is needed before `BRANCH_CHECK`. Use
`cf-spec-brainstorming` when the initial request is vague, creative,
multi-path, or too large for one spec. Skip it for small obvious edits and
already-scoped work.

`cf-spec-brainstorming` is a child pre-state, not a competing user-facing
entry point. It produces a Brainstorming Handoff for spec planning, gets
human direction approval, then returns control to `cf-intake` for routing
toward mini-spec, `cf-spec`, or split specs. It does not replace the
formal spec or test plan.

## State Machine

Follow this skill as canonical agent protocol. Do not skip. Do not combine.

1. `REQUEST_ROUTING`
2. `SPEC_BRAINSTORMING` (optional)
3. `BRANCH_CHECK`
4. `SPEC_DESIGN`
5. `TEST_SCENARIO_DESIGN`
6. `AWAITING_HUMAN_SIGNAL` (Gate 1)
7. `EXECUTION_PLAN_PREVIEW`
8. `EXECUTION_PLAN_REVIEW` (Gate 1.5 when required)
9. `EXECUTION_MODE_SELECT`
10. Build path: subagent loop or manual TDD path
11. `HUMAN_REVIEW` (Gate 2: manual reviews each pending commit; subagent reviews all commits at once)
12. `REVISION_IF_NEEDED`
13. `MR_SUMMARY`
14. `MR_CREATE_AFTER_APPROVAL` (Gate 3)
15. `EXTERNAL_MR_REVIEW`
16. `MERGE_READINESS`
17. `PRODUCTION_READINESS` when release is in scope
18. Launch approval/action/rollout/post-launch validation when release is in scope
19. `FEEDBACK_LOOP`

## State Outputs

### BRANCH_CHECK

Before any spec, code, or test work begins, verify the git branch and
report whether it is protected. Do not make code/test/commit/MR changes on
master, main, or develop without an explicit branch decision.

1. Check current branch:
   ```sh
   git branch --show-current
   ```
2. If on master, main, or develop:
   - Before code/test edits, ask the user for a branch name or explicit
     confirmation to continue on that branch.
   - Determine the base branch: prefer `develop` if it exists remotely or
     locally, otherwise `main`, otherwise `master`.
   - Create the new branch:
     ```sh
     git fetch origin <base>
     git checkout -b <user-branch> origin/<base>
     ```
   - Confirm success: re-run `git branch --show-current` and report.
3. If already on a non-protected branch, report and continue.

Report: current branch, whether a new branch was created, base branch
used, outcome.

### SPEC_DESIGN

Create or update `docs/specs/<slug>.md`. Fill in the spec template from
`~/.agents/controlflow/spec-template.md` when installed, otherwise
`templates/spec-template.md` from this repository. Must include
frontmatter:

```yaml
---
lane: A | B
verifiability: cheap | expensive
risk: low | high
estimated_loc: small | medium | large
requires_independent_reviewer: bool
---
```

Required sections per the workflow doc (Problem, Goals, Non-Goals, Scope,
Current/Desired Behavior, Invariants, Edge Cases, API/data/schema changes,
Risks, Lane classification, Evidence type, Acceptance Criteria).

For Lane B: also include user/research evidence, rollback plan, blast
radius, out-of-scope related items.

Use `cf-spec-planning` for detailed spec work. Pass it the lane and
verifiability context. If `cf-spec-brainstorming` ran, pass the Brainstorming
Handoff as input to the spec.

### TEST_SCENARIO_DESIGN

Add test plan to spec or create `docs/specs/<slug>-tests.md`. Use the
test plan template. Required sections per workflow doc:

- Lane and verifiability classification.
- Unit/integration/failure/concurrency scenarios.
- Fixtures and test data.
- Commands expected to run.
- Expected failing test before implementation.
- Verification cost (runtime, complexity).
- Unverified areas (what is NOT covered and why acceptable).

For Lane B, also include: independent verification method (different
model, deterministic tool, or named human), severity classification
policy.

Pass the test plan to the `cf-testing` skill with Lane B requirements when
applicable.

### AWAITING_HUMAN_SIGNAL

Stop and ask for approval before code changes.

Before asking for approval and before accepting `approved`, check every
`Open Questions` section in the spec and test plan. Gate 1 is blocked if
any question is `unresolved`, blank, or lacks an explicit decision.
`None`, `decided`, and `out-of-scope` are valid only when explicit.

If unresolved open questions remain, do not continue to
`TDD_FAILING_TESTS`. Respond:

```text
Gate 1 blocked. Open questions remain: <list>. Please answer them, convert them to decisions, or mark them out-of-scope before approval.
```

A bare `approved` reply does not override unresolved open questions.

Ask one direct question:

```text
Approve spec and test plan so I can write failing tests first? Reply with `approved` or `deferred`.
```

#### Gate Review Hygiene

Approval only counts if the review is real. Enforce:

- **Size the gate to the artifact.** Multi-section PRDs must be split
  before approval.
- **Make the ask concrete.** "Approve if X" not "approve if this looks
  right." The reviewer states the specific condition that flipped their
  decision.
- **Require evidence.** Specs need user/research evidence. Test plans
  need `file:line` evidence.
- **Rotate the reviewer when the team is larger than 3.** For 2-3 person
  teams, the same reviewer must explicitly note they read the artifact
  and call out the section that changed their mind. Lane B requires an
  external reviewer (not the spec approver).
- **Make rejection cheap.** A "no, redo" is the workflow working, not
  failing.
- **Track approval latency.** Approving an 800-line spec in 30 seconds
  is a red flag. Flag it.
- **Sample-audit past approvals.** Periodically re-read closed MRs.

Do not implement until approval is explicit.

### TDD_FAILING_TESTS

Write tests first. Keep diff limited to test files unless compile helpers
are unavoidable.

Run targeted tests and confirm failure is expected behavior gap, not
environment/setup noise.

Report: test files changed, command run, failure summary, why expected.

### IMPLEMENTATION

Make the smallest production change needed to pass tests.

Rules: preserve architecture boundaries, avoid broad refactors, update
spec/test plan if behavior changes, keep unrelated files untouched.

Use the appropriate language peer skill for implementation (e.g.,
`cf-golang-engineer` for Go). Pass the lane context to the peer skill:
Lane B changes must not expand scope beyond approved spec. For
languages without a peer skill, follow the same TDD principles with
the language's standard tooling.

### AI_SELF_REVIEW

Use `cf-review` or a specialized reviewer path before asking a human to
review.

Fix confirmed correctness, safety, or test issues. Do not churn
style-only items unless clear value.

### AI_TESTING

Run targeted tests first, then wider affordable tests.

Use `cf-integration-testing` when integration tests are relevant.

For Lane B: run deterministic tools (SAST, secret scan, fuzz) if
configured. Report results even if clean.

### COMMIT_PREP

Manual mode uses `cf-commit-create` only after tests, self-review, and human
approval for that pending commit. Subagent mode may create commits inside
the approved subagent loop without per-commit human approval; Gate 2 then
reviews all subagent commits at once.

Before commit: inspect status and diff, stage only intended files, use
Conventional Commit message, and never commit secrets. Require explicit
user confirmation in manual mode; in subagent mode, the approved execution
plan authorizes subagent commits until Gate 2.

### HUMAN_REVIEW

Manual mode: summarize pending diff, test evidence, commit preview, and
known risks before each commit. Subagent mode: summarize all commits since
Gate 1/Gate 1.5, aggregate diff, test evidence, AI review evidence, and
known risks. Wait for user feedback.

Include: what changed, why, files changed, test evidence, lane
classification, risks, unverified areas.

### REVISION_IF_NEEDED

When review feedback changes behavior, update spec/test plan first, then
tests, then implementation.

Classify feedback: `required`, `test-gap`, `nit`, `question`,
`follow-up`, `wont-fix`.

Use `cf-post-review-fix` for structured reviewer feedback handling.

### MR_SUMMARY

Use `cf-mr-summary` to prepare MR title/body. Use the MR body template.

Include lane classification, verifiability, linked spec/test plan,
independent reviewer (Lane B only).

Do not create MR yet.

### MR_CREATE_AFTER_APPROVAL

Use `cf-glab-mr-create` for GitLab or `cf-gh-pr-create` for GitHub. Preview
title, body, target/base branch, and command. Require explicit confirmation
before publishing.

### FEEDBACK_LOOP

After merge, rejection, or major reviewer feedback, capture lessons:
missing tests, unclear spec sections, repeated bug patterns, repo
workflow updates needed, gates that were rubber-stamped, independent
verification that caught something the implementer model missed.

#### Agent Promotion Ladder

Track which handoffs earn trust and which must stay human-only.

Three rungs:
- **Shadow** — Agent produces artifacts; human does real work. No
  authority.
- **Assisted** (default) — Artifacts used, human reviews every item.
  Current state of this workflow.
- **Autonomous** — Artifacts flow end-to-end; humans spot-audit.
  **Lane A only.** Lane B never goes above Assisted.

Promotion: earned per handoff (not globally), requires a defined eval
passed over a representative sample, reviewed by a human not the
operator. Regression moves the rung back down. A streak of misses on a
Lane B trigger drops to Shadow for that category.

## Small-Team Adaptation (2-3 People)

A 2-3 person team hits the human-review ceiling immediately. Adapt:
- Rotation replaced with explicit "I read this" acknowledgment. The
  reviewer names the section that changed their mind.
- Lane B requires an external reviewer. Internal-only review on Lane B is
  not a review, it is a sync.
- Deterministic tools (SAST, secret scanners, fuzz, contract tests) are
  mandatory for Lane B when a second human reviewer is unavailable.
- Specs and test plans must be smaller. Multi-section PRDs blocked at the
  gate. Split before approval.

## Human Gates

Require explicit approval before:
- branch creation (if on a protected branch: master, main, or develop)
- implementation after spec/test plan
- commit creation
- MR creation
- production readiness handoff when release is in scope
- launch or any production/staging/paid-service action
- running destructive, costly, or external-service integration tests

## Repo Context Lookup

Before spec or tests, inspect available repo instructions:
- `AGENTS.md`
- `docs/cf-testing.md`
- `README.md`
- `Makefile`
- CI files

Prefer repo-specific commands over generic commands.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The state-machine detail can skip `cf-*` gates." | It must follow the same ControlFlow gate rules. |
| "The state machine is long, so combine states." | States exist to preserve reviewable handoffs. |
| "Gate approval can be implied from silence." | Approval must be explicit. |
| "Production launch is outside this workflow." | ControlFlow includes production readiness when release is in scope. |

## Red Flags

- New docs point users to `cf-state-machine` instead of `cf-intake`.
- Implementation begins before Gate 1 approval.
- Gate 1.5 is skipped for Lane B or non-trivial Lane A.
- MR creation is treated as final delivery when launch is in scope.
- Production or paid-service actions are proposed without explicit
  approval.

## Verification

Before leaving this skill, confirm:

- [ ] Current state is named.
- [ ] Next gate is named.
- [ ] Lane and verifiability are recorded or not applicable.
- [ ] Required approvals are explicit.
- [ ] Test evidence is recorded or planned.
- [ ] Production-readiness need is marked.

## Integration With Other Skills

Prefer `cf-intake` for new ControlFlow flows. This skill delegates to
`cf-spec-brainstorming`, `cf-spec-planning`, `cf-testing`, `cf-integration-testing`,
`cf-subagent-orchestration`, `cf-mr-summary`, and forge-specific MR/PR skills
where needed.

## Final Response Format

For each phase, report only useful facts:
- state completed
- lane and verifiability
- files changed
- commands run
- result
- blockers or risks
- next required human decision
