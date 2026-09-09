# AGENTS.md

## 项目概览

DD Plugins 是一个 **skill 分发仓库**，不含应用代码，产物全部是 Markdown 与 JSON/YAML 元数据。目标是让同一份 skill 同时可用于三个 AI coding agent：Claude Code、Codex、Pi。

每个顶层目录是一个插件，插件内 `skills/<name>/SKILL.md` 是实际交付内容：

| 插件 | 内容 |
| --- | --- |
| `dd-prd-flow` | PRD 驱动的需求到实现工作流（7 个 skill） |
| `dd-modules` | iOS 模块维护：podspec、changelog、CocoaPods 发布（3 个 skill） |
| `dd-agent` | 跨 agent 项目规范诊断与修复（1 个 skill） |

## 三端布局

| 端 | 市场入口 | 插件清单 | skill 展示元数据 | skill 发现方式 |
| --- | --- | --- | --- | --- |
| Claude Code | `.claude-plugin/marketplace.json` | `<plugin>/.claude-plugin/plugin.json` | 无（读 SKILL.md frontmatter） | 自动扫描插件的 `skills/` |
| Codex | `.agents/plugins/marketplace.json` | `<plugin>/.codex-plugin/plugin.json` | `<plugin>/skills/<name>/agents/openai.yaml` | 由 plugin.json 的 `"skills": "./skills/"` 指定 |
| Pi | 无独立入口 | 无独立清单 | 无 | 启动时 `--skill <本仓库绝对路径>/<plugin>/skills/<name>` |

Pi 当前没有插件市场概念，只能按 skill 目录逐个加载，加载后用 `/skill:<name>` 调用。不要为 Pi 新增 `.pi/` 镜像目录或第三套清单——它读 `AGENTS.md` 和 `.agents/skills`，与本仓库的分发结构无关。

## 边界：分发用 skill 不是项目 skill

`<plugin>/skills/` 是**要分发给别的项目**的插件源码。它们不是本仓库自己使用的 project skill，因此：

- 不要把它们迁移或链接到 `.agents/skills/`、`.claude/skills/`。
- 本仓库目前没有自用 project skill；真要新增，才在 `.agents/skills/<name>/` 建实体并从 `.claude/skills/<name>` 相对链接。
- `dd-agent` 的 `agent-doctor` 描述的是**目标项目**的规范，不适用于本仓库的 `<plugin>/skills/` 布局。在本仓库运行 agent-doctor 时不要用它搬动插件源码。

## 新增或修改 skill

新增 skill 时按顺序落地，缺一项在某个端上就不可见：

1. `<plugin>/skills/<name>/SKILL.md` —— frontmatter 至少含 `name`（必须等于目录名）和 `description`。
2. `<plugin>/skills/<name>/agents/openai.yaml` —— Codex 展示元数据，含 `interface.display_name`、`short_description`、`default_prompt`。
3. 配套资源放在 skill 目录内（如 `assets/`），用相对路径引用，不要指向仓库外。
4. 新增插件时还要同步四处：两份 `plugin.json`、两份 `marketplace.json`；`plugin.json` 的 `name`、`version`、`description` 两端必须逐字一致。
5. 更新 `README.md` 的插件表与目录结构。
6. 运行校验：`./scripts/check-plugins.sh`。

## SKILL.md 约定

- `description` 写清**何时触发**和**何时不触发**，因为三端都靠它做 skill 选择；把典型措辞写进去。
- 有远端副作用的 skill（如 `cocoapods-release`）在 description 里显式声明"仅在用户主动调用时使用"，正文单列触发条件。
- 默认中文；路径、命令、API、代码符号、第三方名称保留原文。
- 产物路径保持稳定，便于 skill 之间串联。
- 正文过长时拆到 `references/`，在 SKILL.md 中写明"执行 X 前读取 `references/y.md`"——普通 Markdown 链接不代表 agent 会自动加载。

## 验证

本仓库无构建和测试，唯一的自动检查是：

```bash
./scripts/check-plugins.sh
```

它校验 JSON 合法性、两端市场插件列表一致、市场路径真实存在、插件目录已被两端收录、`plugin.json` 三字段两端一致、`interface` 引用的资源文件存在、每个 SKILL.md 的 frontmatter 与目录名匹配、每个 skill 有 `openai.yaml`。有失败项时退出码为 1。

脚本只做静态检查。"文件已生成并静态通过"不等于"agent 已在新会话实际加载"——涉及加载行为的改动，需要在客户端里实际装一次才能下结论。

## 展示资源

三个插件的 `assets/icon.png`（纯图标）和 `assets/logo.png`（图标 + 插件名）都是 512×512 PNG，由 [scripts/gen-assets.py](scripts/gen-assets.py) 生成，不要手工编辑 PNG：

```bash
python3 scripts/gen-assets.py          # 写回各插件 assets/
python3 scripts/gen-assets.py /tmp/out # 只预览，不覆盖
```

依赖 `rsvg-convert`（`brew install librsvg`）。设计约定：白色圆角卡片 + 细边框 + 柔和阴影，主体是统一的比熊犬头像，右上角徽章按插件区分——`dd-prd-flow` 层叠文档（青绿）、`dd-modules` 等距立方体（蓝）、`dd-agent` 勾选徽章（紫）。新增插件时在脚本的 `PLUGINS` 里加一组配色与名称，并在 `BADGES` 里加对应徽章函数。

各插件 Codex `interface` 的 `brandColor` 与徽章主色保持一致。

## 已知缺口

- `dd-agent` 版本为 `0.1.0`，另外两个插件为 `1.0.0`。
