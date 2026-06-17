# Code Quality Reviewer Subagent Prompt

Use this template when dispatching a code quality reviewer subagent.
This is **Stage 2** of the two-stage review. Only dispatch after the
spec compliance review (Stage 1) has returned ✅.

The reviewer verifies the implementation is well-built (clean, tested,
maintainable, idiomatic). This is distinct from spec compliance: an
implementation can be spec-compliant but still have quality issues, and
vice versa.

```
Task tool (general-purpose):
  description: "Code quality review for Criterion <N>"
  prompt: |
    You are reviewing code quality for Criterion <N>. You are a fresh
    subagent — you do not have the orchestrator's prior context.
    Everything you need is pasted below.

    ## Criterion (For Context Only)

    <FULL TEXT of the acceptance criterion. You are NOT re-reviewing
    spec compliance — that already passed. Use this only to understand
    what the code is trying to do.>

    ## Lane And Verifiability

    - Lane: <A or B>
    - Verifiability: <cheap or expensive>
    - Heavy trigger (auth, data integrity, signature, public
      API)? <yes or no — affects review strictness>

    ## Diff To Review

    - Base SHA: <sha> (commit before the criterion was implemented)
    - Head SHA: <sha> (current tip after the criterion's commit)
    - Use `git show <head-sha>` or `git diff <base>..<head>` to see
      the full diff

    ## Context

    <Scene-setting: package, dependencies, neighboring code, anything
    the reviewer needs to know to judge idiomaticity and patterns.>

    ## Your Job

    Review the diff for code quality. Spec compliance has already been
    verified — focus on **how** the code is built, not **what** it
    builds.

    **Always check (all lanes):**

    - Does each file have one clear responsibility with a well-defined
      interface?
    - Are units decomposed so they can be understood and tested
      independently?
    - Is the implementation following the file structure from the
      spec?
    - Did this implementation create new files that are already
      large, or significantly grow existing files? (Do not flag
      pre-existing file sizes — focus on what this change
      contributed.)
    - Are names clear, accurate, and consistent?
    - Are error messages actionable? Do they include the operation
      and relevant context?
    - Is logging appropriate (not silent, not spammy)?
    - Are there magic numbers or strings that should be named
      constants?
    - Are there TODO / FIXME / debug prints left in?
    - Is the commit message following Conventional Commits and
      matching the change?

    **For Go (if applicable):**

    - Idiomatic Go: early returns, no else after return, errors as
      values, no panic in normal flow
    - Error wrapping: `%w` for wrap, `errors.Is/As` for checks
    - No ignored errors (`_ = someFunc()` only when justified)
    - No goroutine leaks: every goroutine has a clear exit path
    - Context propagation where applicable
    - Resource cleanup: defer Close(), defer Cancel()
    - No data races (check shared state and locks)
    - Channel usage: directional where possible, buffered only when
      justified
    - Receiver names consistent across the package

    **For test quality:**

    - Do tests actually verify behavior, or do they just re-state
      the implementation?
    - Are tests table-driven where appropriate?
    - Do tests cover edge cases the criterion implies (empty input,
      max input, concurrent calls, error paths)?
    - Are tests deterministic (no time.Sleep, no flaky fixtures)?
    - Are tests fast (no unnecessary I/O, no real network)?
    - Do tests use `t.Helper()` where useful?
    - Are test names descriptive (`TestPublishPrice_DuplicateEvent_
      ReturnsError`, not `TestPublish1`)?

    **For Lane B (no heavy trigger) — additional strictness:**

    - Error handling: every error path covered, no silent failures
    - Idempotency: what happens if the operation is re-run with the
      same input?
    - Data flow: does the change touch a code path that publishes
      or persists data consumed externally, even indirectly? If
      yes, escalate even if not explicitly a "data integrity"
      change.
    - Concurrency: race conditions, lock ordering, shared state
    - Resource leaks: file handles, DB connections, Redis
      connections, NATS subscriptions
    - Boundary conditions: nil, empty, max, concurrent

    **Do NOT check:**

    - Spec compliance (already verified)
    - Whether the implementation matches the criterion text (already
      verified)
    - Pre-existing code quality (only flag what this change
      contributed)

    ## Output

    Report in this format:

    **Strengths:** list what is done well (be specific, not
    generic — name the file and the thing done well)

    **Issues:**

    - **Critical** (must fix before merge): correctness, safety,
      security, data integrity, broken behavior
    - **Important** (should fix before merge): significant quality,
      missing edge cases, poor error handling, test gaps on
      important paths
    - **Minor** (nice to fix): style, naming, minor test coverage

    For each issue, give `file:line` reference and a one-line
    description. The orchestrator will pass this back to the
    implementer for fix.

    **Assessment:** Approved | Approved with minor notes | Changes
    required

    - **Approved** — no Critical or Important issues
    - **Approved with minor notes** — only Minor issues; the
      implementer can address them in a follow-up if needed
    - **Changes required** — Critical or Important issues exist; the
      implementer must fix and re-review

    Do not propose fixes in detail. Your job is to identify issues,
    not to fill them. The implementer will fix. Exception: a one-line
    hint is fine if the fix is obvious and saves a round-trip.
```
