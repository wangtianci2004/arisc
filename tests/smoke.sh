#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

TEST_HOME="$TEST_ROOT/home"
WORKSPACE="$TEST_HOME/arisc"
TEST_REPO="${ARISC_TEST_UPSTREAM_REPO:-$WORKSPACE/aris-codex-skills}"
FAKE_BIN="$TEST_ROOT/bin"
mkdir -p "$TEST_HOME" "$FAKE_BIN"
mkdir -p "$WORKSPACE"
rsync -a \
  --exclude='/.git/' \
  --exclude='/projects/' \
  --exclude='/shared/' \
  --exclude='/reports/' \
  --exclude='/aris-codex-skills/' \
  --exclude='/.trash/' \
  --exclude='/config' \
  --exclude='/task_plan.md' \
  --exclude='/findings.md' \
  --exclude='/progress.md' \
  "$SOURCE_ROOT/" "$WORKSPACE/"
[[ -f "$WORKSPACE/templates/shared/env" ]]
[[ -f "$WORKSPACE/templates/shared/mcp.json" ]]

if [[ -z "${ARISC_TEST_UPSTREAM_REPO:-}" ]]; then
  mkdir -p "$TEST_REPO/tools" "$TEST_REPO/skills/skills-codex"
  git -C "$TEST_REPO" init -q
  cat > "$TEST_REPO/tools/install_aris_codex.sh" <<'INSTALLER'
#!/usr/bin/env bash
set -euo pipefail
project="$1"
mkdir -p "$project/.aris" "$project/.agents/skills"
printf 'project_root=%s\n' "$project" > "$project/.aris/installed-skills-codex.txt"
printf '# Test project\n' > "$project/AGENTS.md"
echo 'Install complete'
INSTALLER
  chmod +x "$TEST_REPO/tools/install_aris_codex.sh"
fi

cat > "$FAKE_BIN/uv" <<'UV'
#!/usr/bin/env bash
set -euo pipefail
[[ ${1:-} == "venv" ]] || { echo "unexpected uv call: $*" >&2; exit 2; }
mkdir -p .venv/bin
printf '#!/usr/bin/env bash\nexec python3 "$@"\n' > .venv/bin/python
chmod +x .venv/bin/python
UV
chmod +x "$FAKE_BIN/uv"

REAL_GIT_BIN="$(command -v git)"
cat > "$FAKE_BIN/git" <<'GIT_WRAPPER'
#!/usr/bin/env bash
set -euo pipefail
if [[ ${1:-} == "clone" ]]; then
  echo "unexpected network clone during isolated smoke test" >&2
  exit 97
fi
exec "$ARISC_TEST_REAL_GIT" "$@"
GIT_WRAPPER
chmod +x "$FAKE_BIN/git"

export HOME="$TEST_HOME"
export PATH="$FAKE_BIN:$TEST_HOME/.local/bin:$PATH"
export ARISC_TEST_REAL_GIT="$REAL_GIT_BIN"
unset WORKSPACE_ROOT ARIS_REPO

mkdir -p "$WORKSPACE/projects/.agents/skills"
ln -s "$WORKSPACE/templates/base/skills/aris-tail" "$WORKSPACE/projects/.agents/skills/aris-tail"

INSTALL_ARGS=(--yes --no-path --skip-doctor)
if [[ -n "${ARISC_TEST_UPSTREAM_REPO:-}" ]]; then
  INSTALL_ARGS+=(--repo-path "$TEST_REPO")
fi
"$WORKSPACE/install.sh" "${INSTALL_ARGS[@]}"

[[ -L "$TEST_HOME/.local/bin/arisc" ]]
[[ ! -L "$WORKSPACE/projects/.agents/skills/aris-tail" ]]
[[ ! -e "$TEST_HOME/.local/bin/aris" ]]
[[ ! -e "$WORKSPACE/bin/aris" ]]
[[ -f "$WORKSPACE/config" ]]
grep -Fq "ARIS_REPO=\"$TEST_REPO\"" "$WORKSPACE/config"
[[ "$TEST_REPO" == "$WORKSPACE/aris-codex-skills" || -n "${ARISC_TEST_UPSTREAM_REPO:-}" ]]
[[ "$(arisc --version)" == "arisc 0.1.0" ]]

arisc new reproducible-research >/dev/null
PROJECT="$WORKSPACE/projects/reproducible-research"
[[ -d "$PROJECT/.venv" ]]
[[ -L "$PROJECT/.env" ]]
[[ -L "$PROJECT/.mcp.json" ]]
[[ -f "$PROJECT/AGENTS.md" ]]
[[ -f "$PROJECT/RESEARCH_BRIEF.md" ]]
[[ -f "$PROJECT/.aris/installed-skills-codex.txt" ]]
[[ -d "$PROJECT/.git" ]]
[[ "$(arisc path reproducible-research)" == "$PROJECT" ]]

arisc ls --json | jq -e '.items[] | select(.name == "reproducible-research" and .type == "project")' >/dev/null
arisc status --json | jq -e '.workspace_root == $root' --arg root "$WORKSPACE" >/dev/null
arisc inspect reproducible-research --json | jq -e '.slug == "reproducible-research"' >/dev/null
arisc report --save --no-doctor >/dev/null
arisc reports --type report --json | jq -e '.count >= 1 and .items[0].size_bytes > 0' >/dev/null
WORKSPACE_ROOT="$WORKSPACE" arisc audit --json | jq -e '.ok == true' >/dev/null

arisc rename reproducible-research renamed-research --force >/dev/null
[[ -d "$WORKSPACE/projects/renamed-research" ]]
grep -Eq '^name = "renamed-research"[[:space:]]*$' "$WORKSPACE/projects/renamed-research/pyproject.toml"
arisc del renamed-research --force >/dev/null
arisc purge --all --force >/dev/null
[[ ! -e "$WORKSPACE/projects/renamed-research" ]]

echo "[OK] isolated install, project lifecycle, status, reports, and audit passed"
