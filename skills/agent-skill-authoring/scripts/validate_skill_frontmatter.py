#!/usr/bin/env python3
import argparse
import re
from pathlib import Path


NAME_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
SEMVER_PATTERN = re.compile(
    r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)"
    r"(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?"
    r"(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"
)
SUPPORTED_TOP_LEVEL_KEYS = {
    "name",
    "description",
    "license",
    "compatibility",
    "metadata",
    "allowed-tools",
}
SUPPORTED_METADATA_KEYS = {
    "author",
    "version",
}
EMAIL_PATTERN = re.compile(r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b")
LOCAL_PATH_PATTERN = re.compile(
    r"(^~[/\\])|(^/)|(^[A-Za-z]:[/\\])|(^\\\\)|(/home/|/Users/|/mnt/|/etc/|/var/)"
)


def _strip_quotes(value: str) -> str:
    return value.strip().strip('"').strip("'")


def _detect_sensitive_value_kind(value: str) -> str | None:
    if EMAIL_PATTERN.search(value):
        return "email address"

    if value.lower().startswith("file://"):
        return "local file path"

    if LOCAL_PATH_PATTERN.search(value):
        return "local file path"

    return None


def parse_frontmatter(text: str) -> tuple[dict[str, str | dict[str, str]], str | None]:
    lines = text.splitlines()
    if not lines:
        return {}, "missing content"

    first_line = lines[0].lstrip("\ufeff")
    if first_line != "---":
        return {}, "missing frontmatter"

    end_index = None
    for index in range(1, len(lines)):
        if lines[index] == "---":
            end_index = index
            break

    if end_index is None:
        return {}, "unterminated frontmatter"

    frontmatter: dict[str, str | dict[str, str]] = {}
    current_map_key: str | None = None

    for raw_line in lines[1:end_index]:
        if not raw_line.strip():
            continue
        if raw_line.lstrip().startswith("#"):
            continue

        is_indented = bool(re.match(r"^\s", raw_line))
        line = raw_line.strip()

        if is_indented:
            if current_map_key is None:
                continue
            if ":" not in line:
                continue
            child_key, child_value = line.split(":", 1)
            parent_value = frontmatter.get(current_map_key)
            if isinstance(parent_value, dict):
                parent_value[child_key.strip()] = _strip_quotes(child_value)
            continue

        current_map_key = None
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        value = value.strip()

        if not value:
            frontmatter[key] = {}
            current_map_key = key
            continue

        frontmatter[key] = _strip_quotes(value)

    return frontmatter, None


def validate_skill(skill_dir: Path) -> list[str]:
    issues: list[str] = []
    skill_file = skill_dir / "SKILL.md"

    if not skill_file.is_file():
        return ["missing SKILL.md"]

    text = skill_file.read_text(encoding="utf-8")
    frontmatter, parse_error = parse_frontmatter(text)
    if parse_error:
        issues.append(parse_error)
        return issues

    unknown_top_level_keys = sorted(
        key for key in frontmatter if key not in SUPPORTED_TOP_LEVEL_KEYS
    )
    if unknown_top_level_keys:
        issues.append(
            "unsupported top-level frontmatter field(s): "
            + ", ".join(unknown_top_level_keys)
        )

    name = frontmatter.get("name")
    description = frontmatter.get("description")

    if name and not isinstance(name, str):
        issues.append("name must be a string")
        name = ""
    if description and not isinstance(description, str):
        issues.append("description must be a string")
        description = ""

    name = name or ""
    description = description or ""

    if not name:
        issues.append("missing name")
    else:
        sensitive_kind = _detect_sensitive_value_kind(name)
        if sensitive_kind is not None:
            issues.append(f"name must not contain {sensitive_kind}")
        if not (1 <= len(name) <= 64):
            issues.append("name length out of range (1-64)")
        if not NAME_PATTERN.match(name):
            issues.append("name pattern invalid")
        if name != skill_dir.name:
            issues.append(f"name does not match dir ({name} != {skill_dir.name})")

    if not description:
        issues.append("missing description")
    else:
        sensitive_kind = _detect_sensitive_value_kind(description)
        if sensitive_kind is not None:
            issues.append(f"description must not contain {sensitive_kind}")
        if len(description) > 1024:
            issues.append("description too long (>1024)")

    compatibility = frontmatter.get("compatibility")
    if compatibility is not None and not isinstance(compatibility, str):
        issues.append("compatibility must be a string")
        compatibility = ""
    if compatibility is not None:
        sensitive_kind = _detect_sensitive_value_kind(compatibility)
        if sensitive_kind is not None:
            issues.append(f"compatibility must not contain {sensitive_kind}")
        if not (1 <= len(compatibility) <= 500):
            issues.append("compatibility length out of range (1-500)")

    license_value = frontmatter.get("license")
    if license_value is not None:
        if not isinstance(license_value, str):
            issues.append("license must be a string")
        else:
            sensitive_kind = _detect_sensitive_value_kind(license_value)
            if sensitive_kind is not None:
                issues.append(f"license must not contain {sensitive_kind}")
            if not license_value.strip():
                issues.append("license must be non-empty if provided")

    metadata = frontmatter.get("metadata")
    if metadata is not None and not isinstance(metadata, dict):
        issues.append("metadata must be a key-value map")
    elif isinstance(metadata, dict):
        unknown_metadata_keys = sorted(
            meta_key for meta_key in metadata if meta_key not in SUPPORTED_METADATA_KEYS
        )
        if unknown_metadata_keys:
            issues.append(
                "unsupported metadata field(s): " + ", ".join(unknown_metadata_keys)
            )

        for meta_key, meta_value in metadata.items():
            if not meta_key:
                issues.append("metadata keys must be non-empty strings")
                continue
            if not isinstance(meta_value, str):
                issues.append(
                    f"metadata value for '{meta_key}' must be a string"
                )
                continue

            sensitive_kind = _detect_sensitive_value_kind(meta_value)
            if sensitive_kind is not None:
                issues.append(
                    f"metadata value for '{meta_key}' must not contain {sensitive_kind}"
                )

        version = metadata.get("version")
        if version is not None:
            if not isinstance(version, str):
                issues.append("metadata.version must be a string")
            elif not SEMVER_PATTERN.match(version):
                issues.append("metadata.version must be valid SemVer (e.g. 1.0.0)")

    allowed_tools = frontmatter.get("allowed-tools")
    if allowed_tools is not None:
        if not isinstance(allowed_tools, str):
            issues.append("allowed-tools must be a string")
        else:
            sensitive_kind = _detect_sensitive_value_kind(allowed_tools)
            if sensitive_kind is not None:
                issues.append(f"allowed-tools must not contain {sensitive_kind}")
            if not allowed_tools.strip():
                issues.append("allowed-tools must be non-empty if provided")

    line_count = text.count("\n") + 1
    if line_count > 500:
        issues.append("SKILL.md exceeds 500 lines (recommended limit)")

    return issues


def find_skill_dirs(root: Path) -> list[Path]:
    if (root / "SKILL.md").is_file():
        return [root]
    return sorted(
        child
        for child in root.iterdir()
        if child.is_dir() and (child / "SKILL.md").is_file()
    )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate target skill directories by checking each SKILL.md frontmatter and basic specification constraints."
    )
    parser.add_argument(
        "path",
        nargs="?",
        default=".",
        help="Path to a skill directory or a directory containing multiple skills.",
    )
    args = parser.parse_args()

    root = Path(args.path).resolve()
    if not root.exists():
        print(f"error: path does not exist: {root}")
        return 2

    skill_dirs = find_skill_dirs(root)
    if not skill_dirs:
        print(f"error: no skills found under {root}")
        return 2

    has_issues = False
    for skill_dir in skill_dirs:
        issues = validate_skill(skill_dir)
        if issues:
            has_issues = True
            print(f"{skill_dir.name}: FAIL")
            for issue in issues:
                print(f"  - {issue}")
        else:
            print(f"{skill_dir.name}: OK")

    return 1 if has_issues else 0


if __name__ == "__main__":
    raise SystemExit(main())
