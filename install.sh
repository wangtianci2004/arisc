#!/usr/bin/env bash
# install.sh：在当前机器上初始化 ARIS-Codex 工作区。

if (( BASH_VERSINFO[0] < 4 )); then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    for modern_bash in /opt/homebrew/bin/bash /usr/local/bin/bash; do
      if [[ -x "$modern_bash" ]]; then
        exec "$modern_bash" "$0" "$@"
      fi
    done
    echo "[ERROR] ARISC 需要 Bash 4.4+；请先运行：brew install bash" >&2
  else
    echo "[ERROR] ARISC 需要 Bash 4.4+，当前版本：$BASH_VERSION" >&2
  fi
  exit 1
fi
set -euo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$HOME/arisc"

DO_PATH=true
DO_REPO=true
DO_DOCTOR=true
AUTO_INSTALL_UV=false
REPO_PATH=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-path) DO_PATH=false ;;
    --skip-repo) DO_REPO=false ;;
    --skip-doctor) DO_DOCTOR=false ;;
    --install-uv) AUTO_INSTALL_UV=true ;;
    --yes|-y) AUTO_INSTALL_UV=true ;;
    --repo-path)
      [[ $# -ge 2 ]] || { echo "[ERROR] --repo-path 需要一个路径" >&2; exit 2; }
      REPO_PATH="$2"
      shift
      ;;
    --help|-h)
      cat <<'EOF'
用法：install.sh [options]

作用：
  初始化当前 ARIS-Codex 工作区：
  - 创建 projects/ 和 shared/
  - 注册全局 arisc -> 当前工作区 bin/arisc
  - 注册全局 arisc 命令
  - 初始化 shared/env 和 shared/mcp.json
  - 非交互配置 ARIS Codex 研究技能仓库
  - 默认把 ~/.local/bin 写入当前 shell rc
  - 物化 base 环境并运行 doctor 检查

平台：
  Linux / WSL2：需要 Bash 4.4+
  macOS：先运行 `brew install bash jq tmux uv`；安装器会自动切换 Homebrew Bash

选项：
  -y, --yes         一键模式；缺少 uv 时通过官方安装器安装
  --install-uv      缺少 uv 时通过官方安装器安装
  --repo-path PATH  指定 ARIS 研究技能仓库路径
  --skip-repo       跳过 ARIS 研究技能仓库配置
  --skip-doctor     跳过最终 doctor 检查
  --no-path         不修改 shell rc，只注册 ~/.local/bin/arisc
EOF
      exit 0
      ;;
    *) echo "[ERROR] 未知参数：$1" >&2; exit 2 ;;
  esac
  shift
done

echo "[INFO] 安装 ARIS-Codex 工作区：$WORKSPACE_ROOT"

mkdir -p "$WORKSPACE_ROOT/projects" "$WORKSPACE_ROOT/shared"
echo "[INFO] 已确保 projects/ shared/"

USER_BIN="$HOME/.local/bin"
GLOBAL_ARISC="$USER_BIN/arisc"
mkdir -p "$USER_BIN"
if [[ -e "$GLOBAL_ARISC" && ! -L "$GLOBAL_ARISC" ]]; then
  echo "[WARN] $GLOBAL_ARISC 已存在且不是符号链接，跳过全局 arisc 注册" >&2
else
  ln -sfn "$WORKSPACE_ROOT/bin/arisc" "$GLOBAL_ARISC"
  echo "[INFO] 已注册全局命令：$GLOBAL_ARISC -> $WORKSPACE_ROOT/bin/arisc"
fi
seed() {
  local tmpl="$WORKSPACE_ROOT/templates/$1" dest="$WORKSPACE_ROOT/$2"
  if [[ -e "$dest" ]]; then
    echo "[INFO] $2 已存在，保持不变"
  elif [[ -f "$tmpl" ]]; then
    cp "$tmpl" "$dest"
    echo "[INFO] 已从 templates/$1 初始化 $2"
  else
    echo "[WARN] 模板缺失：templates/$1，跳过 $2" >&2
  fi
}
seed shared/env shared/env
seed shared/mcp.json shared/mcp.json

