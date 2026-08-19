---
name: aris-base
description: "ARIS-Codex base 工作区统一监控和接管入口。用于用户说“base 状态”、“base 监控”、“接管议程”、“接管摘要”、“自动推进并监控”、“生成交接报告”、“保存 base 快照”、“进入 base”等场景。"
argument-hint: "[status|watch|alerts|agenda|summary|auto|triage|report|reports|snapshot|info|enter|doctor|audit|init] ..."
allowed-tools: Bash(arisc *)
---

# Base 工作区入口

该技能调用 `arisc base`，统一封装 base 视角的状态、监控、告警、议程、接管摘要、自动推进、诊断、报告、报告查看、快照、信息、进入、doctor、audit 和初始化。

## 执行

```bash
arisc base $ARGUMENTS
```

## 说明

- `arisc base` 等价于 `arisc base status`。
- `arisc base status` 等价于 `arisc status`。
- `arisc base watch` 等价于 `arisc watch`。
- `arisc base alerts` 等价于 `arisc alerts`。
- `arisc base agenda` 等价于 `arisc agenda`。
- `arisc base summary` 只读输出当前告警、最新保存材料和 status/doctor/audit JSON 路径、查看命令和接管议程；加 `--json` 输出机器可读摘要，路径位于 `latest` 对象。
- `arisc base auto` 等价于 `arisc auto`。
- `arisc base triage` 等价于 `arisc triage`。
- `arisc base report` 等价于 `arisc report`。
- `arisc base reports` 等价于 `arisc reports`。
- `arisc base snapshot` 会保存交接报告、接管诊断、全环境导出、status/doctor/audit JSON 和内嵌接管议程摘要的快照索引；单项诊断失败时继续生成索引。
- `arisc base info` 等价于 `arisc info base`。
- `arisc base enter` 等价于 `arisc enter base`。
- 该入口本身不创建普通项目、不发送消息、不删除项目。
