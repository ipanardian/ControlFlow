# Production Readiness Checklist Reference

Use this reference when `cf-ship` prepares a launch handoff or when a spec
has production impact.

## Release Scope

- What changes for users or systems.
- What is explicitly not included.
- Feature flag or config state.
- Services, jobs, queues, databases, or clients affected.

## Rollout Plan

- Deployment order.
- Feature flag or staged rollout steps.
- Migration order if any.
- Manual steps and owners.
- Expected timing and dependencies.

## Rollback Plan

- Exact rollback command or procedure.
- Whether rollback is safe after migration.
- Config or feature flag reversal.
- Data cleanup or reconciliation if needed.
- External communication if user-visible.

## Monitoring

- Logs to inspect.
- Metrics to watch.
- Alerts expected or missing.
- Dashboards or queries.
- Error budget or threshold for stopping rollout.

## Post-Launch Validation

- Smoke checks.
- API or UI checks.
- Background job checks.
- Data consistency checks.
- Downstream consumer checks.

## Approval Rules

- Production, staging, destructive, or paid-service actions require
  explicit approval.
- Launch approval is separate from MR approval.
- If rollback is unclear, do not launch.
- If monitoring is absent for a risky change, escalate before launch.
