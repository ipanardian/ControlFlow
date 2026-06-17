# Launch Handoff Template

Use this template for ControlFlow production-readiness and launch handoffs.
Do not run production, staging, destructive, or paid-service actions until
explicit approval is recorded.

Fill the template below, then produce the final output as a pasteable
markdown block using the **Pasteable Output** format at the bottom of this
file. The agent prints the filled content inside a `text` fenced code
block; the user copies the block content and pastes it into Slack, Notion,
GitLab, or any markdown renderer for a clean display.

## Template Fields

### Release Scope

- **Change:** <what changes>
- **Affected systems:** <services, jobs, queues, databases, clients>
- **Feature flags/config:** <flags or config involved, or none>
- **Out of scope:** <what this launch does not include>

### Preconditions

- MR/review state: <approved/merged/pending>
- Required migrations: <none or list>
- Required config: <none or list>
- Required manual steps: <none or list>
- Required approvals: <names or roles>

### Rollout Plan

1. <step>
2. <step>
3. <step>

Include deployment order, feature flag stages, owner, expected timing, and
dependency notes.

### Rollback Plan

1. <step>
2. <step>
3. <step>

State whether rollback is safe after migrations, config changes, external
effects, or user-visible state changes.

### Monitoring And Alerts

- Logs: <where to look>
- Metrics: <what to watch>
- Alerts: <expected alerts or missing alerts>
- Dashboards/queries: <links or commands>
- Stop threshold: <condition that pauses or rolls back launch>

### Post-Launch Validation

- Smoke check: <command or manual check>
- API/UI check: <command or manual check>
- Data check: <query or invariant>
- Background job check: <queue/job check>
- Downstream check: <consumer/system check>

### Risks And Mitigations

- <risk>: <mitigation>

### Stop Conditions

- <condition requiring pause>
- <condition requiring rollback>
- <condition requiring escalation>

### Approval

- Launch plan approved by: <name/role>
- Production action approved by: <name/role>
- Approval timestamp/context: <message/link>

## Pasteable Output

After filling all fields, output the final handoff as a single `text`
fenced code block. The content inside the block is pure markdown — when
copied and pasted into a markdown renderer (Slack, Notion, GitLab, GitHub,
etc.) it renders as a clean, structured document.

```text
## 🚀 Production Readiness

### Release Scope
- **Change:** <what changes>
- **Affected systems:** <services, jobs, queues, databases, clients>
- **Feature flags/config:** <flags or config involved, or none>
- **Out of scope:** <what this launch does not include>

### Preconditions
- MR/review state: <approved/merged/pending>
- Required migrations: <none or list>
- Required config: <none or list>
- Required manual steps: <none or list>
- Required approvals: <names or roles>

### Rollout Plan
1. <step>
2. <step>
3. <step>

### Rollback Plan
1. <step>
2. <step>

### Monitoring And Alerts
| Signal | Where | Healthy | Stop Threshold |
|---|---|---|---|
| <log> | <link> | <expected> | <condition> |
| <metric> | <dashboard> | <expected> | <condition> |

### Post-Launch Validation
- [ ] Smoke check: <command or manual check>
- [ ] API/UI check: <command or manual check>
- [ ] Data check: <query or invariant>
- [ ] Background job check: <queue/job check>
- [ ] Downstream check: <consumer/system check>

### Risks And Mitigations
| Risk | Mitigation |
|---|---|
| <risk> | <mitigation> |

### Stop Conditions
- Pause if: <condition>
- Rollback if: <condition>
- Escalate if: <condition>

### Approval
- Launch plan approved by: <name/role>
- Production action approved by: <name/role>
- Approval timestamp: <when>
```
