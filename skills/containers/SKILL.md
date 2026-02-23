---
name: containers
description: Apply container-related preferences including Podman-first usage, rootless defaults, and container file naming conventions.
compatibility: Personal coding preferences for environments using Agent Skills SKILL.md.
metadata:
  author: jonathan-tyler
  version: "1.0.1"
---

# Containers Skill

## Scope

- Applies to: `**/devcontainer.json`, `**/Dockerfile`, `**/Containerfile`,
  `**/docker-compose*.yml`, `**/docker-compose*.yaml`, `**/*.container`, `**/*.quadlet`

## Rules

- Use Podman commands and naming conventions instead of Docker.
  - Use `Containerfile` instead of `Dockerfile`.
- Prefer rootless containers.
