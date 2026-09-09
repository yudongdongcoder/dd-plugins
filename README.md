# DD Plugins

DD Plugins 是一组面向 AI coding agent 的本地插件集合，提供项目 AI 规范诊断、中文 PRD 驱动开发流程和 iOS 模块维护辅助能力。

当前仓库同时维护三端元数据：

- Codex：`.agents/plugins/marketplace.json`、各插件的 `.codex-plugin/plugin.json`、各 skill 的 `agents/openai.yaml`
- Claude：`.claude-plugin/marketplace.json`、各插件的 `.claude-plugin/plugin.json`
- Pi：无独立清单，按 skill 目录用 `--skill <绝对路径>` 加载

在本仓库开发 skill 的约定见 [AGENTS.md](AGENTS.md)（`CLAUDE.md` 通过 `@AGENTS.md` 导入同一份内容）。

## 插件列表

| 插件 | 用途 | 主要能力 |
| --- | --- | --- |
| `dd-prd-flow` | PRD 驱动的需求到实现工作流 | 创建 PRD、生成功能规格、制定实施计划、拆解任务、校验文档一致性、按任务逐步实现 |
| `dd-modules` | 实用开发模块集合 | 格式化 CocoaPods podspec、生成中文更新日志、发布 CocoaPods 版本 |
| `dd-agent` | 跨 agent 项目规范诊断与修复 | 初始化项目指引、统一 skill 实体目录、修复链接与重复内容 |

## 目录结构

```text
.
├── AGENTS.md                             # 本仓库的开发约定（三端公用）
├── CLAUDE.md                             # 仅一行 @AGENTS.md
├── scripts/check-plugins.sh              # 三端元数据一致性校验
├── scripts/gen-assets.py                 # 生成各插件 icon.png / logo.png
├── .agents/plugins/marketplace.json      # Codex 本地插件市场入口
├── .claude-plugin/marketplace.json       # Claude 本地插件市场入口
├── dd-prd-flow/
│   ├── .codex-plugin/plugin.json
│   ├── .claude-plugin/plugin.json
│   ├── assets/
│   └── skills/<skill-name>/
│       ├── SKILL.md
│       └── agents/openai.yaml            # Codex 展示元数据
├── dd-modules/
│   ├── .codex-plugin/plugin.json
│   ├── .claude-plugin/plugin.json
│   ├── assets/
│   └── skills/<skill-name>/
│       ├── SKILL.md
│       └── agents/openai.yaml
└── dd-agent/
    ├── .codex-plugin/plugin.json
    ├── .claude-plugin/plugin.json
    ├── assets/
    └── skills/agent-doctor/
        ├── SKILL.md
        ├── agents/openai.yaml
        └── references/
```

`dd-prd-flow` 的 skill 为 `create-prd`、`generate-spec`、`plan-feature`、`generate-tasks`、`validate-flow`、`implement-feature`、`orchestrate-feature`；`dd-modules` 的 skill 为 `podspec-formatter`、`update-changelog`、`cocoapods-release`。

## `dd-prd-flow`

`dd-prd-flow` 将产品想法逐步推进到可实现、可验证的任务清单。默认使用中文生成文档，并保留 `feature id`、文件路径、API 名称、命令和代码符号的原文。

标准流程：

```text
PRD -> feature spec -> implementation plan -> task checklist -> validation -> implementation
```

### 技能说明

| Skill | 默认产物 | 适用场景 |
| --- | --- | --- |
| `create-prd` | `docs/PRD.md` | 将产品想法、需求讨论或草稿整理成中文 PRD |
| `generate-spec` | `docs/specs/<feature-id>.md` | 从 PRD 中展开单个功能规格 |
| `plan-feature` | `docs/tasks/<feature-id>-plan.md` | 结合现有代码生成代码感知实施计划，不修改业务代码 |
| `generate-tasks` | `docs/tasks/<feature-id>-tasks.md` | 将规格和可选计划拆成可执行任务清单 |
| `validate-flow` | 报告或最小文档修复 | 校验 PRD、spec、plan、tasks 的一致性和实现就绪度 |
| `implement-feature` | 代码、测试、任务进度更新 | 按任务清单实现下一个未完成任务 |
| `orchestrate-feature` | 自动选择下一阶段 | 根据当前仓库文档状态推进最合适的一步 |

### 使用示例

```text
根据这次讨论创建中文 PRD
```

```text
从 docs/PRD.md 为 auth-login 生成功能规格
```

```text
为 auth-login 生成代码感知实施计划
```

