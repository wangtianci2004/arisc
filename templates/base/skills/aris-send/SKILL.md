---
name: aris-send
description: "向另一个 ARISC 项目的 tmux-backed Codex 会话发送指令。用于用户说“告诉 <slug> 干啥”、“send to <slug>”、“指挥那个 agent”、“让 <slug> 做 X”、“broadcast”等场景。"
argument-hint: "<slug> <message...> [--dry-run]"
allowed-tools: Bash(arisc *)
---

# 向项目 Codex 会话发送消息

目标会话是 tmux session `aris-codex-<slug>` 中运行的 Codex。该技能调用 `arisc send`，由 CLI 统一负责项目目录校验、pane 预览、dry-run 和发送。

参数：`$ARGUMENTS`，格式为 `<slug> <message...> [--dry-run]`。

## 执行

```bash
if [[ -z "$ARGUMENTS" ]]; then
  echo "用法：/aris-send <slug> <message...> [--dry-run]"
  exit 2
fi
arisc send $ARGUMENTS
```

## 约束

- 当前只支持单行消息；多行内容请拆成多次发送。
- 如果存在同名 tmux 会话但 pane 当前目录不匹配当前项目，`arisc send` 会拒绝发送。
