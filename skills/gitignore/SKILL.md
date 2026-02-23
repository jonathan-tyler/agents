---
name: gitignore
description: Enforce `.gitignore` safety preferences related to VS Code workspace directories.
compatibility: Personal coding preferences for environments using Agent Skills SKILL.md.
metadata:
  author: jonathan-tyler
  version: "1.0.1"
---

# Gitignore Skill

## Scope

- Applies to: `**/.gitignore`

## Resources

- Use [this sample](assets/.gitignore) as a starter template.

## Rules

- Never add `.vscode` or `.vscode/` to `.gitignore`.
- If `.vscode` or `.vscode/` is found in `.gitignore`, explicitly warn the user.
