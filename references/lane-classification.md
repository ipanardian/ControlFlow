# Lane Classification Reference

Use this reference when `cf-intake` or `cf-spec` needs to classify risk
before implementation.

## Lane A

Lane A is for low-risk, cheap-to-verify work.

Use Lane A when all are true:

- No Lane B trigger applies.
- Behavior is unchanged or low blast radius.
- Verification is mechanical, local, or cheap.
- Rollback is simple.
- Reviewer alignment is not needed before code.

Examples:

- Documentation wording.
- Lint or formatting.
- Small internal refactor with tests.
- Small UI copy or spacing tweak.
- Local config value with no production impact.

## Lane B

Lane B is for behavior, contracts, or high-blast-radius changes.

Use Lane B when any are true:

- New feature or behavior change.
- API, schema, proto, database, or public contract change.
- Cross-service or external integration.
- Security, auth, billing, permissions, or data-integrity concern.
- Migration, rollout, rollback, or launch decision is involved.
- Verification is expensive or depends on downstream consumers.

## Heavy Triggers

Any single trigger forces Lane B:

- Auth, authorization, session, or token changes.
- Irreversible migrations or destructive data operations.
- Security boundaries, secrets handling, or cryptographic code.
- Public API or proto contract changes.
- Data integrity: any change that could cause incorrect data to be
  persisted, published, signed, attested, or consumed externally.

## Verifiability

Classify verifiability separately from lane.

Cheap:

- File read.
- Unit test.
- Local deterministic command.
- Small manual check with obvious expected result.

Expensive:

- Integration test.
- Manual validation across states.
- Cross-service behavior.
- Production-like data.
- Correctness depends on downstream consumers.

## Escalation Rules

- Escalate Lane A to Lane B if any heavy trigger appears later.
- Do not downgrade Lane B without explicit human approval and written
  rationale.
- Treat unknown blast radius as Lane B until clarified.
- Treat expensive verification as requiring stronger gates even when diff
  size is small.
