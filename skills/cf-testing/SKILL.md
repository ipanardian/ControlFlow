---
name: cf-testing
description: Designs and writes Go tests with table-driven patterns, edge-case coverage, mocks, and coverage targets. Use when writing tests, improving coverage, cf-debugging flaky tests, or doing TDD for Go code. This skill is a Go-specific peer of the generic test patterns in `cf-intake`; for other languages, follow the same TDD principles with their own test tooling.
---

# Testing

Write thorough, maintainable Go tests. Focus on coverage, edge cases, and test quality.

## Principles

1. **Tests are first-class code** — Write tests with the same care as production code. No copy-paste duplication, no unclear test names.
2. **Test behavior, not implementation** — Test what the function does, not how it does it. If refactoring the implementation breaks a test, the test was wrong.
3. **Every bug gets a test first** — Before fixing a bug, write a test that reproduces it. The test should fail, then pass after the fix.
4. **Deterministic or explicitly skipped** — No flaky tests. If a test depends on timing, network, or external state, make it deterministic or skip it with a clear reason.

## Workflow

### 1. Identify what to test

From the spec, code change, or bug report, list:
- The **function** or **method** under test.
- The **behavior** it should exhibit for each input class.
- The **edge cases** — nil, zero, empty, duplicate, concurrent, too-large.
- The **error paths** — what should fail, and with what error.

### 2. Write the test structure

#### Table-driven tests (preferred)

```go
func TestService_CreateOrder(t *cf-testing.T) {
    tests := []struct {
        name    string
        input   CreateOrderInput
        want    *Order
        wantErr error
    }{
        {
            name:    "valid order",
            input:   CreateOrderInput{ProductID: "p1", Quantity: 2},
            want:    &Order{ID: "ord_1", ProductID: "p1", Quantity: 2},
            wantErr: nil,
        },
        {
            name:    "zero quantity",
            input:   CreateOrderInput{ProductID: "p1", Quantity: 0},
            wantErr: ErrInvalidQuantity,
        },
        {
            name:    "duplicate order is idempotent",
            input:   CreateOrderInput{ProductID: "p1", Quantity: 2, IdempotencyKey: "key1"},
            want:    &Order{ID: "ord_1"}, // same ID returned
            wantErr: nil,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *cf-testing.T) {
            // setup per-case state if needed
            got, err := svc.CreateOrder(ctx, tt.input)
            if !errors.Is(err, tt.wantErr) {
                t.Errorf("CreateOrder() error = %v, want %v", err, tt.wantErr)
            }
            if diff := cmp.Diff(tt.want, got); diff != "" {
                t.Errorf("CreateOrder() mismatch (-want +got):\n%s", diff)
            }
        })
    }
}
```

#### Single test for simple cases

For trivial functions, a single test function is fine:

```go
func TestParseUserID(t *cf-testing.T) {
    got, err := ParseUserID("user_123")
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if got != 123 {
        t.Errorf("ParseUserID() = %d, want 123", got)
    }
}
```

### 3. Mock external dependencies

#### Define interfaces on the consumer side

```go
// In the service package — only the methods the service needs.
type OrderRepository interface {
    Create(ctx context.Context, order *Order) error
    GetByID(ctx context.Context, id string) (*Order, error)
}
```

#### Implement mocks in test files

```go
type mockOrderRepo struct {
    orders map[string]*Order
    err    error
}

func (m *mockOrderRepo) Create(ctx context.Context, order *Order) error {
    if m.err != nil {
        return m.err
    }
    m.orders[order.ID] = order
    return nil
}

func (m *mockOrderRepo) GetByID(ctx context.Context, id string) (*Order, error) {
    if m.err != nil {
        return nil, m.err
    }
    return m.orders[id], nil
}
```

**When to use mock frameworks** (like `gomock` or `testify/mock`): Only when the interface has many methods and hand-written mocks become unwieldy. Prefer hand-written mocks for interfaces with 1-4 methods.

#### Mocking external services (HTTP)

