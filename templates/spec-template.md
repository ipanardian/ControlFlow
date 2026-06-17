# Spec Template

Use this template for new features and behavioral changes. Smaller changes
(docs, lint, typo fixes) can use a trimmed version inline in the MR.

> **Workflow reference:** see `docs/state-machine.md` for human-readable
> gate expectations and approval semantics. Agent execution rules live in
> `skills/cf-state-machine/SKILL.md`.

## Frontmatter (required)

```yaml
---
lane: A | B
verifiability: cheap | expensive
risk: low | high
estimated_loc: small | medium | large
requires_independent_reviewer: bool
---
```

`verifiability` answers a separate question that often gets missed: how
quickly and cheaply can we tell whether the change actually works? A typo
fix is trivial to verify by reading the file. A new aggregation formula
is not, even if the change is small in lines of code.

## Problem

What is broken, missing, or needed? One to three sentences. Cite the
issue, the user report, or the observation that triggered this work.

## Goals

What does success look like? Bullet list, observable outcomes.

## Non-Goals

What is explicitly out of scope? This section prevents silent scope
creep during implementation.

## Scope

- **In scope:**
- **Out of scope (but related):**

## Current Behavior

What happens today? Include file paths and line ranges (`file:line`)
where relevant.

## Desired Behavior

What should happen after this change? Same level of detail as Current
Behavior, ideally with a worked example.

## Invariants

What must remain true before, during, and after the change? These are
the contracts that should not be broken.

## Edge Cases

List the unusual inputs, race conditions, empty states, error paths, or
boundary conditions that need to be handled.

## API / Data / Schema Changes

Any changes to public interfaces, proto files, database schema, message
formats, or persisted data? Be explicit. Even "no change" should be
stated.

## Risks

What could go wrong? Include both technical risks and product risks.
For Lane B, also note blast radius.

## Lane Classification and Justification

What lane is this, and why? If Lane B, which Lane B trigger applies?
(Auth, irreversible migration, security boundary, public API change,
data integrity — anything that could cause incorrect data to be
persisted, published, signed, attested, or consumed externally —
consensus or signature handling, etc.)

## Evidence Type Required

What evidence do we need to confirm the change works? Pick one or more:

- Unit test
- Integration test
- Contract test
- Manual reproduction steps
- External review
- Deterministic tool (SAST, secret scan, fuzz)

## Acceptance Criteria

Testable, observable conditions that must hold for the work to be
considered done. If a criterion cannot be tested or observed, rewrite
it. Number them for easy reference.

1.
2.
3.

## Validation Scenarios

Required for any feature addition, bug fix, or behavior change, including
mini-spec work. Non-behavioral direct edits may omit this section only with
an explicit reason.

| ID | Linked AC | Type | Actor | Environment | Steps | Expected Result | Required Before MR |
|---|---|---|---|---|---|---|---|
| VS-1 | AC-1 | unit / integration / manual | AI / human | local / staging / sandbox | `<steps>` | `<expected>` | yes / no |

Rules:

- Each scenario must map to acceptance criteria.
- `Actor` is `AI` or `human`.
- `Required Before MR = yes` blocks MR creation until result and evidence are recorded.
- Human-owned required scenarios must be requested by AI before MR creation.

## Open Questions

Questions that must be answered before Gate 1 approval. State `None` if
there are no open questions. Gate 1 approval is blocked while any item is
`unresolved`, blank, or missing an explicit decision.

Use this format for each item:

```md
1. Status: unresolved | decided | out-of-scope
   Question: <question>
   Decision: <answer, or why this is out of scope>
```

If a topic can be resolved during implementation without changing scope,
acceptance criteria, test expectations, risk, or rollout behavior, record
it in Risks or the execution plan instead of Open Questions.

## Lane B Additions

Include these only for Lane B specs.

### User or Research Evidence

What evidence shows the change is needed and the chosen approach is
correct? Link issues, prior incidents, user reports, research notes, or
benchmark results.

### Rollback Plan and Blast Radius

How do we undo this change if it goes wrong? What is the blast radius
of getting it wrong (who is affected, for how long, how severely)?

### Out-of-Scope but Related Items

Items that came up while writing the spec that we are explicitly not
doing in this MR. Capture them here so they do not silently leak into
implementation.