```text
把 auth-login 拆成开发任务
```

```text
检查 auth-login 的 PRD flow 是否一致
```

```text
继续实现 auth-login 的下一个未完成任务
```

## `dd-modules`

`dd-modules` 面向 iOS 模块维护，处理常见发布和元数据整理工作。

### 技能说明

| Skill | 适用场景 |
| --- | --- |
| `podspec-formatter` | 查找并整理仓库内 `.podspec` 文件，统一版本来源、homepage/source、license 和内部依赖声明 |
| `update-changelog` | 根据 git commit 历史生成面向用户的中文更新日志、发布说明或 App Store 更新文案 |
| `cocoapods-release` | 在明确调用后检查发布前提，更新版本与 changelog，创建 release commit/tag，并按 `PODSPEC` 顺序发布 podspec |

### 使用示例

```text
整理这个仓库里的 podspec 文件
```

```text
根据最近一次 tag 到 HEAD 的提交生成中文更新日志
```

```text
/cocoapods-release patch
```

## `dd-agent`

`dd-agent` 是独立插件，包含 `agent-doctor` skill，面向 Claude Code、Codex 和 Pi 项目的 AI 指引与 skill 规范管理。

### 使用示例

```text
使用 agent-doctor 检查并修复当前项目的 AI 规范，统一 Claude、Codex 和 Pi 的项目指引与 skill 目录
```

`agent-doctor` 默认诊断并修复不符合规范的项目，也支持明确要求“只检查”。公共指引保存在 `AGENTS.md`，由 `CLAUDE.md` 导入；项目 skill 完整实体统一到 `.agents/skills/<name>/`，`.claude/skills/<name>` 使用相对符号链接。当前 Pi 直接读取 `.agents/skills`，无需额外镜像。迁移保留资源和人工内容，无法确定的同名冲突单独报告。完整说明见 [SKILL.md](dd-agent/skills/agent-doctor/SKILL.md)。

Codex 和 Claude 可通过独立的 `dd-agent` 插件发现该 skill。Pi 可在目标项目目录启动时使用 `--skill /本仓库绝对路径/dd-agent/skills/agent-doctor` 加载，然后调用 `/skill:agent-doctor`；此处的路径需替换为本机实际路径。

## 安装与使用

本仓库以本地插件源形式组织。插件入口已经写入：

- Codex 插件市场：`.agents/plugins/marketplace.json`
- Claude 插件市场：`.claude-plugin/marketplace.json`

在支持本地插件源的客户端中导入本仓库后，可安装：

- `dd-prd-flow`
- `dd-modules`
- `dd-agent`

也可以直接使用单个插件目录作为本地插件源：

- `./dd-prd-flow`
- `./dd-modules`
- `./dd-agent`

## 维护约定

新增或调整插件时，需要同步检查以下位置：

- 插件目录下的 `.codex-plugin/plugin.json`
- 插件目录下的 `.claude-plugin/plugin.json`
- Codex 市场入口 `.agents/plugins/marketplace.json`
- Claude 市场入口 `.claude-plugin/marketplace.json`
- 对应 `skills/<skill-name>/SKILL.md`
- 对应 `skills/<skill-name>/agents/openai.yaml`
- 展示资源 `assets/icon.png` 和 `assets/logo.png` 由 `python3 scripts/gen-assets.py` 生成，不手工编辑

新增 skill 时，建议保持以下约定：

- `SKILL.md` 顶部包含 `name`（等于目录名）和 `description`
- `agents/openai.yaml` 提供 Codex 的 `display_name`、`short_description`、`default_prompt`
- 明确适用场景、输入、输出、工作流和质量标准
- 默认中文沟通，代码符号、路径、命令和第三方名称保留原文
- 产物路径稳定，便于后续 skill 串联

完整约定见 [AGENTS.md](AGENTS.md)。

## 发布检查

发布前先运行校验脚本：

```bash
./scripts/check-plugins.sh
```

它自动检查：JSON 合法性、两端市场插件列表一致、市场路径真实存在、插件目录已被两端收录、`plugin.json` 的 `name`/`version`/`description` 两端一致、`interface` 引用的资源文件存在、每个 `SKILL.md` 的 frontmatter `name` 与目录名匹配、每个 skill 都有 `agents/openai.yaml`。有失败项时退出码为 1。

脚本覆盖不到、仍需人工确认的部分：

- 所有 `SKILL.md` 可以独立说明触发场景和边界
- 版本号已按改动幅度递增
- `git status` 中没有无关临时文件或系统文件
