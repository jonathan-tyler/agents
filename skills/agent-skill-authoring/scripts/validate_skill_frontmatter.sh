#!/usr/bin/env bash
set -euo pipefail

name_pattern='^[a-z0-9]+(-[a-z0-9]+)*$'
semver_pattern='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-((0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*)(\.(0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*))*))?(\+([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?$'

declare -a supported_top_level_keys=(
  name
  description
  license
  compatibility
  metadata
  allowed-tools
)

declare -a supported_metadata_keys=(
  author
  version
)

in_array() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

strip_quotes() {
  local value
  value="$(trim "$1")"
  if [[ ${#value} -ge 2 ]]; then
    if [[ ${value:0:1} == '"' && ${value: -1} == '"' ]]; then
      value="${value:1:${#value}-2}"
    elif [[ ${value:0:1} == "'" && ${value: -1} == "'" ]]; then
      value="${value:1:${#value}-2}"
    fi
  fi
  printf '%s' "$value"
}

detect_sensitive_value_kind() {
  local value="$1"

  if printf '%s\n' "$value" | grep -Eiq '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'; then
    printf '%s' 'email address'
    return 0
  fi

  local lower
  lower="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  if [[ "$lower" == file://* ]]; then
    printf '%s' 'local file path'
    return 0
  fi

  if printf '%s\n' "$value" | grep -Eq '(^~[/\\])|(^/)|(^[A-Za-z]:[/\\])|(^\\\\)|(/home/|/Users/|/mnt/|/etc/|/var/)'; then
    printf '%s' 'local file path'
    return 0
  fi

  return 1
}

join_sorted_csv() {
  local -a values=("$@")
  if [[ ${#values[@]} -eq 0 ]]; then
    printf '%s' ''
    return
  fi
  printf '%s\n' "${values[@]}" | sort -u | paste -sd ', ' -
}

parse_frontmatter() {
  local file_path="$1"
  local -n out_scalars_ref="$2"
  local -n out_maps_ref="$3"
  local -n out_map_parents_ref="$4"
  local -n out_error_ref="$5"

  out_scalars_ref=()
  out_maps_ref=()
  out_map_parents_ref=()
  out_error_ref=''

  local first_line
  first_line="$(head -n 1 "$file_path" 2>/dev/null || true)"
  if [[ -z "$first_line" ]]; then
    out_error_ref='missing content'
    return
  fi

  first_line="${first_line#$'\ufeff'}"
  if [[ "$first_line" != '---' ]]; then
    out_error_ref='missing frontmatter'
    return
  fi

  local end_index
  end_index="$(awk 'NR>1 && $0=="---" { print NR; exit }' "$file_path")"
  if [[ -z "$end_index" ]]; then
    out_error_ref='unterminated frontmatter'
    return
  fi

  local current_map_key=''
  local line_number=0
  while IFS= read -r raw_line; do
    line_number=$((line_number + 1))
    if (( line_number == 1 )); then
      continue
    fi
    if (( line_number >= end_index )); then
      break
    fi

    local stripped
    stripped="$(trim "$raw_line")"
    [[ -z "$stripped" ]] && continue
    [[ "$stripped" == \#* ]] && continue

    if [[ "$raw_line" =~ ^[[:space:]] ]]; then
      if [[ -z "$current_map_key" ]]; then
        continue
      fi
      if [[ "$stripped" != *:* ]]; then
        continue
      fi
      local child_key="${stripped%%:*}"
      local child_value="${stripped#*:}"
      child_key="$(trim "$child_key")"
      child_value="$(strip_quotes "$child_value")"
      out_maps_ref["${current_map_key}.${child_key}"]="$child_value"
      continue
    fi

    current_map_key=''
    if [[ "$stripped" != *:* ]]; then
      continue
    fi

    local key="${stripped%%:*}"
    local value="${stripped#*:}"
    key="$(trim "$key")"
    value="$(trim "$value")"

    if [[ -z "$value" ]]; then
      out_map_parents_ref["$key"]=1
      current_map_key="$key"
      continue
    fi

    out_scalars_ref["$key"]="$(strip_quotes "$value")"
  done < "$file_path"
}

validate_skill() {
  local skill_dir="$1"
  local skill_file="$skill_dir/SKILL.md"
  local -n issues_ref="$2"

  issues_ref=()

  if [[ ! -f "$skill_file" ]]; then
    issues_ref+=("missing SKILL.md")
    return
  fi

  local -A frontmatter_scalars=()
  local -A frontmatter_maps=()
  local -A frontmatter_map_parents=()
  local parse_error=''
  parse_frontmatter "$skill_file" frontmatter_scalars frontmatter_maps frontmatter_map_parents parse_error

  if [[ -n "$parse_error" ]]; then
    issues_ref+=("$parse_error")
    return
  fi

  local -a unknown_top_level=()
  local key
  for key in "${!frontmatter_scalars[@]}"; do
    if ! in_array "$key" "${supported_top_level_keys[@]}"; then
      unknown_top_level+=("$key")
    fi
  done
  for key in "${!frontmatter_map_parents[@]}"; do
    if ! in_array "$key" "${supported_top_level_keys[@]}"; then
      unknown_top_level+=("$key")
    fi
  done
  if [[ ${#unknown_top_level[@]} -gt 0 ]]; then
    issues_ref+=("unsupported top-level frontmatter field(s): $(join_sorted_csv "${unknown_top_level[@]}")")
  fi

  local name="${frontmatter_scalars[name]-}"
  local description="${frontmatter_scalars[description]-}"
  local dir_name
  dir_name="$(basename "$skill_dir")"

  if [[ -z "$name" ]]; then
    issues_ref+=("missing name")
  else
    local sensitive_kind=''
    if sensitive_kind="$(detect_sensitive_value_kind "$name")"; then
      issues_ref+=("name must not contain $sensitive_kind")
    fi
    if (( ${#name} < 1 || ${#name} > 64 )); then
      issues_ref+=("name length out of range (1-64)")
    fi
    if [[ ! "$name" =~ $name_pattern ]]; then
      issues_ref+=("name pattern invalid")
    fi
    if [[ "$name" != "$dir_name" ]]; then
      issues_ref+=("name does not match dir ($name != $dir_name)")
    fi
  fi

  if [[ -z "$description" ]]; then
    issues_ref+=("missing description")
  else
    local sensitive_kind=''
    if sensitive_kind="$(detect_sensitive_value_kind "$description")"; then
      issues_ref+=("description must not contain $sensitive_kind")
    fi
    if (( ${#description} > 1024 )); then
      issues_ref+=("description too long (>1024)")
    fi
  fi

  local has_compatibility=0
  local compatibility=''
  if [[ -n ${frontmatter_scalars[compatibility]+x} ]]; then
    has_compatibility=1
    compatibility="${frontmatter_scalars[compatibility]}"
  elif [[ -n ${frontmatter_map_parents[compatibility]+x} ]]; then
    issues_ref+=("compatibility must be a string")
    has_compatibility=1
    compatibility=''
  fi
  if (( has_compatibility )); then
    local sensitive_kind=''
    if sensitive_kind="$(detect_sensitive_value_kind "$compatibility")"; then
      issues_ref+=("compatibility must not contain $sensitive_kind")
    fi
    if (( ${#compatibility} < 1 || ${#compatibility} > 500 )); then
      issues_ref+=("compatibility length out of range (1-500)")
    fi
  fi

  if [[ -n ${frontmatter_scalars[license]+x} ]]; then
    local license_value="${frontmatter_scalars[license]}"
    local sensitive_kind=''
    if sensitive_kind="$(detect_sensitive_value_kind "$license_value")"; then
      issues_ref+=("license must not contain $sensitive_kind")
    fi
    if [[ -z "$(trim "$license_value")" ]]; then
      issues_ref+=("license must be non-empty if provided")
    fi
  elif [[ -n ${frontmatter_map_parents[license]+x} ]]; then
    issues_ref+=("license must be a string")
  fi

  local metadata_is_present=0
  if [[ -n ${frontmatter_map_parents[metadata]+x} ]]; then
    metadata_is_present=1
  elif [[ -n ${frontmatter_scalars[metadata]+x} ]]; then
    issues_ref+=("metadata must be a key-value map")
  fi

  if (( metadata_is_present )); then
    local -a unknown_metadata=()
    local meta_key
    local meta_value
    for key in "${!frontmatter_maps[@]}"; do
      if [[ "$key" == metadata.* ]]; then
        meta_key="${key#metadata.}"
        meta_value="${frontmatter_maps[$key]}"
        if [[ -z "$meta_key" ]]; then
          issues_ref+=("metadata keys must be non-empty strings")
          continue
        fi
        if ! in_array "$meta_key" "${supported_metadata_keys[@]}"; then
          unknown_metadata+=("$meta_key")
        fi
        local sensitive_kind=''
        if sensitive_kind="$(detect_sensitive_value_kind "$meta_value")"; then
          issues_ref+=("metadata value for '$meta_key' must not contain $sensitive_kind")
        fi
      fi
    done

    if [[ ${#unknown_metadata[@]} -gt 0 ]]; then
      issues_ref+=("unsupported metadata field(s): $(join_sorted_csv "${unknown_metadata[@]}")")
    fi

    if [[ -n ${frontmatter_maps[metadata.version]+x} ]]; then
      local version_value="${frontmatter_maps[metadata.version]}"
      if [[ ! "$version_value" =~ $semver_pattern ]]; then
        issues_ref+=("metadata.version must be valid SemVer (e.g. 1.0.0)")
      fi
    fi
  fi

  if [[ -n ${frontmatter_scalars[allowed-tools]+x} ]]; then
    local allowed_tools="${frontmatter_scalars[allowed-tools]}"
    local sensitive_kind=''
    if sensitive_kind="$(detect_sensitive_value_kind "$allowed_tools")"; then
      issues_ref+=("allowed-tools must not contain $sensitive_kind")
    fi
    if [[ -z "$(trim "$allowed_tools")" ]]; then
      issues_ref+=("allowed-tools must be non-empty if provided")
    fi
  elif [[ -n ${frontmatter_map_parents[allowed-tools]+x} ]]; then
    issues_ref+=("allowed-tools must be a string")
  fi

  local line_count
  line_count="$(awk 'END { print NR }' "$skill_file")"
  if (( line_count > 500 )); then
    issues_ref+=("SKILL.md exceeds 500 lines (recommended limit)")
  fi
}

find_skill_dirs() {
  local root="$1"
  local -n out_dirs_ref="$2"
  out_dirs_ref=()

  if [[ -f "$root/SKILL.md" ]]; then
    out_dirs_ref+=("$root")
    return
  fi

  while IFS= read -r skill_dir; do
    out_dirs_ref+=("$skill_dir")
  done < <(find "$root" -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/SKILL.md' ';' -print | sort)
}

main() {
  local path="${1:-.}"
  local root
  root="$(realpath "$path" 2>/dev/null || true)"

  if [[ -z "$root" || ! -e "$root" ]]; then
    printf '%s\n' "error: path does not exist: ${path}"
    return 2
  fi

  local -a skill_dirs=()
  find_skill_dirs "$root" skill_dirs
  if [[ ${#skill_dirs[@]} -eq 0 ]]; then
    printf '%s\n' "error: no skills found under ${root}"
    return 2
  fi

  local has_issues=0
  local skill_dir
  for skill_dir in "${skill_dirs[@]}"; do
    local -a issues=()
    validate_skill "$skill_dir" issues
    if [[ ${#issues[@]} -gt 0 ]]; then
      has_issues=1
      printf '%s\n' "$(basename "$skill_dir"): FAIL"
      local issue
      for issue in "${issues[@]}"; do
        printf '  - %s\n' "$issue"
      done
    else
      printf '%s\n' "$(basename "$skill_dir"): OK"
    fi
  done

  if (( has_issues )); then
    return 1
  fi
  return 0
}

main "$@"