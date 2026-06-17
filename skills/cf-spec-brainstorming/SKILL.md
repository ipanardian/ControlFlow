---
name: cf-spec-brainstorming
description: Use before spec design when a feature, bug report, or product request is vague, multi-path, creative, or too large for one spec. Produces a lightweight brainstorming handoff with clarified problem, constraints, options, recommendation, scope, acceptance signals, and next workflow step; do not use for small obvious edits or already-scoped work.
---

# Spec Brainstorming

Clarify vague or multi-path work before writing a spec. This is an optional
intake stage for the spec-driven workflow, not a replacement for
`cf-spec-planning` or `cf-intake`.

## When To Use This Skill

Use this skill when:

- The request is vague, creative, product-facing, or multi-path.
- The scope may need decomposition before a spec.
- The user asks to brainstorm, explore options, compare approaches, or
  propose a direction.
- A behavior change has unclear success criteria.
- Two engineers could reasonably build different valid versions from the
  same request.

Do not use this skill when:

- The task is a small obvious edit such as a typo, rename, formatting
  change, dependency bump, or docs tweak.
- The user already supplied a complete spec or acceptance criteria.
- The root cause and fix are clear enough to move directly to spec or code.
- The task is already in an approved workflow state.

## Core Principles

- **Context first** — inspect repo docs, related files, and existing specs
  before asking questions.
- **One question at a time** — avoid interview walls; prefer multiple
  choice when possible.
- **Options before commitment** — propose 2-3 real approaches with
  trade-offs before choosing a direction.
- **Handoff, not implementation** — output clarified direction only.
- **Right-size rigor** — skip brainstorming when it adds ceremony without
  reducing ambiguity.

## Process

1. **Gather context**
   - Read relevant project docs and files before asking detailed questions.
   - Identify current behavior, existing patterns, and related specs if any.

2. **Decide if brainstorming is needed**
   - If the task is small and clear, say brainstorming is not needed and
     route to the appropriate next step.
   - If the task is broad, vague, or has multiple valid solutions,
     continue.

3. **Ask clarifying questions one at a time**
   - Focus on goal, users, constraints, success signals, and scope
     boundaries.
   - Prefer multiple choice when it makes the answer easier.
   - Stop when there is enough information to choose a direction; do not
     turn brainstorming into open-ended product discovery.

4. **Propose approaches**
   - Present 2-3 approaches.
   - Lead with the recommended approach.
   - Include the main trade-off for each option.
   - Do not invent fake alternatives just to reach three options.

5. **Get direction approval**
   - Ask the user to choose an option or approve the recommendation.
   - If the user rejects the direction, revise the options before writing
     the handoff.

6. **Write the Brainstorming Handoff**
   - Do not write code.
   - Do not create a full spec unless the user asks or the next workflow
     step begins.
   - Do not create a test plan.
   - Do not invoke an implementation skill.

7. **Route to the next workflow step**
   - Tiny clear change: direct edit can be acceptable.
   - Small risky or behavioral change: mini-spec.
   - Medium or large change: `cf-spec-planning`.
   - Full gated workflow request: `cf-intake`.
   - Huge request: split into sub-specs first.

## Brainstorming Handoff Template

```md
## Brainstorming Handoff

### Problem
<what the user wants or what pain exists>

### Context
<repo, product, or domain facts discovered>

### Constraints
<technical, product, time, risk, or workflow constraints>

### Options Considered
1. <option> — <main trade-off>
2. <option> — <main trade-off>
3. <option> — <main trade-off>

### Recommendation
<chosen direction and why>

### Scope
In:
- <included>

Out:
- <deferred>

### Acceptance Signals
- <observable success condition>
- <observable success condition>

### Open Questions
- <remaining question or "None">

### Suggested Next Step
<direct edit | mini-spec | cf-spec-planning | cf-intake | split into sub-specs>
```

## Anti-patterns

- **Do not force brainstorming for every task** — clear small work should
  not get blocked by ceremony.
- **Do not skip context gathering** — questions asked before reading the
  repo usually waste user time.
- **Do not ask many questions at once** — this skill clarifies through a
  short dialogue, not a questionnaire.
- **Do not produce implementation details as the final output** — leave
  design details for the spec and implementation plan.
- **Do not expand scope silently** — new ideas go in Out of Scope or become
  separate specs.

## Integration With Other Skills

- `cf-intake`: may invoke this before `BRANCH_CHECK` when the
  initial request is vague, creative, multi-path, or too large for one
  spec.
- `cf-spec-planning`: consumes the Brainstorming Handoff as input for the
  formal spec.
- `cf-debugging`: for bug reports with unclear root cause, use `cf-debugging`
  before or alongside spec design; use this skill only when the desired
  product or behavior direction is also unclear.
- Implementation peer skills such as `cf-golang-engineer` are not invoked
  from this skill.
