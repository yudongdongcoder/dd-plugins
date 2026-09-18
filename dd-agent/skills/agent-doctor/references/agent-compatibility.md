# Agent 项目指引兼容性

核对日期：Codex、Claude Code、Pi 为 2026-09-09，WorkBuddy 为 2026-09-18。以下用于选择项目文件布局，不是要求修改客户端配置；特定版本与这里不符时，以安装版本的文档或源码为准。

## Codex

- 默认读取 `AGENTS.md`。同一目录中的非空 `AGENTS.override.md` 优先，因此仅更新 `AGENTS.md` 可能不起作用。
- 启动时按全局及项目目录链构建指引；项目通常从仓库根目录到当前工作目录逐层发现。不要把“根目录启动”理解成所有深层规则都已经加载。
- 默认项目指引累计大小上限为 32 KiB，可由配置调整；保持入口简洁，不为初始化擅自调整全局上限。
- `@AGENTS.md` 是这里用于 Claude 的导入机制，不是 Codex 的通用 Markdown 导入机制。

来源：[Codex AGENTS.md 官方说明](https://learn.chatgpt.com/docs/agent-configuration/agents-md)。

## Claude Code

- 使用 `CLAUDE.md` 作为入口，通过正文中的 `@AGENTS.md` 导入同目录公共文件。导入路径相对包含该导入的文件解析。
- 可以在导入后保留 Claude 专属指引；不要同时复制公共全文。
- 支持祖先目录指引，并在读取子目录文件时加载对应的子目录指引；现有 `.claude/CLAUDE.md`、`.claude/rules/` 和 `CLAUDE.local.md` 也要考虑，避免重复或矛盾。
- 已有 `.claude/CLAUDE.md` 若被保留为入口，其到根目录公共文件的相对导入是 `@../AGENTS.md`；不要机械套用同目录路径。
- 可在新会话使用 `/context` 检查 Memory files 中的入口。

来源：[Claude Code 项目记忆官方说明](https://code.claude.com/docs/en/memory)。

## Pi

- 指 pi-mono 的 coding agent（目前 npm 包名为 `@earendil-works/pi-coding-agent`）。它在启动时从全局、祖先目录和当前目录读取项目上下文，支持 `AGENTS.md` 或 `CLAUDE.md`。
- 当前版本支持同目录 `AGENTS.override.md` 替代该目录的 `AGENTS.md` 或 `CLAUDE.md`；覆盖只作用于所在目录，其他目录的上下文文件仍会拼接进来。存在覆盖文件时先核实实际加载结果。
- 默认使用根目录 `AGENTS.md` 即可，不依赖 Pi 解析 Claude 的 `@` 导入。
- `.pi/SYSTEM.md` 会替换默认系统提示，不是普通项目指引初始化所需的文件。`--no-context-files` 会禁用上下文文件发现。
- 不假定从仓库根目录启动后，会自动发现后续访问的所有子目录上下文。可在新会话启动信息中检查已加载的项目指引。

来源：[Pi 官方 README：Context Files](https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/README.md#context-files)。

## WorkBuddy / CodeBuddy Code

- WorkBuddy 桌面端以内置的 CodeBuddy Code CLI 作为运行时，两者共用同一套项目发现规则。差别只在用户级配置目录：桌面端给 CLI 传 `CODEBUDDY_CONFIG_DIR=~/.workbuddy`，单独安装的 CLI 默认 `~/.codebuddy`。项目级配置目录两种情况下都是 `<工作目录>/.codebuddy`。
- 项目主指引按 `CODEBUDDY.md`、`CODEBUDDY.mdc`、`AGENTS.md`、`AGENTS.mdc` 的顺序取**首个命中**，同一目录只加载一份，随后用同样顺序再看该目录下的 `.codebuddy/`。因此只维护 `AGENTS.md` 就能被读取；新增 `CODEBUDDY.md` 会让同目录 `AGENTS.md` 不再加载。
- 主指引沿从文件系统根到工作目录的每一层目录各取一份，不在仓库根停止。工作目录上方的个人目录若有 `AGENTS.md`，同样会进入上下文；判断实际生效内容时要看整条路径，而不只是仓库根。
- `CODEBUDDY.local.md` 是工作目录的个人本地文件。`<工作目录>/.codebuddy/rules/` 下的 `.md` 和 `.mdc` 递归加载（跟随符号链接），frontmatter 的 `paths:` 限定生效文件范围，`alwaysApply` 控制是否无条件注入。
- 正文支持 `@路径` 导入，语义与 Claude Code 一致：相对路径按当前文件所在目录解析，也接受 `~/` 和绝对路径，代码块内的 `@` 不展开，导入深度上限 5。
- 单个指引或规则文件超过 40000 字符会被整份丢弃，不是截断；拆分文件或改用 `@` 导入。
- 桌面端在会话首轮还会额外注入一段 `project_context`：只取首个命中的主指引文件原文，在 8000 字符处截断，并且**不展开** `@` 导入。所以把公共正文全部藏在 `CODEBUDDY.md` 的一行导入后面时，CLI 能读到而桌面端首轮读不到。
- Skill 只从 `<工作目录>/.codebuddy/skills/` 和用户级 `<配置目录>/skills/` 发现，不扫描 `.agents/skills` 或 `.claude/skills`。
- `.codebuddy/settings*.json`、`.codebuddy/rules/`、`.codebuddy/agents/`、`.codebuddy/commands/`、`CODEBUDDY.md` 在该端属于“agent 自身配置”，在 WorkBuddy 或 CodeBuddy Code 会话里修改会被判定为自我修改并要求确认。

来源：WorkBuddy 5.5.6 应用包内 `workbuddy-server` 的 project-context、project-config 实现，以及内置 agent-cli（`@tencent-ai/codebuddy-code` 2.137.1）的 memory loader 与 skill provider 实现。核对方式是读打包代码，未在客户端实际加载验证。

## 局部规则的跨 agent 布局

有必要新增 `packages/mobile/AGENTS.md` 时，可同时创建 `packages/mobile/CLAUDE.md` 导入同目录 `@AGENTS.md`。在根 `AGENTS.md` 中明确写出：修改 `packages/mobile/` 前，读取 `packages/mobile/AGENTS.md`。

这样既有客户端可发现的局部入口，也有从根目录开始工作的明确阅读指引。局部文件只写该范围的差异，不复制根规则；仍应说明实际客户端加载尚未验证。

WorkBuddy 只在工作目录位于该子目录内时才会读到它的 `packages/mobile/AGENTS.md`，从仓库根启动的会话不会自动加载；根 `AGENTS.md` 里的按需读取提示对它同样必要。
