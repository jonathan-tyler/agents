---
name: repository-bootstrap
description: Create a consistent baseline for a new project or repository. Use when initializing or scaffolding a repo.
metadata:
  author: jonathan-tyler
  version: "1.0.2"
---

# Repository Bootstrap Skill

Use this skill when creating a new project or a new repository.

## Scope

- Applies to: new repositories and first-commit scaffolding

## Required Baseline

Each new repository should typically include:

- `.gitignore` (from template)
- `.devcontainer/devcontainer.json` (from template)
- `.devcontainer/Containerfile` (from template)
- `README.md`

## Template Sources

Use these existing templates:

- `.gitignore`: `../gitignore/assets/.gitignore`
- Dev container config: `../dev-containers/assets/devcontainer.json`
- Dev container Containerfile: `../dev-containers/assets/Containerfile`

Optional companion file when using the template setup:

- `.devcontainer/settings.json` from `../dev-containers/assets/settings.json`

## README.md Guidance

- Add project purpose and status.
- Include setup and run commands.
- Include testing/linting commands when applicable.

## Working Rule

- If a user requests a minimal setup, still include all baseline files above unless they explicitly opt out.