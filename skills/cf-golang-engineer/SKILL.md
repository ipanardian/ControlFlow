---
name: cf-golang-engineer
description: Implements scoped Go changes with tests first, clean architecture boundaries, and safe handling of concurrency, error propagation, and external dependencies. Use when implementing, fixing, or refactoring Go code — especially services with GORM, gRPC, grpc-gateway, Wire, NATS JetStream, Redis, or MySQL. This is the Go-specific implementation skill; for other languages, follow the same TDD principles with a peer skill for that language.
---

# Go Engineer

Implement scoped Go changes following production-grade practices.

## Principles

1. **Tests first** — Write or update tests before implementation. No PR is complete without test coverage for the change.
2. **Surgical changes** — Make the smallest change that solves the problem. Do not refactor adjacent code unless the change requires it.
3. **Explicit over implicit** — Name errors, return early, avoid magic. Prefer `if err != nil { return fmt.Errorf("doing X: %w", err) }` over silent error swallowing.
4. **No speculative code** — Don't add "flexibility" nobody asked for. Don't pre-build abstractions that have only one concrete user.

## Workflow

### 1. Understand the change

- Read the relevant source files, tests, and any spec or issue description.
- Identify the **entry point** (handler, service method, repository method) and the **blast radius** (what else touches this code path).
- List invariants that must hold before and after the change.

### 2. Write or update tests first

- Start with the **failure case**: what should error, and with what message?
- Add the **happy path**: what does correct input produce?
- Add **edge cases**: nil/zero inputs, concurrent access, duplicate entries.
- For changes touching existing code: run `go test ./... -count=1 -race` first to confirm baseline passes.

### 3. Implement

Follow the project's existing patterns. When the project has no strong convention, default to:

#### Architecture layers

```
handler/  → gRPC/HTTP handlers (thin, validate + delegate)
service/  → business logic (one struct per domain aggregate)
repo/     → GORM queries (one struct per database table)
model/    → domain entities + DTOs (no ORM tags on DTOs)
wire/     → dependency injection (Wire providers)
```

#### Error handling

- Wrap errors with context: `fmt.Errorf("repository.CreateOrder: %w", err)`
- Use sentinel errors for domain validation: `var ErrNotFound = errors.New("order not found")`
- Check errors with `errors.Is` / `errors.As` — never string matching.
- Return `pkg/status` gRPC status codes from handlers, not from services.

#### Concurrency

- `ctx context.Context` is the first parameter, always.
- Respect `ctx.Done()` in long-running loops and external calls.
- Use `errgroup` for fan-out; propagate cancelation.
- Prefer `sync.Mutex` over channels for simple state protection.
- Never start goroutines without a clear exit condition.

#### Database (GORM)

- Use parameterized queries. Never interpolate user input into raw SQL strings.
- Wrap transactions: `db.WithContext(ctx).Transaction(func(tx *gorm.DB) error { ... })`.
- Close rows: always `defer rows.Close()` after `db.Raw(...).Rows()`.
- Avoid N+1: use `Preload` or `Joins` explicitly.
- Migrations: additive only in a PR. Column renames and drops go in a separate PR.

#### gRPC / grpc-gateway

- Proto changes: backwards-compatible only (add fields, never rename/remove).
- Validate in the handler before delegating to the service.
- Map domain errors to gRPC status codes in the handler layer, not the service layer.

#### Redis

- Use context timeouts: `redis.Client.Get(ctx, key)`.
- Key naming: `{service}:{entity}:{id}`.
- Handle cache misses gracefully — treat them as "not found", not as errors.

#### NATS JetStream

- Publish with `PublishMsg` and check `Ack()` for exactly-once semantics where needed.
- Consume with `PullSubscribe` + explicit `Fetch`/`Ack` — never "at-most-once" fire-and-forget for business events.
- Set `Nats-Msg-Id` for idempotent publishes.

### 4. Verify

- Run `go test ./... -count=1 -race -cover` from the module root.
- Run `go vet ./...` and fix any findings.
- If the project has linters configured, run them (`golangci-lint run ./...`).
- Verify the change compiles: `go build ./...`

### 5. Commit message

- Use Conventional Commits: `feat(site): add order creation endpoint`, `fix(repo): handle duplicate key error`.
- Keep the subject line under 72 characters.

## Anti-patterns to avoid

- `_ = someFuncThatReturnsError()` — never discard errors silently.
- `panic` in library code or handlers — only in `init()` for unrecoverable setup failures.
- `interface{}` when a concrete type or generic works.
- Global mutable state (package-level `var db *gorm.DB`). Use dependency injection.
- Business logic in `main()`, handlers, or repositories. Keep it in services.

## Scope boundaries

- **One change per PR.** If the change spans multiple domains, split the PR.
- If you discover a bug in adjacent code while implementing, file a separate issue — don't fix it in this PR.
- If the change is unclear or seems too large, stop and ask for clarification before proceeding.