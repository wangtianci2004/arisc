# ARISC 使用说明

`arisc` 是这个工作区的全局命令。它像 conda 管理环境一样管理科研项目：每个项目是一个独立环境，有自己的 `.codex/` 元数据、`.agents/skills/` 技能入口、Python 虚拟环境、Git 仓库和 tmux 后台 Codex 会话。

## 先确认命令可用

```bash
arisc help
arisc doctor
```

如果提示找不到 `arisc`，先运行：

```bash
~/arisc/install.sh --yes
exec $SHELL -l
```

当前安装脚本会把 `~/arisc/bin/arisc` 注册为 `~/.local/bin/arisc`。你的 `PATH` 中已有 `~/.local/bin` 时，终端可以直接运行 `arisc`。

启用命令补全：

```bash
source <(arisc completion bash)
# Zsh: source <(arisc completion zsh)
```

macOS 需要先安装 Homebrew 依赖：

```bash
brew install bash jq tmux uv
```

`install.sh` 和 `arisc` 会在 macOS 自动切换到 `/opt/homebrew/bin/bash`（Apple Silicon）或 `/usr/local/bin/bash`（Intel），不会修改系统 `/bin/bash`。

## 第一次使用

`install.sh --yes` 会自动初始化并设置根目录 `aris-codex-skills` submodule。若安装时使用了 `--skip-repo`，可在之后非交互配置：

```bash
arisc repo setup
```

需要交互选择路径或更新已有技能仓库时，运行 `arisc repo`。

然后进入 base 总控环境：

```bash
arisc base
arisc enter base
```

`arisc base` 会从终端输出 base 视角的一屏工作区总览。`base` 的工作目录是 `projects/`，它用于看全局状态、调度项目、向项目会话发送指令，不建议在 base 里直接做具体科研项目实现。

## 创建科研环境

创建一个新项目：

```bash
arisc new llm-tokenizer
```

`slug` 必须是 kebab-case，只能包含小写字母、数字和连字符。例如：

```bash
arisc new graph-routing
arisc new paper-review-agent
arisc new gpu-scheduler
```

创建后项目会位于：

```text
~/arisc/projects/<slug>/
```

项目内会自动生成：

```text
.codex/                         Codex 项目元数据
.agents/skills/                 Codex skills 入口
.aris/installed-skills-codex.txt 技能安装 manifest
.venv/                          uv 创建的 Python 虚拟环境
AGENTS.md                       项目级 Codex 指令
RESEARCH_BRIEF.md               研究简报入口
pyproject.toml                  Python 项目配置
```

## 从现有研究工作区导入项目

如果你已经在其他研究工作区中有项目，可以把它 fork 到当前 ARISC workspace：

```bash
arisc fork ailab
```

默认源目录是：

```text
~/aris-workspace/projects/<project_name>/
```

默认目标目录是：

```text
~/arisc/projects/<project_name>/
```

你也可以给 Codex 侧项目指定新名字：

```bash
arisc fork ailab ailab-codex
```

`new_name` 可以省略。省略时沿用原项目名；提供时用新名字作为 ARISC 项目目录名。

目标名必须是 kebab-case，只能包含小写字母、数字和连字符。如果旧项目名包含下划线，需要显式传入新名字：

```bash
arisc fork qwen_adalora2_delivery qwen-adalora2-delivery
```

`arisc fork` 会复制原项目里的科研文件和 `.git/` 历史，但会排除或重建这些运行态：

```text
.claude/                         来源项目的运行目录
.venv/                           来源项目的 Python 虚拟环境
.agents/                         Codex skills 入口，迁移后重建
.codex/                          Codex 项目元数据，迁移后重建
.env                             链接到当前 Codex workspace 的 shared/env
.mcp.json                        链接到当前 Codex workspace 的 shared/mcp.json
.aris/installed-skills.txt       来源项目的旧 skills manifest
```

迁移完成后会自动补齐：

```text
.codex/aris.env
.agents/skills/
.aris/installed-skills-codex.txt
.aris/tools -> <ARIS_REPO>/tools
.venv/
AGENTS.md
```

