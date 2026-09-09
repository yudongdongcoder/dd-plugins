# Skill 布局与迁移

在 doctor 需要检查或整理项目 skills 时读取。目标是唯一真实来源与有效入口，保留 skill 的行为、资源及原有目录作用域。

## 规范布局

```text
project/
├── AGENTS.md
├── CLAUDE.md                         # @AGENTS.md
├── .agents/
│   └── skills/
│       └── example/
│           ├── SKILL.md
│           ├── scripts/              # 如果原 skill 有配套资源，完整保留
│           └── references/
└── .claude/
    └── skills/
        └── example -> ../../.agents/skills/example
```

`.agents/skills` 和其直接 skill 子目录应为真实目录，不以指向 `.claude`、`.pi` 或项目外的链接充当实体。这里的链接是文件系统符号链接，不是 Markdown 快捷文件、macOS Finder 替身或复制品。`.claude/skills` 默认是容纳逐 skill 链接的真实目录，而不是整个 `.claude` 指向 `.agents`。

`SKILL.md` 保留合法的 `name`、`description` 和原有可选元数据。目录名与名称不一致时先检查调用方，再修正明确的错误并更新相关引用；不同 agent 的专属元数据不能因为另一个 agent 不使用就删除。

## 修复顺序

1. **只读盘点。** 使用不会自动跟随链接的目录检查（例如 `lstat`、`readlink`）；包括断链，不能仅靠 `exists()`。先检查 `.agents`、`.claude`、`.pi` 和各自 `skills` 容器本身，再检查每个入口，避免通过父级链接误改项目外内容。记录实际路径、文件类型、skill 名称与作用域、完整文件清单、内容摘要、权限及内部链接。
2. **确定迁移对象。** 只迁移用户目标项目拥有的 skill 实体。读源码中的相对路径、文档中的路径和相关项目设置，识别移出旧目录会断开的引用。路径含空格、`~` 或非 ASCII 字符时使用正确引用或文件 API，不能把路径当作可执行 shell 文本。
3. **先保证实体完整。** 目标不存在时整体迁移目录，连同 scripts、references、assets、隐藏文件、许可证及执行权限。同一文件系统优先重命名；需复制时先复制并验证，再处理原目录。内部链接不能盲目解引用，迁移后按原意修正相对目标。成功操作应可通过反向迁移恢复。
4. **解决已存在的目标。** 按下表判断。涉及合并、内容修改或移除重复实体前，把受影响原件及原路径映射保存到项目内不参与 skill 发现的备份位置，例如 `.agents/doctor-backups/<本次唯一标识>/`。不把备份放进任何 `skills` 扫描目录；不在没有实际风险改动或重复无变化运行时生成备份。备份保留至用户决定清理，不自动删除。
5. **建立入口。** 实体确认完整后，才将旧入口变为指向规范实体的相对链接。用入口父目录到实体计算相对路径；标准 Claude 入口为 `../../.agents/skills/<name>`。替换链接时仅操作链接本身，不递归删除目标，不使用强制覆盖未知目录的命令。
6. **核验与重扫。** 对比迁移前后的文件内容、权限和资源路径；解析所有新链接，检查断链、循环和重复的逻辑名称。再次按原规则盘点，已经合规的布局不再改动。

| 现状 | 处理 |
| --- | --- |
| 只有 `.agents/skills/<name>` 实体 | 保留实体，补齐 Claude 链接 |
| 只有 `.claude/skills/<name>` 或 `.pi/skills/<name>` 实体 | 整体迁入同作用域 `.agents/skills/<name>`，建立需要的入口 |
| 多份完整目录完全相同 | 比较所有文件、内部链接与权限；保留规范实体，备份后将 Claude 副本改为链接 |
| 同名目录有互补资源或正文差异 | 逐项比较；明确互补且不改变意图的内容可合并，无法确定的冲突保留原件并询问该项，继续处理其他 skill |
| Claude 链接目标正确但为绝对路径 | 只将链接改成可随项目移动的相对路径 |
| 断链且规范位置有对应实体 | 确认名称与意图后重建链接；无实体时报告缺失来源，不伪造 skill |
| `.agents/skills` 指向项目内旧实体目录 | 记录并备份链接布局，将实际内容移为规范位置实体，再重建消费入口；避免自指循环 |
| `.claude/skills` 整目录链接到规范目录 | 改为真实容器和逐 skill 链接；原链接先记录，规范实体保持原位 |
| 指向项目外实体、安装缓存或子模块 | 不搬动、删除或自动复制外部来源；报告该项不符合实体规范，说明需用户确定是否本地化 |
| 非 skill 文件或无法识别的目录占据目标路径 | 保留原件，报告具体路径冲突；不为完成迁移直接覆盖 |

没有任何项目 skill 时无需创建空目录或示例 skill，记录“暂无项目 skills”，在项目指引中写明后续新增规范即可。

## Pi 与发现范围

当前 Pi 原生发现项目 `.agents/skills`，所以缺少 `.pi/skills` 是合规状态。原 `.pi/skills` 实体迁出后，若没有被其他文件引用且当前版本确认不需要它，移除空的旧入口即可；有引用或需兼容的入口保留相对符号链接，不保留重复实体。

仅在旧版本确实不支持 `.agents/skills` 或用户明确要求时，创建 `.pi/skills/<name> -> ../../.agents/skills/<name>`，并验证当前版本支持这种链接。不要同时新增 `settings.skills` 和同目标链接。已存在且正常工作的 Pi 链接可保留；发现重复加载时根据真实目标去重，仅移除本项目中确认冗余的入口或精确配置项，保留其他设置。

如果 Pi 的项目信任未启用或使用了 `--no-skills`，目录正确不等于已被加载。报告原因，不自动批准信任或修改全局设置。平台无法创建符号链接时说明限制，不用复制品冒充合规。

monorepo 中逐个作用域规范化，普通项目 `.agents/skills` 不能保证从任意兄弟目录启动都可发现。插件分发目录遵循插件 manifest，不套用项目消费端布局。

## 已核对的发现规则

- Codex 扫描当前目录至仓库根目录间的 `.agents/skills`，支持 skill 文件夹链接；同名 skill 不自动合并。[Codex 官方说明](https://learn.chatgpt.com/docs/build-skills)
- Claude 项目入口是 `.claude/skills/<name>/SKILL.md`，支持将 `<name>` 作为目录符号链接。[Claude 官方说明](https://code.claude.com/docs/en/skills#where-skills-live)
- Pi 支持 `.pi/skills` 与当前及祖先目录中的 `.agents/skills`，项目 skills 受项目信任与发现开关影响。[Pi 官方说明](https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/skills.md#locations)

核对日期：2026-09-09；本机 Pi 0.85.1 文档也确认 `.agents/skills` 支持。不要把该版本号固定成使用此 skill 的最低版本。
