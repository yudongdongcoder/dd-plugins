---
name: plan-feature
description: Create a Chinese implementation plan for one PRD-flow feature without modifying product code. Use when the user asks to analyze how to build a feature from docs/PRD.md and its docs/specs feature file, inspect existing code structure, identify integration points, dependencies, migrations, risks, phases, validation strategy, or write a docs/tasks feature plan before task breakdown or coding.
---

# Plan Feature

Create a code-aware implementation plan without changing business code. Default output: `docs/tasks/<feature-id>-plan.md`.

## Workflow

1. Identify the target `feature id`; ask only if it cannot be inferred.
2. Read `docs/PRD.md` and `docs/specs/<feature-id>.md`.
3. Inspect the existing codebase with fast search (`rg`, `rg --files`) and read relevant modules.
4. Identify module boundaries, data flow, dependencies, integration points, migrations, compatibility risks, and testing surface.
5. Split implementation into ordered phases with validation for each phase.
6. Create or update `docs/tasks/<feature-id>-plan.md`.

## Required Structure

1. 目标与输入文档
2. 现有代码结构观察
3. 关键集成点
4. 数据、接口或迁移影响
5. 分阶段实施方案
6. 测试与验证策略
7. 风险、取舍与回滚思路
8. 后续任务拆解建议

## Constraints

- Do not implement feature code in this skill.
- Do not modify business files; only create or update the plan document unless the user explicitly asks otherwise.
- Keep the plan specific to files, modules, commands, and validation steps where discoverable.
- If code structure is missing or ambiguous, state the assumption and propose the safest next check.
