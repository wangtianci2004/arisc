---
name: aris-report
description: "生成 ARISC 工作区只读交接报告。用于用户说“交接报告”、“早上接管”、“整晚进度”、“汇总所有项目”等场景。"
argument-hint: "[--with-pane] [--pane-lines N] [--with-agenda] [--with-triage] [--no-doctor] [--save] [--out FILE]"
allowed-tools: Bash(arisc *)
---

# 生成交接报告

该技能是 `arisc report` 的 base 入口。它只读取状态，不创建项目、不启动 Codex、不发送消息、不删除文件。

参数：`$ARGUMENTS`，支持 `--with-pane`、`--pane-lines N`、`--with-agenda`、`--with-triage`、`--no-doctor`、`--save` 和 `--out FILE`。

## 执行

```bash
if [[ -z "$ARGUMENTS" ]]; then
  arisc report
else
  arisc report $ARGUMENTS
fi
```

## 说明

- 默认汇总 `arisc ls`、`arisc goal --status`、告警摘要、`arisc alerts`、运行中 tmux 会话、项目 Git 状态和 `arisc doctor`。
- 默认不输出 pane 内容，避免把真实项目输出混进报告。
- 用户明确要求查看运行中输出时，使用 `--with-pane --pane-lines N`。
- 用户明确要求处理顺序或接管议程时，使用 `--with-agenda` 追加 `arisc agenda` 的只读结果。
- 用户明确要求接管诊断时，使用 `--with-triage` 追加 `arisc triage` 的只读结果。
- 需要保存交接文件时，使用 `--save` 写入 `reports/`，并同步更新 `reports/latest.md`；使用 `--out FILE` 只写指定路径。
