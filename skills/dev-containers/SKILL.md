---
name: dev-containers
description: Create and maintain Development Container configurations with practical defaults, predictable mounts, and container-engine-aware settings.
metadata:
    author: jonathan-tyler
    version: "1.0.3"
---

# Dev Containers Skill

- Use this skill when creating or updating a dev container
- Applies to: `**/.devcontainer/*`, `**/devcontainer.json`

## Resources

Use this [template](assets/devcontainer.json) as a base to build from.

## Container Images

- Prefer `dhi.io` base images, with the understanding that they may need extra configuration due to how locked-down they are.
- Use microsoft dev container images as a fallback

### Troubleshooting `dhi.io` Pull Errors

If users get an error like `image not known` for a `dhi.io/...` image, authenticate first and then pull explicitly:

```bash
podman login dhi.io
```

Use the `dhi.io` username and a login token as the password.

Then pull the image:

```bash
podman image pull dhi.io/debian-base:trixie-debian13-dev
```

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
