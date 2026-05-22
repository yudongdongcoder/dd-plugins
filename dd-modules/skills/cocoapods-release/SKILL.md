---
name: cocoapods-release
description: 仅当用户主动调用 /cocoapods-release 或明确要求发布当前 CocoaPods 项目版本时使用；负责更新 VERSION/CHANGELOG、创建 release commit/tag，并按根目录 PODSPEC 列表执行 pod repo push。该 skill 有远端发布副作用，禁止自动触发。
argument-hint: "<version|patch|minor|major>"
---

# CocoaPods Release

用于在当前仓库执行本地发布流程：更新 `VERSION`、由 AI 更新 `CHANGELOG.md`、创建 release commit、创建并推送 Git tag，然后直接运行本 Skill 内置的 `assets/pod-push-all.sh`，按根目录 `PODSPEC` 文件列出的顺序发布 podspec。默认发布到 `BoostApplePods`，如需其它私有 specs repo，可在执行脚本时使用 `POD_REPO=<repo-name>` 覆盖。

## 触发条件

只在以下场景使用：

- 用户主动输入 `/cocoapods-release ...`。
- 用户明确要求发布当前 CocoaPods 项目版本并授权执行发布流程。

不要在普通代码修改、changelog 修改、版本号讨论或 CI/CD 咨询中自动触发真实发布。

## 参数

用户调用参数为：`$ARGUMENTS`

支持：

- `x.y.z`：显式目标版本，例如 `4.0.2`。
- `x.y.z.n`：兼容历史四段版本，例如 `2.8.0.16`。
- `patch`：当前 `VERSION` 最后一段 +1。
- `minor`：当前 `VERSION` 中间段 +1，后续段归零。
- `major`：当前 `VERSION` 首段 +1，后续段归零。

版本必须匹配：`^[0-9]+(\.[0-9]+){2,3}$`。

Tag 名必须等于 `VERSION`，不要添加 `v` 前缀。

## PODSPEC 文件

仓库根目录必须提供 `PODSPEC` 文件，用于声明本次需要发布的 podspec 以及发布顺序。

规则：

- 每行一个 podspec，支持 `VPNNetwork` 或 `VPNNetwork.podspec` 两种写法。
- 空行会被忽略。
- 以 `#` 开头的行会被忽略。
- 发布顺序严格按文件中从上到下执行；有内部依赖时，被依赖的 pod 必须排在依赖它的 pod 前面。

示例：

```text
VPNNetwork
VPNNEHeartbeat
VPNNetworkiOS
```

## 发布前只读检查

在修改任何文件前，先执行这些检查：

1. 定位仓库根目录。
2. 读取 `VERSION` 和 `CHANGELOG.md`。
3. 读取根目录 `PODSPEC`，解析需要发布的 podspec 列表；至少解析到 1 个 podspec，不能有重复项，且发布计划中列出数量、文件名和顺序。
4. 运行 `git status --short`，工作区必须干净。
5. 根据参数计算目标版本，并确认目标版本合法且高于当前版本。
6. 检查本地不存在目标版本 tag。
7. 检查远端 `origin` 不存在目标版本 tag。
8. 检查 `PODSPEC` 中列出的 podspec 文件都存在。
9. 检查 `PODSPEC` 中列出的 podspec 都包含动态版本行：

   ```ruby
   s.version          = `scripts/version.sh`
   ```

10. 检查 `PODSPEC` 中列出的 podspec 的 source tag 使用 `:tag => s.version`。
11. 检查 `scripts/version.sh` 存在。
12. 检查本 Skill 内置脚本 `.claude/skills/cocoapods-release/assets/pod-push-all.sh` 存在且可执行；如果不存在或不可执行，停止发布并提示用户处理，不要在只读检查阶段自动修改权限。

如果任一检查失败，停止发布并向用户说明原因。

## 第一次确认

只读检查通过后，修改任何文件前必须询问用户确认。确认内容应包含 `PODSPEC` 文件解析出的 podspec 列表及顺序：

