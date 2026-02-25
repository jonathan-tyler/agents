---
name: agent-skill-authoring
description: Create and validate Agent Skills using the SKILL.md format, required frontmatter, and practical structure. Use when defining new skills, splitting docs into skill files, or reviewing skill metadata and naming rules.
metadata:
  author: jonathan-tyler
  version: "1.0.9"
---

# Agent Skill Authoring

Use this skill when creating or reviewing Agent Skills.

## Rules

- Follow the Open Agent Skills specification: [references/specification.md](references/specification.md)
- Run validator script to quickly validate all skills: `bash scripts/validate_skill_frontmatter.sh <skills-dir>`
- Flag any values that look like personal data leaks (for example email addresses or local file paths with usernames)

## New Skills

- Place broadly reusable skills in `.agents/skills`; place project-specific skills or skills containing project-sensitive details in `.agents/local-skills`.
- Add the skill name to the .agents/README.md.  Avoid suggesting adding any other content to this file.
- Add reasonable but terse YAML frontmatter, an H1 header with the name of the skill, and an H2 "Rules" header with whatever the user asked you to add and/or nothing else.

## YAML Frontmatter

- Include `compatibility` only when the skill has concrete environment prerequisites; format it as a terse, comma-separated list of tools and/or glob paths (for example `**/*.py, python3`), and omit it otherwise.
- When changing any skill, bump `metadata.version` once for the current uncommitted change set; do not bump it again until those changes are committed.
- Enforce `metadata` sub-key validation: allowing only `author` and `version`.

