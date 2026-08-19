# 用 Agent 安全卸载 ARISC

将下面的提示词完整复制给具备终端操作能力的 Agent。它会先识别和备份本地研究数据，再移除 ARISC 命令、shell 配置、后台会话、根目录 submodule 与工作区。

ARISC 同时提供确定性的 `~/arisc/uninstall.sh`。Agent 应先完成路径与数据检查，再根据用户选择调用 `--keep-data`、`--backup DIR` 或 `--purge`，而不是自行拼接宽泛删除命令。

```text
请帮我从当前设备安全、完整地卸载 ARISC。先检查和展示计划，得到我的明确确认后再执行删除，不要只给我卸载教程。

ARISC 默认目录：
  ~/arisc

安全规则：
1. 只允许操作解析后的精确目录 "$HOME/arisc"，禁止对 $HOME、~、/、/Users、/home 或任何父目录执行递归删除。
2. 先确认目标同时满足：
   - 是 Git 仓库；
   - origin 指向 https://github.com/wangtianci2004/arisc.git；
   - 存在 bin/arisc、install.sh、README.md 和 .gitmodules。
3. 检查 projects、shared、reports、.trash 和 config。这些可能包含项目、API Key、报告和设备配置，绝不能未经确认直接删除。
4. 不要读取、输出或复制 shared/env 中的密钥内容。
5. 不要删除 ~/.codex、其他 Git 仓库、系统 Bash、Homebrew、uv、jq、tmux 或 Codex CLI。
6. 不要删除任何不属于 ARISC 的 ~/.local/bin/arisc 普通文件或符号链接。

执行流程：

1. 解析并展示：
   - ARISC 根目录；
   - Git remote 与当前分支；
   - ~/.local/bin/arisc 的类型和目标；
   - projects、shared、reports、.trash 的存在情况和大小；
   - 名称以 aris-codex- 开头的 tmux 会话。

2. 询问我选择一种数据策略：
   A. 备份后卸载（推荐）；
   B. 保留数据目录，仅移除命令和 shell 配置；
   C. 永久删除全部 ARISC 数据。

   确认后优先调用对应命令：
   - A：`~/arisc/uninstall.sh --keep-data --yes`
   - B：`~/arisc/uninstall.sh --backup <确认的目录> --yes`
   - C：`~/arisc/uninstall.sh --purge --yes`

3. 如果选择 A：
   - 在 $HOME 下创建带时间戳的备份目录，例如 $HOME/arisc-backup-YYYYMMDD-HHMMSS；
   - 只复制 projects、shared、reports、.trash 和 config；
   - 保持权限和符号链接；
   - 不在终端打印文件内容；
   - 验证备份目录存在且非空后才继续。

4. 如果选择 B：
   - 将需要保留的数据移动到 $HOME/arisc-data-YYYYMMDD-HHMMSS；
   - 验证移动目标位于 $HOME 下且不是 $HOME 本身。

5. 如果选择 C：
   - 再次明确列出将永久删除的 projects、shared、reports、.trash 和 config；
   - 要求我输入明确确认；
   - 未得到确认时立即停止。

6. 结束 ARISC tmux 会话：
   - 只处理名称以 aris-codex- 开头、且 pane 当前目录位于 $HOME/arisc/projects 内的会话；
   - 不结束其他 tmux 会话。

7. 删除全局命令时必须先验证：
   - $HOME/.local/bin/arisc 是符号链接；
   - 解析目标等于 $HOME/arisc/bin/arisc；
   - 只有两项都满足时才删除该符号链接。

8. 从 ~/.bashrc 和 ~/.zshrc 中删除安装器管理的精确区块：
   # >>> aris-codex workspace >>>
   ...
   # <<< aris-codex workspace <<<

   修改前创建带时间戳备份。不要删除区块外的任何 shell 配置。

9. 在数据已经备份、迁移或明确批准永久删除后，重新解析 $HOME/arisc，确认仍是预期目录，然后删除 ARISC 根目录。根目录中的 aris-codex-skills submodule 会随工作区一起删除，不要另外操作其他上游仓库。

10. 验证卸载结果：
    - command -v arisc 不再指向 $HOME/arisc；
    - $HOME/.local/bin/arisc 不存在，或属于其他软件且未被修改；
    - $HOME/arisc 不存在；
    - shell rc 中不再包含 ARISC 管理区块；
    - 非 ARISC tmux 会话保持运行；
    - 如果选择备份或保留数据，输出备份/数据目录路径，但不要输出其中的密钥内容。

最终请报告每一项删除、保留或备份的内容。任何路径验证不通过时停止，不要尝试猜测或扩大删除范围。
```
