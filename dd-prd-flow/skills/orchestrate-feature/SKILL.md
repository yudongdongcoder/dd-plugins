---
name: orchestrate-feature
description: 判断并执行 dd-prd-flow 的下一步。适用于用户询问下一步做什么、要求端到端推进 PRD 工作流、继续某个 feature、协调 create-prd、generate-spec、plan-feature、generate-tasks、validate-flow、implement-feature，或根据 docs 中已有文件选择合适阶段。
---

# Orchestrate Feature Flow

作为 PRD 驱动流程的控制器，检查仓库状态，选择下一阶段并执行；如果前置条件缺失，明确报告缺口。

## 语言与边界

- 默认使用中文沟通和生成文档；保留 skill 名、路径、命令、`feature id` 和代码标识符原文。
- 默认只推进一个最合适阶段，除非用户明确要求端到端生成。
- 端到端生成可以连续创建 PRD、spec、plan 和 tasks；进入代码实现前必须确认已有 spec 和任务清单，且用户明确要求实现。
- 不为了推进流程而隐藏未确认问题；阻塞项要先说清楚。

## 决策顺序

1. 如果 `docs/PRD.md` 缺失，或用户仍处在产品想法层面，执行 `create-prd`。
2. 如果无法确定目标 `feature id`，先从 PRD 功能地图或用户请求中推断；仍无法判断时提问。
3. 如果目标功能缺少 `docs/specs/<feature-id>.md`，执行 `generate-spec`。
4. 如果目标功能缺少 `docs/tasks/<feature-id>-plan.md`，执行 `plan-feature`。
5. 如果目标功能缺少 `docs/tasks/<feature-id>-tasks.md`，执行 `generate-tasks`。
6. 如果用户要求检查、一致性不明，或文档已有明显漂移，执行 `validate-flow`。
7. 如果任务清单存在未完成任务，且用户要求构建、继续或执行，执行 `implement-feature`。
8. 如果所有任务已完成，总结状态并建议最终验证、发布或回归检查。

## 工作流

1. 判断用户提供的是产品想法、功能名、任务 ID、继续请求还是审查请求。
2. 检查 `docs/` 下已有 PRD-flow 文件。
3. 选择一个阶段并遵循该阶段的输出契约。
4. 如果用户要求端到端推进，按决策顺序逐段执行，并在每段结束时确认产物是否足以进入下一段。
5. 结束时给出短状态摘要：当前阶段、创建或更新的文件、下一步推荐使用的 skill。

## 规则

- 保持标准顺序：PRD -> spec -> plan -> tasks -> validation -> implementation。
- 以 `feature id` 作为跨文件稳定键。
- 不发明与 PRD 功能地图冲突的 `feature id`。
- 在没有 spec 和任务清单时不直接实现代码，除非用户明确绕过流程。
- 多个功能都可能匹配时，只有在 PRD 无法消歧时才询问用户。
