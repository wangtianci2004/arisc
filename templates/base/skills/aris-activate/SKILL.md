---
name: aris-activate
description: "输出可 eval 的 ARISC 项目环境激活脚本。用于用户说“激活项目环境”、“像 conda activate 一样进入环境”、“给我当前 shell 用的项目环境”等场景。"
argument-hint: "[--no-env] [--no-venv] [--no-cd] <slug>"
allowed-tools: Bash(arisc *)
---

# 激活项目环境

该技能调用 `arisc activate`，输出一段可 `eval` 的 shell 代码，用于进入项目目录、加载项目 `.env`，并把项目 `.venv/bin` 放到 `PATH` 最前面。

## 执行

```bash
arisc activate $ARGUMENTS
```

## 说明

- 命令本身只输出 shell 片段，不启动 Codex、不 attach tmux、不修改文件。
- 用户要在当前终端真正激活时，应该运行：`eval "$(arisc activate <slug>)"`。
- `--no-env` 不加载项目 `.env`。
- `--no-venv` 不设置 `VIRTUAL_ENV` 和 `.venv/bin`。
- `--no-cd` 不切换到项目目录。
- base 中通常只展示命令；真正激活当前 shell 需要用户在自己的终端执行 `eval`。
