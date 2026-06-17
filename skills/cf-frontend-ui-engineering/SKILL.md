---
name: cf-frontend-ui-engineering
description: Guides frontend UI implementation and review. Use when building or changing user-facing interfaces, component structure, responsive behavior, state flow, accessibility, or design-system integration.
---

# Frontend UI Engineering

## Overview

Frontend changes need behavior, accessibility, responsive layout, and
runtime validation, not just visual diff edits.

## When To Use This Skill

Use for components, pages, forms, state, responsive UI, accessibility,
design systems, or browser runtime behavior.

## When NOT To Use This Skill

Do not use for backend-only or docs-only changes.

## Process

1. Inspect existing design system and patterns.
2. Define user-visible behavior and states.
3. Cover loading, empty, error, disabled, and success states.
4. Check keyboard and screen-reader basics.
5. Validate desktop and mobile layout.
6. Use `cf-browser-testing` when runtime verification is needed.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It looks fine in code." | UI needs runtime/browser validation. |
| "Accessibility can wait." | Accessibility is behavior, not polish. |

## Red Flags

- No error/empty/loading state.
- Click-only interaction.
- Mobile layout unverified.

## Verification

- [ ] States covered.
- [ ] Accessibility basics checked.
- [ ] Desktop/mobile validation done.
- [ ] Tests or manual evidence recorded.

## Integration With Other Skills

Use with `cf-browser-testing`, `cf-testing`, and `cf-review`.
