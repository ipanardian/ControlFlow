---
name: cf-source-driven-development
description: Grounds framework, library, and platform decisions in authoritative documentation. Use when implementing or reviewing code that depends on external APIs, SDKs, frameworks, cloud services, or unfamiliar tools.
---

# Source-Driven Development

## Overview

External API decisions must be grounded in source docs, not memory or
model confidence.

## When To Use This Skill

Use for framework/library APIs, SDKs, cloud services, config formats,
security behavior, or unfamiliar platform features.

## When NOT To Use This Skill

Do not block obvious repo-local code that does not depend on external API
behavior.

## Process

1. Identify external API or framework claim.
2. Fetch official docs or trusted source.
3. Verify syntax, version, behavior, and limitations.
4. Cite source in notes or MR when material.
5. Mark unverified assumptions explicitly.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I know this API." | APIs and defaults change by version. |
| "Examples online agree." | Prefer official docs or source code. |

## Red Flags

- New framework API without citation.
- Version-specific behavior assumed.
- Security/config defaults guessed.

## Verification

- [ ] Source checked.
- [ ] Version considered.
- [ ] Material assumptions cited or marked unverified.

## Integration With Other Skills

Use during `cf-spec`, `cf-build`, `cf-security-hardening`, and
`cf-ci-cd-automation` when external docs matter.
