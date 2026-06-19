# State Logging

ControlFlow can keep an optional machine-readable state log for work that needs
durable gate, evidence, or rollback history.

Use state logging when chat context may be lost, when the change is Lane B, or
when production readiness matters. Skip it for tiny direct edits unless the user
asks for an audit trail.

## File Location

State logs live next to specs:

```text
docs/specs/<slug>.state.json
```

Template: `templates/state-template.json`.

## Transition Script

Record a state transition:

```bash
scripts/cf-transition.sh \
  --slug fix-duplicate-invoice-emails \
  --to verification \
  --reason "Implementation complete" \
  --evidence "go test ./... passed"
```

Create a Lane B state file and move from request to spec:

```bash
scripts/cf-transition.sh \
  --slug add-billing-webhook-idempotency \
  --lane B \
  --from request \
  --to spec \
  --reason "Lane B data-integrity work needs full workflow" \
  --evidence "User approved ControlFlow spec drafting"
```

Use `--from` when a transition must fail if the state file is not where the
agent thinks it is.

## Rollback Script

Safely stash current task work and record a rollback transition:

```bash
scripts/cf-rollback.sh \
  --slug fix-duplicate-invoice-emails \
  --reason "TDD green step failed; implementation too broad"
```

The rollback script does not run destructive git commands. If the worktree has
changes, it runs `git stash push --include-untracked` with a ControlFlow stash
name and records restore instructions in state evidence. State log files under
`docs/specs/*.state.json` are excluded from the stash so rollback evidence can
be appended after task work is saved.

## Recommended Use

- Lane A: optional.
- Lane B: recommended.
- MR/PR gate work: recommended when review evidence is split across sessions.
- Production action: strongly recommended.

## State Logging Policy

| Case | State log behavior |
|---|---|
| Lane A direct edit | Do not create a state file |
| Lane A mini-spec | Ask once whether state logging is useful |
| Lane B | Auto-create after the slug is known, unless the user opts out |
| Production-bound work | Auto-create; skipping requires explicit user approval |
| Long-running, multi-session, or human handoff | Auto-create |
| Sensitive evidence present | Auto-create, but redact evidence |

Rules:

- Production-bound work overrides lane size. A one-line config change that
  reaches production still needs a state log.
- For Lane B, wait until the slug is known before creating the state file to
  avoid orphan or renamed logs.
- Opt-out is allowed for Lane B non-production work, but must be explicit and
  recorded in the spec or chat.
- Opt-out for production-bound work must be confirmed by the user and
  documented as risk in the launch handoff.

## Evidence Rules

- Evidence must be concrete: approval text, test command/result, review link,
  deploy command, monitoring observation, or rollback stash name.
- Do not record secrets, tokens, credentials, private customer data, or raw logs
  containing sensitive data.
- Human approval evidence should identify what was approved, not imply broader
  approval than was granted.
