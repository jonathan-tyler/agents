---
name: markdown
description: Write and refine Markdown documents that are easy to scan, with key links surfaced early for both humans and agents.
compatibility: Designed for coding agents and chat implementations that support the Agent Skills SKILL.md format.
metadata:
  author: jonathan-tyler
  version: "1.0.0"
---

# Markdown Documentation Skill

## Core preference

- Add a `## Resources` section near the top of the document (immediately after title/summary when possible).
- Put important navigation and reference links in `## Resources` so readers do not need to scan to the end.
- Keep resource labels short and descriptive, and prioritize action-oriented links first.
- When applicable, include implementation guardrails links early (example: `AGENTS.md`).

## Suggested `Resources` shape

```md
## Resources

- [Implementation Guardrails](AGENTS.md)
- [Usage Guide](README.md)
- [Roadmap](TODO.md)
```
