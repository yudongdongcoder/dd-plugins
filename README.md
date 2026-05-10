# DD Plugins

DD Plugins 是一组面向 AI coding agent 的本地插件集合，主要提供中文 PRD 驱动开发流程和 iOS 模块维护辅助能力。

当前仓库同时维护 Codex 与 Claude 插件元数据：

- Codex：`.agents/plugins/marketplace.json`、各插件的 `.codex-plugin/plugin.json`
- Claude：`.claude-plugin/marketplace.json`、各插件的 `.claude-plugin/plugin.json`

## 插件列表

| 插件 | 用途 | 主要能力 |
| --- | --- | --- |
| `dd-prd-flow` | PRD 驱动的需求到实现工作流 | 创建 PRD、生成功能规格、制定实施计划、拆解任务、校验文档一致性、按任务逐步实现 |
| `dd-modules` | 实用开发模块集合 | 格式化 CocoaPods podspec、根据 git 历史生成中文更新日志 |

## 目录结构

```text
.
├── .agents/plugins/marketplace.json      # Codex 本地插件市场入口
├── .claude-plugin/marketplace.json       # Claude 本地插件市场入口
├── dd-prd-flow/
│   ├── .codex-plugin/plugin.json
│   ├── .claude-plugin/plugin.json
│   ├── assets/
│   └── skills/
│       ├── create-prd/
│       ├── generate-spec/
│       ├── plan-feature/
│       ├── generate-tasks/
│       ├── validate-flow/
│       ├── implement-feature/
│       └── orchestrate-feature/
└── dd-modules/
    ├── .codex-plugin/plugin.json
    ├── .claude-plugin/plugin.json
    ├── assets/
    └── skills/
        ├── podspec-formatter/
        └── update-changelog/
```

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

### 使用示例

```text
整理这个仓库里的 podspec 文件
```

```text
根据最近一次 tag 到 HEAD 的提交生成中文更新日志
```

## 安装与使用

本仓库以本地插件源形式组织。插件入口已经写入：

- Codex 插件市场：`.agents/plugins/marketplace.json`
- Claude 插件市场：`.claude-plugin/marketplace.json`

在支持本地插件源的客户端中导入本仓库后，可安装：

- `dd-prd-flow`
- `dd-modules`

也可以直接使用单个插件目录作为本地插件源：

- `./dd-prd-flow`
- `./dd-modules`

## 维护约定

新增或调整插件时，需要同步检查以下位置：

- 插件目录下的 `.codex-plugin/plugin.json`
- 插件目录下的 `.claude-plugin/plugin.json`
- Codex 市场入口 `.agents/plugins/marketplace.json`
- Claude 市场入口 `.claude-plugin/marketplace.json`
- 对应 `skills/<skill-name>/SKILL.md`
- 如有展示资源，更新 `assets/icon.png` 和 `assets/logo.png`

新增 skill 时，建议保持以下约定：

- `SKILL.md` 顶部包含 `name` 和 `description`
- 明确适用场景、输入、输出、工作流和质量标准
- 默认中文沟通，代码符号、路径、命令和第三方名称保留原文
- 产物路径稳定，便于后续 skill 串联

## 发布检查

发布前建议确认：

- 插件名称、版本号、描述在 Codex 与 Claude 元数据中一致
- marketplace 中的插件路径指向真实目录
- 所有 `SKILL.md` 可以独立说明触发场景和边界
- 资源文件存在，路径与 plugin manifest 一致
- `git status` 中没有无关临时文件或系统文件
