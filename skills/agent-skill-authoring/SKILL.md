---
name: agent-skill-authoring
description: Create and validate Agent Skills using the SKILL.md format, required frontmatter, and practical structure. Use when defining new skills, splitting docs into skill files, or reviewing skill metadata and naming rules.
metadata:
  author: jonathan-tyler
  version: "1.0.6"
---

# Agent Skill Authoring

Use this skill when creating or reviewing Agent Skills.

## Resources

- Run validator script: `python scripts/validate_skill_frontmatter.py <skills-dir>`
- Validator implementation: [scripts/validate_skill_frontmatter.py](scripts/validate_skill_frontmatter.py)
- Specification reference: [references/specification.md](references/specification.md)

## Specification

- See [the specification document](references/specification.md) for details.
- When changing any skill, bump `metadata.version` once for the current uncommitted change set; do not bump it again until those changes are committed.
- Include `compatibility` only when the skill has concrete environment prerequisites (for example required tools, packages, network access, or target platform); omit it otherwise.
- Place broadly reusable skills in `.agents/skills`; place project-specific skills or skills containing project-sensitive details in `.agents/local-skills`.
- For `.agents/README.md` only, avoid suggesting new content by default; only suggest updates when they clearly fit that README's existing structure and avoid unnecessary bloat.
- Enforce strict `metadata` validation to prevent surprise or personal-information-bearing fields: only `author` and `version` are allowed metadata keys.
- Reject values that look like personal data leaks (for example email addresses or local file paths) across all frontmatter string fields, including `metadata` values.
- For repository-level skill catalogs in `README.md`, group skills under `### Meta`, `### Init`, and `### Dev` subheaders; within each subheader, order entries as needed for clarity, use a single unique skill-related emoji before each unbulleted skill name, place one bulleted short description line directly beneath it, and include one blank line between entries.