来源项目的会话历史不会被迁移或解析。ARISC 中的新会话由 Codex 自行管理。

如果要从非默认来源目录迁移，使用：

```bash
CLAUDE_WORKSPACE_ROOT=/path/to/old/aris-workspace arisc fork old-project new-project
```

## 进入项目

启动或连接项目 Codex 会话：

```bash
arisc enter llm-tokenizer
```

默认行为：

1. 如果 `aris-codex-llm-tokenizer` tmux 会话已经存在，就直接连接。
2. 如果不存在，就在项目目录创建新的 tmux 会话。
3. 默认优先执行 `codex resume --last`，让 Codex 尝试恢复当前目录最近的会话。

如果存在同名 tmux 会话但 pane 当前目录不是当前 `WORKSPACE_ROOT/projects/<slug>`，`arisc enter` 会拒绝连接，避免误 attach 到其他 workspace。

如果你明确想开一个新 Codex 会话：

```bash
arisc enter llm-tokenizer --new
```

在 tmux 里分离但不结束 Codex：

```text
Ctrl+B D
```

之后重新连接：

```bash
arisc enter llm-tokenizer
```

切换 Codex 二进制或做隔离测试：

```bash
CODEX_BIN=codex arisc enter llm-tokenizer
CODEX_BIN=cat arisc enter llm-tokenizer --new
```

## 查看环境列表

```bash
arisc ls
arisc ls --json
```

输出会包含：

- `base` 元环境。
- 每个项目的最近变更日期。
- 当前阶段。
- tmux 会话是否运行。
- 最近投递的 ARIS goal 摘要。
- `RESEARCH_BRIEF.md` 的标题摘要。

`arisc ls --json` 会输出机器可读环境列表，包含 `name`、`type`、`path`、`last_changed`、`stage`、`tmux_state`、`goal_preview` 和 `summary`。

## 自动投递 goal

`arisc goal` 会向项目 Codex 会话投递 `/goal <目标>`。这是把一个科研环境交给 Codex 后台持续推进的入口：

```bash
arisc goal llm-tokenizer -- "阅读 RESEARCH_BRIEF.md，持续推进 /research-pipeline，并把关键结果写入阶段文件"
arisc auto llm-tokenizer -- "自动推进当前研究目标，并把阻塞点写入 TODO.md"
```

默认行为：

1. 如果 `aris-codex-<slug>` tmux 会话正在运行且 pane 当前目录属于当前项目，就直接把 `/goal` 发到当前 pane。
2. 如果会话没有运行，就在项目目录启动新的后台 Codex 会话，再投递 `/goal`。
3. 最近投递记录会写入 `.codex/aris-goal.tsv` 和 `.codex/aris-goal.md`。

如果存在同名 tmux 会话但不属于当前项目，`arisc goal` 会拒绝投递，避免跨 workspace 误发送。

`arisc auto` 是“投递后立刻监控”的薄封装。它先复用 `arisc goal` 投递 `/goal`，再复用 `arisc base` 输出状态、告警摘要和接管议程。加 `--snapshot` 会在非 dry-run 投递后保存一份 base 接管快照到 `reports/`；批量模式会在整批投递完成后保存一个整体快照。加 `--summary` 会额外输出接管短摘要，加 `--summary-json` 会额外输出机器可读接管摘要。脚本消费时用 `--summary-json-only`，stdout 只保留最终 JSON，其他日志写入 stderr。`--dry-run` 时只预览 goal 动作，不输出监控摘要，也不保存快照。

常用选项：

```bash
arisc goal <slug> --resume -- "恢复最近会话后继续推进这个目标"
arisc goal <slug> --dry-run -- "只预览，不发送"
arisc goal <slug> --attach -- "投递后直接连接 tmux"
arisc goal new-project --create -- "项目不存在时先创建，再投递目标"
arisc auto <slug> --dry-run -- "只预览自动推进，不发送"
arisc auto --with-pane --pane-lines 8 <slug> -- "自动推进并显示 pane 摘要"
arisc auto --snapshot <slug> -- "自动推进并保存 base 接管快照"
arisc auto --summary-json <slug> -- "自动推进并输出接管摘要 JSON"
arisc auto --summary-json-only <slug> -- "自动推进并让 stdout 只输出 JSON"
```

