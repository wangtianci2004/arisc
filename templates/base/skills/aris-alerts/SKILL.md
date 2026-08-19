---
name: aris-alerts
description: "只读列出 ARISC 中需要人工关注的项目。用于用户说“哪些需要处理”、“哪里卡住了”、“show alerts”、“阻塞项目”、“需要我接管吗”等场景。"
argument-hint: "[--summary] [--json] [--sort severity|name] [--only blocked|attention|waiting|stopped] [--pane-lines N]"
allowed-tools: Bash(arisc *)
---

# 查看需要关注的项目

该技能调用 `arisc alerts`，只读列出 `blocked`、`attention`、`waiting` 或有 goal 记录但会话已停止的项目。

## 执行

```bash
arisc alerts $ARGUMENTS
```

## 说明

- 不创建项目、不启动 Codex、不发送消息、不结束会话。
- `--summary` 输出告警数量摘要。
- `--json` 输出机器可读结果，字段与 `arisc goal --status --json` 一致。
- `--summary --json` 会追加 `summary` 字段。
- 默认按严重度排序：blocked、waiting、attention、stopped；`--sort name` 改为按项目名排序。
- `--only blocked|attention|waiting|stopped` 只显示某一类需要关注的项目。
- `--pane-lines N` 附加运行中告警项目的 pane 末尾摘要。
- 需要查看完整 pane 时，用 `arisc goal --peek <slug> 40`。
- 需要人工接管时，用 `arisc enter <slug>`。
