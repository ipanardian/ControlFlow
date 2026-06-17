---
name: cf-integration-testing
description: Plans, writes, runs, and diagnoses integration tests with local dependencies, fixtures, cleanup, and safe external-service boundaries. Use when validating code across DB, Redis, NATS, Docker Compose, Testcontainers, HTTP/gRPC services, or other real dependencies.
---

# Integration Testing

Use integration tests to validate behavior across real boundaries while keeping runs isolated, repeatable, and safe.

## Safety Rules

- Never hit production services.
- Never hit staging or paid external services without explicit user approval.
- Prefer local containers, Testcontainers, mocks, or fakes.
- Use isolated database/schema/test namespace per run when possible.
- Clean created data after each test or test suite.
- Do not run destructive commands without explicit user approval.

## Discovery

Before writing or running integration tests, inspect repo context:

- `README.md`
- `Makefile`
- `docker-compose*.yml`
- `.env.example`
- `go.mod`
- existing `*_test.go`
- CI config
- test helper packages

Identify:

- dependency startup command
- required env vars
- test database name/schema
- fixture patterns
- cleanup patterns
- integration test tags or naming conventions
- slow/flaky test exclusions

## Test Design

For each integration scenario, define:

- dependencies required
- fixture setup
- action under test
- expected persisted state
- expected emitted events/messages when relevant
- failure path
- cleanup strategy

Cover these when relevant:

- DB transaction behavior
- idempotency and duplicate requests
- concurrent requests
- upstream timeout/failure
- retry behavior
- event publishing/consuming
- migrations and schema assumptions

## Running Tests

Prefer narrow command first:

```sh
go test ./path/to/package -run TestName -count=1
```

Then broader package command:

```sh
go test ./path/to/package/... -count=1
```

Then repo-level command only if cheap and expected:

```sh
go test ./... -count=1
```

Use repo-provided `make` targets when present and trustworthy.

## Failure Diagnosis

Classify failures:

- expected TDD failure
- compile failure
- dependency unavailable
- fixture/setup failure
- flaky timing/concurrency failure
- real behavior regression

Do not patch production code until failure class is known.

## Evidence

Always report:

- command run
- dependencies used
- result
- failure summary if any
- data cleanup status
- unverified integration areas

## Validation Scenario Results

When integration tests satisfy approved validation scenarios, record the
result using the ControlFlow validation table fields:

- scenario ID and linked acceptance criterion
- actor (`AI` unless a human ran it)
- environment and dependencies used
- steps run
- expected result and actual result
- result: `PASS`, `FAIL`, `BLOCKED`, or `N/A`
- evidence: command, log excerpt, link, screenshot, or note

Required validation scenarios that are `FAIL` or `BLOCKED` must be surfaced
as Gate 2 and MR-creation blockers.

## Local Env Policy

If env vars are missing, read examples and ask user only for secrets or choices. Do not invent credentials.

If local services are down, offer exact command to start them or start them when command is safe and local.
