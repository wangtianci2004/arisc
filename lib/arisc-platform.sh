#!/usr/bin/env bash
# Cross-platform helpers for GNU/Linux and BSD/macOS userlands.

arisc_stat_mtime() {
  local path="$1"
  if stat -c '%Y' "$path" >/dev/null 2>&1; then
    stat -c '%Y' "$path"
  else
    stat -f '%m' "$path"
  fi
}

arisc_stat_size() {
  local path="$1"
  if stat -c '%s' "$path" >/dev/null 2>&1; then
    stat -c '%s' "$path"
  else
    stat -f '%z' "$path"
  fi
}

arisc_date_from_epoch() {
  local epoch="$1" format="$2"
  if date -d "@$epoch" "+$format" >/dev/null 2>&1; then
    date -d "@$epoch" "+$format"
  else
    date -r "$epoch" "+$format"
  fi
}

arisc_realpath() {
  local source="$1" dir target
  if command -v realpath >/dev/null 2>&1; then
    realpath "$source" 2>/dev/null && return 0
  fi
  if readlink -f "$source" >/dev/null 2>&1; then
    readlink -f "$source" 2>/dev/null && return 0
  fi

  while [[ -L "$source" ]]; do
    dir="$(cd -P "$(dirname "$source")" 2>/dev/null && pwd)" || return 1
    target="$(readlink "$source")" || return 1
    if [[ "$target" == /* ]]; then
      source="$target"
    else
      source="$dir/$target"
    fi
  done
  dir="$(cd -P "$(dirname "$source")" 2>/dev/null && pwd)" || return 1
  printf '%s/%s\n' "$dir" "$(basename "$source")"
}

arisc_run_with_timeout() {
  local seconds="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$seconds" "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$seconds" "$@"
  else
    "$@"
  fi
}

arisc_latest_mtime_depth() {
  local root="$1" max_depth="$2" path relative part mtime latest=0
  local had_dotglob=false had_nullglob=false skip
  local -a paths=() parts=()

  [[ -d "$root" ]] || return 0
  shopt -q dotglob && had_dotglob=true
  shopt -q nullglob && had_nullglob=true
  shopt -s dotglob nullglob

  paths+=("$root"/*)
  (( max_depth >= 2 )) && paths+=("$root"/*/*)
  (( max_depth >= 3 )) && paths+=("$root"/*/*/*)

  for path in "${paths[@]}"; do
    [[ -f "$path" ]] || continue
    relative="${path#"$root"/}"
    IFS='/' read -r -a parts <<<"$relative"
    skip=false
    for part in "${parts[@]}"; do
      case "$part" in
        .git|.venv|.aris|.agents|.codex|research-wiki) skip=true; break ;;
      esac
    done
    $skip && continue
    mtime="$(arisc_stat_mtime "$path" 2>/dev/null || printf '0')"
    [[ "$mtime" =~ ^[0-9]+$ ]] || mtime=0
    (( mtime > latest )) && latest="$mtime"
  done

  $had_dotglob || shopt -u dotglob
  $had_nullglob || shopt -u nullglob
  (( latest > 0 )) && printf '%s\n' "$latest"
}

arisc_files_by_mtime() {
  local directory="$1"
  shift
  local file name pattern matched mtime
  local had_nullglob=false
  local -a rows=()

  [[ -d "$directory" ]] || return 0
  shopt -q nullglob && had_nullglob=true
  shopt -s nullglob
  for file in "$directory"/*; do
    [[ -f "$file" ]] || continue
    name="$(basename "$file")"
    matched=false
    for pattern in "$@"; do
      # Pattern matching is intentional; patterns are internal constants.
      # shellcheck disable=SC2053
      if [[ "$name" == $pattern ]]; then
        matched=true
        break
      fi
    done
    $matched || continue
    mtime="$(arisc_stat_mtime "$file")"
    rows+=("$mtime"$'\t'"$file")
  done
  $had_nullglob || shopt -u nullglob

  if [[ ${#rows[@]} -gt 0 ]]; then
    printf '%s\n' "${rows[@]}" | sort -nr | cut -f2-
  fi
}
