---
name: generate-tasks
description: Break a PRD-flow feature specification and optional implementation plan into a Chinese executable task checklist. Use when the user asks to create development tasks, dependency order, work packages, tracking checklists, testing steps, docs updates, or a docs/tasks feature task file from the feature spec and plan.
---

# Generate Tasks

Create an ordered implementation checklist for one feature. Default output: `docs/tasks/<feature-id>-tasks.md`.

## Workflow

1. Identify the target `feature id`; ask only if it cannot be inferred.
2. Read `docs/specs/<feature-id>.md`.
3. Read `docs/tasks/<feature-id>-plan.md` if it exists; otherwise read `docs/PRD.md` as backup context.
4. Split work into small, dependency-ordered tasks that one agent session can complete.
5. Include implementation, tests, docs updates, migration/backfill steps, and verification commands when relevant.
6. Create or update `docs/tasks/<feature-id>-tasks.md`.

## Task Format

Use checkboxes and stable task IDs:

```markdown
- [ ] T01: 简短任务标题
  - 目标：
  - 涉及文件或模块：
  - 前置依赖：
  - 验收标准：
  - 验证方式：
  - 复杂度：S/M/L
```

## Quality Bar

- Avoid vague tasks like “实现功能”.
- Keep each task independently reviewable and testable.
- Preserve dependency order.
- Include acceptance criteria that let `implement-feature` know when to stop.
- If the plan and spec disagree, note the conflict instead of hiding it.
