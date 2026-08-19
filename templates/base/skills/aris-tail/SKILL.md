---
name: aris-tail
description: "说明 ARIS-Codex 当前暂不支持按项目解析 Codex 会话历史。用于用户想查看某个项目最近对话时给出明确替代路径。"
argument-hint: "<slug> [N=20]"
allowed-tools: Bash(arisc *)
---

# 查看项目最近对话

当前阶段该能力暂不实现。原因是 Codex 会话存储在 `~/.codex/sessions/`，不是按项目绝对路径编码的固定目录；直接照搬旧 JSONL 规则会读错会话。

## 执行

```bash
if [[ -z "$ARGUMENTS" ]]; then
  echo "用法：/aris-tail <slug> [N]"
  exit 2
fi
arisc tail $ARGUMENTS
```

后续实现要求：基于 Codex 官方会话记录格式建立项目 cwd 过滤和最新会话选择，不能使用旧路径规则。