批量投递多个项目：

```bash
printf 'api-agent\t继续推进当前科研目标，先更新 TODO 和阻塞点\nphyscode\t检查当前 blocked 状态并整理需要人工决策的问题\n' > goals.tsv
arisc auto --batch goals.tsv --dry-run
arisc goal --batch goals.tsv --dry-run
arisc goal --batch goals.tsv
printf 'api-agent\t继续更新 TODO\nphyscode\t整理当前阻塞原因\n' | arisc goal --batch - --dry-run
arisc goal --batch goals.tsv --continue-on-error
```

`--batch` 文件每行格式是 `slug<TAB>目标文本`。传 `--batch -` 时从标准输入读取，方便 base 动态生成批量目标。空行和以 `#` 开头的注释行会跳过。批量模式也支持 `--create` 和 `--resume`；不支持 `--attach`。默认某个项目失败会中止；显式加 `--continue-on-error` 时会继续后续项目并在最后汇总失败项。实际投递前建议先运行 `--dry-run`。

查看最近投递：

```bash
arisc goal --list
arisc goal --status
arisc goal --status --json
arisc alerts
arisc alerts --summary
arisc alerts --only blocked
arisc alerts --sort name
arisc alerts --pane-lines 8
arisc agenda
arisc agenda --only blocked
arisc agenda --json
arisc triage
arisc triage --sort name
arisc triage --only blocked --with-pane --pane-lines 8
arisc triage --save
arisc goal --peek llm-tokenizer 40
arisc goal --show llm-tokenizer
arisc ls
```

`arisc goal --status --json` 会输出机器可读状态，字段包含 `slug`、`tmux_state`、`pane_status`、`mode`、`created_at`、`goal_preview`、`session_name`、`project_dir`、`has_goal_record` 和 `alert`，方便 base 或外部脚本自动判断哪些项目正在运行、阻塞或需要人工处理。

`mode=external` 表示会话属于当前 workspace，但没有 `.codex/aris-goal.tsv` 投递记录，通常是手动 `arisc enter` 或早期会话。

`arisc alerts` 是 `arisc goal --alerts` 的便捷入口，只显示 `blocked`、`attention`、`waiting` 或有 goal 记录但会话已停止的项目。默认按严重度排序，先 blocked、waiting、attention、stopped；加 `--sort name` 可改为项目名顺序。加 `--summary` 可输出告警数量摘要；加 `--json` 可输出机器可读结果；加 `--summary --json` 会追加 `summary` 字段；加 `--only blocked|attention|waiting|stopped` 可按类型筛选；加 `--pane-lines N` 可在文本输出或 JSON 中附带运行中告警 pane 摘要。

`arisc agenda` 会基于 `arisc alerts` 生成只读接管议程，按优先级列出需要关注项目、原因、建议动作和下一步命令。它不创建项目、不启动 Codex、不发送消息。默认按严重度排序；加 `--only blocked|attention|waiting|stopped` 可只生成某类告警议程；加 `--json` 输出机器可读结果，适合 base 或外部脚本决定接管顺序。

`arisc triage` 会把 `arisc alerts` 和 `arisc inspect` 串起来，逐个输出需要接管项目的只读诊断。它不创建项目、不启动 Codex、不发送消息、不结束会话。默认沿用 `alerts` 的严重度排序；加 `--sort name` 可改为项目名顺序。需要查看运行中 pane 末尾时，加 `--with-pane --pane-lines N`；只想诊断某类项目时，加 `--only blocked|attention|waiting|stopped`。需要单独保存接管诊断时，加 `--save` 写入 `reports/aris-triage-*.md`，或用 `--out <file>` 指定路径。

从 base 里也可以使用：

```text
/aris-goal llm-tokenizer 持续推进研究流程，先补齐简报和实验计划
```

## 生成交接报告