```go
func startTestServer(t *cf-testing.T, handler http.HandlerFunc) *httptest.Server {
    t.Helper()
    srv := httptest.NewServer(handler)
    t.Cleanup(srv.Close)
    return srv
}
```

#### Mocking time

```go
type Clock interface {
    Now() time.Time
}

type realClock struct{}

func (realClock) Now() time.Time { return time.Now() }

type fakeClock struct{ fixed time.Time }

func (c fakeClock) Now() time.Time { return c.fixed }
```

### 4. Test categories

#### Unit tests

- Test one function or method in isolation.
- Mock all external dependencies (DB, cache, message queue, HTTP).
- Target: fast (<1s per test), no network, no filesystem.
- Run with: `go test ./... -count=1`

#### Integration tests

- Test the full stack: handler → service → repository → real database.
- Use build tags: `//go:build integration` to separate from unit tests.
- Use Docker or test containers for real database instances.
- Run with: `go test ./... -tags=integration -count=1`

#### Concurrency tests

- Always run with `-race`: `go test ./... -race -count=1`
- For concurrent code, write a test that runs the same operation from multiple goroutines.
- Use `sync.WaitGroup` to synchronize, check for data races.

```go
func TestService_ConcurrentCreate(t *cf-testing.T) {
    var wg sync.WaitGroup
    errCh := make(chan error, 100)

    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func(i int) {
            defer wg.Done()
            _, err := svc.Create(ctx, input)
            errCh <- err
        }(i)
    }

    wg.Wait()
    close(errCh)

    for err := range errCh {
        if err != nil && !errors.Is(err, ErrDuplicate) {
            t.Errorf("unexpected error: %v", err)
        }
    }
}
```

### 5. Coverage targets

- **New code**: >80% line coverage minimum. Aim for 90%+ on business logic.
- **Bug fixes**: The reproducer test must cover the exact bug scenario.
- **Error paths**: Every `if err != nil` branch should have at least one test.

Check coverage:

```bash
go test ./... -cover -coverprofile=coverage.out
go tool cover -func=coverage.out
```

### 6. Test naming conventions

```
Test<Package>_<Function>_<Scenario>
```

Examples:
- `TestService_CreateOrder_ValidInput`
- `TestService_CreateOrder_ZeroQuantity`
- `TestRepo_GetByID_NotFound`
- `TestHandler_ListOrders_Pagination`

For table-driven: the `name` field describes the scenario, the function name describes the method.

### 7. Handle test flakes

If a test fails intermittently:

1. **Never** add `time.Sleep` or `runtime.Gosched()` as a fix.
2. Use explicit synchronization: channels, `WaitGroup`, or test-level timeouts.
3. If the test depends on ordering of concurrent operations, make the ordering explicit.
4. If a race condition is in production code, fix the production code — don't work around it in the test.

## Anti-patterns

- **Testing private functions directly** — Test through the public API. If you must test a private function, consider extracting it to a testable package.
- **Asserting on full structs when only some fields matter** — Use `cmp.Diff` with `cmpopts.IgnoreFields` to focus assertions.
- **Shared mutable state across test cases** — Each `t.Run` case should set up its own state.
- **Ignoring errors in test setup** — Always check errors in test setup: `srv, err := NewTestServer(); require.NoError(t, err)`.
- **Testing framework behavior** — Don't test that `t.Error` is called; test that the production code behaves correctly.
- **Commenting out failing tests** — Fix them or skip with `t.Skip("reason: ...")`.
- **Using `assert` or `require` without a message** — Always include context: `require.NoError(t, err, "CreateOrder should succeed for valid input")`.

## Tools

- `go test ./... -count=1 -race` — Run tests with race detector, no caching.
- `go test ./... -cover -coverprofile=coverage.out` — Generate coverage report.
- `go tool cover -func=coverage.out` — Show per-function coverage.
- `golangci-lint run ./...` — Lint before committing.
- `github.com/google/go-cmp/cmp` — Deep comparison with readable diffs.
- `github.com/stretchr/testify` — Assertions (use sparingly, prefer `cmp.Diff`).
