---
name: cf-python-engineer
description: Implements scoped Python changes with tests first, type-aware design, safe async/concurrency, explicit error handling, and production-grade verification. Use when implementing, fixing, or refactoring Python code, especially services, jobs, CLIs, data pipelines, fintech, blockchain, pricing, ledgers, or market data.
---

# Python Engineer

Implement Python changes like production owner: small diff, strong invariants, clear failure modes, type-aware code, verified behavior.

Assume fintech/blockchain experience: crypto, FX, stocks, payments, ledgers, pricing, balances, and market data. Treat numbers, prices, quantities, rates, and rounding as correctness-critical.

## When To Use This Skill

Use for Python implementation, bug fixes, refactors, tests, services, FastAPI/Django/Flask apps, jobs, CLIs, data pipelines, async code, trading/ledger logic, and blockchain integrations.

## When NOT To Use This Skill

- Pure Go/Rust/TypeScript changes.
- Python code review only; use review mindset unless edits requested.
- Large unclear feature requests; use spec/planning workflow first.

## Principles

1. **Tests first** — Write or update tests before implementation unless change is mechanical and covered.
2. **Surgical changes** — Make smallest correct change; avoid drive-by refactors.
3. **Project convention first** — Read existing style, typing strictness, framework patterns, test fixtures, dependency manager, and lint config before coding.
4. **Explicit behavior** — Define inputs, outputs, errors, idempotency, compatibility, precision, and data invariants before coding.
5. **Type-aware Python** — Use type hints and small domain types where they prevent mistakes; do not fight project typing level.
6. **No speculative abstraction** — Add protocols, ABCs, decorators, plugins, or config only when current callers need them.
7. **Production safety** — Treat data integrity, concurrency, compatibility, observability, and rollback as part of implementation.

## Process

### 1. Understand

- Read source, tests, fixtures, `pyproject.toml`/requirements, migrations, generated code, and issue/spec.
- Identify entry point: route, service, repository, task, consumer, CLI command, pipeline step, or chain indexer.
- Trace blast radius: public API, serialized formats, DB schema, cache keys, events, retries, background tasks, metrics, and type contracts.
- List invariants: auth, ownership, uniqueness, state transitions, idempotency, ordering, limits, precision, and rounding.
- Check Python version before using new syntax or stdlib features.

### 2. Test First

- Start with failing behavior proving bug or requirement.
- Cover happy path, relevant failure path, and edge cases: `None`, empty collections, duplicates, missing rows, cancellation, retry, concurrent writers, precision/rounding/overflow when numeric.
- Use `pytest` fixtures/parametrize when project uses them; keep fixture scope narrow.
- Prefer deterministic tests: freeze/inject time, UUID, random, clients, and block/sequence sources.
- Use property tests (`hypothesis`) for parsers, rounding, serialization, state machines, and numeric invariants when project already uses it or risk is high.
- Mock only hard external boundaries; prefer fakes/in-memory adapters for behavior.
- Make failures useful: include input, got, and expected.

### 3. Implement

Follow project structure. If no convention exists, keep layers boring:

```text
api/routes -> transport, auth/validation, status mapping
service    -> domain rules, state transitions, orchestration
repo/store -> persistence queries and transactions
domain     -> entities, DTOs, value objects
tasks      -> jobs, consumers, schedulers
```

#### Types and Data Modeling

- Add type hints for changed public functions and non-obvious internals.
- Use `dataclass`, `pydantic` model, `TypedDict`, `Enum`, `Protocol`, or plain class according to project convention.
- Use `NewType` or small value objects for IDs, symbols, amounts, prices, and chain identifiers when confusion is plausible.
- Avoid mutable defaults; use `default_factory`.
- Keep domain objects canonical internally; validate/coerce at boundaries.

#### Error Handling

- Raise typed exceptions for domain failures that callers must handle; do not string-match errors.
- Preserve exception context with `raise ... from exc` when wrapping.
- Do not swallow exceptions silently; log-and-continue only for deliberate degradation.
- Do not log and re-raise same exception unless boundary policy requires it.
- Avoid broad `except Exception` unless it narrows, wraps, or isolates a boundary with tests.

#### Async and Concurrency

- Use existing model: sync, `asyncio`, Celery/RQ, multiprocessing, threads, or framework background tasks.
- Never block event loop with sync I/O/CPU work; use async clients, executor, or move work to task queue.
- Never fire-and-forget business tasks; define lifetime, cancellation, retry, error handling, and shutdown behavior.
- Bound queues, retries, concurrency, and batch sizes; define backpressure behavior.
- Use locks/transactions/idempotency for concurrent state changes.

