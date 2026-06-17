---
name: cf-debugging
description: Systematic cf-debugging — 4-phase root cause analysis (reproduce, gather evidence, hypothesize, verify) plus verification-before-completion protocol. Use when investigating bugs, performance issues, race conditions, panics, integration failures, or any unexpected behavior in any service or system. Examples throughout use Go, NATS, Redis, MySQL, and GORM as illustration; adapt the techniques to your stack.
---

# Debugging

Systematic root-cause analysis for any service or system. **Evidence
first, no speculative fixes.** This skill enforces a 4-phase
protocol and a mandatory verification step before declaring a bug
fixed.

The worked examples in this skill use Go with GORM, gRPC, NATS
JetStream, Redis, and MySQL — a common stack for backend services.
The techniques (reproduction, evidence gathering, hypothesis
cf-testing, verification) apply to any language and any stack. Adapt
the commands and tools to your project; the discipline is the same.

## When To Use This Skill

Use this skill when ANY of these are true:

- Investigating a bug, panic, or unexpected behavior
- Performance issue (slow endpoint, high latency, high CPU, OOM)
- Race condition or data corruption report
- Integration failure between services
- Test failure that is not obviously a typo or env issue
- "It works locally but not in [environment]"

Do NOT use this skill when:

- The bug is obvious from reading the code (e.g., typo, wrong variable
  name). Just fix it.
- The user has already provided a root cause analysis. Trust it but
  verify.
- The change is a feature addition, not a bug investigation. Use
  `cf-intake` instead.

For data-integrity issues in any Lane B trigger (auth, signature,
public API/contract, or any domain where wrong data is published
externally), this skill is **mandatory**
before any fix. Do not skip phases.

## Core Principles

1. **Observe before acting** — Collect data (logs, metrics, traces)
   before hypothesizing. Never change code based on a guess.
2. **Reproduce reliably** — A bug you cannot reproduce is a bug you
   cannot verify is fixed.
3. **Binary search the problem space** — Narrow by halving: which
   service? which handler? which function? which line?
4. **Root cause, not symptom** — Fixing the symptom means the bug
   returns. Fix the cause.
5. **Fix once, fix right** — When root cause is found, fix it properly
   with a regression test. No band-aids, no `time.Sleep`, no
   "we'll fix it later."
6. **Leave breadcrumbs** — Add structured logging and metrics for the
   next person. If you had to dig for it, someone else will too.

## The 4-Phase Protocol

```
Phase 1: REPRODUCE          (mandatory)
   ↓
Phase 2: GATHER EVIDENCE    (mandatory)
   ↓
Phase 3: HYPOTHESIZE        (rank by likelihood, design tests)
   ↓
Phase 4: TEST & ISOLATE     (binary search, one change at a time)
   ↓
ROOT CAUSE CONFIRMED
   ↓
FIX (TDD: failing test → fix → passing test)
   ↓
VERIFY (verification-before-completion protocol)
   ↓
DOCUMENT (post-mortem in spec / PR / issue)
```

**Do not skip phases.** "I think it's X, let me just try fixing X" is
speculation, not cf-debugging. If a phase produces nothing, note it and
move on — but you did the phase.

---

## Phase 1: Reproduce

A bug you cannot reproduce is a bug you cannot verify is fixed.

### Reproducible?

Write a test that triggers the issue. **This becomes the regression
test.** The test must:

- Be deterministic (no `time.Sleep`, no flaky fixtures, no test-only
  env dependence)
- Be minimal (strip away everything not needed to trigger the bug)
- Fail on the current code (proves the test actually catches the bug)
- Pass on the fixed code (proves the fix actually addresses the bug)

### Not Reproducible Locally?

Collect production evidence. You cannot skip reproduction; you can
only shift it to "production reproduction":

- Logs (filtered by trace ID, request ID, time window)
- Metrics (counters, histograms, dashboards)
- Traces (distributed tracing spans)
- pprof profiles (CPU, heap, goroutine, block, mutex)
- Reproduction steps from user report (do them exactly, do not assume)

### Intermittent?

Narrow the conditions:

- Specific load level? (try `wrk` / `vegeta` / `ghz` for gRPC)
- Specific data? (a particular symbol? a particular timestamp? a
  particular nonce?)
- Specific time window? (correlate with deploys, scheduled jobs,
  external events)
- Specific concurrency? (run with `go test -race` and `-count=1000`)

If you cannot narrow it, the bug is not ready to be fixed. Keep
gathering data.

**Exit criterion for Phase 1:** you have a reliable way to trigger
the bug, OR a clear production dataset that demonstrates it.

---

## Phase 2: Gather Evidence

Common evidence sources (commands shown are for a Go/NATS/Redis/MySQL
stack — adapt to your tools):

### Logs

```bash
# Filter by request ID or trace ID across services
grep "trace_id=abc123" service.log

# Filter by error level in a time window
grep -E "level=error|level=fatal" service.log | grep "2024-01-15T10:"

# Count errors by type
grep "level=error" service.log | jq -r '.msg' | sort | uniq -c | sort -rn

# Filter by request path or symbol
grep "path=/api/v1/prices" service.log
```

For data-pipeline issues: also grep for the affected entity
identifier (symbol, account ID, order ID, key, etc.) and the names
of the stages in the pipeline. Data-pipeline bugs often manifest as
"missing" or "stale" rather than as errors.

### Runtime Profiling (pprof)

```bash
# CPU profile for 30 seconds
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30

# Heap profile
go tool pprof http://localhost:6060/debug/pprof/heap

# Goroutine dump — look for leaked goroutines
go tool pprof http://localhost:6060/debug/pprof/goroutine

# Block profile (requires runtime.SetBlockProfileRate)
go tool pprof http://localhost:6060/debug/pprof/block

# Mutex contention (requires runtime.SetMutexProfileFraction)
go tool pprof http://localhost:6060/debug/pprof/mutex
```

Inside pprof:

```
(pprof) top 20          # top 20 consumers
(pprof) list FuncName   # source-level annotation
(pprof) web            # graph visualization (requires graphviz)
```

### Traces

```bash
# Collect a 5-second trace
curl -o trace.out http://localhost:6060/debug/pprof/trace?seconds=5
go tool trace trace.out
```

Look for:

- GC pauses (>10ms is worth investigating)
- Scheduler delays
- Network wait times
- Blocking operations on the goroutine timeline

### Database Queries

```sql
-- Slow queries (MySQL)
SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 20;

-- Currently running queries
SHOW PROCESSLIST;

-- Lock waits
SELECT * FROM information_schema.innodb_lock_waits;
```

For GORM: enable logger at `logger.Info` level to see query timing.
For slow endpoints: check N+1 by counting queries per request.

### NATS / JetStream

```bash
# Check stream state
nats stream info <STREAM_NAME>

# Check consumer lag
nats consumer info <STREAM_NAME> <CONSUMER_NAME>

# List slow consumers
nats consumer ls <STREAM_NAME>
```

For data pipelines using NATS: a stalled consumer can manifest
as "missing data" downstream, which looks like an upstream bug but
is actually a consumer bug.

### Redis

```bash
# Check key TTL
redis-cli TTL "<your-key-pattern>"

# Check key count (unbounded growth?)
redis-cli DBSIZE

# Check memory
redis-cli INFO memory
```

**Exit criterion for Phase 2:** you have a list of evidence items
that constrain the possible root causes. If your evidence could fit
20 different root causes, you do not have enough yet.

---

## Phase 3: Hypothesize

Based on evidence, list hypotheses **ranked by likelihood**. For each,
note what evidence supports it and what test would confirm or rule it
out:

```markdown
## Hypotheses

1. **<most likely cause>** — evidence: <what supports this>.
   Confirm by: <how to check>.
   Rule out by: <how to check>.
2. **<second most likely>** — evidence: <...>.
3. **<less likely>** — evidence: <...>.
```

**Anchor hypotheses to evidence, not to what is easiest to test.** A
hypothesis "it's the [component] doing [thing]" without supporting
evidence is a guess, not a hypothesis.

