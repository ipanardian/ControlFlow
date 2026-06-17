---
name: cf-rust-engineer
description: Implements scoped Rust changes with tests first, safe ownership/concurrency, explicit error handling, and production-grade verification. Use when implementing, fixing, or refactoring Rust code, especially services, CLI tools, async code, database integrations, fintech, blockchain, pricing, ledgers, or market data.
---

# Rust Engineer

Implement Rust changes like production owner: small diff, strong invariants, safe ownership, clear failure modes, verified behavior.

Assume fintech/blockchain experience: crypto, FX, stocks, payments, ledgers, pricing, balances, and market data. Treat numbers, prices, quantities, rates, and rounding as correctness-critical.

## When To Use This Skill

Use for Rust implementation, bug fixes, refactors, tests, async services, CLIs, database code, message consumers, blockchain indexers, trading/ledger logic, and API integrations.

## When NOT To Use This Skill

- Pure Go/Python/TypeScript changes.
- Rust code review only; use review mindset unless edits requested.
- Large unclear feature requests; use spec/planning workflow first.

## Principles

1. **Tests first** — Write or update tests before implementation unless change is mechanical and covered.
2. **Surgical changes** — Make smallest correct change; avoid drive-by refactors.
3. **Project convention first** — Read existing modules, error types, async runtime, lint config, and dependency patterns before coding.
4. **Type invariants** — Encode domain invariants in types when useful: newtypes, enums, non-zero types, validated constructors.
5. **No speculative abstraction** — Add traits, generics, macros, feature flags, or builders only when current callers need them.
6. **Production safety** — Treat data integrity, concurrency, compatibility, observability, precision, and rollback as part of implementation.

## Process

### 1. Understand

- Read source, tests, `Cargo.toml`, feature flags, lints, migrations, generated code, and issue/spec.
- Identify entry point: handler, service, repository, job, consumer, CLI command, or chain indexer.
- Trace blast radius: public API, serialized formats, DB schema, caches, events, tasks, retries, metrics, and unsafe blocks.
- List invariants: auth, ownership, uniqueness, state transitions, idempotency, ordering, limits, precision, and rounding.
- Check MSRV/rust-toolchain before using new language or std features.

### 2. Test First

- Start with failing behavior proving bug or requirement.
- Cover happy path, relevant failure path, and edge cases: `None`, empty collections, duplicates, missing rows, cancellation, retry, concurrent writers, precision/rounding/overflow when numeric.
- Use focused unit tests for pure logic; integration tests for DB, network, serialization, async runtime, chain/event replay.
- Prefer deterministic tests: inject clock, UUID, RNG, clients, and block/sequence sources.
- Use property tests (`proptest`/`quickcheck`) for parsers, rounding, serialization, state machines, and numeric invariants when project already uses them or risk is high.
- Make failures useful: include input, got, and want.

### 3. Implement

Follow project structure. If no convention exists, keep layers boring:

```text
handler/api -> transport, auth/validation, status mapping
service     -> domain rules, state transitions, orchestration
repo/store  -> persistence queries and transactions
domain      -> types, invariants, DTOs
```

#### Ownership and Types

- Prefer borrowing over cloning; clone only when ownership boundary or simplicity justifies it.
- Keep lifetimes simple; prefer owned domain types at service boundaries when lifetime complexity leaks.
- Use `Option` for absence and `Result` for fallible operations; never encode errors as magic values.
- Use enums for finite states; avoid stringly typed states.
- Use newtypes for IDs, amounts, prices, symbols, chain IDs, block numbers, and sequence numbers when mistakes are plausible.
- Avoid `unsafe`. If unavoidable, isolate it, document invariants, and add tests around safe wrapper behavior.

#### Error Handling

- Return `Result<T, E>`; do not `panic!` for normal failures.
- Use project error style: `thiserror` for domain/library errors, `anyhow`/`eyre` for binaries or top-level orchestration when accepted.
- Preserve source errors with `#[source]` or context (`.context("load config")?`) where useful.
- Match typed errors instead of string matching.
- Do not log and return same error unless boundary policy requires it.
- Avoid `unwrap()` / `expect()` outside tests, examples, startup constants, or impossible states with clear message.

#### Async and Concurrency

- Use existing runtime (`tokio`, `async-std`, sync) and project cancellation/shutdown pattern.
- Do not hold `std::sync::MutexGuard` across `.await`; use async-aware locks or restructure.
- Prefer message passing or scoped tasks when it clarifies ownership; prefer locks for simple shared state.
- Never fire-and-forget business tasks; define lifetime, cancellation, join/error handling, and test synchronization.
- Bound channels, queues, retries, and concurrency; define backpressure behavior.
- Use `Send`/`Sync` consciously; avoid hiding non-thread-safe state behind global singletons.