需要人工接管、早上查看整晚进度或做阶段汇报时，运行：

```bash
arisc report
```

报告会汇总：

- 环境列表和最近变更。
- `arisc goal --status` 的后台 goal 状态。
- 告警数量摘要。
- `arisc alerts` 的需要关注项目。
- 运行中的 `aris-codex-*` tmux 会话。
- 项目 Git 分支、未提交改动数量和最近提交。
- `arisc doctor` 检查结果。

默认不会输出 tmux pane 内容。如果需要把运行中 pane 的末尾也放进报告，显式运行：

```bash
arisc report --with-agenda --no-doctor
arisc report --with-triage --no-doctor
arisc report --with-pane --pane-lines 20
arisc report --save --with-pane --pane-lines 20
arisc reports
arisc reports --show latest
arisc reports --path current
arisc reports --type triage
arisc reports --type env
arisc reports --type snapshot
arisc reports --type status
arisc reports --type doctor
arisc reports --type audit
```

如果要把接管议程一起放进报告，使用 `--with-agenda`。它会追加 `arisc agenda` 的只读结果，适合早上先判断 blocked、waiting、attention 的处理顺序。

如果要把接管诊断一起放进报告，使用 `--with-triage`。它会追加 `arisc triage` 的只读结果，适合早上直接接手 blocked 或 attention 项目。

想减少输出、跳过 doctor：

```bash
arisc report --no-doctor
```

想保存一份交接报告到本机忽略目录 `reports/`：

```bash
arisc report --save
arisc report --out /tmp/aris-report.md
```

使用 `--save` 时会同时更新 `reports/latest.md`，给脚本或编辑器提供稳定入口。`--out` 只写指定文件，不更新默认报告指针。`arisc triage --save` 生成的接管诊断也在 `reports/` 下，但不会更新 `latest.md`。`arisc env export --save <slug|base>` 会把环境清单保存到 `reports/aris-env-export-*.md` 或 `.json`，同样不会包含 `.env` 内容。`arisc base snapshot` 会一次性保存交接报告、接管诊断、全环境导出、status/doctor/audit JSON 和 `aris-snapshot-*.md` 索引；索引内嵌接管议程摘要。保存的诊断 JSON 可分别用 `arisc reports --type status`、`arisc reports --type doctor` 和 `arisc reports --type audit` 查看。单项诊断返回非零时，`arisc base snapshot` 会记录告警并继续生成快照索引，避免接管材料丢失。

保存后查看：

```bash
arisc reports
arisc reports --show latest
arisc reports --path latest
arisc reports --path current
arisc reports --type triage
arisc reports --type triage --show latest
arisc reports --type env
arisc reports --type env --show latest
arisc reports --type snapshot
arisc reports --type snapshot --show latest
arisc reports --type status
arisc reports --type doctor
arisc reports --type audit
arisc reports --type all
arisc reports --type all --json
```

从 base 里也可以使用：

```text
/aris-report
/aris-report --with-pane --pane-lines 20
```

## 实时监控

只输出一屏工作区状态：

```bash
arisc status
arisc status --json
arisc status --with-pane --pane-lines 3
```

需要在终端持续观察后台项目时，运行：

```bash
arisc watch
```

只输出一次：

```bash
arisc watch --once
```

附加运行中 pane 的末尾摘要：

```bash
arisc watch --with-pane --pane-lines 3
```

指定刷新间隔或关闭清屏：

```bash
arisc watch --interval 10
arisc watch --interval 10 --no-clear
```

`arisc status` 和 `arisc watch` 都是只读命令，不创建项目、不启动 Codex、不发送消息。`arisc status` 只输出一次；加 `--json` 会输出机器可读总览，包含 `environments`、`goals`、`alerts` 和 `sessions`，便于 base 或外部脚本消费。`arisc watch` 会按间隔刷新。默认输出环境列表、goal 状态、告警摘要、需要关注项目和 tmux 会话。需要生成可保存的交接文本时，用 `arisc report`。

## 单项目诊断

需要只看某一个项目的骨架、goal、tmux 和 Git 状态时，运行：