For data-integrity issues in a multi-service pipeline, common
hypotheses to test (adapt the layers to your actual pipeline):

- Source/provider changed schema or format and the ingest step did
  not parse the new shape
- Conversion or transformation error (unit, scale, encoding,
  decimal precision)
- Window or filter logic (which records are included/excluded by
  the aggregation step)
- Ordering issue (latest vs oldest, event time vs processing time)
- Cache staleness (Redis or in-process cache serving old data after
  upstream change)
- Consumer lag (NATS / Kafka / queue consumer falling behind, data
  not flowing)
- Clock skew between services (timestamp comparison wrong across
  hosts)
- Race in concurrent update (last write wins, but which is "last"?)
- Backpressure or shedding (service dropping requests under load)

**Exit criterion for Phase 3:** you have at most 2-3 plausible
hypotheses and a clear test for each.

---

## Phase 4: Test and Isolate

Test hypotheses, starting with the most likely.

### Binary Search

If you are unsure which function, add a log in the middle of the call
chain. If the issue manifests before the log, go up the call stack. If
it manifests after, go down.

For concurrent bugs: race detector (`go test -race`) is a binary
search tool. It pinpoints the exact line where the race occurs. Always
run it.

### Minimize the Reproduction

Strip away everything not needed to trigger the bug. The smallest
possible reproduction:

- Single test function if possible
- Hardcoded inputs that trigger the bug
- No external dependencies (use fakes/mocks for DB, NATS, Redis)
- No concurrency unless the bug is concurrency-related

### One Change at a Time

Never change two things simultaneously while cf-debugging. If you do and
the bug "disappears," you do not know which change fixed it. If it
persists, you do not know which change is wrong.

**Exit criterion for Phase 4:** one hypothesis is confirmed and the
others are ruled out. The root cause is identified to a specific
file:line or behavior.

---

## Fix: TDD Style

Once root cause is confirmed, fix it using the same TDD discipline as
feature work:

1. **Write a failing test** that reproduces the bug (this is your
   regression test — if it does not exist, the bug will return).
2. **Run the test** — confirm it fails for the expected reason
   (the bug is present, not a compile or env error).
3. **Write the minimal fix** that addresses the root cause, not the
   symptom.
4. **Run the test** — confirm it passes.
5. **Run the full test suite** with `-race`:
   `go test ./... -count=1 -race`.
6. **Run neighboring tests** in the affected package and its
   consumers — to confirm no regression.
7. **Add defensive logging or metric** at the point of failure so the
   next person (or you, in 3 months) can find this faster.

If the fix touches shared initialization (database, cache, config,
logger), also run the smoke test from
`cf-state-machine` section 7.1 if it touches shared initialization,
and update the spec's "Test Evidence" section.

---

## Verification Before Completion

**This step is mandatory. Do not declare a bug fixed without it.**

The verification protocol:

### Did The Test You Wrote Actually Fail Before The Fix?

Replay the test against the pre-fix code (use `git stash`, then run
the test). It MUST fail. If it passes before the fix, the test does
not actually catch the bug.

```bash
# Save the fix
git stash

# Run the regression test
go test ./path/to/package -run TestRegression -v

# Restore the fix
git stash pop
```

### Does The Test Pass With The Fix?

Run the regression test with the fix applied. It MUST pass.

### Does The Test Pass Consistently?

Run with `-count=1000` for intermittent bugs:

```bash
go test ./path/to/package -run TestRegression -count=1000 -race
```

A test that passes once may still be flaky. For data-integrity and
concurrency bugs, this is non-negotiable.

### Does The Full Suite Pass?

```bash
go test ./... -count=1 -race
```

No new failures. If something else broke, fix that too or escalate.

### Is The Production Evidence Consistent With The Fix?

If the bug was "users saw price X when it should be Y," the fix
should produce a test that asserts "given inputs, the output is Y."
Not "the output is not the old wrong value."

### Is The Fix At The Root Cause?

Ask yourself:

- Does this fix prevent the bug from recurring, or just hide the
  symptom?
- If the same input arrives tomorrow, will the fix still apply?
- Did I add a band-aid (`if err != nil { return }` to silence an
  error) instead of understanding the error?

