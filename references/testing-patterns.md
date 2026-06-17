# Testing Patterns Reference

Use this reference when designing or validating ControlFlow test evidence.

## Evidence Requirements

Every behavior change needs evidence that the behavior was tested.

Record:

- Command run.
- Pass/fail result.
- Relevant file paths.
- Expected failure before implementation when TDD applies.
- Unverified areas and why they are acceptable.

Use one source of truth for delivery evidence: the approved test plan,
spec, or MR body. Do not leave final evidence only in a Jira/Trello
comment or separate spreadsheet.

## Delivery Checklist

Before Gate 2 or MR handoff, record:

- Unit test evidence, or `N/A` with reason.
- Integration happy path evidence when the change crosses a component
  boundary.
- Manual verification evidence when automation is too expensive or the
  behavior only appears in UI, staging config, sandbox integrations, or
  smoke tests.
- Unverified areas and why they are acceptable.

Keep the checklist proportional to risk. Small pure-function changes can
use a short bullet list. Cross-boundary or risky changes should use the
table in `templates/test-plan-template.md`.

## Test Categories

Unit tests:

- Pure logic.
- Edge cases.
- Error mapping.
- Validation rules.

Integration tests:

- Database behavior.
- Redis, NATS, queues, or external local dependencies.
- HTTP/gRPC boundary behavior.
- Transaction and retry behavior.
- Minimum happy path across the changed boundary before staging or
  production delivery.

Failure tests:

- Timeout.
- Partial failure.
- Duplicate request.
- Invalid input.
- Dependency unavailable.

Concurrency tests:

- Race conditions.
- Duplicate event handling.
- Idempotency.
- Shared mutable state.

## TDD Rules

- Write failing tests before code for behavior changes.
- Confirm the failure is the expected behavior gap.
- Do not treat setup errors as red phase.
- Implement the smallest change to pass.
- Re-run targeted tests after implementation.

## Red Flags

- Test passes before implementation when it should fail.
- Test only checks no error, not outcome.
- Mock asserts implementation detail but not behavior.
- Integration test depends on remote paid or production service without
  approval.
- Unverified areas omitted.
