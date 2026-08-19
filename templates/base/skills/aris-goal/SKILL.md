---
name: aris-goal
description: "向某个 ARIS-Codex 项目投递 Codex /goal，让项目在 tmux 后台持续执行。用于用户说“让 <slug> 自动干”、“给 <slug> 设置长期目标”、“持续推进这个项目”、“后台跑 goal”等场景。"
argument-hint: "<slug> <goal...> [--create] [--resume] [--dry-run] | --batch FILE|- [--dry-run] [--create] [--resume] [--continue-on-error] | --status [--json] [slug] | --alerts [--json] [--summary] [--sort severity|name] [--only X] [--pane-lines N] | --peek <slug> [N]"
allowed-tools: Bash(arisc *)
---

# 投递项目长期目标

该技能是 `arisc goal` 的 base 入口。它会把目标转换成 Codex slash command：`/goal <目标>`，投递到项目的 `aris-codex-<slug>` tmux 会话。

参数：`$ARGUMENTS`，格式为 `<slug> <goal...> [--create] [--resume] [--dry-run]`，或 `--batch FILE|- [--dry-run] [--create] [--resume] [--continue-on-error]`、`--status [--json] [slug]`、`--alerts [--json] [--summary] [--sort severity|name] [--only X] [--pane-lines N]`、`--peek <slug> [N]`。

## 执行

```bash
if [[ -z "$ARGUMENTS" ]]; then
  echo "用法：/aris-goal <slug> <goal...> [--create] [--resume] [--dry-run]"
  echo "      /aris-goal --batch FILE|- [--dry-run] [--create] [--resume] [--continue-on-error]"
  echo "      /aris-goal --status [--json] [slug]"
  echo "      /aris-goal --alerts [--json] [--summary] [--sort severity|name] [--only blocked|attention|waiting|stopped] [--pane-lines N]"
  echo "      /aris-goal --peek <slug> [N]"
  exit 2
fi

arisc goal $ARGUMENTS
```

## 查看目标

```bash
echo ""
echo "goal 状态："
arisc goal --status
```

## 说明

- 目标项目不存在时，必须显式传 `--create`。
- 已有项目会话时，目标会直接发送到当前 tmux pane。
- 没有项目会话时，默认启动新的后台 Codex 会话；传 `--resume` 时会先尝试 `codex resume --last`。
- 批量投递使用 `--batch FILE`，文件每行格式为 `slug<TAB>目标文本`；传 `--batch -` 时从标准输入读取。空行和 `#` 注释跳过。批量模式支持 `--dry-run`、`--create`、`--resume` 和 `--continue-on-error`，不支持 `--attach`。默认单项失败会中止；加 `--continue-on-error` 会继续后续项目并汇总失败。
- 最近投递记录写入项目 `.codex/aris-goal.tsv` 和 `.codex/aris-goal.md`，供 `arisc ls`、`arisc goal --list` 和 `/aris-status` 查看。
- `--status [slug]` 会显示 goal 记录、tmux 状态和 pane 粗分类；加 `--json` 输出 `tmux_state`、`pane_status`、`mode`、`created_at`、`goal_preview`、`session_name`、`project_dir`、`has_goal_record` 和 `alert`。
- `--alerts` 只显示需要关注的项目；默认按严重度排序，先 blocked、waiting、attention、stopped，可用 `--sort name` 改为项目名顺序；可用 `--summary` 输出数量摘要，用 `--only blocked|attention|waiting|stopped` 筛选，用 `--pane-lines N` 附加运行中 pane 摘要。
- `mode=external` 表示会话属于当前 workspace，但没有 ARIS goal 投递记录。
- `--peek <slug> [N]` 会读取目标 tmux pane 末尾 N 行，不连接会话。