```bash
arisc inspect llm-tokenizer
```

附加当前 tmux pane 的末尾摘要：

```bash
arisc inspect llm-tokenizer --with-pane --pane-lines 20
```

机器可读输出：

```bash
arisc inspect llm-tokenizer --json
```

`arisc inspect` 是只读命令，不创建项目、不启动 Codex、不发送消息、不结束会话。它适合在 `arisc alerts` 发现某个项目异常后，先做单项目接管前诊断。

## 发送一次性指令

如果某个项目的 Codex tmux 会话已经运行，可以用 `arisc send` 发送一行消息：

```bash
arisc send llm-tokenizer -- "继续整理实验计划，先列出当前阻塞点"
```

发送前会显示目标 pane 末尾和待发送内容。只想校验目标、预览 pane，不实际投递时：

```bash
arisc send llm-tokenizer --dry-run --pane-lines 10 -- "只预览，不发送"
```

规则：

- 目标必须是普通项目，不能是 `base`。
- 目标 tmux 会话必须已经运行；不会自动创建项目或启动 Codex。
- 如果存在同名会话但 pane 当前目录不是当前 `WORKSPACE_ROOT/projects/<slug>`，会拒绝发送。
- 当前只支持单行消息；多行任务建议写进项目文件，再发送一行指令让 Codex 阅读。

从 base 里也可以使用：

```text
/aris-send llm-tokenizer 继续整理实验计划，先列出当前阻塞点
```

## tmux 隔离规则

当前 ARISC workspace 可以和其他临时 workspace 同时运行。命令会校验 tmux pane 当前目录：

- `arisc ls`、`arisc enter --list`、`arisc goal --status`、`arisc watch` 和 `arisc report` 只显示当前 `WORKSPACE_ROOT/projects/<slug>` 对应的会话。
- `arisc goal`、`arisc goal --peek`、`arisc send`、`arisc enter`、`arisc enter --kill`、`arisc del`、`arisc rename` 和 `/aris-send` 遇到同名但目录不匹配的会话时会拒绝操作。
- 如果要人工处理外部 tmux 会话，先运行 `tmux list-sessions` 和 `tmux display-message -p -t =<session>:0.0 '#{pane_current_path}'` 确认目录。

## 修复已有项目骨架

如果项目已经在 `projects/` 下，但不是通过 `arisc new` 或 `arisc fork` 创建，可能缺少 `.codex/`、`.agents/skills/`、`.venv/`、`.env` 或 `.mcp.json`。这时运行：

```bash
arisc repair lora
```

一次修复多个项目：

```bash
arisc repair project-a project-b
```

修复所有项目：

```bash
arisc repair --all
```

只补 Codex 骨架和技能，不创建 `.venv/`：

```bash
arisc repair lora --no-venv
```

`arisc repair` 会补齐共享配置链接、`.codex/aris.env`、`.agents/skills/`、`.aris/tools`、`installed-skills-codex.txt`、`.venv/` 和 `.gitignore` 运行态规则。它不会覆盖已有普通 `.env` 或 `.mcp.json` 文件；如果遇到冲突，会报错让你手动处理。

## 获取项目路径

```bash
arisc path llm-tokenizer
```

常用写法：

```bash
cd $(arisc path llm-tokenizer)
code $(arisc path llm-tokenizer)
```

## 查看环境信息

```bash
arisc env
arisc env create llm-tokenizer
arisc env fork ailab ailab-codex
arisc env list --json
arisc env info llm-tokenizer
arisc env export llm-tokenizer
arisc env export --json llm-tokenizer
arisc env export --save llm-tokenizer
arisc env export --all
arisc env export --all --json
arisc env export --all --save
arisc info
arisc info --json
arisc info llm-tokenizer
arisc info --json llm-tokenizer
```

`arisc info` 类似 `conda info`。不带项目名时输出工作区总览，包括全局入口、项目规模、告警摘要、doctor 和 audit 状态；带项目名时输出单项目路径、goal、tmux、Git 和常用入口摘要。它只读取状态，不创建项目、不启动 Codex、不发送消息、不删除文件。

