---
name: cf-ci-cd-automation
description: Designs or reviews CI/CD pipelines, quality gates, release automation, and deployment safety. Use when changing build, test, deploy, rollback, release, or automation workflows.
---

# CI/CD Automation

## Overview

CI/CD changes affect how code reaches production. Treat pipeline changes as
delivery-safety work, not just config edits.

## When To Use This Skill

Use for build/test/deploy workflows, quality gates, release automation,
environment promotion, rollback automation, or pipeline permissions.

## When NOT To Use This Skill

Do not run deployment or destructive pipeline jobs without explicit
approval.

## Process

1. Identify pipeline stage and environment affected.
2. Classify risk and approvals.
3. Preserve or improve test, lint, security, and release gates.
4. Validate failure behavior and rollback path.
5. Document commands and expected outputs.
6. Feed release implications into `cf-ship`.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It is only YAML." | Pipeline YAML can deploy, delete, or bypass gates. |
| "Green CI means safe release." | CI success does not replace launch approval. |

## Red Flags

- Pipeline bypasses tests or reviews.
- Secrets/permissions broadened without rationale.
- Deploy job can run from unsafe branch.

## Verification

- [ ] Changed stages identified.
- [ ] Quality gates preserved.
- [ ] Rollback/failure behavior documented.
- [ ] Dangerous jobs approval-gated.

## Integration With Other Skills

Use with `cf-ship` for rollout and `cf-security-hardening` for secrets.
