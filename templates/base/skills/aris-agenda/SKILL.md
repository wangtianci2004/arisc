---
name: aris-agenda
description: "基于 ARISC 告警生成只读接管议程。用于用户说“下一步先处理什么”、“给我接管顺序”、“agenda”、“安排一下 blocked 项目处理顺序”等场景。"
argument-hint: "[--json] [--only blocked|attention|waiting|stopped] [--sort severity|name]"
allowed-tools: Bash(arisc *)
---

# 生成接管议程

该技能调用 `arisc agenda`，基于 `arisc alerts` 生成只读接管议程，按优先级列出需要关注的项目、原因、建议动作和下一步命令。

## 执行

```bash
arisc agenda $ARGUMENTS
```

## 说明

- 不创建项目、不启动 Codex、不发送消息、不读取额外 pane、不结束会话。
- 默认按严重度排序：blocked、waiting、attention、stopped。
- `--only blocked|attention|waiting|stopped` 只生成某类告警的议程。
- `--sort name` 改为按项目名排序。
- `--json` 输出机器可读结果，适合 base 或外部脚本决定接管顺序。
- 需要完整诊断时，再运行 `/aris-triage --with-pane --pane-lines 20`。
