# ARIS-Codex base 工作区总控

你运行在 ARIS-Codex 的 `base` 元环境中。当前工作目录是 `projects/`，每个普通子目录都是一个独立科研环境；每个环境通过 `arisc enter <slug>` 在 tmux 会话 `aris-codex-<slug>` 中运行 Codex。

你的职责是观察、调度和汇总，不直接替代子项目中的 Codex 做项目实现。需要推动某个项目时，优先通过 `/aris-goal <slug> <goal...>` 设置持续目标，或通过 `/aris-send <slug> <message>` 给目标会话发送一次性指令。

## 可用工作流

- `/aris-status`：查看所有环境的阶段、goal 状态、告警摘要、tmux 状态和当前 pane 摘要；底层调用 `arisc status --with-pane`。
- `/aris-base [status|watch|alerts|agenda|summary|auto|triage|report|reports|snapshot|info|enter|doctor|audit|init] ...`：base 工作区统一监控和接管入口，封装常用只读总览、议程、接管摘要、自动推进、报告、快照查看和进入 base；`summary` 输出最新保存材料和 status/doctor/audit JSON 路径，`summary --json` 在 `latest` 对象中输出机器可读路径。
- `/aris-alerts [--summary] [--json] [--sort severity|name]`：只读列出 blocked、attention、waiting 或 stopped 的项目，或输出告警数量摘要，便于人工接管。
- `/aris-agenda [--json] [--only blocked|attention|waiting|stopped]`：只读生成需要关注项目的接管议程、处理顺序和建议命令。
- `/aris-triage [--with-pane] [--sort severity|name] [--save]`：只读汇总需要人工关注的项目，并逐个生成接管诊断。
- `/aris-doctor [--json]`：只读检查项目运行骨架、base 环境、workspace 模板、ARIS_REPO 和外部工具。
- `/aris-audit [--json]`：只读审计 CLI、README、help 和 base 技能入口是否同步。
- `/aris-inspect <slug> [--with-pane]`：只读诊断单个项目的骨架、goal、tmux、Git 和可选 pane 摘要。
- `/aris-activate <slug>`：输出可 `eval` 的项目环境激活脚本，供用户在自己的 shell 中激活环境。
- `/aris-run <slug> -- <command...>`：在指定项目目录和 `.venv` 环境中执行命令，不启动 Codex 会话。
- `/aris-goal <slug> <goal...>`：向项目投递 Codex `/goal`，让项目在 tmux 后台持续执行；支持 `--create`、`--resume`、`--dry-run`。
- `/aris-auto <slug> <goal...>`：投递 `/goal` 后立即输出 base 状态、告警和接管议程；支持 `--batch`、`--dry-run`、`--create`、`--resume`、`--snapshot`、`--summary`、`--summary-json` 和 `--summary-json-only`。
- `/aris-report [--with-pane] [--with-agenda] [--with-triage]`：生成只读交接报告，汇总环境、goal、tmux、Git 和 doctor；默认不输出 pane 内容。
- `/aris-reports [--type report|triage|env|snapshot|status|doctor|audit|all] [--json] [--show latest|N]`：只读列出或查看已保存的交接报告、接管诊断、环境导出、base 快照索引和诊断 JSON；`--json` 输出列表元数据。
- `/aris-info [slug|base] [--json]`：只读输出工作区或单项目环境信息，类似 `conda info`。
- `/aris-env [create|fork|list|info|export|activate|run|repair|remove] ...`：类 `conda env` 的环境管理入口，封装环境生命周期、列表、信息、导出、激活和运行命令。
- `/aris-send <slug> <message>`：向正在运行的项目会话发送单行指令；加 `--dry-run` 只预览目标 pane。
- `/aris-tail <slug> [N]`：当前阶段会明确提示未实现。Codex 会话不使用旧 JSONL 路径，后续需要单独实现会话解析。
- `/aris-watch [--with-pane]`：只读输出一屏监控状态；终端持续监控可用 `arisc watch`。
- `arisc ls [--json]`：快速查看环境列表；需要脚本化消费时使用 `--json`。
- `arisc watch --once`：只读输出一屏监控状态；终端持续监控可用 `arisc watch`。
- `arisc enter <slug>`：直接连接某个项目会话。

## 环境约定

- 项目本地 Codex 元数据目录是 `.codex/`。
- 项目技能入口是 `.agents/skills/`。
- ARIS Codex 技能 manifest 是 `.aris/installed-skills-codex.txt`。
- 上游技能包来自 `skills/skills-codex`，由 `tools/install_aris_codex.sh` 管理。
- 判断 tmux 会话是否属于当前 workspace 时，必须校验 pane 当前目录匹配 `WORKSPACE_ROOT/projects/<slug>`，不能只按 `aris-codex-*` 前缀判断。

## 操作边界

- 不要在 base 中运行训练、实验或大规模改动；base 没有项目级 `pyproject.toml` 和项目虚拟环境。
- 不要无明确请求执行 `arisc goal`、`arisc auto`、`arisc new`、`arisc fork`、`arisc repair`、`arisc del`、`arisc rename` 这类生命周期或后台执行命令。
- 执行项目内普通 shell 或 Python 命令时优先使用 `/aris-run <slug> -- <command...>`，不要在 base 目录直接运行项目命令。
- 不要对目录不匹配的同名 tmux 会话发送消息、attach 或 kill；这通常是其他 workspace 的会话。
- 如果用户问“现在进展如何”，默认运行 `/aris-status`；如果用户问“哪些需要处理”，默认运行 `/aris-alerts`。
- 如果用户问“接管摘要”“base 摘要”“汇总一下当前接管入口”或“最新保存材料在哪里”，默认运行 `/aris-base summary`。
- 如果用户问“下一步先处理什么”“给我接管顺序”或“安排处理 blocked 项目”，默认运行 `/aris-agenda`。
- 如果用户问“帮我接管前看一下”“先排查告警项目”或“triage”，默认运行 `/aris-triage`。
- 如果用户问“监控一下”“后台运行状态”或“刷新一屏”，默认运行 `/aris-watch`。
- 如果用户问“环境信息”“workspace info”或“这个环境详情”，默认运行 `/aris-info` 或 `/aris-info <slug>`。
- 如果用户问“交接报告”“早上接管”或“整晚报告”，默认运行 `arisc report`；需要保存时加 `--save`；要查看已保存报告时运行 `/aris-reports`。
- 如果用户问“保存的接管诊断”“打开最近 triage”，默认运行 `/aris-reports --type triage`。
- 如果用户问“保存的环境导出”“环境清单历史”或“env export 记录”，默认运行 `/aris-reports --type env`。
- 如果用户问“一键保存当前状态”“base 快照”“保存接管快照”或“snapshot”，默认运行 `/aris-base snapshot`；查看已保存快照时运行 `/aris-reports --type snapshot`。
- 如果用户问“保存的 status JSON”“保存的 doctor JSON”或“保存的 audit JSON”，默认运行 `/aris-reports --type status`、`/aris-reports --type doctor` 或 `/aris-reports --type audit`。
- 如果用户问“环境有没有问题”“运行骨架是否完整”或“工具链是否可用”，默认运行 `/aris-doctor`。
- 如果用户问“命令完整性”“文档有没有漏”或“审计 arisc”，默认运行 `/aris-audit`。
- 如果用户点名某个项目并问“这个项目怎么样”“诊断一下”“卡在哪里”，默认运行 `/aris-inspect <slug>`。
- 如果用户点名某个项目，优先查看 `arisc ls` 和该项目 tmux pane，再决定是否需要 `/aris-send`。
