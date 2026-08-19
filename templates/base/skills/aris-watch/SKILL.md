---
name: aris-watch
description: "输出一屏 ARIS-Codex 只读监控状态。用于用户说“监控一下”、“看后台运行状态”、“watch all projects”等场景。"
argument-hint: "[--with-pane] [--pane-lines N]"
allowed-tools: Bash(arisc *)
---

# 输出监控状态

该技能是 `arisc watch --once` 的 base 入口。它只读取状态，不创建项目、不启动 Codex、不发送消息、不删除文件。

参数：`$ARGUMENTS`，常用 `--with-pane --pane-lines N`。

## 执行

```bash
if [[ -z "$ARGUMENTS" ]]; then
  arisc watch --once
else
  arisc watch --once $ARGUMENTS
fi
```

## 说明

- 输出 `arisc ls`、`arisc goal --status`、告警摘要、需要关注项目和运行中 tmux 会话。
- 默认不输出 pane 内容；用户明确要求时使用 `--with-pane`。
- 需要可保存的交接报告时，使用 `/aris-report` 或 `arisc report`。
