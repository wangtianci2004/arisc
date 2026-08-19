---
name: aris-inspect
description: "只读诊断单个 ARIS-Codex 项目。用于用户点名某个项目并问“看看这个项目”、“诊断一下 <slug>”、“这个项目卡在哪里”、“inspect <slug>”等场景。"
argument-hint: "<slug> [--json] [--with-pane] [--pane-lines N] [--embed]"
allowed-tools: Bash(arisc *)
---

# 诊断单个项目

该技能调用 `arisc inspect`，只读汇总一个项目的路径、骨架、goal、tmux、Git 和可选 pane 摘要。

## 执行

```bash
if [[ -z "$ARGUMENTS" ]]; then
  echo "用法：/aris-inspect <slug> [--json] [--with-pane] [--pane-lines N]"
  exit 2
fi

arisc inspect $ARGUMENTS
```

## 说明

- 不创建项目、不启动 Codex、不发送消息、不结束会话。
- 默认不输出 pane 内容；用户明确要求查看运行输出时，使用 `--with-pane --pane-lines N`。
- `--json` 输出机器可读结果，适合 base 或脚本判断单项目是否需要接管。
- `--embed` 省略顶层标题，通常只由 `arisc triage` 内部调用。
