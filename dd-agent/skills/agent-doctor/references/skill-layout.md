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
├── .claude/
│   └── skills/
│       └── example -> ../../.agents/skills/example
└── .codebuddy/
    └── skills/
        └── example -> ../../.agents/skills/example
```

`.agents/skills` 和其直接 skill 子目录应为真实目录，不以指向 `.claude`、`.pi`、`.codebuddy` 或项目外的链接充当实体。这里的链接是文件系统符号链接，不是 Markdown 快捷文件、macOS Finder 替身或复制品。`.claude/skills` 和 `.codebuddy/skills` 默认是容纳逐 skill 链接的真实目录，而不是整个 `.claude`、`.codebuddy` 指向 `.agents`。`.codebuddy/skills` 只在项目确有 skill 时创建，与该目录下的其他配置（`settings*.json`、`rules/`、`agents/`、`commands/`）无关，不要一并改动。

`SKILL.md` 保留合法的 `name`、`description` 和原有可选元数据。目录名与名称不一致时先检查调用方，再修正明确的错误并更新相关引用；不同 agent 的专属元数据不能因为另一个 agent 不使用就删除。

## 修复顺序

1. **只读盘点。** 使用不会自动跟随链接的目录检查（例如 `lstat`、`readlink`）；包括断链，不能仅靠 `exists()`。先检查 `.agents`、`.claude`、`.pi`、`.codebuddy` 和各自 `skills` 容器本身，再检查每个入口，避免通过父级链接误改项目外内容。记录实际路径、文件类型、skill 名称与作用域、完整文件清单、内容摘要、权限及内部链接。
2. **确定迁移对象。** 只迁移用户目标项目拥有的 skill 实体。读源码中的相对路径、文档中的路径和相关项目设置，识别移出旧目录会断开的引用。路径含空格、`~` 或非 ASCII 字符时使用正确引用或文件 API，不能把路径当作可执行 shell 文本。
3. **先保证实体完整。** 目标不存在时整体迁移目录，连同 scripts、references、assets、隐藏文件、许可证及执行权限。同一文件系统优先重命名；需复制时先复制并验证，再处理原目录。内部链接不能盲目解引用，迁移后按原意修正相对目标。成功操作应可通过反向迁移恢复。
4. **解决已存在的目标。** 按下表判断。涉及合并、内容修改或移除重复实体前，把受影响原件及原路径映射保存到项目内不参与 skill 发现的备份位置，例如 `.agents/doctor-backups/<本次唯一标识>/`。不把备份放进任何 `skills` 扫描目录；不在没有实际风险改动或重复无变化运行时生成备份。备份保留至用户决定清理，不自动删除。
5. **建立入口。** 实体确认完整后，才将旧入口变为指向规范实体的相对链接。用入口父目录到实体计算相对路径；标准 Claude 入口和 WorkBuddy 入口都是 `../../.agents/skills/<name>`。替换链接时仅操作链接本身，不递归删除目标，不使用强制覆盖未知目录的命令。
6. **核验与重扫。** 对比迁移前后的文件内容、权限和资源路径；解析所有新链接，检查断链、循环和重复的逻辑名称。再次按原规则盘点，已经合规的布局不再改动。

| 现状 | 处理 |
| --- | --- |
| 只有 `.agents/skills/<name>` 实体 | 保留实体，补齐 Claude 与 WorkBuddy 链接 |
| 只有 `.claude/skills/<name>`、`.pi/skills/<name>` 或 `.codebuddy/skills/<name>` 实体 | 整体迁入同作用域 `.agents/skills/<name>`，建立需要的入口 |
| 多份完整目录完全相同 | 比较所有文件、内部链接与权限；保留规范实体，备份后将消费端副本改为链接 |
| 同名目录有互补资源或正文差异 | 逐项比较；明确互补且不改变意图的内容可合并，无法确定的冲突保留原件并询问该项，继续处理其他 skill |
| 消费端链接目标正确但为绝对路径 | 只将链接改成可随项目移动的相对路径 |
| 断链且规范位置有对应实体 | 确认名称与意图后重建链接；无实体时报告缺失来源，不伪造 skill |
| `.agents/skills` 指向项目内旧实体目录 | 记录并备份链接布局，将实际内容移为规范位置实体，再重建消费入口；避免自指循环 |
| `.claude/skills` 或 `.codebuddy/skills` 整目录链接到规范目录 | 改为真实容器和逐 skill 链接；原链接先记录，规范实体保持原位 |
| 指向项目外实体、安装缓存或子模块 | 不搬动、删除或自动复制外部来源；报告该项不符合实体规范，说明需用户确定是否本地化 |
| 非 skill 文件或无法识别的目录占据目标路径 | 保留原件，报告具体路径冲突；不为完成迁移直接覆盖 |

没有任何项目 skill 时无需创建空目录或示例 skill，记录“暂无项目 skills”，在项目指引中写明后续新增规范即可。

## 参考命令

以下命令已在含正常实体、断链、外部链接、缺 `SKILL.md` 和根级散文件的目录上验证过。执行前确认当前目录是目标项目根，并按实际 skill 名替换 `<name>`。

**盘点**：用 `lstat`/`readlink` 语义，断链、指向项目外和不会被识别的条目都能看到。

```bash
python3 - <<'PY'
import os, pathlib
root = pathlib.Path.cwd()
for base in (".agents/skills", ".claude/skills", ".pi/skills", ".codebuddy/skills"):
    b = root / base
    if not b.is_symlink() and not b.exists():
        continue
    print(f"\n# {base}" + (f"  [容器本身是链接 -> {os.readlink(b)}]" if b.is_symlink() else ""))
    if not b.is_dir():
        continue
    for q in sorted(b.iterdir()):
        if q.is_symlink():
            tgt = os.readlink(q)
            real = pathlib.Path(os.path.normpath(q.parent / tgt))
            if not q.exists():
                state = "断链"
            elif root != real and root not in real.parents:
                state = "指向项目外"
            elif not (real / "SKILL.md").is_file():
                state = "缺 SKILL.md"
            else:
                state = "ok"
            print(f"  {q.name:<20} 链接 -> {tgt:<38} {state}")
        elif q.is_dir():
            n = sum(1 for x in q.rglob("*") if x.is_file())
            print(f"  {q.name:<20} 实体   {n} 个文件" + ("" if (q / "SKILL.md").is_file() else "，缺 SKILL.md"))
        else:
            print(f"  {q.name:<20} 普通文件，不会被识别为 skill")
