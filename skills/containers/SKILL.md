---
name: containers
description: Apply container-related preferences including Podman-first usage, rootless defaults, and container file naming conventions.
metadata:
  author: jonathan-tyler
  version: "1.0.2"
---

# Containers Skill

## Scope

- Applies to: `**/devcontainer.json`, `**/Dockerfile`, `**/Containerfile`,
  `**/docker-compose*.yml`, `**/docker-compose*.yaml`, `**/*.container`, `**/*.quadlet`

## Rules

- Use Podman commands and naming conventions instead of Docker.
  - Use `Containerfile` instead of `Dockerfile`.
- Prefer rootless containers.