if ! command -v uv >/dev/null 2>&1; then
  if $AUTO_INSTALL_UV; then
    command -v curl >/dev/null 2>&1 || {
      echo "[ERROR] 自动安装 uv 需要 curl；请先安装 curl，或手动安装 uv" >&2
      exit 1
    }
    echo "[INFO] 未发现 uv，正在运行 Astral 官方安装器"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
    command -v uv >/dev/null 2>&1 || {
      echo "[ERROR] uv 安装完成后仍未出现在 PATH 中" >&2
      exit 1
    }
  else
    echo "[WARN] 未发现 uv；创建项目需要 uv。可重新运行：./install.sh --install-uv" >&2
  fi
fi

if $DO_REPO; then
  echo "[INFO] 配置 ARIS Codex 研究技能仓库"
  if [[ -n "$REPO_PATH" ]]; then
    WORKSPACE_ROOT="$WORKSPACE_ROOT" "$WORKSPACE_ROOT/bin/aris-repo" setup "$REPO_PATH"
  else
    WORKSPACE_ROOT="$WORKSPACE_ROOT" "$WORKSPACE_ROOT/bin/aris-repo" setup "${ARIS_REPO:-$WORKSPACE_ROOT/aris-codex-skills}"
  fi
else
  echo "[INFO] --skip-repo：跳过 ARIS 研究技能仓库配置"
fi

if $DO_PATH; then
  case "${SHELL:-}" in
    *zsh) RC="$HOME/.zshrc" ;;
    *) RC="$HOME/.bashrc" ;;
  esac
  touch "$RC"

  if [[ "$WORKSPACE_ROOT" == "$HOME/"* ]]; then
    ROOT_REF="\$HOME/${WORKSPACE_ROOT#"$HOME"/}"
  else
    ROOT_REF="$WORKSPACE_ROOT"
  fi
  BEGIN="# >>> aris-codex workspace >>>"
  END="# <<< aris-codex workspace <<<"

  cp "$RC" "$RC.aris-backup-$(date +%Y%m%d-%H%M%S)"
  tmp=$(mktemp)
  awk -v b="$BEGIN" -v e="$END" '
    $0==b {inblk=1; next}
    $0==e {inblk=0; next}
    inblk {next}
    /arisc\/bin/ && /export PATH/ {next}
    {print}
  ' "$RC" > "$tmp"

  {
    printf '%s\n' "$BEGIN"
    if [[ "$WORKSPACE_ROOT" != "$DEFAULT_ROOT" ]]; then
      printf 'export WORKSPACE_ROOT="%s"\n' "$ROOT_REF"
    fi
    printf 'export PATH="$HOME/.local/bin:$PATH"\n'
    printf '%s\n' "$END"
  } >> "$tmp"

  mv "$tmp" "$RC"
  echo "[INFO] PATH 已写入 ${RC}；重新加载：exec \$SHELL -l"
else
  echo "[INFO] --no-path：跳过 shell rc 修改，请确认 $HOME/.local/bin 在 PATH 中"
fi

echo "[INFO] 初始化 base 环境"
WORKSPACE_ROOT="$WORKSPACE_ROOT" "$WORKSPACE_ROOT/bin/aris-base-init"

echo "[INFO] 检查外部工具"
if $DO_DOCTOR && [[ -x "$WORKSPACE_ROOT/bin/aris-doctor" ]]; then
  WORKSPACE_ROOT="$WORKSPACE_ROOT" "$WORKSPACE_ROOT/bin/aris-doctor" 2>&1 | sed 's/^/  /' || true
elif ! $DO_DOCTOR; then
  echo "[INFO] --skip-doctor：跳过检查"
fi

cat <<EOF

[OK] ARIS-Codex 已安装：$WORKSPACE_ROOT

下一步：
  exec \$SHELL -l
  arisc doctor
  arisc enter base
  arisc new <slug>

填写本机密钥：
  \$EDITOR $WORKSPACE_ROOT/shared/env
EOF
