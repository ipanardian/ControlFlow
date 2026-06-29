---
name: cf-code-simplification
description: Simplifies working code while preserving behavior. Use when code is correct but too complex, duplicated, hard to review, or harder to maintain than needed.
---

# Code Simplification

## Overview

Simplification reduces maintenance risk only when behavior stays the same
and tests protect the change.

Use the smallest safe change: the least implementation surface that
satisfies approved acceptance criteria while preserving tests, safety,
operability, and public contracts. This is not code golf; fewer lines are a
signal, not the goal.

## When To Use This Skill

Use after behavior is correct, tests pass, or review identifies excessive
complexity.

## When NOT To Use This Skill

Do not simplify while behavior is still unclear or tests are missing.

## Process

1. Identify exact complexity problem.
2. Confirm behavior with tests.
3. Run the lean-change ladder and stop at the first rung that safely holds.
4. Preserve public interfaces unless approved.
5. Remove duplication, dead code, speculative options, or unnecessary
   abstraction.
6. Re-run tests.
7. Record what behavior stayed unchanged.

## Lean-Change Ladder

Before adding or keeping code, ask in order:

1. Can this be solved with no code change, existing behavior, docs, or
   configuration?
2. Does an existing repo pattern or helper already solve it?
3. Does stdlib, framework, or native platform behavior solve it?
4. Does an installed dependency already solve it?
5. Is a localized change enough?
6. Only then add a new abstraction, dependency, schema, service boundary,
   config surface, or public API.

When using rung 6, state the reason. Good reasons include protecting a domain
invariant, reducing repeated real callers, preserving a public contract, or
isolating a risky boundary.

## Never Cut

- Auth or authorization checks.
- Trust-boundary input validation.
- Data integrity, idempotency, or concurrency guards.
- Migration safety, rollback path, or data-loss handling.
- Error handling for external IO.
- Tests that prove acceptance criteria.
- Observability required for production-risk changes.
- Accessibility in user-facing UI.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Cleaner code is worth a broad refactor." | Scope creep increases risk. |
| "Tests are not needed because behavior should not change." | Tests prove behavior did not change. |
| "Fewer lines are always better." | The smallest safe change may keep guards, tests, or explicit branches. |
| "This helper might be useful later." | Add abstraction after a real second use or invariant needs it. |

## Red Flags

- Public API changes during simplification.
- Large diff with unclear benefit.
- Tests not rerun.
- New dependency, config, schema, or public API without ladder rationale.
- Safety, validation, observability, or accessibility removed to reduce code.

## Verification

- [ ] Behavior-preserving intent stated.
- [ ] Tests pass before/after or baseline exists.
- [ ] Public contracts unchanged or approved.
- [ ] Lean-change ladder applied; rung 6 additions are justified.
- [ ] Safety carve-outs remain intact.
- [ ] Diff is smaller or clearer.

## Integration With Other Skills

Use inside `cf-build` or `cf-review` after correctness is established. In
`cf-build`, use it as a post-green simplification pass. In `cf-review`, use it
to produce concrete overengineering findings and explicit keep-rationale for
necessary complexity.