PY
```

**迁移实体**：同一文件系统内用重命名保留权限；目标已存在时一律不覆盖，回到现状表逐项比较。

```bash
name=<name>
if [ -e ".agents/skills/$name" ]; then
  echo "目标已存在，先比较两份完整目录"
else
  mkdir -p .agents/skills && mv ".pi/skills/$name" ".agents/skills/$name"
fi
```

**建立消费入口**：`-e` 对断链返回假，必须同时判断 `-L`，否则会把断链当成缺失入口重建。不要用 `ln -sf` 覆盖未知内容。`.codebuddy/skills` 供 WorkBuddy 使用，按同样方式建立。

```bash
name=<name>
for base in .claude/skills .codebuddy/skills; do
  mkdir -p "$base"
  if [ -e "$base/$name" ] || [ -L "$base/$name" ]; then
    echo "$base/$name 入口已存在（可能是断链或错误目标），按现状表判断"
  else
    ln -s "../../.agents/skills/$name" "$base/$name"
  fi
done
```

**备份**：仅在合并、修改或移除重复实体前执行，放在不参与 skill 发现的位置。

```bash
stamp=$(date +%Y%m%d-%H%M%S)
mkdir -p ".agents/doctor-backups/$stamp"
cp -R ".claude/skills/<name>" ".agents/doctor-backups/$stamp/claude-<name>"
```


## Pi 与发现范围

当前 Pi 原生发现项目 `.agents/skills`，所以缺少 `.pi/skills` 是合规状态。原 `.pi/skills` 实体迁出后，若没有被其他文件引用且当前版本确认不需要它，移除空的旧入口即可；有引用或需兼容的入口保留相对符号链接，不保留重复实体。

仅在旧版本确实不支持 `.agents/skills` 或用户明确要求时，创建 `.pi/skills/<name> -> ../../.agents/skills/<name>`，并验证当前版本支持这种链接。不要同时新增 `settings.skills` 和同目标链接。已存在且正常工作的 Pi 链接可保留；发现重复加载时根据真实目标去重，仅移除本项目中确认冗余的入口或精确配置项，保留其他设置。

如果 Pi 的项目信任未启用或使用了 `--no-skills`，目录正确不等于已被加载。报告原因，不自动批准信任或修改全局设置。平台无法创建符号链接时说明限制，不用复制品冒充合规。

monorepo 中逐个作用域规范化，普通项目 `.agents/skills` 不能保证从任意兄弟目录启动都可发现。插件分发目录遵循插件 manifest，不套用项目消费端布局。

## WorkBuddy 与发现范围

WorkBuddy 和 CodeBuddy Code 只发现 `<工作目录>/.codebuddy/skills` 与用户级 `<配置目录>/skills`（WorkBuddy 为 `~/.workbuddy/skills`），不读 `.agents/skills`。因此这里的 `.codebuddy/skills/<name>` 链接是该端能用上项目 skill 的必要入口，不是可选兼容层；项目暂无 skill 时不建空目录。

该端从 `skills` 根递归到第 5 层，把遇到的**每个** `SKILL.md` 都算作一个 skill。实体内部的 `references/`、`examples/` 等子目录里如果还有 `SKILL.md`，会多出一个同源 skill；盘点时发现这种嵌套要报告，不擅自删除或改名。备份目录放在 `.agents/doctor-backups/`，不在任何端的扫描路径内。

同名 skill 按项目、用户、connector、内置的顺序先命中者胜，所以 `.codebuddy/skills` 里的同名项会遮蔽 `~/.workbuddy/skills` 中的同名 skill。只在项目作用域内处理，不改用户级目录，也不用它来解决项目内的命名冲突。

`SKILL.md` 缺少 `name` 时该端按路径派生名称，非字符串的 `name`（例如 `name: 1024`）会被忽略并回落到路径名，这类值要加引号。`display_name` / `display-name`、`user-invocable`、`disable-model-invocation` 是该端的展示与调用控制字段，迁移和去重时保留。会话级的 `CODEBUDDY_SESSION_SKILL_DIRS` 由客户端自己管理，不写进项目，也不依赖它替代入口链接。

WorkBuddy 桌面端另有一条 `<工作目录>/.workbuddy/skills` 路径，只供**设置页的 skill 列表**使用：桌面壳的 `getSkillList` 扫它，和 `batchToggleSkills`、`setSkillOverrides` 是同一组 UI 管理方法。真正执行的是外部 CLI 进程，由 `createSession` 通过 `opts.env` 拉起，它读的是 `.codebuddy/skills`。两条路径都存在，作用不同：

| 路径 | 谁在读 | 不建的后果 |
| --- | --- | --- |
| `.codebuddy/skills/<name>` | CLI 运行时 | agent 加载不到该 skill |
| `.workbuddy/skills/<name>` | 桌面端设置页 | 用户在 skill 列表里看不到、无法开关 |

只建后者不建前者，会得到“设置页里看得见、agent 却用不上”的错觉状态——这是容易误判的一处，盘点时两条都要查。项目确有 skill 时两处都建相对链接；没有 skill 时都不建。

项目把 `.workbuddy/` 或 `.codebuddy/` 整个写进 `.gitignore` 时（里面常有 memory 日志、tasks 等运行时产物），入口链接会一并被忽略，换机器 clone 下来就没有。需要改成忽略目录内容但放行 skills，例如 `.workbuddy/*` 加 `!.workbuddy/skills/`——注意直接忽略目录本身（`.workbuddy/`）会让 git 不再递归进去，此时 `!` 放行规则无效。改完用 `git check-ignore -v` 分别验证日志被忽略、链接未被忽略。

## 已核对的发现规则

- Codex 扫描当前目录至仓库根目录间的 `.agents/skills`，支持 skill 文件夹链接；同名 skill 不自动合并。[Codex 官方说明](https://learn.chatgpt.com/docs/build-skills)
- Claude 项目入口是 `.claude/skills/<name>/SKILL.md`，支持将 `<name>` 作为目录符号链接。[Claude 官方说明](https://code.claude.com/docs/en/skills#where-skills-live)
- Pi 支持 `.pi/skills` 与当前及祖先目录中的 `.agents/skills`，向上查找到 git 仓库根为止（不在仓库内时到文件系统根）；项目 skills 需要项目已被信任，并受 `--no-skills` 影响。[Pi 官方说明](https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/skills.md#locations)
- WorkBuddy 与 CodeBuddy Code 扫描 `<工作目录>/.codebuddy/skills` 和用户级 `<配置目录>/skills`，递归深度 5，目录符号链接按解析后的类型跟随，因此逐 skill 链接可用；不扫描 `.agents/skills` 与 `.claude/skills`。依据 WorkBuddy 5.5.6 内置 agent-cli（`@tencent-ai/codebuddy-code` 2.137.1）的 skill provider 实现，读打包代码核对，没有可引用的公开文档。
- WorkBuddy 桌面端设置页的 skill 列表另扫 `<工作目录>/.workbuddy/skills`（桌面壳 `getSkillList`），与 CLI 运行时的 `.codebuddy/skills` 是两条独立路径。依据 WorkBuddy 5.5.6 应用包 `app.asar` 内的 skill 管理实现，读打包代码核对，没有可引用的公开文档。

核对日期：Codex、Claude Code、Pi 为 2026-09-09，WorkBuddy 为 2026-09-18；本机 Pi 0.85.1 文档也确认 `.agents/skills` 支持。不要把这些版本号固定成使用此 skill 的最低版本。
