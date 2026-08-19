---
name: aris-reports
description: "只读列出或查看 arisc report --save 保存的交接报告、arisc triage --save 保存的接管诊断、arisc env export --save 保存的环境导出，以及 arisc base snapshot 保存的快照索引和诊断 JSON。用于用户说“打开最近报告”、“看保存的接管诊断”、“看环境导出历史”、“看 base 快照”、“看保存的诊断 JSON”、“reports”、“上一份报告”等场景。"
argument-hint: "[--type report|triage|env|snapshot|status|doctor|audit|all] [--json] [--show latest|N] [--path latest|N|current]"
allowed-tools: Bash(arisc *)
---

# 查看保存的报告和诊断

该技能调用 `arisc reports`，只读取 `reports/` 下由 `arisc report --save` 写入的交接报告、由 `arisc triage --save` 写入的接管诊断、由 `arisc env export --save` 写入的环境导出，或由 `arisc base snapshot` 写入的快照索引和诊断 JSON。

## 执行

```bash
arisc reports $ARGUMENTS
```

## 说明

- 不采集新状态、不读取 tmux pane、不发送消息、不启动或结束会话。
- 默认列出最近保存的交接报告。
- `--type triage` 列出或查看保存的接管诊断。
- `--type env` 列出或查看保存的环境导出。
- `--type snapshot` 列出或查看保存的 base 快照索引；索引内嵌接管议程摘要。
- `--type status`、`--type doctor`、`--type audit` 列出或查看 `arisc base snapshot` 保存的诊断 JSON。
- `--type all` 同时列出交接报告、接管诊断、环境导出、base 快照索引和诊断 JSON。
- `--json` 输出列表模式的机器可读元数据；不能和 `--show` 或 `--path` 同用。
- `--show latest` 显示当前类型的最新条目全文。
- `--path latest` 只输出当前类型的最新条目路径。
- `--path current` 输出 `reports/latest.md` 稳定路径；该指针只属于交接报告。
