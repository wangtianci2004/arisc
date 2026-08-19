# 用 Agent 一键安装 ARISC

将下面的提示词完整复制给具备终端操作能力的 Agent（例如 Codex、Claude Code 或 Cursor Agent）。Agent 会识别系统、安装依赖、配置 ARISC，并验证唯一的 `arisc` 命令入口。

```text
请直接在当前设备上完整安装并配置 ARISC，不要只给我安装教程。

项目仓库：
https://github.com/wangtianci2004/arisc

完成标准：安装结束后，我可以在新终端中直接使用：

  arisc --version
  arisc help
  arisc new <project-slug>

请按以下要求执行：

1. 自动识别 Ubuntu、Debian、WSL2、macOS Apple Silicon 或 macOS Intel。

2. 检查 Git、curl、Bash 4.4+、jq、tmux、uv、rsync 和 Codex CLI，只安装缺失的依赖。

3. 在 Ubuntu、Debian 或 WSL2 上，缺少系统依赖时使用：

   sudo apt-get update
   sudo apt-get install -y git curl jq tmux rsync

4. 在 macOS 上使用：

   brew install bash jq tmux uv rsync

   不要替换系统 /bin/bash。ARISC 会自动使用 Apple Silicon 的 /opt/homebrew/bin/bash 或 Intel Mac 的 /usr/local/bin/bash。

5. 安装目录固定为：

   ~/arisc

6. 如果目录不存在，执行：

   git clone --recurse-submodules https://github.com/wangtianci2004/arisc.git ~/arisc

7. 如果目录已经存在：
   - 不要删除 projects、shared、reports、config 或 .trash；
   - 先检查 Git 状态；
   - 平台代码没有未提交修改时，执行 git -C ~/arisc pull --ff-only；
   - 随后执行 git -C ~/arisc submodule update --init --recursive；
   - 存在未提交的平台代码修改时，不要覆盖，先向我报告。

8. 执行一键安装：

   ~/arisc/install.sh --yes

   安装器必须初始化根目录的 ~/arisc/aris-codex-skills submodule，不要把上游克隆到 ~/work 或其他工作区外目录。

9. 让当前终端立即识别命令入口：

   export PATH="$HOME/.local/bin:$PATH"

10. 验证 `arisc` 属于当前 ARISC 项目：

    command -v arisc
    ls -l "$HOME/.local/bin/arisc"
    arisc --version
    arisc help

11. 继续验证工作区：

    arisc repo status
    arisc doctor
    WORKSPACE_ROOT="$HOME/arisc" arisc audit

12. 安全要求：
    - 不要读取、打印或提交 shared/env 中的 API Key；
    - 不要提交 projects、shared、reports、config、.trash 或 vendor；
    - 不要删除已有研究项目；
    - 不要覆盖已有的普通 .env 或 .mcp.json；
    - 不要使用 git reset --hard；
    - sudo 只能用于安装明确缺失的系统依赖。

13. 如果项目 slug 由我提供，并且项目尚不存在，可以执行：

    arisc new <project-slug>

    如果没有提供项目 slug，不要擅自创建示例项目。

14. 只有在全部验证通过后才报告成功。最终报告必须包含：
    - 操作系统与 Bash 版本；
    - ARISC 版本与安装路径；
    - arisc 的命令路径；
    - ARIS/AIRS 技能仓库路径；
    - Git、uv、jq、tmux 与 Codex CLI 状态；
    - doctor 与 audit 结果；
    - 是否可以直接使用 arisc new。

如果安装过程中遇到错误，请读取完整错误、定位根因、修复后重新运行验证。不要在验证失败时声称安装成功。
```

安装成功后，使用 `arisc` 创建并进入项目：

```bash
arisc new my-research-project
arisc enter my-research-project
```
