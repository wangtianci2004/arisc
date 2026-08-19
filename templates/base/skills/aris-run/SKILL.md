---
name: aris-run
description: "在指定 ARISC 项目环境中执行普通命令。用于用户说“在某个项目里跑一下命令”、“用项目 venv 执行”、“像 conda run 一样运行脚本”等场景。"
argument-hint: "[--no-env] [--no-venv] [--dry-run] <slug> -- <command...>"
allowed-tools: Bash(arisc *)
---

# 在项目环境中执行命令

该技能调用 `arisc run`，在目标项目目录中执行普通 shell 命令，默认加载项目 `.env`，并把项目 `.venv/bin` 放到 `PATH` 最前面。

## 执行

```bash
arisc run $ARGUMENTS
```

## 说明

- 不启动 Codex、不 attach tmux、不发送消息、不结束会话。
- 命令会在 `projects/<slug>/` 下执行。
- 默认加载项目 `.env`；不需要密钥时可传 `--no-env`。
- 默认使用项目 `.venv/bin`；只想用系统环境时可传 `--no-venv`。
- 不确定命令是否正确时先传 `--dry-run`。
- 执行会修改项目文件的命令前，先确认用户确实要求运行该命令。
