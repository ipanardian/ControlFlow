---
name: cf-spec-planning
description: Turns a vague feature request or bug report into a concrete specification with scope, invariants, edge cases, and acceptance criteria. Use when planning, designing, or scoping a feature before implementation.
---

# Spec Planning

Produce a clear, implementable specification from a rough idea, request, or issue.

## When to use this skill

- Before writing any code for a new feature or significant change.
- When the user says "plan this", "design this feature", "spec this out", or provides a vague request.
- When breaking down a large task into smaller, scoped units of work.
- After `cf-spec-brainstorming` produces a Brainstorming Handoff that needs
  to become a formal spec.

## Workflow

### 1. Gather context

- Read the existing codebase for the affected domain: models, services, handlers, tests.
- Identify the current state: what exists now, what's missing, what's broken.
- Find related specs, issues, or documentation if they exist.
- If a Brainstorming Handoff exists, use it as input for the problem,
  constraints, scope, recommendation, acceptance signals, and open
  questions. Do not treat it as a substitute for repo context.

### 2. Define the problem

Write a concise problem statement:

```
## Problem
<one or two sentences describing what's wrong or missing>
```

### 3. Define the scope

Be explicit about what's **in** and **out**:

```
## In Scope
- <thing this spec covers>

## Out of Scope
- <related thing explicitly deferred>
```

If something is tempting to include but not essential, put it in "Out of Scope" with a note like "(future PR)" or "(separate issue)".

### 4. Define invariants

List the rules that must always hold — before, during, and after the change:

```
## Invariants
1. <rule that must always be true>
2. <another rule>
```

Examples for any service:
- "Order IDs are globally unique and never reused."
- "A user can only have one active session per device."
- "All monetary calculations use `decimal.Decimal`, never `float64`."
- "Every write operation must be idempotent for the same request ID."

### 5. Define edge cases

Think about what can go wrong:

```
## Edge Cases
1. <what happens on duplicate request?>
2. <what happens on concurrent access?>
3. <what happens on partial failure (e.g., DB write succeeds, NATS publish fails)?>
4. <what happens on nil/zero/empty input?>
5. <what happens when upstream dependency is slow or down?>
```

### 6. Define the interface

If the change involves API changes, proto changes, or new public functions:

```
## Interface

### gRPC / Proto
<message or rpc definition, or "no proto changes">

### REST / HTTP (gateway)
<endpoint, method, request/response shape, or "no HTTP changes">

### Internal (language-specific)
<new function signatures, interface changes, or "no internal API changes"
— adapt the heading to the language of the project>
```

### 7. Define acceptance criteria

Each criterion must be **testable** and **unambiguous**:

```
## Acceptance Criteria
- [ ] <specific, measurable outcome>
- [ ] <another criterion>
```

Good: "POST /v1/orders returns 201 with the created order for valid input."
Bad: "Orders endpoint works."

### 8. Identify risks and mitigations

```
## Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-------------|
| <risk> | High/Med/Low | High/Med/Low | <how to handle> |
```

### 9. List open questions

```
## Open Questions
1. Status: unresolved | decided | out-of-scope
   Question: <question that needs answering before Gate 1 approval>
   Decision: <answer, or why this is out of scope>
```

If there are no open questions, state "None" — don't skip this section.
Gate 1 approval is blocked while any open question is `unresolved`, blank,
or missing an explicit decision. If a topic can be resolved during
implementation without changing scope, acceptance criteria, test
expectations, risk, or rollout behavior, record it in Risks or the
execution plan instead of Open Questions.

## Output format

Produce the spec as a single markdown document with these sections in order:

1. **Problem** — What's wrong or missing.
2. **In Scope / Out of Scope** — Boundaries.
3. **Invariants** — Rules that must always hold.
4. **Edge Cases** — What can go wrong.
5. **Interface** — API, proto, or internal contract changes.
6. **Acceptance Criteria** — Testable conditions for "done".
7. **Risks** — Risk table with mitigations.
8. **Open Questions** — Decisions required before Gate 1 approval, or `None`.

## Execution Plan Handoff

Spec planning defines what and why. It may identify likely work slices,
but the formal execution plan is produced after Gate 1 from the approved
spec and test plan.

Every implementation must have a visible execution plan before coding:

- Lane B always requires a separate Gate 1.5 execution-plan approval.
- Lane A requires Gate 1.5 for non-trivial, multi-step, multi-file,
  multi-commit, subagent-eligible, or >30 minute work.
- Trivial Lane A work may use a mini execution plan without a separate
  approval gate.

If a large request cannot be expressed as 2-5 smaller specs or small
execution tasks, split the spec before implementation.

## Anti-patterns

- Don't write implementation details in the spec. The spec says "what" and "why", not "how".
- Don't skip edge cases because they seem unlikely. If it can happen in production, it's in scope.
- Don't leave acceptance criteria vague. If you can't test it, redefine it.
- Don't expand scope mid-spec. Put new ideas in "Out of Scope" and track them separately.

## Spec complexity tiers

Not every change needs a full spec. Size your output to the change:

- **Small** (bug fix, log level change, config toggle): Skip directly to Acceptance Criteria + Invariants. One paragraph for Problem.
- **Medium** (new endpoint, new DB table, new consumer): Full spec with all sections.
- **Large** (new service, cross-domain workflow, schema migration): Full spec + break into 2-5 smaller specs before implementation.