If the answer is "this just hides the symptom," keep digging.

### Is The Commit Self-Contained?

- No unrelated changes
- No debug code, no commented-out code, no scratch files
- Commit message explains the root cause, not just the symptom

### What Did I Add So The Next Person Finds This Faster?

At minimum:

- A structured log line at the point of failure (if not already
  present)
- A metric or counter that surfaces the failure mode
- A test that documents the bug (the regression test is this)

**Verification is not "the test passed once."** Verification is the
full checklist above. Skip items only with a recorded reason, not
silently.

---

## Document

Add a brief post-mortem in the spec, PR, or issue:

```markdown
Root cause: <what happened, with file:line>
Fix: <what changed, with file:line>
Test: <link to regression test, name and path>
Prevention: <what monitoring/log/metric was added>
```

For Lane B fixes (auth, signature, public contract, data integrity),
this goes in the spec under "Test
Evidence" and in the MR description.

---

## Common Go Debugging Scenarios

### Goroutine leak

**Symptoms:** memory grows over time, `runtime.NumGoroutine()` climbs.

**Diagnosis:** pprof goroutine dump → look for routines stuck in
channel receive/select.

**Common causes:**

- Missing `ctx.Done()` check in `for` loops
- Channel never closed — receiver blocks forever
- `WaitGroup.Add` without matching `Done` on error paths
- HTTP response body not closed → connection goroutine leaks

**Fix pattern:**

```go
// WRONG: goroutine never exits
go func() {
    for {
        msg := ch.Recv() // blocks forever if context cancelled
        process(msg)
    }
}()

// RIGHT: respect context cancellation
go func() {
    for {
        select {
        case <-ctx.Done():
            ch.Close()
            return
        case msg := <-ch:
            process(msg)
        }
    }
}()
```

### Race condition

**Symptoms:** intermittent failures, data corruption, `go test -race`
reports.

**Diagnosis:** `go test -race ./...` — always use in CI.

**Common causes:**

- Shared slice/map written from multiple goroutines without
  synchronization
- `map` concurrent read/write (Go maps are NOT concurrent-safe)
- Lazy initialization without `sync.Once`

**Fix pattern:**

```go
// WRONG: concurrent map access
var cache = map[string]string{}

// RIGHT: sync.RWMutex for hot paths, sync.Map for rare writes
var cache struct {
    sync.RWMutex
    m map[string]string
}

// Or: use sync.Once for lazy init
var once sync.Once
var client *Client

func GetClient() *Client {
    once.Do(func() {
        client = NewClient()
    })
    return client
}
```

### Memory leak / unbounded growth

**Symptoms:** OOM kills, increasing heap in pprof.

**Diagnosis:** `go tool pprof http://localhost:6060/debug/pprof/heap`
→ `top 20` → `list <func>`.

**Common causes:**

- Unbounded slice/map accumulation (no eviction policy)
- Missing TTL on cache entries
- Large objects held in long-lived references (e.g., request-scoped
  data stored in a global)
- `defer` in loops holding references

**Fix:** add eviction (LRU cache), TTL, or scope reduction.

### Slow endpoint

**Symptoms:** high p99 latency, timeout errors.

**Diagnosis:** trace the request end-to-end. Check each layer:

1. HTTP handler → service → repository → database
2. Look for N+1 (query per loop iteration)
3. Look for missing indexes (`EXPLAIN` the slow query)
4. Look for lock contention (mutex profile)
5. Look for external call timeouts (are you setting
   `context.WithTimeout`?)

### Panic in production

**Symptoms:** service restarts, `recover()` logs.

**Diagnosis:** check `stderr` logs for panic stack traces.

**Common causes:**

- Nil pointer dereference (most common)
- Index out of range
- Map concurrent read/write
- Type assertion without comma-ok check

**Prevention:**

```go
// Top-level recovery in HTTP/gRPC handlers
func RecoverMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        defer func() {
            if err := recover(); err != nil {
                log.Error("panic recovered", "error", err, "stack", string(debug.Stack()))
                w.WriteHeader(http.StatusInternalServerError)
            }
        }()
        next.ServeHTTP(w, r)
    })
}
```

