---
name: cf-security-hardening
description: Reviews and hardens security-sensitive code. Use when work touches auth, authorization, sessions, tokens, secrets, cryptography, user input, external boundaries, or data that can be persisted or consumed externally.
---

# Security Hardening

## Overview

Security hardening is a Lane B support skill for ControlFlow. It identifies
trust boundaries, validates controls, and records evidence before review or
launch.

## When To Use This Skill

Use for auth, permissions, secrets, crypto, user input, storage, external
integrations, or public API boundaries.

## When NOT To Use This Skill

Do not use it to approve security changes without `cf-intake` gates.

## Process

Use `references/security-checklist.md`.

1. Identify trust boundaries.
2. Classify Lane B triggers.
3. Review input validation and authorization.
4. Check secret handling and logging.
5. Check error exposure and external-call safety.
6. Record tests, scans, manual review notes, and unverified areas.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This only changes one line." | Security risk follows blast radius, not diff size. |
| "Tests pass." | Security behavior needs boundary and failure checks. |

## Red Flags

- Auth changed without Lane B.
- Secrets appear in logs, commits, or errors.
- User input crosses a boundary without validation.

## Verification

- [ ] Lane B trigger recorded.
- [ ] Boundary checks reviewed.
- [ ] Evidence recorded.
- [ ] Unverified areas listed.

## Integration With Other Skills

Called by `cf-review`, `cf-spec`, or `cf-ship` when security risk exists.
