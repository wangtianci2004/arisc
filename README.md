<div align="center">

# ARISC

### AI Research Workspace Manager for Codex

集成 AIRS 开箱即用的 AI Research 终端工具，一键创建你的专属科研工作区。

[![License: MIT](https://img.shields.io/badge/License-MIT-22c55e.svg)](LICENSE)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform: Linux, macOS & WSL2](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20WSL2-0f172a?logo=apple&logoColor=white)](#系统要求)
[![Version](https://img.shields.io/badge/version-0.1.0-6366f1.svg)](CHANGELOG.md)
[![GitHub Release](https://img.shields.io/github/v/release/wangtianci2004/arisc?display_name=tag)](https://github.com/wangtianci2004/arisc/releases/latest)
[![Code style: ShellCheck](https://img.shields.io/badge/style-ShellCheck-7c3aed.svg)](https://www.shellcheck.net/)

[快速开始](#快速开始) · [功能全景](#功能全景) · [命令参考](#命令参考) · [架构](#架构与目录) · [贡献](#参与贡献)

</div>

---

ARISC 是一个面向 Codex 的多项目 AI Research Workspace 管理平台。它把每个研究方向放进独立的 Git 仓库、Python 虚拟环境、Codex 技能集合与 tmux 会话中，同时提供统一的 base 控制面，用来投递目标、查看告警、生成交接报告、恢复项目和审计整个工作区。

它适合需要并行推进多个实验、让 AI 会话在后台持续工作、又希望每个项目保持可复现与可治理的研究者和工程团队。

> [!TIP]
> 请使用 [Agent 一键安装提示词](AGENT_INSTALL_PROMPT.md) 快速安装 ARISC。安装完成后即可直接使用 `arisc`。

## 为什么选择 ARISC

- **项目级隔离**：每个项目拥有独立目录、`.venv`、Git 历史、研究简报和 Codex 运行骨架。
- **一次配置，多项目复用**：密钥和 MCP 配置保存在本机 `shared/`，通过符号链接安全复用，不进入项目提交。
- **后台持续执行**：每个项目对应独立 tmux 会话，可分离、恢复、投递目标和发送后续指令。
- **工作区控制面**：`base` 环境统一展示状态、阻塞、待处理事项、报告和诊断材料。
- **可观测、可交接**：状态、告警、议程、triage、快照和 JSON 输出可供人或自动化系统消费。
- **生命周期完整**：创建、fork、重命名、软删除、恢复、永久清理与批量修复都有明确边界。
- **本地优先**：项目、报告、密钥和运行状态留在你的设备上；开源仓库只包含管理器与模板。
- **可审计**：内置 `doctor` 与 `audit` 检查工具链、链接、命令、文档和技能模板是否一致。

## 快速开始

### 系统要求

| 组件 | 要求 | 用途 |
| --- | --- | --- |
| 操作系统 | Linux、macOS 或 WSL2 | 正式支持的平台 |
| Bash | 4.4+ | CLI 运行时；macOS 使用 Homebrew Bash |
| Git | 2.x | 安装、更新和项目版本控制 |
| curl | 任意较新版本 | 一键模式缺少 `uv` 时调用官方安装器 |
| uv | 较新版本 | 创建轻量、快速的 Python 虚拟环境 |
| jq | 1.6+ | JSON 状态与诊断 |
| tmux | 3.x | 后台托管 Codex 会话 |
| Codex CLI | 当前稳定版 | 进入项目并执行 AI Research 工作流 |

`./install.sh --yes` 可以自动安装 `uv`；`git`、`curl`、`jq`、`tmux` 与 Codex CLI 请先通过系统或官方安装方式准备好。

#### Ubuntu / Debian / WSL2

```bash
sudo apt-get update
sudo apt-get install -y git curl jq tmux
```

#### macOS

macOS 需要 Homebrew Bash 4.4+。安装器和 `arisc` 入口会自动从 Apple Silicon 的 `/opt/homebrew/bin/bash` 或 Intel Mac 的 `/usr/local/bin/bash` 重新启动，无需修改系统 `/bin/bash`：

```bash
brew install bash jq tmux uv
```

如果尚未安装 Homebrew，请先按照 [Homebrew 官方安装文档](https://docs.brew.sh/Installation)完成安装。Codex CLI 仍需按其官方方式单独安装。

### 使用 Agent 安装或卸载

- [Agent 一键安装提示词](AGENT_INSTALL_PROMPT.md)：让终端 Agent 自动识别系统、安装依赖、初始化根目录 submodule 并完成验证。
- [Agent 安全卸载提示词](AGENT_UNINSTALL_PROMPT.md)：先备份或迁移研究数据，再精确移除 ARISC 命令、shell 配置、后台会话和工作区。

卸载提示词默认不会直接删除 `projects/`、`shared/`、`reports/`、`.trash/` 或 `config`；Agent 必须先让你选择备份、保留或永久删除。

普通用户也可以直接运行确定性的卸载器；默认会把本地数据移动到带时间戳的 `$HOME/arisc-data-*` 目录：

```bash
~/arisc/uninstall.sh --keep-data
```

### 新设备一键配置

在新设备执行下面的一键安装命令：

```bash
git clone --recurse-submodules https://github.com/wangtianci2004/arisc.git ~/arisc \
  && ~/arisc/install.sh --yes
```

需要固定安装首个稳定版本时使用：

```bash
git clone --branch v0.1.0 --recurse-submodules \
  https://github.com/wangtianci2004/arisc.git ~/arisc \
  && ~/arisc/install.sh --yes
```

安装器会：

1. 初始化 `projects/` 与 `shared/` 本地目录；
2. 注册 `~/.local/bin/arisc -> ~/arisc/bin/arisc`；
3. 初始化本机密钥与 MCP 配置模板；
4. 初始化并验证根目录 `aris-codex-skills` submodule；
5. 在需要时安装 `uv`；
6. 物化 base 控制面并运行健康检查。

加载新的 PATH，然后创建第一个项目：

```bash
exec "$SHELL" -l
arisc doctor
arisc enter base
arisc new my-first-research
arisc enter my-first-research
```

在项目中先编辑 `RESEARCH_BRIEF.md`，再通过 Codex 启动研究流程。tmux 中按 `Ctrl+B`、再按 `D` 即可安全分离；后台会话会继续运行。

### 默认 base 管理环境

ARISC 安装后会自动物化一个内置的 `base` 环境。它不是具体科研项目，而是提供给 Agent 的工作区控制环境，用于观察、管理和调度 `projects/` 下的所有研究项目：

```bash
arisc enter base
```

base Agent 会加载 `templates/base/skills/` 中的 ARISC Control Skills，因此能够理解并调用 `arisc status`、`alerts`、`agenda`、`goal`、`report`、`doctor`、`audit` 等管理命令。它适合处理“哪些项目被阻塞”“给项目投递下一步目标”“生成全局交接报告”“检查所有环境”等跨项目任务。

具体的文献、实验和论文工作仍应在独立项目中完成；这些项目使用 `aris-codex-skills` submodule 提供的 AIRS Research Skills：

```bash
arisc new my-research
arisc enter my-research
```

简单理解：`base` 负责管理项目，`projects/<slug>` 负责执行科研。

### 已克隆仓库的安装选项

```bash
./install.sh --yes                       # 推荐：非交互配置，必要时安装 uv
./install.sh --no-path                   # 不修改 Bash/Zsh 启动文件
./install.sh --repo-path /path/to/skills # 使用指定的研究技能仓库
./install.sh --skip-repo                 # 暂不配置研究技能仓库
./install.sh --skip-doctor               # 跳过安装后的健康检查
```

默认上游以根目录 Git submodule 管理，GitHub 会显示为 `aris-codex-skills @ <commit>`。高级用户仍可通过 `--repo-path` 临时使用自定义技能仓库。

### Shell completion

在 Bash 中启用当前终端补全：

```bash
source <(arisc completion bash)
```

在 Zsh 中启用当前终端补全：

```zsh
source <(arisc completion zsh)
```

补全支持顶层命令、常用参数和现有项目 slug。需要永久启用时，把对应 `source` 行加入自己的 shell rc。

## 功能全景

```text
                              ARISC base 控制面
                   status · alerts · agenda · reports
                                    │
             ┌──────────────────────┼──────────────────────┐
             │                      │                      │
      project-alpha           project-beta          project-gamma
      ├─ .venv                ├─ .venv               ├─ .venv
      ├─ Git                  ├─ Git                 ├─ Git
      ├─ Codex skills         ├─ Codex skills        ├─ Codex skills
      └─ tmux session         └─ tmux session        └─ tmux session
             │                      │                      │
             └──────────────────────┴──────────────────────┘
                       shared/.env · shared/mcp.json
```

一个典型的长期研究循环如下：

```bash
arisc new sparse-moe-routing
arisc goal sparse-moe-routing -- "完成文献综述并提出三个可证伪假设"
arisc status
arisc alerts --only blocked
arisc inspect sparse-moe-routing
arisc send sparse-moe-routing -- "优先验证第二个假设"
arisc report --save
```

## 命令参考

运行 `arisc help` 查看完整入口帮助，运行 `arisc <command> --help` 查看参数。当前公开接口包含以下全部命令。

### 项目生命周期

| 命令 | 说明 |
| --- | --- |
| `arisc new <slug>` | 创建独立项目、uv 环境、共享配置链接、Codex 技能与 Git 仓库 |
| `arisc fork <project> [new]` | 从已有研究工作区复制项目并迁移到 Codex 骨架 |
| `arisc rename <old> <new>` | 原地重命名项目并更新相关运行元数据 |
| `arisc del <slug>` | 软删除项目到 `.trash/`，同时结束对应 tmux 会话 |
| `arisc restore <slug>` | 从回收站恢复项目 |
| `arisc purge --older-than <days>` | 永久清理超过指定天数的回收站条目 |
| `arisc repair <slug...>` | 为已有项目补齐链接、环境、Codex 目录和技能清单 |
| `arisc path <slug>` | 输出项目绝对路径，适合 `cd "$(arisc path demo)"` |

项目 slug 使用 kebab-case，例如 `llm-tokenizer` 或 `nas-routing-mac`。`base` 是保留名称。

### 运行与会话

| 命令 | 说明 |
| --- | --- |
| `arisc enter <slug>` | 创建或连接 tmux 托管的 Codex 会话 |
| `arisc enter base` | 进入工作区级 base Codex 环境 |
| `arisc goal <slug> -- <text>` | 向项目会话投递 `/goal` 并确保后台运行 |
| `arisc auto <slug> -- <text>` | 投递 goal 后立即输出 base 监控摘要 |
| `arisc send <slug> -- <message>` | 向正在运行的项目发送单行指令 |
| `arisc run <slug> -- <command>` | 在项目目录和 `.venv` 环境中执行命令 |
| `arisc activate <slug>` | 输出可由 `eval` 使用的环境激活脚本 |

自动化场景还可以使用：

```bash
arisc auto --snapshot demo -- "继续实验并保存接管材料"
arisc auto --summary-json demo -- "推进任务并输出摘要 JSON"
arisc auto --summary-json-only demo -- "只输出机器可读摘要"
arisc goal --status --json
```

### 监控、诊断与交接

| 命令 | 说明 |
| --- | --- |
| `arisc status` | 输出一屏工作区总览；支持 `--json` |
| `arisc watch` | 持续刷新环境、goal 与 tmux 状态；支持只看一次 |
| `arisc alerts` | 显示 blocked、attention、waiting 或 stopped 项目 |
| `arisc agenda` | 为需要人工处理的项目生成只读接管议程 |
| `arisc triage` | 聚合异常项目，并逐个生成 inspect 诊断；支持保存 |
| `arisc inspect <slug>` | 诊断单个项目的骨架、goal、tmux、Git 和 pane 状态 |
| `arisc info [slug]` | 输出工作区或指定项目的环境信息 |
| `arisc report` | 生成只读交接报告；`--save` 更新稳定入口 |
| `arisc reports` | 列出或读取已保存的报告、诊断和快照材料 |
| `arisc ls` | 列出项目阶段与 tmux 状态；支持 `--json` |
| `arisc doctor` | 检查外部工具、路径、链接、项目骨架与本机配置 |
| `arisc audit` | 审计 CLI、帮助、README 和 base 技能是否同步 |

报告支持按类型筛选和机器读取：

```bash
arisc reports --type triage
arisc reports --type env
arisc reports --type snapshot
arisc reports --type status
arisc reports --type doctor
arisc reports --type audit
arisc reports --type all --json
arisc reports --path current
```

### base 控制面

`base` 是 ARISC 默认提供的 Agent 管理环境。`arisc base ...` 适合从普通终端直接调用控制功能，`arisc enter base` 或 `arisc base enter` 则进入持久化的 base Codex 会话，让 Agent 使用内置 Control Skills 管理其他所有环境。base 只负责跨项目观察、调度、诊断与交接，不承载具体科研实现。

| 命令 | 说明 |
| --- | --- |
| `arisc base` | 默认输出统一工作区总览 |
| `arisc base status` | 查看一次 base 状态 |
| `arisc base watch` | 持续监控工作区 |
| `arisc base alerts` | 聚合需要人工注意的项目 |
| `arisc base agenda` | 生成接管议程 |
| `arisc base summary` | 输出适合快速接管的短摘要 |
| `arisc base auto` | 从 base 入口执行自动投递流程 |
| `arisc base triage` | 聚合诊断异常项目 |
| `arisc base report` | 生成工作区交接报告 |
| `arisc base reports` | 浏览保存材料 |
| `arisc base snapshot` | 保存报告、环境导出、status/doctor/audit JSON 与索引 |
| `arisc base info` | 显示 base 工作区信息 |
| `arisc base enter` | 进入 base Codex 会话 |
| `arisc base doctor` | 执行工作区健康检查 |
| `arisc base audit` | 执行一致性审计 |
| `arisc base init` | 物化或修复 base 环境 |
| `arisc base-init` | 直接调用底层 base 初始化器 |

`arisc base summary --json` 会同时给出最新保存材料和诊断 JSON 路径，方便外部控制器找到 `latest.status`、`latest.doctor` 与 `latest.audit`。`arisc base snapshot` 则把一次接管所需材料原子化保存到 `reports/`。

### 环境管理

`arisc env` 提供类似 conda 的统一命名空间：

```bash
arisc env list [--json]
arisc env create <slug>
arisc env fork <source> [new]
arisc env info [slug]
arisc env export [slug|--all] [--save]
arisc env activate <slug>
arisc env run <slug> -- <command>
arisc env repair <slug...>
arisc env remove <slug>
arisc env rename <old> <new>
arisc env restore <slug>
arisc env path <slug>
```

顶层 `arisc env` 命令只做路由，底层行为与对应生命周期命令保持一致。

### 仓库与更新

| 命令 | 说明 |
| --- | --- |
| `arisc repo` | 初始化、选择或更新 ARIS Codex 研究技能仓库 |
| `arisc repo status` | 查看根目录 submodule 的远端、提交与 Codex 链路状态 |
| `arisc repo setup [path]` | 默认初始化根目录 submodule；也可验证自定义仓库路径 |
| `arisc update` | 同步 ARISC Git 固定的 submodule commit，并收敛所有项目技能链接 |
| `arisc completion bash` | 输出 Bash completion 脚本 |
| `arisc completion zsh` | 输出 Zsh completion 脚本 |

设备专属的绝对路径写在根目录 `config` 中，该文件被 Git 忽略。发布仓库不会包含维护者机器上的路径。

普通用户执行 `arisc update` 时只会同步当前 ARISC 版本记录的固定 gitlink，从而保证同一 ARISC commit 使用同一套 Research Skills。仓库的定时 GitHub Actions 每天北京时间 06:00 检查官方 ARIS `main`；发现新提交后，机器人会更新 `wangtianci2004/arisc` 中的 gitlink 并触发完整 CI。用户下一次 `git pull` 后即可获得经过 ARISC 仓库记录的新固定版本。

## 架构与目录

```text
~/arisc/
├── bin/                  # arisc 分发器与全部 aris-* 子命令
├── aris-codex-skills/    # 官方 ARIS skills submodule（GitHub 显示 path @ commit）
├── templates/            # 项目、共享配置和 base 技能模板
├── tests/                # 隔离烟雾测试
├── projects/             # 本机项目与 base 控制面（Git ignored）
│   ├── .codex/
│   ├── .agents/skills/
│   └── <slug>/
├── shared/               # 本机密钥、MCP 配置与共享技能（Git ignored）
├── reports/              # 保存的交接材料（Git ignored）
├── .trash/               # 软删除项目（Git ignored）
├── config                # 设备专属 ARIS_REPO 路径（Git ignored）
├── install.sh            # 幂等安装器
├── VERSION
└── LICENSE
```

每个 `arisc new <slug>` 创建的项目结构：

```text
projects/<slug>/
├── .agents/skills/       # 项目可用的 Codex skills
├── .aris/                # 技能安装清单与工具链接
├── .codex/aris.env       # ARISC 项目运行元数据
├── .env -> shared/env    # 本机共享密钥，不提交
├── .mcp.json -> shared/mcp.json
├── .venv/                # uv 虚拟环境
├── .git/                 # 独立 Git 历史
├── AGENTS.md             # Codex 项目指令
├── RESEARCH_BRIEF.md     # 研究问题、约束与交付物
└── pyproject.toml
```

### 设计边界

- ARISC 管理工作区与运行生命周期，不替代 Codex CLI、Git、uv 或 tmux。
- `projects/` 中的每个项目是独立 Git 仓库；根仓库只发布管理平台本身。
- `.env` 与 `.mcp.json` 是到本机共享配置的链接，不应提交到项目仓库。
- 删除默认是可恢复的软删除；永久清理必须显式运行 `purge`。
- JSON 输出是自动化接口；面向人的输出可能随可读性改进而调整。

## 多设备迁移

在新设备执行一键安装，然后只迁移你真正需要的本地状态：

1. 从各自远端重新克隆 `projects/<slug>` 中的项目仓库，或安全复制项目目录；
2. 手动填写新设备的 `shared/env`，不要通过 Git 同步密钥；
3. 按设备调整 `shared/mcp.json`；
4. 运行 `arisc repair <slug...>` 重建符号链接、虚拟环境和 Codex 技能；
5. 运行 `arisc doctor` 与 `arisc audit` 验证新设备。

如果只是平台升级：

```bash
git -C ~/arisc pull --ff-only
git -C ~/arisc submodule update --init --recursive
~/arisc/install.sh --yes
arisc update
arisc doctor
```

## 故障排查

### `arisc` 不在 PATH

```bash
exec "$SHELL" -l
command -v arisc
ls -l ~/.local/bin/arisc
```

安装器默认更新 `~/.bashrc` 或 `~/.zshrc`。若使用 `--no-path`，请自行将 `~/.local/bin` 加入 PATH。

### `arisc new` 提示 ARIS_REPO 不存在

```bash
arisc repo setup
arisc repo status
```

默认路径应为 `~/arisc/aris-codex-skills`。如果 submodule 未初始化，运行 `arisc repo setup` 即可恢复。

### 项目骨架或链接异常

```bash
arisc inspect <slug>
arisc repair <slug>
arisc doctor
```

`repair` 不会静默覆盖已有的普通 `.env` 或 `.mcp.json` 文件；遇到冲突时会停止并要求人工确认。

### tmux 会话问题

```bash
arisc enter --list
arisc enter <slug>
arisc enter --kill <slug>
```

### 发布前自检

```bash
make check
WORKSPACE_ROOT="$PWD" arisc audit
git status --short
```

烟雾测试使用临时 HOME、临时技能仓库与假的 `uv`，不会创建真实研究项目，也不会修改你的用户配置。

## 安全与隐私

> [!WARNING]
> `shared/env` 可能包含 API 密钥。它和 `shared/mcp.json`、`config`、`projects/`、`reports/` 默认都被根仓库忽略。发布前仍应人工检查 `git diff --cached`。

- 只通过 `arisc repo setup` 配置你信任的技能仓库；技能安装器会在本机执行代码。
- 不要把 `.env`、私有数据集、会话日志或带凭据的诊断输出粘贴到 Issue。
- 发现安全问题时请按 [SECURITY.md](SECURITY.md) 使用私密渠道报告。
- `arisc audit` 是一致性检查，不是恶意代码扫描器或沙箱。

安全卸载：

```bash
~/arisc/uninstall.sh --keep-data   # 移出并保留本地数据
~/arisc/uninstall.sh --backup "$HOME/arisc-backup" # 备份后卸载
~/arisc/uninstall.sh --purge       # 二次确认后永久删除全部数据
```

## 参与贡献

欢迎提交 bug 修复、平台兼容改进、测试、文档和研究工作流建议。

```bash
git clone <your-fork-url>
cd arisc
make check
```

提交 Pull Request 前请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 与 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。命令行为发生变化时，应同步更新 `bin/arisc`、`help.md`、README 和测试。

## 路线图

- 更完整的发行包与固定版本升级通道；
- 持续扩展 Linux、macOS 与 WSL2 的跨平台回归覆盖；
- Shell completion 与更稳定的机器可读 schema；
- 可选的远程运行节点和跨设备只读控制面；
- 更丰富的端到端恢复与迁移测试。

路线图不构成发布承诺。欢迎在 GitHub Discussions 或 Feature Request 中说明真实研究场景。

## 致谢

ARISC 的 AIRS 研究工作流与 Codex Skills 集成建立在开源项目 [wanshuiyin/Auto-claude-code-research-in-sleep](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) 的工作基础上。

特别感谢 ARIS / AIRS 项目的作者与所有贡献者，为自动化科研流程、研究技能体系和持续运行的 AI Research 实践提供了重要基础。ARISC 在此之上专注于多项目工作区隔离、环境管理、后台会话、可观测性与跨设备配置。

## 许可证

ARISC 以 [MIT License](LICENSE) 开源。你可以自由使用、复制、修改、合并、发布和分发本项目，但需保留版权与许可声明。

第三方工具和 ARIS Codex 研究技能仓库保留其各自许可证；使用者应独立确认相关条款。

---

<div align="center">

**让每一个 AI Research 项目都可隔离、可追踪、可恢复。**

</div>
