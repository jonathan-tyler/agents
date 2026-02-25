---
name: code-organization
description: Apply an onion-lite code organization with clear abstractions and minimal layering. Use when structuring or refactoring project layout and dependency boundaries.
metadata:
  author: jonathan-tyler
  version: "1.0.1"
---

# Code Organization Skill

## Rules

- Prefer a lightweight onion architecture with clear separation and minimal layers.
- Use `./src/core` for:
  - abstractions and interfaces
  - domain models
  - simple CRUDL functionality
- Keep `core` dependency-safe:
  - can import from standard library and other core modules
  - must not import external dependencies or infra-specific code
- Use `./src/infra` for dependency implementations, such as:
  - databases
  - API clients
  - file system integrations
- Allow `infra` to import from core and external dependencies.
- Do not import from application or interface layers into `infra`.