#### API, Serialization, and Persistence

- Preserve public Rust API, JSON/protobuf schema, DB schema, event schema, cache keys, and CLI behavior unless migration plan exists.
- Use explicit serde names/tags for cross-process structs; serialized field names are contracts.
- Validate input at boundaries; keep domain types canonical internally.
- Use transactions for multi-row/table state changes; use locks or optimistic concurrency when writers race.
- Make writes idempotent when requests, jobs, chain events, or webhooks can retry.
- Avoid N+1 and unbounded queries; add pagination/limits.

#### Financial Numbers and Ledger Safety

- Never use `f32`/`f64` for money, token amounts, prices, rates, PnL, balances, fees, or accounting quantities.
- Use project-approved decimal/fixed-point type, integer minor units, or big integer for on-chain base units (`rust_decimal`, `bigdecimal`, `num_bigint`, `U256`, etc.).
- Keep scale explicit: currency minor units, token decimals, price precision, quote/base precision, tick size, lot size, fee precision.
- Validate rounding mode at every external boundary. Prefer banker rounding (`round half to even`) for neutral accounting/statistical rounding only when domain rules allow it.
- Do not use banker rounding when exchange, chain, tax, settlement, or product rules require floor, ceiling, truncate, or half-up.
- Round only at required boundaries; do not round intermediates unless domain rule requires it.
- Make ledger writes double-entry or otherwise provably balanced; preserve sign semantics for debits, credits, reversals, fees, and PnL.
- Enforce idempotency keys for deposits, withdrawals, trades, fills, transfers, webhooks, chain events, and payment callbacks.

#### Market Data, Trading, and Blockchain

- Separate base asset, quote asset, quantity, price, notional, fee, and rate types when project patterns allow it.
- Respect exchange rules: tick size, step size, min notional, lot size, price bands, trading status, and time-in-force.
- Preserve ordering/sequence for candles, order books, fills, balances, positions, and blocks; design replay from known offset/block/sequence.
- For chain indexing, track block number, hash, parent hash, log index, tx hash, confirmation depth, and removed/reorg status.
- Never assume finality until chain-specific confirmation/finality rule is met.
- Keep keys, seed phrases, API secrets, webhook secrets, and signing material out of logs, tests, fixtures, metrics, and errors.
- Verify signatures/webhooks before mutating financial state.
- Prefer append-only audit trails and reconciliation metadata for balance-affecting changes.

#### Style and Maintainability

- Run `cargo fmt`; do not hand-format.
- Prefer standard library and existing crates; add dependencies only with clear value.
- Keep functions small enough to see invariants; extract only when name removes complexity.
- Avoid macros unless they remove real repetition and are readable at call sites.
- Use iterator adapters when clearer; use loops when control flow, mutation, or cf-debugging is clearer.
- Prefer `matches!`, `let else`, `?`, `From`/`TryFrom`, `Default`, `AsRef`, and `IntoIterator` idioms when supported by MSRV and project style.

### 4. Verify

- Run targeted tests first: `cargo test -p <crate> <test_name>` or `cargo test <module>::`.
- Run crate tests: `cargo test -p <crate>`.
- Run broader suite when feasible: `cargo test --workspace`.
- Run `cargo fmt --check` and `cargo clippy --workspace --all-targets --all-features` when configured/feasible.
- Run `cargo build --workspace --all-features` if tests do not compile all affected crates.
- Run integration/replay tests for DB, queues, chain indexers, serialization, and ledger changes.
- Record skipped verification and reason.

## Anti-Patterns

- **Don't use `unwrap()`/`expect()` in production paths** — it turns recoverable failures into crashes.
- **Don't use floats for financial quantities** — precision and rounding bugs become money bugs.
- **Don't hide invariants in comments only** — use types, constructors, validation, and tests.
- **Don't spawn untracked tasks** — leaks, lost errors, and shutdown bugs follow.
- **Don't add traits before real consumers exist** — Rust abstractions add compile-time and cognitive cost.
- **Don't serialize implicit field names across process boundaries** — renames become breaking changes.

## Integration With Other Skills

- Use with `cf-intake` / `spec-tdd-workflow` during implementation stages.
- Use `cf-integration-testing` for DB, queues, services, chain replay, or external dependencies.
- Use `cf-security-hardening` when touching auth, keys, signatures, custody, secrets, or webhook verification.
- Use `cf-performance-optimization` when latency, throughput, allocations, or replay speed matter.
