# Global Development Guidelines

## Core Principles

### Communication

- Ask clarifying questions when multiple valid approaches exist before proceeding
- Explain trade-offs between approaches when relevant
- Confirm understanding of requirements for non-trivial changes

### Code Quality

**Readability over documentation**

- Write self-documenting code with meaningful variable and function names
- Extract complex logic into well-named functions instead of adding comments
- Avoid comments and docstrings; the code should speak for itself
- Naming of variables, functions, classes, etc should be clear and don't use abbreviations or acronyms

**Formatting standards**

- No unnecessary blank lines; use whitespace purposefully
- Keep imports at module level unless lazy loading is required
- Follow language-specific formatters (see [Tooling](#tooling))

## Git Safety Rules

### Protected Branches

The following branches are protected across all projects: `main`, `master`, `staging`

**Forbidden without explicit user request:**

- Direct commits or modifications
- `git push` commands
- Force pushes or history rewrites

**Required workflow:**

1. Create a feature branch from the target branch
2. Make changes on the feature branch
3. Request user approval before any merge or push to protected branches

## Development Environment

### General

- Try to avoid compound commands (pipes | or &&, etc), or with $() command substitution, to minimize asking for permissions.
- Avoid command that contains quoted characters in flag names.

### DevContainer Rule

If the project contains a `.devcontainer/` directory, use the `devcontainer` skill to locate the running container and execute ALL project commands (tests, linting, builds, migrations, etc.) inside it. Never run project commands on the host machine when a devcontainer is present.

### Docker Compose Environment Rule

If the project contains a `docker-compose.yml` or `compose.yml` file, ALL commands (tests, linting, formatting, migrations, scripts, etc.) MUST be executed inside the appropriate Docker Compose service container using `docker compose exec <service> <command>` or `docker compose run <service> <command>`. Never run project commands directly on the host machine. No exceptions.

Examples:

- Tests: `docker compose exec web python -m pytest`
- Formatting: `docker compose exec web black .`
- Migrations: `docker compose exec web python manage.py migrate`
- Linting: `docker compose exec web flake8`

Always identify the correct service name from the compose file before running any command.

### Package Management

- Never install packages at system level
- Always use virtual environments (.venv, nvm, etc.)
- Document dependencies in appropriate manifest files
- Identify the relevant package manager to manage project dependencies
- Manage dependencies using docker compose run <service> if available

### Tooling

| Language              | Formatter | Linter |
| --------------------- | --------- | ------ |
| Python                | black     | flake8 |
| JavaScript/TypeScript | prettier  | eslint |
| HTML                  | prettier  | -      |
| CSS/SCSS              | prettier  | -      |

## Workflow Agents

Use the appropriate agent for each task:

| Agent           | Purpose                |
| --------------- | ---------------------- |
| `code-writer`   | Implementing new code  |
| `code-reviewer` | Reviewing code changes |

## Useful skills

| Skill                       | Purpose                                                                          |
| --------------------------- | -------------------------------------------------------------------------------- |
| `implementation-workflow`   | Non-trivial code changes requiring planning                                      |
| `software-designer-mindset` | write/review code to use modern principles of software design                    |
| `devcontainer`              | Find and execute commands inside the VSCode devcontainer for the current project |

## Quick Reference

```
✓ Ask before choosing between valid approaches
✓ Use feature branches for all changes
✓ Self-documenting code, no comments
✓ Virtual environments for packages
✓ Run formatters before committing

✗ Push directly to main/master/staging
✗ System-level package installations
✗ Unnecessary blank lines or comments
✗ Top-level side effects in imports
```
