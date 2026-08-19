---
name: aris-auto
description: "投递 ARIS-Codex /goal 后立即输出 base 监控摘要，可选保存 base 接管快照或输出接管摘要 JSON。用于用户说“一条命令自动干”、“让项目自动推进并监控”、“自动推进并保存快照”、“批量自动推进项目”等场景。"
argument-hint: "[--no-monitor] [--with-pane] [--pane-lines N] [--no-agenda] [--snapshot] [--summary] [--summary-json] [--summary-json-only] <slug> [goal options] -- <goal...> | --batch FILE|- [goal batch options]"
allowed-tools: Bash(arisc *)
---

# 自动推进并监控

该技能调用 `arisc auto`，先复用 `arisc goal` 投递项目 `/goal`，再从 base 视角输出状态、告警和接管议程；加 `--snapshot` 时会保存 base 接管快照，加 `--summary-json` 时会额外输出机器可读接管摘要。

## 执行

```bash
arisc auto $ARGUMENTS
```

## 说明

- 单项目用法：`arisc auto <slug> -- <goal...>`。
- 批量用法：`arisc auto --batch FILE|- [--dry-run] [--create] [--resume] [--continue-on-error]`。
- 监控选项必须放在 goal 参数前，例如 `arisc auto --with-pane --pane-lines 8 <slug> -- <goal...>`。
- `--snapshot` 会在非 dry-run 投递后保存交接报告、接管诊断、全环境导出、status/doctor/audit JSON 和快照索引。
- `--summary` 会在非 dry-run 投递后额外输出 `arisc base summary`。
- `--summary-json` 会在非 dry-run 投递后额外输出 `arisc base summary --json`。
- `--summary-json-only` 会把操作日志写入 stderr，stdout 只保留最终 `arisc base summary --json`，适合脚本消费。
- `--dry-run` 时只预览 goal 动作，不输出监控摘要，也不保存快照。
- 该入口不实现新的会话逻辑；投递完全复用 `arisc goal`，监控完全复用 `arisc base`。