`arisc env` 是类 `conda env` 的统一入口。它不重写底层逻辑，只把已有项目命令收进同一个命名空间：`arisc env create` 等价于 `arisc new`，`arisc env fork` 等价于 `arisc fork`，`arisc env list` 等价于 `arisc ls`，`arisc env info` 等价于 `arisc info`，`arisc env export` 只读导出环境清单且不输出 `.env` 内容，`arisc env activate` 等价于 `arisc activate`，`arisc env run` 等价于 `arisc run`，`arisc env repair` 等价于 `arisc repair`，`arisc env remove` 等价于 `arisc del`。

`arisc env export --all` 会导出 base 和所有项目的环境清单。加 `--save` 会写入 `reports/aris-env-export-*.md` 或 `.json`，之后可用 `arisc reports --type env` 查看。

## 在项目环境中执行命令

```bash
eval "$(arisc activate lora)"
eval "$(arisc env activate lora)"
eval "$(arisc activate --no-env lora)"
arisc env run lora -- python -V
arisc run lora -- python -V
arisc run lora -- python scripts/evaluate.py
arisc run lora -- bash -lc 'pwd && python -m pip list | head'
arisc run --dry-run lora -- python scripts/evaluate.py
arisc run --no-env lora -- env
```

`arisc activate` 会输出可 `eval` 的 shell 片段，默认进入项目目录、加载项目 `.env`，并把项目 `.venv/bin` 放到 `PATH` 最前面。它类似 `conda activate`，适合让当前终端持续处于某个项目环境中；可用 `--no-env`、`--no-venv` 或 `--no-cd` 精简激活动作。

`arisc run` 会进入目标项目目录，默认加载项目 `.env`，并把项目 `.venv/bin` 放到 `PATH` 最前面，适合像 `conda run` 一样在指定科研环境里执行脚本或检查工具。它不启动 Codex、不 attach tmux、不发送消息。可用 `--no-env` 跳过 `.env`，用 `--no-venv` 跳过项目虚拟环境。

## base 中的协调技能

进入 base：

```bash
arisc base
arisc enter base
```

终端里也可以直接用 `arisc base` 命名空间做监控和接管：

```bash
arisc base status
arisc base agenda
arisc base summary
arisc base summary --json
arisc base auto llm-tokenizer -- "自动推进当前研究目标，并输出 base 监控摘要"
arisc base triage --with-pane --pane-lines 20
arisc base report --with-agenda --with-triage
arisc base snapshot
arisc base enter
```

`arisc base summary` 会列出当前告警、最新保存材料路径、最新 status/doctor/audit JSON 路径、查看命令和接管议程；`--json` 会把这些路径放在 `latest.snapshot`、`latest.report`、`latest.triage`、`latest.env`、`latest.status`、`latest.doctor` 和 `latest.audit` 字段里。

base 里可用这些协调技能：

```text
/aris-status [--json]
/aris-base [status|watch|alerts|agenda|summary|auto|triage|report|reports|snapshot|info|enter|doctor|audit|init] ...
/aris-alerts [--summary] [--json] [--sort severity|name]
/aris-agenda [--json] [--only blocked|attention|waiting|stopped]
/aris-triage [--with-pane] [--sort severity|name] [--save]
/aris-doctor [--json]
/aris-audit [--json]
/aris-inspect <slug> [--with-pane]
/aris-env [create|fork|list|info|export|activate|run|repair|remove] ...
/aris-activate <slug>
/aris-run <slug> -- <command...>
/aris-goal <slug> <goal...>
/aris-auto [--snapshot] [--summary] [--summary-json] [--summary-json-only] <slug> <goal...>
/aris-report [--with-pane] [--with-agenda] [--with-triage]
/aris-reports [--type report|triage|env|snapshot|status|doctor|audit|all] [--json] [--show latest|N]
/aris-info [slug|base] [--json]
/aris-send <slug> <message>
/aris-watch [--with-pane]
```

