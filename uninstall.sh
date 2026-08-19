#!/usr/bin/env bash
# uninstall.sh：安全卸载 ARISC，默认将本地数据移出工作区后保留。

if (( BASH_VERSINFO[0] < 4 )); then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    for modern_bash in /opt/homebrew/bin/bash /usr/local/bin/bash; do
      [[ -x "$modern_bash" ]] && exec "$modern_bash" "$0" "$@"
    done
  fi
  echo "[ERROR] ARISC 卸载器需要 Bash 4.4+" >&2
  exit 1
fi
set -euo pipefail

WORKSPACE_ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/arisc-platform.sh
source "$WORKSPACE_ROOT/lib/arisc-platform.sh"

MODE="keep"
BACKUP_DIR=""
YES=false
DRY_RUN=false

usage() {
  cat <<'EOF'
用法：./uninstall.sh [--keep-data | --backup DIR | --purge] [--yes] [--dry-run]

数据策略：
  --keep-data   默认；把 projects/shared/reports/.trash/config 移到 ~/arisc-data-<时间>
  --backup DIR  复制本地数据到指定的 $HOME 子目录，然后卸载
  --purge       永久删除 ARISC 及全部本地数据，需要明确确认

其他选项：
  --yes         跳过交互确认
  --dry-run     只显示计划，不修改任何文件
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep-data) MODE="keep"; shift ;;
    --backup)
      [[ $# -ge 2 ]] || { echo "[ERROR] --backup 需要目录" >&2; exit 2; }
      MODE="backup"
      BACKUP_DIR="$2"
      shift 2
      ;;
    --purge) MODE="purge"; shift ;;
    --yes|-y) YES=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "[ERROR] 未知参数：$1" >&2; usage >&2; exit 2 ;;
  esac
done

HOME_ROOT="$(cd -P "$HOME" && pwd)"
EXPECTED_ROOT="$HOME_ROOT/arisc"
[[ "$WORKSPACE_ROOT" == "$EXPECTED_ROOT" ]] || {
  echo "[ERROR] 只允许卸载精确目录：$EXPECTED_ROOT" >&2
  echo "        当前脚本位于：$WORKSPACE_ROOT" >&2
  exit 1
}
[[ "$WORKSPACE_ROOT" != "$HOME_ROOT" && "$WORKSPACE_ROOT" != "/" ]] || {
  echo "[ERROR] 拒绝对宽泛目录执行卸载" >&2
  exit 1
}
[[ -x "$WORKSPACE_ROOT/bin/arisc" && -f "$WORKSPACE_ROOT/install.sh" && -f "$WORKSPACE_ROOT/README.md" ]] || {
  echo "[ERROR] 目标不像有效的 ARISC 工作区：$WORKSPACE_ROOT" >&2
  exit 1
}

if [[ -d "$WORKSPACE_ROOT/.git" ]]; then
  ORIGIN="$(git -C "$WORKSPACE_ROOT" remote get-url origin 2>/dev/null || true)"
  case "$ORIGIN" in
    https://github.com/wangtianci2004/arisc.git|git@github.com:wangtianci2004/arisc.git) ;;
    *) echo "[ERROR] Git origin 不是官方 ARISC 仓库：$ORIGIN" >&2; exit 1 ;;
  esac
fi

TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
if [[ "$MODE" == "keep" ]]; then
  DATA_DIR="$HOME_ROOT/arisc-data-$TIMESTAMP"
