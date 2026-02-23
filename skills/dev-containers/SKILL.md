---
name: dev-containers
description: Create and maintain Development Container configurations with practical defaults, predictable mounts, and container-engine-aware settings.
compatibility: Designed for repositories that use the Agent Skills SKILL.md standard.
metadata:
    author: jonathan-tyler
    version: "1.0.0"
---

# Dev Containers Skill

- Use this skill when creating or updating a dev container
- Applies to: `**/.devcontainer/*`, `**/devcontainer.json`

## Resources

Use this [template](assets/devcontainer.json) as a base to build from.

## Container Images

- Prefer `dhi.io` base images, with the understanding that they may need extra configuration due to how locked-down they are.
- Use microsoft dev container images as a fallback

## Node Images

Add:

```json
"mounts": [
    "type=volume,source=pnpm,target=/home/developer/.pnpm"
],
"customizations": {
    "vscode": {
        "extensions": [
            "esbenp.prettier-vscode",
            "dbaeumer.vscode-eslint"
        ]
    }
}
```
