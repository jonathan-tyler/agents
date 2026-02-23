---
name: javascript
description: Apply JavaScript and TypeScript tooling defaults for package management, linting, formatting, and dev containers. Use when creating or updating JS/TS projects, tooling, or workspace setup.
compatibility: Personal coding preferences for environments using Agent Skills SKILL.md.
metadata:
  author: jonathan-tyler
  version: "1.0.0"
  migratedFrom: /mnt/c/Users/daily/AppData/Roaming/Code/User/prompts/javascript.instructions.md
---

# JavaScript Skill

## Scope

- Applies to: `**/*.{js,jsx,mjs,cjs,ts,tsx}`

## Rules

- Prefer `pnpm` when package-manager choice is open.
  artifact and mount the `pnpm` volume to the workspace's `.pnpm` directory.
- Use `eslint` with the `eslint:recommended` ruleset, and extend it with `prettier`
  configuration to avoid conflicts with `prettier` formatting.
- Use `prettier` with a maximum line length of 100 characters, and configure it to
  work with `eslint` via `eslint-plugin-prettier`.