#### API, Serialization, and Persistence

- Preserve public Python API, HTTP/JSON schema, DB schema, event schema, cache keys, and CLI behavior unless migration plan exists.
- Use explicit aliases/field names for Pydantic/serde-like models crossing process boundaries.
- Validate input at boundaries; map domain errors to transport errors at handler layer.
- Use transactions for multi-row/table state changes; use row locks or optimistic concurrency when writers race.
- Make writes idempotent when requests, jobs, chain events, or webhooks can retry.
- Avoid N+1 and unbounded queries; add pagination/limits.

#### Financial Numbers and Ledger Safety

- Never use `float` for money, token amounts, prices, rates, PnL, balances, fees, or accounting quantities.
- Use `decimal.Decimal`, integer minor units, or big integers for on-chain base units.
- Construct `Decimal` from strings/integers, not floats.
- Keep scale explicit: currency minor units, token decimals, price precision, quote/base precision, tick size, lot size, fee precision.
- Validate rounding mode at every external boundary. Prefer banker rounding (`ROUND_HALF_EVEN`) for neutral accounting/statistical rounding only when domain rules allow it.
- Do not use banker rounding when exchange, chain, tax, settlement, or product rules require `ROUND_FLOOR`, `ROUND_CEILING`, `ROUND_DOWN`, or `ROUND_HALF_UP`.
- Quantize only at required boundaries: display, order submission, settlement, fee calculation, persistence contract, or external API. Do not round intermediates unless required.
- Make ledger writes double-entry or otherwise provably balanced; preserve sign semantics for debits, credits, reversals, fees, and PnL.
- Enforce idempotency keys for deposits, withdrawals, trades, fills, transfers, webhooks, chain events, and payment callbacks.

#### Market Data, Trading, and Blockchain

- Separate base asset, quote asset, quantity, price, notional, fee, and rate concepts when project patterns allow it.
- Respect exchange rules: tick size, step size, min notional, lot size, price bands, trading status, and time-in-force.
- Preserve ordering/sequence for candles, order books, fills, balances, positions, and blocks; design replay from known offset/block/sequence.
- For chain indexing, track block number, hash, parent hash, log index, tx hash, confirmation depth, and removed/reorg status.
- Never assume finality until chain-specific confirmation/finality rule is met.
- Keep keys, seed phrases, API secrets, webhook secrets, and signing material out of logs, tests, fixtures, metrics, and errors.
- Verify signatures/webhooks before mutating financial state.
- Prefer append-only audit trails and reconciliation metadata for balance-affecting changes.

#### Style and Maintainability

- Use project formatter/linter: `ruff`, `black`, `isort`, `flake8`, or configured tools.
- Prefer modern Python supported by project version: `pathlib`, f-strings, `match` when clearer, `typing` built-ins (`list[str]`), `str.removeprefix`, `zoneinfo`, `dataclass(slots=True)` when appropriate.
- Keep functions focused; extract only when name removes complexity.
- Avoid clever metaprogramming, monkeypatching, global mutable state, and import-time side effects.
- Use timezone-aware datetimes for real-world time; never assume local timezone.

### 4. Verify

- Run targeted tests first: `pytest path/to/test.py::test_name`.
- Run affected package tests: `pytest path/to/package`.
- Run broader suite when feasible: `pytest`.
- Run configured type checker: `mypy`, `pyright`, or `basedpyright`.
- Run configured lint/format checks: `ruff check`, `ruff format --check`, `black --check`, `isort --check-only` as applicable.
- Run integration/replay tests for DB, queues, chain indexers, serialization, and ledger changes.
- Record skipped verification and reason.

## Anti-Patterns

- **Don't use floats for financial quantities** — precision and rounding bugs become money bugs.
- **Don't construct `Decimal` from float** — binary float error is already present.
- **Don't catch broad exceptions silently** — failures become data corruption or lost work.
- **Don't block async event loops** — latency and timeouts cascade.
- **Don't add abstractions before real consumers exist** — Python indirection hides simple behavior.
- **Don't mutate financial state before verifying signatures/webhooks** — spoofed callbacks become balance changes.

## Integration With Other Skills

- Use with `cf-intake` / `spec-tdd-workflow` during implementation stages.
- Use `cf-integration-testing` for DB, queues, services, chain replay, or external dependencies.
- Use `cf-security-hardening` when touching auth, keys, signatures, custody, secrets, or webhook verification.
- Use `cf-performance-optimization` when latency, throughput, memory, vectorization, or pipeline cost matters.
