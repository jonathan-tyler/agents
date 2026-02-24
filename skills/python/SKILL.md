---
name: python
description: Apply Python coding and testing preferences, including type hints and pytest conventions. Use when creating, reviewing, or refactoring Python code and tests.
compatibility: Requires Python 3; pytest is required when running the testing guidance in this skill.
metadata:
  author: jonathan-tyler
  version: "1.0.2"
---

# Python Skill

## Scope

- Applies to: `**/*.py`

## Code Style Guidelines

- Use type hints and validate.
- Use pytest for testing, and organize tests in a `tests` directory with test files
  named `test_*.py`.

## Common Voice Input Typos

- `pycache`: `(PI|py|π) (cache|cash|catch)`
- `pylance`: `(PI|py|π) (lance|lands)`
- `pytest`: `(PI|py|π) (test|tests)`
- `venv`: `(VNV)`
