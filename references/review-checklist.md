# Review Checklist Reference

Use this reference for Gate 2, AI self-review, MR review, and review
feedback handling.

## Spec Compliance

- Each acceptance criterion is covered.
- Out-of-scope items were not implemented.
- Invariants still hold.
- Edge cases are covered or explicitly unverified.
- Behavior changes match approved spec.

## Code Quality

- Smallest correct change.
- Clear error propagation.
- No broad refactor outside scope.
- No unrelated file changes.
- Concurrency and cleanup are safe.
- Names match existing project conventions.

## Test Evidence

- Required tests were run.
- Failing test was observed first when TDD applies.
- Integration evidence exists when needed.
- Integration happy path is covered for cross-boundary changes.
- Manual verification evidence exists when automation is impractical or
  staging/sandbox behavior must be checked.
- Validation scenario results exist for every feature addition, bug fix, or
  behavior change, including mini-spec work.
- Human-owned required validation scenarios were run before MR creation.
- No required validation scenario is missing, `FAIL`, or `BLOCKED` unless
  the spec/test plan was updated and approved again.
- Unverified areas are listed.
- Test commands are copy-pasteable.

## Risk And Rollback

- Risks are specific, not "low" by default.
- Rollback handles migrations, config, external effects, and user-visible
  state.
- Lane B independent reviewer requirement is satisfied or blocked.
- Production-readiness need is marked.

## Feedback Classification

- `required`: correctness, safety, security, broken behavior.
- `test-gap`: missing coverage.
- `nit`: style, naming, readability.
- `question`: needs clarification.
- `follow-up`: valid but out of scope.
- `wont-fix`: rejected with reason.
