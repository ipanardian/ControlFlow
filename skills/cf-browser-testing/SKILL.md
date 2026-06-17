---
name: cf-browser-testing
description: Verifies browser runtime behavior with live evidence. Use when UI, browser APIs, network calls, console errors, accessibility, responsiveness, or performance must be validated in a real browser.
---

# Browser Testing

## Overview

Browser cf-testing proves what users experience at runtime: DOM, console,
network, layout, accessibility, and performance signals.

## When To Use This Skill

Use for UI behavior, browser-only bugs, responsive layout, network flows,
console errors, accessibility checks, or frontend performance.

## When NOT To Use This Skill

Do not use when no browser runtime exists or code-level tests are enough.

## Process

1. Start app using repo-specific command.
2. Open relevant page/state.
3. Inspect console and network errors.
4. Validate user flow and responsive layout.
5. Capture accessibility/performance evidence when relevant.
6. Record browser, route, steps, result, and issues.

When browser testing satisfies a validation scenario, record scenario ID,
linked acceptance criterion, actor, environment, steps, expected result,
actual result, `PASS` / `FAIL` / `BLOCKED` / `N/A`, and evidence.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Unit tests cover it." | Unit tests do not prove browser runtime behavior. |
| "Screenshot looks fine." | Console/network/accessibility may still fail. |

## Red Flags

- Console errors ignored.
- Network failures hidden behind stale UI.
- Only desktop viewport checked.

## Verification

- [ ] Route and browser recorded.
- [ ] User flow checked.
- [ ] Console/network checked.
- [ ] Evidence added to review or MR.
- [ ] Required validation scenario result recorded when UI behavior changed.

## Integration With Other Skills

Use with `cf-frontend-ui-engineering`, `cf-performance-optimization`, and
`cf-review`.
