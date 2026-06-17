---
name: cf-performance-optimization
description: Measures and improves performance using evidence. Use when latency, throughput, memory, CPU, bundle size, Core Web Vitals, query cost, or resource regressions matter.
---

# Performance Optimization

## Overview

Performance work must be measurement-first. Do not optimize without a
baseline, target, and verification command.

## When To Use This Skill

Use for performance regressions, explicit targets, hot paths, expensive
queries, frontend vitals, or resource usage concerns.

## When NOT To Use This Skill

Do not refactor for theoretical performance without measurement.

## Process

1. Define metric and target.
2. Capture baseline.
3. Identify bottleneck with profiler, trace, benchmark, query plan, or
   browser tooling.
4. Make smallest safe change.
5. Re-measure using same method.
6. Record trade-offs and production monitoring needs.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This should be faster." | Performance claims need measurements. |
| "Microbenchmark is enough." | Production path may differ from microbenchmark. |

## Red Flags

- No baseline.
- Different measurement before/after.
- Optimization harms correctness or readability without need.

## Verification

- [ ] Baseline recorded.
- [ ] Target recorded.
- [ ] Before/after evidence recorded.
- [ ] Risks and monitoring noted.

## Integration With Other Skills

Use with `cf-browser-testing` for frontend runtime evidence and `cf-ship` for
launch monitoring.
