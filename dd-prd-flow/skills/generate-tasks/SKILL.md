---
name: generate-tasks
description: 将指定功能规格拆解成中文可执行任务清单。适用于用户要求根据 feature spec 生成开发任务、实施步骤、依赖顺序或可跟踪 checklist。
---

# Generate Task Breakdown

读取 `docs/specs/<feature-name>.md`，生成可逐项执行和跟踪的中文任务拆解，默认保存到 `docs/tasks/<feature-name>-tasks.md`。

## 适用场景

- 功能规格已经写好，需要拆成开发任务。
- 用户需要实现 checklist、任务依赖顺序或单次会话可完成的工作包。
- 后续会用 `implement-feature` 按任务逐步实现。

## 工作流

1. 确认功能名；如果无法推断，再询问用户。
2. 阅读 `docs/specs/<feature-name>.md`，必要时回看 `docs/PRD.md`。
3. 识别实现步骤、测试步骤、文档更新和验证动作。
4. 按依赖关系排序任务。
5. 为每个任务标注目标、涉及文件或模块、验收标准和复杂度。
6. 创建或更新 `docs/tasks/<feature-name>-tasks.md`。

## 任务质量要求

- 每个任务尽量控制在一次会话可以完成的范围内。
- 每个任务都要有可判断完成的验收标准。
- 避免“实现功能”这类过大的任务；拆成清晰的工程动作。
- 用复选框或状态字段让进度可跟踪。
