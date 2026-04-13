---
name: python-testing
description: Use this skill when writing or reviewing Python tests. Provides pytest best practices for test structure, fixtures, mocking, parametrization, and test organization. Triggers when: (1) Writing new test files, (2) Modifying existing tests, (3) Reviewing test code, (4) Debugging test failures, or (5) Any other Python testing tasks.
---

# Python Testing

Use pytest over unittest. Follow these guidelines for clean, maintainable tests.

> Also apply the `general-testing-guidelines` skill — it covers language-agnostic naming, structure, and organization rules that govern all test code.

## Core Principles

- Test file pattern: `test_*.py`, `*_tests.py`
- Test function pattern: `def test_*`
- Wrap test functions inside a class when grouping makes sense.
- Imports should always be at the top level of the file unless strictly required.

## Fixtures

Check existing fixtures before creating new ones. Use appropriate scope:

- `function` (default): New instance per test
- `class`: Shared across test class
- `module`: Shared across file
- `session`: Shared across entire test suite

```python
@pytest.fixture(scope="module")
def db_connection():
    conn = create_connection()
    yield conn
    conn.close()
```

## Mocking

Prefer pytest-mock mocker over unittest.mock. Do not use `@mock.patch` decorators and `with mock.patch`context managers - use `mocker.patch` instead.

```python
def test_api_call(mocker):
    mock_get = mocker.patch('requests.get')
    mock_get.return_value.json.return_value = {'data': 'test'}
```

Combine with fixtures for reusability:

```python
@pytest.fixture
def mock_api(mocker):
    return mocker.patch('app.external_api.call')

def test_feature(mock_api):
    mock_api.return_value = {'status': 'ok'}
    # test code
    mock_api.assert_called_once_with(expected_args)
```

Use monkeypatch when appropriate:

```python
def fake_get(url):
    class FakeResponse:
        def json(self):
            return {"temperature": 25}
    return FakeResponse()

def test_get_temperature(monkeypatch):
    monkeypatch.setattr("app.weather.requests.get", fake_get)
    assert get_temperature("London") == 25
```

## External Services

Never call external services (APIs, databases, networks). Always mock external dependencies and assert correct calls:

```python
def test_send_email(mocker):
    mock_smtp = mocker.patch('smtplib.SMTP')
    send_notification('user@example.com')
    mock_smtp.assert_called_once()
    mock_smtp.return_value.send_message.assert_called_once()
```

## Parametrization

Use `@pytest.mark.parametrize` for multiple test cases:

```python
@pytest.mark.parametrize("input,expected", [
    (0, 0),
    (1, 1),
    (5, 120),
    (-1, ValueError),
])
def test_factorial(input, expected):
    if expected == ValueError:
        with pytest.raises(ValueError):
            factorial(input)
    else:
        assert factorial(input) == expected
```

## Checklist

- [ ] Using pytest
- [ ] Checked for existing reusable fixtures
- [ ] Fixtures have appropriate scope
- [ ] Using `mocker` fixture instead of `@patch` decorators
- [ ] External services are mocked
- [ ] Mock assertions verify correct calls
- [ ] Parametrized tests for multiple scenarios
- [ ] Test functions are clean and focused

## Example Structure

```python
import pytest

@pytest.fixture(scope="module")
def api_client(mocker):
    """Reusable mocked API client"""
    return mocker.patch('app.api.Client')

@pytest.mark.parametrize("status_code,expected", [
    (200, "success"),
    (404, "not_found"),
    (500, "error"),
])
def test_handle_response(api_client, status_code, expected):
    api_client.get.return_value.status_code = status_code

    result = handle_api_response()

    assert result == expected
    api_client.get.assert_called_once()
```