elif [[ "$MODE" == "backup" ]]; then
  case "$BACKUP_DIR" in
    "$HOME_ROOT"/*) DATA_DIR="$BACKUP_DIR" ;;
    *) echo "[ERROR] 备份目录必须位于 $HOME_ROOT 下" >&2; exit 1 ;;
  esac
  [[ "$DATA_DIR" != "$HOME_ROOT" && "$DATA_DIR" != "$WORKSPACE_ROOT" ]] || {
    echo "[ERROR] 备份目录不安全：$DATA_DIR" >&2
    exit 1
  }
else
  DATA_DIR=""
fi

echo "ARISC 根目录 : $WORKSPACE_ROOT"
echo "数据策略      : $MODE"
[[ -n "$DATA_DIR" ]] && echo "数据目标      : $DATA_DIR"
echo "全局命令      : $HOME_ROOT/.local/bin/arisc"

for state_name in projects shared reports .trash config; do
  if [[ -e "$WORKSPACE_ROOT/$state_name" ]]; then
    size="$(du -sh "$WORKSPACE_ROOT/$state_name" 2>/dev/null | awk '{print $1}' || true)"
    printf '本地数据      : %-10s %s\n' "$state_name" "${size:--}"
  fi
done

if $DRY_RUN; then
  echo "[OK] dry-run 完成，未修改任何文件"
  exit 0
fi

if ! $YES; then
  if [[ "$MODE" == "purge" ]]; then
    printf '将永久删除全部 ARISC 数据。输入 PURGE 确认：'
    read -r reply
    [[ "$reply" == "PURGE" ]] || { echo "[INFO] 已取消"; exit 0; }
  else
    printf '继续卸载 ARISC？[y/N] '
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]] || { echo "[INFO] 已取消"; exit 0; }
  fi
fi

if [[ "$MODE" == "keep" ]]; then
  mkdir -p "$DATA_DIR"
  for state_name in projects shared reports .trash config; do
    [[ -e "$WORKSPACE_ROOT/$state_name" ]] || continue
    mv "$WORKSPACE_ROOT/$state_name" "$DATA_DIR/$state_name"
  done
  echo "[OK] 本地数据已移动到：$DATA_DIR"
elif [[ "$MODE" == "backup" ]]; then
  mkdir -p "$DATA_DIR"
  for state_name in projects shared reports .trash config; do
    [[ -e "$WORKSPACE_ROOT/$state_name" ]] || continue
    rsync -a "$WORKSPACE_ROOT/$state_name" "$DATA_DIR/"
  done
  [[ -n "$(ls -A "$DATA_DIR" 2>/dev/null)" ]] || {
    echo "[ERROR] 备份目录为空，拒绝继续卸载" >&2
    exit 1
  }
  echo "[OK] 本地数据已备份到：$DATA_DIR"
fi

if command -v tmux >/dev/null 2>&1; then
  while IFS= read -r session; do
    [[ "$session" == aris-codex-* ]] || continue
    pane_cwd="$(tmux display-message -p -t "=$session:0.0" '#{pane_current_path}' 2>/dev/null || true)"
    case "$pane_cwd" in
      "$WORKSPACE_ROOT/projects"|"$WORKSPACE_ROOT/projects/"*)
        tmux kill-session -t "=$session"
        echo "[OK] 已结束 tmux：$session"
        ;;
    esac
  done < <(tmux list-sessions -F '#{session_name}' 2>/dev/null || true)
fi

GLOBAL_ARISC="$HOME_ROOT/.local/bin/arisc"
if [[ -L "$GLOBAL_ARISC" ]]; then
  actual="$(arisc_realpath "$GLOBAL_ARISC" 2>/dev/null || true)"
  expected="$(arisc_realpath "$WORKSPACE_ROOT/bin/arisc" 2>/dev/null || true)"
  if [[ -n "$actual" && "$actual" == "$expected" ]]; then
    rm -f "$GLOBAL_ARISC"
    echo "[OK] 已删除全局命令：$GLOBAL_ARISC"
  else
    echo "[WARN] 全局 arisc 不属于当前工作区，保持不变：$GLOBAL_ARISC" >&2
  fi
elif [[ -e "$GLOBAL_ARISC" ]]; then
  echo "[WARN] 全局 arisc 不是符号链接，保持不变：$GLOBAL_ARISC" >&2
fi

clean_rc() {
  local rc="$1" tmp backup
  [[ -f "$rc" ]] || return 0
  grep -Eq '^# >>> (aris-codex|arisc) workspace >>>$' "$rc" || return 0
  backup="$rc.arisc-backup-$TIMESTAMP"
  cp "$rc" "$backup"
  tmp="$(mktemp "$rc.arisc.XXXXXX")"
  awk '
    $0 == "# >>> aris-codex workspace >>>" || $0 == "# >>> arisc workspace >>>" { managed=1; next }
    $0 == "# <<< aris-codex workspace <<<" || $0 == "# <<< arisc workspace <<<" { managed=0; next }
    !managed { print }
  ' "$rc" > "$tmp"
  mv "$tmp" "$rc"
  echo "[OK] 已清理 shell 配置：$rc（备份：$backup）"
}

clean_rc "$HOME_ROOT/.bashrc"
clean_rc "$HOME_ROOT/.zshrc"

cd "$HOME_ROOT"
[[ "$WORKSPACE_ROOT" == "$HOME_ROOT/arisc" ]] || { echo "[ERROR] 最终路径校验失败" >&2; exit 1; }
rm -rf -- "$WORKSPACE_ROOT"

echo "[OK] ARISC 已卸载"
[[ -n "$DATA_DIR" ]] && echo "[INFO] 保留数据：$DATA_DIR"