`/aris-status` 用于查看所有项目状态，基于 `arisc status --with-pane`，会汇总环境列表、goal 状态、告警摘要、tmux pane 和会话状态。需要脚本化判断时使用 `/aris-status --json`。

`/aris-base` 是 base 工作区统一入口，底层调用 `arisc base`；`/aris-base summary` 会输出最新保存材料和 status/doctor/audit JSON 路径：

```text
/aris-base
/aris-base agenda
/aris-base summary
/aris-base summary --json
/aris-base auto llm-tokenizer -- 自动推进当前研究目标，并输出 base 监控摘要
/aris-base report --with-agenda
/aris-base snapshot
/aris-base enter
```

`/aris-audit` 用于只读审计 CLI、README、help 和 base 技能是否同步：

```text
/aris-audit
/aris-audit --json
```

`/aris-doctor` 用于只读检查项目运行骨架、base 环境、workspace 模板、ARIS_REPO 和外部工具：

```text
/aris-doctor
/aris-doctor --json
```

`/aris-inspect` 用于只读诊断单个项目：

```text
/aris-inspect llm-tokenizer
/aris-inspect llm-tokenizer --with-pane --pane-lines 20
```

`/aris-env` 是类 `conda env` 的环境管理入口：

```text
/aris-env
/aris-env create llm-tokenizer
/aris-env fork ailab ailab-codex
/aris-env list --json
/aris-env info llm-tokenizer
/aris-env export llm-tokenizer
/aris-env export --all --save
/aris-env run llm-tokenizer -- python -V
```

`/aris-activate` 用于输出可 `eval` 的项目环境激活脚本：

```text
/aris-activate llm-tokenizer
/aris-activate --no-env llm-tokenizer
```

`/aris-run` 用于在指定项目目录和 `.venv` 环境中执行普通命令：

```text
/aris-run llm-tokenizer -- python -V
/aris-run --dry-run llm-tokenizer -- python scripts/evaluate.py
```

`/aris-info` 用于查看工作区或单项目环境信息：

```text
/aris-info
/aris-info llm-tokenizer
/aris-info --json
```

`/aris-alerts` 用于只读列出需要人工关注的项目：

```text
/aris-alerts
/aris-alerts --summary
/aris-alerts --json
/aris-alerts --only blocked
/aris-alerts --sort name
/aris-alerts --pane-lines 8
```

`/aris-agenda` 用于基于告警生成只读接管议程：

```text
/aris-agenda
/aris-agenda --only blocked
/aris-agenda --json
```

`/aris-triage` 用于只读汇总需要人工关注的项目并逐个诊断：

```text
/aris-triage
/aris-triage --sort name
/aris-triage --only blocked --with-pane --pane-lines 8
/aris-triage --save
```

`/aris-goal` 用于把持续目标投递给项目 Codex 会话：

```text
/aris-goal llm-tokenizer 阅读 RESEARCH_BRIEF.md，持续推进 /research-pipeline
```

`/aris-auto` 用于投递 goal 后立即输出 base 监控摘要：

```text
/aris-auto llm-tokenizer 阅读 RESEARCH_BRIEF.md，持续推进 /research-pipeline
/aris-auto --snapshot llm-tokenizer 阅读 RESEARCH_BRIEF.md，持续推进 /research-pipeline
/aris-auto --summary-json llm-tokenizer 阅读 RESEARCH_BRIEF.md，持续推进 /research-pipeline
/aris-auto --summary-json-only llm-tokenizer 阅读 RESEARCH_BRIEF.md，持续推进 /research-pipeline
/aris-auto --batch goals.tsv --dry-run
```

`/aris-report` 用于生成只读交接报告，默认不输出 pane 内容：

```text
/aris-report
/aris-report --with-agenda --no-doctor
/aris-report --with-triage --no-doctor
```

`/aris-reports` 用于查看 `arisc report --save` 保存的交接报告，也能查看 `arisc triage --save` 保存的接管诊断、`arisc env export --save` 保存的环境导出，以及 `arisc base snapshot` 保存的快照索引和诊断 JSON：