```text
准备发布当前 CocoaPods 项目 <target-version>：
1. 更新 VERSION
2. 根据 git log 更新 CHANGELOG.md
3. 创建 release commit
4. 创建 tag <target-version>
5. push commit 和 tag 到 origin
6. 直接执行 .claude/skills/cocoapods-release/assets/pod-push-all.sh 发布 PODSPEC 中列出的 <podspec-count> 个 podspec（脚本会使用 --allow-warnings、--skip-import-validation、--skip-tests、--use-modular-headers）：
   1. <podspec-name>.podspec
   2. <podspec-name>.podspec

请确认是否继续？
```

未得到明确确认前，不要修改文件、不要提交、不要创建 tag、不要 push、不要执行 pod 发布。

## 更新 VERSION 和 CHANGELOG.md

确认后：

1. 将 `VERSION` 改为目标版本，只保留版本号和结尾换行。
2. 找到上一个 tag：
   - 优先使用发布前 `VERSION` 对应 tag。
   - 如果不存在，使用最新语义版本 tag。
3. 收集变更：
   - `git log <previous-tag>..HEAD --oneline --no-merges`
   - 必要时读取 `git diff --stat <previous-tag>..HEAD`
4. 由 AI 总结用户可理解的 changelog，不机械复制 commit hash。
5. 在 `CHANGELOG.md` 的 `# Change Log` 标题后插入：

   ```markdown
   ## <target-version> - <YYYY-MM-DD>

   - ...
   ```

release commit 只能包含：

- `VERSION`
- `CHANGELOG.md`

不要提交 podspec 的临时版本替换。

## 创建 release commit

提交信息使用：

```text
chore(release): <target-version>
```

提交前检查 staged 文件只包含 `VERSION` 和 `CHANGELOG.md`。

## 第二次确认

release commit 创建后，执行远端副作用前必须再次确认：

```text
release commit 已创建。
接下来会执行远端副作用操作：
1. git tag -a <target-version> -m "Release <target-version>"
2. git push origin HEAD
3. git push origin <target-version>
4. .claude/skills/cocoapods-release/assets/pod-push-all.sh <target-version>

确认后会发布到远端 Git 仓库和 configured pod repo；这些远端副作用不会自动回滚。
是否继续？
```

未得到明确确认前，不要创建 tag、不要 push、不要执行 pod 发布。

## 发布执行顺序

第二次确认后，按顺序执行；内置脚本必须在本地 tag 创建且远端 tag push 成功后运行：

```bash
git tag -a <target-version> -m "Release <target-version>"
git push origin HEAD
git push origin <target-version>
.claude/skills/cocoapods-release/assets/pod-push-all.sh <target-version>
```

如果需要发布到非默认 specs repo，最后一步改为：

```bash
POD_REPO=<repo-name> .claude/skills/cocoapods-release/assets/pod-push-all.sh <target-version>
```

## 脚本失败处理

如果 `.claude/skills/cocoapods-release/assets/pod-push-all.sh` 运行失败：

1. 停止流程，不要自动重试 `pod repo push`，不要尝试修改代码、修改 podspec、调整脚本、重排 `PODSPEC`、补发依赖、删除 tag、重新 tag、force push 或执行其它修复动作。
2. 直接向用户报告失败的 podspec、关键错误信息、已经完成的远端副作用（例如 release commit/tag 是否已 push、哪些 podspec 从输出看已成功 push）。
3. 给出解决建议，但不代替用户执行。常见建议包括：检查 `PODSPEC` 发布顺序、先把被依赖的 pod 排到前面、确认私有 specs repo 已包含依赖版本、必要时由用户手动执行 `pod repo update` 后重试。
4. 如果脚本留下本地临时修改，只报告现状并询问用户是否要清理；不要擅自清理。

## 发布后验证

发布结束后检查：

1. `git status --short` 为空；如果不为空，区分是否为脚本未恢复的 podspec 临时修改或其它文件变更，只报告现状并询问用户，不要擅自清理。
2. `VERSION` 等于目标版本。
3. `CHANGELOG.md` 包含目标版本条目。
4. 本地 tag 存在。
5. 远端 tag 存在。
6. `PODSPEC` 中列出的所有 podspec 的 `s.version` 都恢复为：

   ```ruby
   s.version          = `scripts/version.sh`
   ```

7. `assets/pod-push-all.sh` 输出显示 `PODSPEC` 中列出的所有 podspec 发布成功。

最后用简短中文汇总发布结果和任何需要用户手动确认的事项。
