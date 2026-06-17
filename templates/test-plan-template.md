# Test Plan Template

Use this template to plan tests before writing code. Smaller changes can
embed the test plan inline in the spec.

> **Workflow reference:** see `docs/state-machine.md` for human-readable
> evidence and approval semantics. Agent execution rules live in
> `skills/cf-state-machine/SKILL.md`.

## Frontmatter (required)

```yaml
---
lane: A | B
verifiability: cheap | expensive
linked_spec: docs/specs/<feature-slug>.md
---
```

## Lane and Verifiability

State the lane and verifiability classification, copied from the linked
spec. If they differ between spec and test plan, the spec wins; update
the test plan.

## Unit Test Scenarios

List the unit tests to be written. For each scenario, state:

- The function or method under test (`file:line`).
- The input or precondition.
- The expected output or behavior.
- A short name for the test function.

## Integration Test Scenarios

List integration tests to be written. Cover the boundary between
components: HTTP handlers, gRPC services, database access, message
queue publishers and consumers, external API calls.

## Failure Scenarios

What does the code do when something goes wrong? Cover at minimum:

- Network errors (timeouts, connection refused, DNS failure).
- Invalid input (malformed payload, out-of-range values, missing fields).
- Dependency unavailable (DB down, cache miss, downstream service
  down).
- Partial failure (some messages processed, some not; transactions
  interrupted).

## Concurrency or Idempotency Scenarios

When relevant, list scenarios that exercise concurrent or repeated
invocation:

- Two callers hitting the same endpoint at once.
- Replaying a message that was already processed.
- Restarting mid-transaction.
- Read-modify-write races.

State "not applicable" if the change has no concurrency surface.

## Fixtures and Test Data

What fixtures, seed data, mocks, fakes, or containers are needed?
Include:

- Database state or migration applied.
- External service mocks (HTTP fixtures, gRPC fakes).
- Test data files or generators.

## Commands Expected to Run

The exact commands that will be run during this work. Repo-specific
commands from `Makefile`, `README.md`, CI, or `docs/cf-testing.md` take
priority.

```sh
# Targeted test example
go test ./path/to/package -run TestName -count=1

# Package-level test example
go test ./path/to/package/... -count=1

# Wider test example
go test ./... -count=1
```

## Test Evidence Checklist

Complete this before Gate 2 or MR handoff. Keep it short for small
changes; use tables only when the evidence is easier to review that way.

Automated tests:

| Type | Scenario | Command | Result | Notes |
|---|---|---|---|---|
| Unit | `<scenario>` | `<command>` | `PASS` / `FAIL` / `N/A` | `<notes>` |
| Integration | `<happy path across boundary>` | `<command>` | `PASS` / `FAIL` / `N/A` | `<notes>` |

Manual verification:

| Scenario | Environment | Steps | Expected Result | Result | Evidence |
|---|---|---|---|---|---|
| `<scenario>` | `local` / `staging` | `<short steps>` | `<expected behavior>` | `PASS` / `FAIL` / `N/A` | `<screenshot, log, link, or note>` |

Rules:

- Integration happy path is required when the change crosses a component
  boundary: HTTP/gRPC handler, database, queue, cache, external API,
  migration, auth, or multi-step workflow.
- Manual verification is for behavior that is expensive or impractical to
  automate before delivery: UI flow, staging-only config, third-party
  sandbox, or smoke test.
- If unit, integration, or manual verification is not applicable, state
  `N/A` with the reason.

## Validation Scenario Results

Complete before Gate 2 handoff and before MR creation. Required for any
feature addition, bug fix, or behavior change, including mini-spec work.

| ID | Linked AC | Type | Actor | Environment | Steps Run | Expected Result | Actual Result | Result | Evidence | Runner | Timestamp |
|---|---|---|---|---|---|---|---|---|---|---|---|
| VS-1 | AC-1 | unit / integration / manual | AI / human | local / staging / sandbox | `<steps>` | `<expected>` | `<actual>` | PASS / FAIL / BLOCKED / N/A | `<log/link/screenshot/note>` | `<name/model>` | `<ISO8601>` |

Rules:

- `PASS`: expected result matches actual result and evidence is recorded.
- `FAIL`: scenario ran and failed; required scenarios block Gate 2 and MR creation.
- `BLOCKED`: scenario could not run because environment, dependency, or permission was missing; required scenarios block Gate 2 and MR creation.
- `N/A`: scenario is not applicable, with reason. If a required behavior scenario becomes `N/A`, update and reapprove the spec or test plan.
- Human-owned required scenarios must include runner name and evidence note/link.

## Expected Failing Test Before Implementation

Which test should fail before implementation begins, proving that the
test setup is correct and the behavior is not yet present? Quote the
expected failure summary.

## Verification Cost

How long does the full test suite take? How complex is the setup? This
is the basis for the `verifiability` field in the spec frontmatter. If
this number grows, the spec should be re-evaluated for lane.

## Unverified Areas

What the tests do NOT cover and why it is acceptable. This section is
required, not optional. "Nothing" is a valid answer only if you can
defend it on inspection.

## Lane B Additions

Include these only for Lane B test plans.

### Independent Verification Method

How will the change be independently verified? Pick at least one:

- A different model than the implementer, reviewing the diff.
- A deterministic tool: SAST, secret scanner, fuzz test, authz test,
  contract test.
- A named human reviewer who was not the spec approver.

The required method is also confirmed in the MR description.

### Severity Classification Policy

Who decides whether a finding is high or critical severity? What
overrides exist if the assigner misses a bug? For money, auth, PII,
irreversible migrations, and data integrity (anything that could
cause incorrect data to be persisted, published, signed, attested,
or consumed externally), human review overrides agent-assigned
severity. State that explicitly here so it is not invented at
review time.
