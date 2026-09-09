# Agent 项目指引兼容性

核对日期：2026-09-09。以下用于选择项目文件布局，不是要求修改客户端配置；特定版本与这里不符时，以安装版本的文档或源码为准。

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

## 局部规则的跨 agent 布局

有必要新增 `packages/mobile/AGENTS.md` 时，可同时创建 `packages/mobile/CLAUDE.md` 导入同目录 `@AGENTS.md`。在根 `AGENTS.md` 中明确写出：修改 `packages/mobile/` 前，读取 `packages/mobile/AGENTS.md`。

这样既有客户端可发现的局部入口，也有从根目录开始工作的明确阅读指引。局部文件只写该范围的差异，不复制根规则；仍应说明实际客户端加载尚未验证。
