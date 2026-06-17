---
name: cf-code-simplification
description: Simplifies working code while preserving behavior. Use when code is correct but too complex, duplicated, hard to review, or harder to maintain than needed.
---

# Code Simplification

## Overview

Simplification reduces maintenance risk only when behavior stays the same
and tests protect the change.

## When To Use This Skill

Use after behavior is correct, tests pass, or review identifies excessive
complexity.

## When NOT To Use This Skill

Do not simplify while behavior is still unclear or tests are missing.

## Process

1. Identify exact complexity problem.
2. Confirm behavior with tests.
3. Preserve public interfaces unless approved.
4. Remove duplication, dead code, or unnecessary abstraction.
5. Re-run tests.
6. Record what behavior stayed unchanged.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Cleaner code is worth a broad refactor." | Scope creep increases risk. |
| "Tests are not needed because behavior should not change." | Tests prove behavior did not change. |

## Red Flags

- Public API changes during simplification.
- Large diff with unclear benefit.
- Tests not rerun.

## Verification

- [ ] Behavior-preserving intent stated.
- [ ] Tests pass before/after or baseline exists.
- [ ] Public contracts unchanged or approved.
- [ ] Diff is smaller or clearer.

## Integration With Other Skills

Use inside `cf-build` or `cf-review` after correctness is established.
