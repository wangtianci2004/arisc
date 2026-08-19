---
name: aris-status
description: "查看 ARIS-Codex 工作区的跨项目状态。用于用户说“全局状态”、“看一下所有环境”、“all projects”、“workspace status”、“who is working on what”等场景。"
argument-hint: "[--json] [--with-pane] [--pane-lines N]"
allowed-tools: Bash(arisc *)
---

# ARIS-Codex 工作区状态

从 base 环境运行。目标是输出项目总览、ARIS goal 状态、告警摘要、需要关注项目和运行中的 tmux 会话。

该技能调用统一的 `arisc status`，由 CLI 负责 workspace 目录校验、tmux 会话过滤和 pane 截断。需要脚本化判断时可以传 `--json`。

## 执行

```bash
if [[ -z "$ARGUMENTS" ]]; then
  arisc status --with-pane --pane-lines 20
else
  arisc status $ARGUMENTS
fi
```

## 汇总要求

运行命令后，用 3 到 6 行中文总结：

- 哪些项目正在运行。
- 哪些项目有最近投递的 `/goal`，pane 是 `running`、`blocked`、`attention` 还是 `waiting`。
- 当前告警数量分布，以及哪些项目需要接管。
- 哪些项目没有 tmux 会话或看起来停滞。
- 需要持续推进时，建议使用 `/aris-goal <slug> <goal...>`。
- 需要一次性干预时，建议使用 `/aris-send <slug> <message>` 或 `arisc enter <slug>`。
- 需要查看某个项目 pane 尾部时，建议使用 `arisc goal --peek <slug> [N]`。

## 跳过规则

- 忽略 `.trash/`，它不是活动项目。
- 不解析 Codex 全局会话历史；当前阶段只使用 `arisc report` 汇总的 tmux pane 和项目文件状态。
