---
name: docker-compose
description: Execute project commands inside Docker Compose services. Use when the project has a docker-compose.yml or compose.yml file and you need to run any project command (tests, linting, builds, migrations, scripts, etc.) inside the container.
---

# Docker Compose Execution

When working inside a repository that has a `docker-compose.yml` or `compose.yml` file, all project commands must run inside the appropriate service container, not on the host machine.

## How to Run Commands

### Step 1: Identify the service name

Read the compose file to find the correct service name:

```bash
cat docker-compose.yml
```

Look for the `services:` block. Common names are `api`, `web`, `app`.

### Step 2: Choose the right command pattern

Use `exec` when the service is already running:
```bash
docker compose exec <service> <command>
```

Use `run --rm` when the service is not running or for one-off commands:
```bash
docker compose run --rm <service> <command>
```

### Step 3: Run the command

Examples:
```bash
# Tests
docker compose exec api uv run pytest

# Linting
docker compose exec api uv run ruff format --check src/

# Migrations
docker compose exec web python manage.py migrate

# Single test
docker compose run --rm api uv run pytest tests/path/to/test_file.py::test_name
```

## Important Notes

- Always identify the correct service name from the compose file before running any command
- Never run project commands (tests, linting, migrations, etc.) directly on the host machine
- If `exec` fails because the service is not running, fall back to `run --rm`
