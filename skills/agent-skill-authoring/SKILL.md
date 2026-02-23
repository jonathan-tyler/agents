---
name: agent-skill-authoring
description: Create and validate Agent Skills using the SKILL.md format, required frontmatter, and practical structure. Use when defining new skills, splitting docs into skill files, or reviewing skill metadata and naming rules.
compatibility: Designed for repositories that use the Agent Skills SKILL.md standard.
metadata:
	author: jonathan-tyler
	version: "1.0.1"
---

# Agent Skill Authoring

Use this skill when creating or reviewing Agent Skills.

## Resources

- Run validator script: `python scripts/validate_skill_frontmatter.py <skills-dir>`
- Validator implementation: [scripts/validate_skill_frontmatter.py](scripts/validate_skill_frontmatter.py)
- Specification reference: [references/specification.md](references/specification.md)

## Specification

- See [the specification document](references/specification.md) for details.
- When changing any skill, bump `metadata.version` for that skill in the same update.
- For repository-level skill catalogs in `README.md`, group skills under `### Meta`, `### Init`, and `### Dev` subheaders; within each subheader, order entries as needed for clarity, use a single unique skill-related emoji before each unbulleted skill name, place one bulleted short description line directly beneath it, and include one blank line between entries.
