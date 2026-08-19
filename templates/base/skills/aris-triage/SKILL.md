---
name: aris-triage
description: "只读汇总 ARIS-Codex 中需要人工关注的项目，并逐个生成接管诊断。用于用户说“帮我接管前看一下”、“哪些项目要处理并给诊断”、“triage”、“先排查告警项目”等场景。"
argument-hint: "[--only blocked|attention|waiting|stopped] [--sort severity|name] [--with-pane] [--pane-lines N] [--json] [--save] [--out FILE] [--embed]"
allowed-tools: Bash(arisc *)
---

# 接管诊断

该技能调用 `arisc triage`，先读取 `arisc alerts`，再对每个告警项目执行 `arisc inspect`。

## 执行

```bash
arisc triage $ARGUMENTS
```

## 说明

- 不创建项目、不启动 Codex、不发送消息、不结束会话。
- 默认不输出 pane 内容；用户明确要求查看运行输出时，使用 `--with-pane --pane-lines N`。
- `--only blocked|attention|waiting|stopped` 只诊断某一类告警项目。
- 默认按严重度排序：blocked、waiting、attention、stopped；`--sort name` 改为按项目名排序。
- `--json` 输出机器可读结果，适合脚本接管。
- `--save` 写入 `reports/aris-triage-*.md`；`--out FILE` 写入指定路径，同时仍输出到终端。
- `--embed` 省略顶层标题，通常只由 `arisc report --with-triage` 内部调用。
