---
name: go-testing
description: Use this skill when writing or reviewing Go tests. Provides Go testing best practices for test structure, naming, table-driven tests, mocking, and test organization. Triggers when: (1) Writing new Go test files (*_test.go), (2) Modifying existing Go tests, (3) Reviewing Go test code, (4) Debugging Go test failures, or (5) Any other Go testing tasks.
---

# Go Testing

Use the standard `testing` package. Follow these guidelines for clean, maintainable tests.

> Also apply the `general-testing-guidelines` skill — it covers language-agnostic naming, structure, and organization rules that govern all test code.

## Naming

- Test functions: `func Test<Subject>(t *testing.T)`
- Subtest names passed to `t.Run()` **must use underscores instead of spaces**: `t.Run("valid_request_returns_200", ...)`.
  - This is required because Go replaces spaces with underscores internally, so using underscores from the start allows copy-pasting the name directly into `-run` without modification.
  - Wrong: `t.Run("valid request returns 200", ...)`
  - Right: `t.Run("valid_request_returns_200", ...)`

## Structure

Group related subtests under a single top-level `Test*` function using `t.Run`:

```go
func TestCreateUser(t *testing.T) {
    t.Parallel()

    t.Run("returns_201_on_success", func(t *testing.T) {
        t.Parallel()
        // ...
    })

    t.Run("returns_400_when_email_is_missing", func(t *testing.T) {
        t.Parallel()
        // ...
    })
}
```

## Table-Driven Tests

Use table-driven tests for multiple scenarios of the same behavior:

```go
func TestValidateEmail(t *testing.T) {
    t.Parallel()

    cases := []struct {
        name    string
        input   string
        wantErr bool
    }{
        {name: "valid_email", input: "user@example.com", wantErr: false},
        {name: "missing_at_sign", input: "userexample.com", wantErr: true},
        {name: "empty_string", input: "", wantErr: true},
    }

    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            t.Parallel()
            err := ValidateEmail(tc.input)
            if tc.wantErr {
                require.Error(t, err)
            } else {
                require.NoError(t, err)
            }
        })
    }
}
```

## Assertions

Use `github.com/stretchr/testify`:

- `require.*` — stops the test immediately on failure (use for preconditions and setup)
- `assert.*` — continues after failure (use for multiple independent checks)

```go
require.NoError(t, err)
require.NotNil(t, result)
assert.Equal(t, expected, actual)
assert.ErrorIs(t, err, ErrNotFound)
```

## Parallelism

- Call `t.Parallel()` at the top of every test and subtest that is safe to run concurrently.
- Do not share mutable state between parallel tests.

## Mocking

Use `github.com/stretchr/testify/mock` for interface mocking:

```go
type MockRepository struct {
    mock.Mock
}

func (m *MockRepository) FindByID(id string) (*User, error) {
    args := m.Called(id)
    return args.Get(0).(*User), args.Error(1)
}

func TestGetUser(t *testing.T) {
    t.Parallel()

    repo := new(MockRepository)
    repo.On("FindByID", "123").Return(&User{ID: "123"}, nil)

    svc := NewUserService(repo)
    user, err := svc.GetUser("123")

    require.NoError(t, err)
    assert.Equal(t, "123", user.ID)
    repo.AssertExpectations(t)
}
```

## Running a Single Test

Because subtest names use underscores, you can copy-paste names directly:

```bash
# Run entire test function
go test -run TestCreateUser ./internal/...

# Run a specific subtest
go test -run TestCreateUser/returns_201_on_success ./internal/...
```

## Checklist

- [ ] Subtest names use underscores, not spaces
- [ ] `t.Parallel()` called on every safe test and subtest
- [ ] `require.*` used for preconditions, `assert.*` for value checks
- [ ] Table-driven tests used for multiple scenarios of the same behavior
- [ ] Mocks assert expectations with `AssertExpectations(t)`
- [ ] No shared mutable state between parallel tests
