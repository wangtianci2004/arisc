---
name: aris-audit
description: "只读审计 ARISC CLI、文档和 base 技能是否同步。用于用户说“检查命令完整性”、“审计 arisc”、“看看有没有漏文档或技能入口”等场景。"
argument-hint: "[--json]"
allowed-tools: Bash(arisc *)
---

# 审计工作区自身一致性

该技能调用 `arisc audit`，只读检查命令脚本、分发器、README、help、base 技能模板和 Codex 模板残留。

## 执行

```bash
arisc audit $ARGUMENTS
```

## 说明

- 不创建项目、不启动 Codex、不发送消息、不读取 tmux pane、不结束会话。
- `--json` 输出机器可读结果，包含 `ok`、`issues` 和 `warnings`。
- `arisc doctor` 检查项目运行骨架，`arisc doctor --json` 适合脚本消费；`arisc audit` 检查 CLI 和文档同步，两者互补。
