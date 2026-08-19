#!/usr/bin/env bash
set -uo pipefail

SOURCE_ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILURES=0

fail() {
  echo "[FAIL] $*" >&2
  FAILURES=$((FAILURES + 1))
}

[[ ! -e "$SOURCE_ROOT/bin/aris-happy" ]] || fail "deprecated arisc happy implementation still exists"
[[ ! -e "$SOURCE_ROOT/bin/aris-tail" ]] || fail "unimplemented arisc tail implementation still exists"
[[ ! -d "$SOURCE_ROOT/templates/base/skills/aris-tail" ]] || fail "deprecated aris-tail control skill directory still exists"

if bash "$SOURCE_ROOT/bin/arisc" completion bash 2>/dev/null | grep -Fq 'complete -F _arisc arisc'; then
  :
else
  fail "Bash completion is unavailable"
fi

if bash "$SOURCE_ROOT/bin/arisc" completion zsh 2>/dev/null | grep -Fq '#compdef arisc'; then
  :
else
  fail "Zsh completion is unavailable"
fi

if grep -Fq -- 'submodule update --init --remote' "$SOURCE_ROOT/bin/aris-update" "$SOURCE_ROOT/bin/aris-repo"; then
  fail "user-facing submodule update still follows unpinned remote HEAD"
fi

if [[ ! -x "$SOURCE_ROOT/uninstall.sh" ]]; then
  fail "uninstall.sh is missing or not executable"
else
  TEST_ROOT="$(mktemp -d)"
  TEST_HOME="$TEST_ROOT/home"
  WORKSPACE="$TEST_HOME/arisc"
  mkdir -p "$TEST_HOME/.local/bin" "$WORKSPACE"
  rsync -a \
    --exclude='/.git/' \
    --exclude='/aris-codex-skills/' \
    --exclude='/projects/' \
    --exclude='/shared/' \
    --exclude='/reports/' \
    --exclude='/.trash/' \
    --exclude='/config' \
    "$SOURCE_ROOT/" "$WORKSPACE/"
  mkdir -p "$WORKSPACE/projects/demo" "$WORKSPACE/shared" "$WORKSPACE/reports" "$WORKSPACE/.trash"
  printf 'research\n' > "$WORKSPACE/projects/demo/result.txt"
  printf 'SECRET_VALUE\n' > "$WORKSPACE/shared/env"
  printf 'report\n' > "$WORKSPACE/reports/latest.md"
  printf 'ARIS_REPO="%s"\n' "$WORKSPACE/aris-codex-skills" > "$WORKSPACE/config"
  ln -s "$WORKSPACE/bin/arisc" "$TEST_HOME/.local/bin/arisc"
  cat > "$TEST_HOME/.bashrc" <<'RC'
before-arisc
# >>> aris-codex workspace >>>
export PATH="$HOME/.local/bin:$PATH"
# <<< aris-codex workspace <<<
after-arisc
RC

  if HOME="$TEST_HOME" "$WORKSPACE/uninstall.sh" --keep-data --yes >/dev/null; then
    [[ ! -e "$WORKSPACE" ]] || fail "workspace remains after uninstall"
    [[ ! -e "$TEST_HOME/.local/bin/arisc" ]] || fail "global arisc link remains after uninstall"
    grep -Fq 'before-arisc' "$TEST_HOME/.bashrc" || fail "shell rc content before managed block was lost"
    grep -Fq 'after-arisc' "$TEST_HOME/.bashrc" || fail "shell rc content after managed block was lost"
    ! grep -Fq 'aris-codex workspace' "$TEST_HOME/.bashrc" || fail "managed shell rc block remains"
    shopt -s nullglob
    data_dirs=("$TEST_HOME"/arisc-data-*)
    shopt -u nullglob
    [[ ${#data_dirs[@]} -eq 1 ]] || fail "preserved data directory was not created exactly once"
    if [[ ${#data_dirs[@]} -eq 1 ]]; then
      [[ -f "${data_dirs[0]}/projects/demo/result.txt" ]] || fail "project data was not preserved"
      [[ -f "${data_dirs[0]}/shared/env" ]] || fail "shared configuration was not preserved"
    fi
  else
    fail "uninstall.sh --keep-data --yes failed"
  fi
  rm -rf "$TEST_ROOT"
fi

if [[ $FAILURES -gt 0 ]]; then
  echo "[FAIL] $FAILURES CLI feature checks failed" >&2
  exit 1
fi

echo "[OK] deprecated commands, pinned updates, completion, and uninstall passed"
