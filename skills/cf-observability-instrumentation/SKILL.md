---
name: cf-observability-instrumentation
description: Designs and reviews logs, metrics, traces, and alerts. Use when changes need production visibility, launch monitoring, incident diagnosis, or post-launch validation evidence.
---

# Observability Instrumentation

## Overview

Observability makes launch outcomes measurable. Add or review telemetry as
part of implementation and production readiness.

## When To Use This Skill

Use when launch needs logs, metrics, traces, dashboards, alerts, or
post-launch validation signals.

## When NOT To Use This Skill

Do not add noisy telemetry without a consumer, threshold, or diagnostic
purpose.

## Process

1. Identify user/system symptom to observe.
2. Choose signal: log, metric, trace, alert, dashboard, query.
3. Add structured fields and correlation IDs when applicable.
4. Avoid secrets and high-cardinality labels.
5. Define healthy signal and stop threshold.
6. Feed monitoring notes into `cf-ship`.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We can check manually." | Launch needs repeatable validation signals. |
| "More logs are safer." | Noisy logs hide incidents and can leak data. |

## Red Flags

- No metric/log for risky launch.
- Alert lacks threshold or owner.
- Telemetry includes secrets or PII.

## Verification

- [ ] Signal maps to launch risk.
- [ ] Healthy and bad states are defined.
- [ ] No secret/PII leakage.
- [ ] `cf-ship` monitoring section updated.

## Integration With Other Skills

Supports `cf-ship`, `cf-review`, and `cf-performance-optimization`.
