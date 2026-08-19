---
name: aris-doctor
description: "只读检查 ARIS-Codex 工作区、项目骨架、base 环境、ARIS_REPO 和外部工具。用于用户说“检查环境”、“doctor”、“运行骨架有没有问题”、“工具链是否可用”等场景。"
argument-hint: "[--json]"
allowed-tools: Bash(arisc *)
---

# 检查工作区运行骨架

该技能调用 `arisc doctor`，只读检查项目运行骨架、base 环境、workspace 模板、ARIS_REPO 和 PATH 中的外部工具。

## 执行

```bash
arisc doctor $ARGUMENTS
```

## 说明

- 不创建项目、不启动 Codex、不发送消息、不读取 tmux pane、不结束会话。
- 默认输出人类可读检查结果。
- `--json` 输出机器可读结果，包含 `workspace_root`、`aris_repo`、`projects`、`base`、`workspace`、`aris_repo_check`、`tools` 和 `ok`。
- `arisc doctor` 检查运行骨架；`arisc audit` 检查 CLI、文档和 base 技能同步，两者互补。
