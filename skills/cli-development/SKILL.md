---
name: cli-development
description: Design and implement robust command-line interfaces with clear help text, reliable flags, predictable output, and correct exit behavior. Use when creating or improving CLI tools in any language.
compatibility: Designed for coding agents and chat implementations that support the Agent Skills SKILL.md format.
metadata:
  author: jonathan-tyler
  version: "1.0.0"
---

# CLI Development Skill

## When to use

- Creating or extending CLI tools
- Defining commands, flags, help, and exit behavior
- Improving scriptability and reliability

## Objectives

- Fast startup
- Predictable UX
- Script-friendly behavior
- Minimal dependency footprint

## Command design checklist

- Define root command and subcommand responsibilities.
- Prefer positional arguments over `--flag` options where appropriate.
- Define flags/options, defaults, and validation.
- Provide clear help examples.
- Document config precedence: flags > env > config file > defaults.

## UX and reliability rules

- Keep `--help` concise and actionable.
- Print normal output to stdout and diagnostics/errors to stderr.
- Return meaningful non-zero exit codes on failure.
- Avoid hidden global state and non-deterministic behavior.
- Minimize startup work for short-lived commands.

## Testing focus

- Argument parsing behavior
- Success and failure paths
- Edge cases and invalid input

## Output expectations

- Command structure summary.
- Implementation and tests.
- Usage examples.
- Packaging/release notes when distribution matters.
