---
name: aris-info
description: "只读输出 ARIS-Codex 工作区或单项目环境信息。用于用户说“环境信息”、“workspace info”、“这个环境详情”、“像 conda info 一样看一下”等场景。"
argument-hint: "[--json] [slug|base]"
allowed-tools: Bash(arisc *)
---

# 查看环境信息

该技能调用 `arisc info`。不带项目名时输出工作区总览；带项目名时输出单个环境的路径、goal、tmux、Git 和常用入口摘要。

## 执行

```bash
arisc info $ARGUMENTS
```

## 说明

- 只读取状态，不创建项目、不启动 Codex、不发送消息、不删除文件。
- `arisc info` 输出工作区级信息，包含全局入口、项目规模、告警摘要、doctor 和 audit 状态。
- `arisc info <slug>` 输出单项目环境信息，底层复用 `arisc inspect --json`。
- `--json` 输出机器可读结果。