### Data pipeline: missing or wrong value

This applies whenever data flows through multiple stages (sources,
ingest, storage, processing, distribution, cache, consumer) and a
downstream stage reports missing, wrong, or stale data. The exact
stage names depend on your project — replace them with the layers
that exist in your system. The diagnosis discipline is what matters:
walk the pipeline from source to consumer in order, checking each
stage before moving to the next.

**Symptoms:** downstream consumer reports missing value, wrong value,
or stale data.

**Diagnosis path** (in order, adapt stage names to your system):

1. Is the source publishing? (check source service logs, message
   stream / queue / topic)
2. Is the ingest step consuming? (check ingest logs, consumer lag
   on the message stream)
3. Is the ingest step writing to storage correctly? (check storage
   row count vs time window, sample recent rows)
4. Is the processing step reading from storage? (check processing
   logs, query patterns)
5. Is the processing step publishing the processed output? (check
   the output stream / topic for the expected record)
6. Is the consumer of the processed output reading correctly? (check
   consumer logs, sample messages)
7. Is the cache serving stale data? (check cache TTL and key value
   for a known-bad input)
8. Is the API returning the cache or the storage? (trace one
   end-to-end request, log the value at each layer)

**Common causes:**

- Source changed schema or format and the ingest step did not parse
  the new shape
- Processing step window or filter logic off-by-one (excludes the
  latest data point)
- Cache served old data after upstream fix (no cache invalidation
  on update path)
- Consumer subscribed to wrong subject / topic / queue name
- Clock skew between services (event-time vs processing-time
  confusion)
- Race: writer updates storage while reader reads, reader sees
  partial state
- Backpressure: a slow downstream service is throttling the
  pipeline, causing old data to be served

**Note:** this pattern shows up in many domains — price pipelines,
event ingestion, audit logs, metrics rollups, search indexing, and
so on. The diagnosis discipline is the same regardless of domain.

---

## Anti-patterns

- **Don't add `time.Sleep` to "fix" race conditions** — This hides
  the bug, not fixes it.
- **Don't catch panic and continue** — Recover at the boundary
  (handler), log the stack, and let the request fail. Panicking
  goroutines in background work should crash the process.
- **Don't debug in production without a plan** — Every debug log or
  pprof hit has cost. Collect what you need, then remove debug
  instrumentation before merge.
- **Don't skip `-race` in tests** — Always run `go test -race`. Race
  conditions found in tests are real bugs.
- **Don't assume the first hypothesis is correct** — Test it. If
  evidence contradicts it, move to the next.
- **Don't fix a bug you cannot reproduce** — You cannot verify the
  fix. Reproduce first, then fix.
- **Don't declare "fixed" without the verification checklist** —
  "I ran the test once and it passed" is not verification. Use the
  full checklist.
- **Don't fix the symptom** — `if err != nil { return nil }` to
  silence an error is not a fix. Understand the error first.
- **Don't add unrelated changes** — If you are fixing a bug, the
  commit is the bug fix. Drive-by refactors and formatting changes go
  in separate commits.
- **Don't skip the regression test** — A bug without a test will
  return. Always write the test that catches it.
- **Don't skip post-mortem documentation** — If you had to dig for
  it, write down what you found. The next person (or you, in 3
  months) will thank you.

---

## Integration With Other Skills

- **`cf-intake`**: use this cf-debugging skill **before** writing
  the fix in TDD mode. The bug report becomes the spec's "Problem"
  section. The regression test is part of the test plan.
- **`cf-subagent-orchestration`**: a bug fix can be one criterion of a
  larger spec. The 4-phase protocol still applies. The implementer
  subagent does Phase 1-4 + fix, with verification as the
  code-quality review focus.
- **`code-review`**: code reviewers must apply the
  verification-before-completion checklist to bug fix MRs.
- **`cf-post-review-fix`**: classification of review feedback
  (`required` / `test-gap` / `nit` / etc.) applies to bug fix
  feedback the same way as feature feedback.
