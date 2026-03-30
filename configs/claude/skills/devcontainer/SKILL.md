---
name: devcontainer
description: Locate and execute commands inside the VSCode devcontainer for the current repository. Use when you need to run tests, linting, builds, or any project command inside the devcontainer environment. Triggers when the user asks to run commands inside the devcontainer, or when the current project has a .devcontainer/ directory and commands should run inside the container.
---

# DevContainer Access

When working inside a repository that has a `.devcontainer/` configuration, all project commands must run inside the devcontainer rather than the host machine.

## How to Find and Use the DevContainer

### Step 1: Identify the repository name

The repository name is the basename of the current working directory. For example:
- `/Users/user/repos/mobility` → repo name is `mobility`
- `/Users/user/repos/platform` → repo name is `platform`

### Step 2: Find the running container

VSCode devcontainers follow this naming pattern for their image:
```
vsc-{repo-name}-{hash}-features
```

Run `docker ps` and look for a container whose IMAGE column starts with `vsc-{repo-name}-`.

Example:
```bash
docker ps
# Look for: vsc-mobility-abc123...-features → container name might be "festive_swartz"
```

### Step 3: Get the remote user

Read `.devcontainer/devcontainer.json` in the repository root and find the `remoteUser` field. This is typically `vscode`.

```bash
git grep remoteUser -- .devcontainer/devcontainer.json
# or
grep remoteUser .devcontainer/devcontainer.json
```

### Step 4: Execute commands inside the container

The workspace is always mounted at `/workspaces/{repo-name}` inside the container.

Use this pattern to run commands:
```bash
docker exec -u {remoteUser} -w /workspaces/{repo-name} {container-name} sh -c "{command}"
```

Example:
```bash
docker exec -u vscode -w /workspaces/mobility festive_swartz sh -c "make test"
```

## Important Notes

- Always use `sh -c "{command}"` to run commands, not bash directly (bash may not be available or configured the same way)
- The working directory inside the container is `/workspaces/{repo-name}`, not the host path
- If no matching container is found, the devcontainer is not running — ask the user to open the project in VSCode with "Reopen in Container"
- If `remoteUser` is not set in `devcontainer.json`, default to `vscode`
- Never run project commands (tests, linting, migrations, etc.) on the host — always use the devcontainer

## Quick Reference

```bash
# 1. Find the container
docker ps

# 2. Get remote user
grep remoteUser .devcontainer/devcontainer.json

# 3. Run a command
docker exec -u vscode -w /workspaces/{repo-name} {container} sh -c "{command}"
```
