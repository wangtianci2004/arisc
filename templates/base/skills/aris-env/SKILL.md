---
name: aris-env
description: "类 conda env 的 ARISC 环境管理入口。用于用户说“创建环境”、“fork 环境”、“列环境”、“环境信息”、“导出环境”、“激活环境”、“在环境里运行命令”等场景。"
argument-hint: "[create|fork|list|info|export|activate|run|repair|remove] ..."
allowed-tools: Bash(arisc *)
---

# 环境管理入口

该技能调用 `arisc env`，统一封装环境创建、迁移、列表、信息、导出、激活、运行、修复、删除和恢复命令。

## 执行

```bash
arisc env $ARGUMENTS
```

## 说明

- `arisc env` 等价于 `arisc env list`。
- `arisc env create <slug>` 等价于 `arisc new <slug>`。
- `arisc env fork <project_name> [new_name]` 等价于 `arisc fork <project_name> [new_name]`。
- `arisc env list [--json]` 等价于 `arisc ls [--json]`。
- `arisc env info [--json] [slug|base]` 等价于 `arisc info [--json] [slug|base]`。
- `arisc env export [--json] [--save] [--out FILE] <slug|base>` 只读导出单环境清单，不输出 `.env` 内容。
- `arisc env export --all [--json] [--save] [--out FILE]` 只读导出 base 和所有项目的环境清单。
- `arisc env activate <slug>` 等价于 `arisc activate <slug>`，只输出可 `eval` 的 shell 片段。
- `arisc env run <slug> -- <command...>` 等价于 `arisc run <slug> -- <command...>`。
- `arisc env repair <slug...>|--all` 等价于 `arisc repair`。
- `arisc env remove <slug>` 等价于 `arisc del <slug>`。
- 该入口本身不启动 Codex、不 attach tmux；具体是否创建、删除或执行项目命令由对应子命令决定。