```text
/aris-reports
/aris-reports --show latest
/aris-reports --path current
/aris-reports --type triage
/aris-reports --type env
/aris-reports --type snapshot
/aris-reports --type status
/aris-reports --type doctor
/aris-reports --type audit
/aris-reports --type all
/aris-reports --type all --json
```

`/aris-send` 用于把一行消息发送到某个正在运行的项目 Codex 会话：

```text
/aris-send llm-tokenizer 继续整理实验计划，先给我一个三步执行表
```

`/aris-watch` 用于输出一屏只读监控状态：

```text
/aris-watch
/aris-watch --with-pane --pane-lines 3
```

## 更新 skills 和项目

同步当前 ARISC Git 记录的固定 ARIS skills commit，并收敛所有项目：

```bash
arisc update
```

只收敛项目，不更新 submodule：

```bash
arisc update --projects-only
```

只更新 submodule，不处理项目：

```bash
arisc update --repo-only
```

更新 base 模板和内置协调技能：

```bash
arisc base-init --force-templates
```

## 检查工作区

```bash
arisc doctor
arisc doctor --json
arisc audit
arisc audit --json
```

`arisc doctor` 会检查项目运行骨架：

- 项目是否有 `.codex/`。
- 项目是否有 `.agents/skills/`。
- 项目是否有 `.aris/installed-skills-codex.txt`。
- 是否残留旧 `.claude/`。
- 是否残留旧 `.aris/installed-skills.txt`。
- `uv`、`tmux`、`codex`、`git`、`jq` 是否在 PATH 中。

`arisc doctor --json` 会输出机器可读检查结果，包含 `workspace_root`、`aris_repo`、`projects`、`base`、`workspace`、`aris_repo_check`、`tools` 和 `ok`，适合 base、脚本或外部监控消费。

`arisc audit` 会检查工作区工具自身是否同步：

- 全局 `arisc` 是否指向当前 ARISC workspace。
- `bin/aris-*` 子命令是否存在、可执行、语法通过。
- `arisc` 分发器是否覆盖所有子命令。
- `README.md`、`help.md` 和 `arisc help` 是否覆盖所有子命令。
- base 技能模板和 `projects/.agents/skills/` 是否同步。
- Codex 模板中是否残留旧 `CLAUDE.md` 或 `.claude/`。

## 重命名项目

```bash
arisc rename old-name new-name
```

它会：

- 结束旧的 `aris-codex-old-name` tmux 会话。
- 移动项目目录。
- 更新 `pyproject.toml` 项目名。
- 更新 `.codex/aris.env`。
- 更新 `.aris/installed-skills-codex.txt`。
- 重新收敛 Codex skills 和 `AGENTS.md`。

## 删除和恢复项目

软删除项目：

```bash
arisc del llm-tokenizer
```

跳过确认：

```bash
arisc del llm-tokenizer --force
```

删除只是移动到 `.trash/`，不会删除 Codex 的全局会话历史。

查看回收站：

```bash
arisc restore --list
```

恢复最新快照：

```bash
arisc restore llm-tokenizer
```

恢复指定快照：

```bash
arisc restore llm-tokenizer --ts 20260523-010846
```

清理超过 30 天的回收站条目：

```bash
arisc purge
```

清理超过 7 天的回收站条目：

```bash
arisc purge --older-than 7
```

清空全部回收站条目：

```bash
arisc purge --all
```

## 常见问题

`arisc` 找不到：

```bash
~/arisc/install.sh
exec $SHELL -l
```

项目无法恢复旧会话：

```bash
arisc enter <slug> --new
```

项目 skills 缺失或链接悬空：

```bash
arisc repair <slug>
```

想确认整体是否正常：

```bash
arisc doctor
```

## 卸载 ARISC

默认保留项目、密钥和报告：

```bash
~/arisc/uninstall.sh --keep-data
```

预览卸载计划：

```bash
~/arisc/uninstall.sh --keep-data --dry-run
```

永久删除全部 ARISC 数据需要显式使用 `--purge` 并完成二次确认。需要 Agent 先检查和解释卸载范围时，使用根目录 `AGENT_UNINSTALL_PROMPT.md`。
