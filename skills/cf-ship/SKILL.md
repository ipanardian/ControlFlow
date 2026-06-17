---
name: cf-ship
description: Coordinates ControlFlow production readiness and launch gates. Use after MR approval or before release when verifying rollout plan, rollback plan, monitoring, operational risks, and launch evidence before production changes proceed.
---

# ControlFlow Ship

Production-readiness and launch gate for ControlFlow.

## Overview

Carry approved changes beyond MR readiness into controlled launch
preparation. This skill prepares launch evidence; it does not perform
production actions without explicit approval.

Use `~/.agents/controlflow/launch-template.md` when installed. If missing,
use `templates/launch-template.md` from this repository.

## When To Use This Skill

Use this skill after MR review approval or when a change needs production
readiness validation before launch.

## When NOT To Use This Skill

Do not use this skill when:

- Work has not reached MR approval or release planning.
- The user only needs MR text; use `cf-mr`.
- Production impact is impossible and no launch handoff is useful.

Never deploy, run destructive production operations, or touch paid,
staging, or production services without explicit user approval.

## Process

Use `~/.agents/controlflow/launch-template.md` for the launch handoff and
`references/production-readiness-checklist.md` as the readiness checklist.
Use `references/stage-handoff.md` when entering production readiness from
MR approval or when launch work should continue in a fresh session without
old brainstorming or implementation history.
Use `agents/production-readiness-reviewer.md` before launch plan approval
when the release touches production, staging, migrations, manual steps, or
external systems.

1. Confirm release state.
   - Verify MR review, merge readiness, or release planning status.
   - If code review is not ready, return to `cf-review` or `cf-mr`.

2. Write release scope.
   - State what changes for users or systems.
   - List affected services, jobs, queues, databases, clients, flags, and
     config.
   - State out-of-scope launch items.

3. Define rollout plan.
   - Include deployment order.
   - Include feature flag or staged rollout steps.
   - Include required owners or manual steps.
   - Include timing and dependencies when relevant.

4. Define rollback plan.
   - Include exact rollback steps or command.
   - State whether rollback is safe after migrations.
   - Include config or feature flag reversal.
   - Include data cleanup or reconciliation when needed.

5. Check migrations and manual steps.
   - List each required migration, config change, backfill, queue drain, or
     manual operation.
   - Order steps explicitly.
   - Mark destructive, irreversible, staging, production, or paid-service
     actions as approval-required.

6. Define monitoring and alerts.
   - List logs, metrics, alerts, dashboards, or queries.
   - State expected healthy signal.
   - State stop threshold for pausing or rollback.

7. Define post-launch validation.
   - Include smoke checks.
   - Include API/UI checks when relevant.
   - Include data consistency checks when relevant.
   - Include downstream consumer checks when relevant.

8. Define incident fallback and stop-the-line rules.
   - State when to pause rollout.
   - State when to rollback.
   - State when to escalate to human/operator.

9. Ask for approvals separately.
   - First ask: approve launch plan? (y/n)
   - Only after plan approval, ask before any production action: proceed with production action? (y/n)
   - Never treat MR approval as launch approval.

## Launch Handoff Output

Fill the launch template fields, then produce the final handoff as a
single `text` fenced code block. The content inside the block is pure
markdown. The user copies the block content and pastes it into Slack,
Notion, GitLab, or any markdown renderer for a clean, structured display
without angle-bracket noise.

Do not emit the template placeholders — emit the filled handoff.

```text
## 🚀 Production Readiness

### Release Scope
- **Change:** deploy v2.1.0 — new `/api/search` endpoint
- **Affected systems:** api-gateway, search-worker, redis-cache
- **Feature flags/config:** `SEARCH_V2_ENABLED` feature flag
- **Out of scope:** search UI changes, analytics pipeline

### Preconditions
- MR/review state: merged — !1234
- Required migrations: `20240601_add_search_index.sql`
- Required config: set `SEARCH_V2_ENABLED=true` in production config
- Required manual steps: none
- Required approvals: SRE on-call

### Rollout Plan
1. Run migration `20240601_add_search_index.sql` against prod DB
2. Set `SEARCH_V2_ENABLED=true` in production config (flag disabled)
3. Deploy `api-gateway` canary (1 instance)
4. Enable flag for 5% of traffic, observe 15 min
5. Deploy full `api-gateway`, ramp flag to 100%

### Rollback Plan
1. Set `SEARCH_V2_ENABLED=false`
2. Rollback `api-gateway` to previous sha
3. Migration is additive — no data loss on rollback

### Monitoring And Alerts
| Signal | Where | Healthy | Stop Threshold |
|---|---|---|---|
| `search_latency_p99` | Grafana /api-search | <200ms | >500ms for 2 min |
| `search_error_rate` | Grafana /api-search | <0.1% | >1% for 1 min |
| `redis_memory` | Datadog redis | <80% | >90% |

### Post-Launch Validation
- [ ] Smoke check: `curl https://api.example.com/search?q=test`
- [ ] API check: compare p50/p99 latency vs baseline
- [ ] Data check: `SELECT count(*) FROM search_index` > 0
- [ ] Background job check: search-worker queue depth normal
- [ ] Downstream check: notify mobile team

### Risks And Mitigations
| Risk | Mitigation |
|---|---|
| Migration locks search_index table | Run during low-traffic window |
| Cache cold start increases latency | Pre-warm cache before full rollout |

### Stop Conditions
- Pause if: p99 latency exceeds 500ms
- Rollback if: error rate exceeds 1% or data mismatch detected
- Escalate if: rollback fails or DB migration is irreversible

### Approval
- Launch plan approved by: SRE lead
- Production action approved by: SRE on-call
- Approval timestamp: 2024-06-01 14:00 UTC
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "MR approval means launch approval." | Merge and production launch are separate risk transitions. |
| "Rollback is obvious." | Rollback must account for migrations, config, external effects, and user-visible state. |
| "Monitoring can happen after launch." | Monitoring and post-launch checks are part of readiness. |
| "The deploy command is harmless." | Staging, production, destructive, and paid-service actions require explicit approval. |

## Red Flags

- Launch handoff lacks rollback plan.
- Monitoring or post-launch validation is unspecified.
- Manual steps are not ordered.
- Production command is proposed before explicit approval.
- MR approval is reused as launch approval.

## Verification

Before leaving this skill, confirm:

- [ ] Release scope is clear.
- [ ] Rollout and rollback plans are written.
- [ ] Monitoring and post-launch checks are listed.
- [ ] Manual steps and migrations are called out.
- [ ] Known risks and mitigations are explicit.
- [ ] Launch approval question is asked before production action.
- [ ] Stop conditions are explicit.
- [ ] Destructive, staging, production, and paid-service actions are
      approval-gated.
- [ ] Production-readiness reviewer is used when launch risk applies.
- [ ] Pasteable stage handoff is produced when launch work should continue
      in a fresh session.

## Integration With Other Skills

This skill extends `cf-intake` beyond MR creation. Use after `cf-mr`
or when release planning starts.
