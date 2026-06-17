---
name: cf-documentation-adrs
description: Creates or reviews durable documentation and architecture decision records. Use when behavior, architecture, API contracts, operational procedures, or long-lived trade-offs need documented rationale.
---

# Documentation And ADRs

## Overview

Document why decisions exist, not just what changed. Use ADRs for durable
architecture or operational choices.

## When To Use This Skill

Use for architecture changes, public APIs, operational runbooks, launch
procedures, migrations, or decisions future maintainers must understand.

## When NOT To Use This Skill

Do not create ADRs for tiny local changes with no future decision value.

## Process

1. Identify decision or procedure to document.
2. Record context and constraints.
3. Record considered options.
4. Record decision and consequences.
5. Link spec, tests, MR, launch handoff, or runbook.
6. Keep docs close to owning code or standard docs location.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The code explains it." | Code rarely explains rejected options or trade-offs. |
| "We can document after launch." | Missing launch docs create operational risk. |

## Red Flags

- Public behavior changes without docs.
- Migration steps only live in chat.
- Decision rationale absent from MR/spec.

## Verification

- [ ] Context and decision recorded.
- [ ] Consequences listed.
- [ ] Links to spec/MR/tests added.
- [ ] Runbook/launch steps documented when needed.

## Integration With Other Skills

Supports `cf-spec`, `cf-mr`, and `cf-ship`.
