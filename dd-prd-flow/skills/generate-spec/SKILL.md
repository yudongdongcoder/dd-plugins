---
name: generate-spec
description: Generate a detailed Chinese feature specification from docs/PRD.md for one selected feature. Use when the user asks to expand a PRD feature into engineering-readable scope, non-goals, acceptance criteria, data model, state flow, interfaces, errors, dependencies, traceability, or a docs/specs feature file for later planning and tasks.
---

# Generate Feature Spec

Turn one PRD feature into an implementation-ready specification. Default output: `docs/specs/<feature-id>.md`.

## Workflow

1. Identify the target `feature id` from the user request or `docs/PRD.md`; ask only if it cannot be inferred.
2. Read `docs/PRD.md` and extract relevant goals, user stories, constraints, dependencies, and non-goals.
3. Inspect existing docs or code only when needed to avoid inventing incompatible interfaces.
4. Define product scope, implementation boundaries, state transitions, data needs, and acceptance criteria.
5. Record assumptions, open questions, and traceability back to PRD sections or feature-map entries.
6. Create or update `docs/specs/<feature-id>.md`.

## Required Structure

1. 功能概述
2. PRD 对应关系
3. 用户故事与验收标准
4. 范围与非目标
5. 关键流程与状态
6. 数据对象、字段与约束
7. 接口、事件或集成点
8. 错误处理与边界情况
9. 权限、安全、性能与可访问性要求
10. 测试与验证建议
11. 假设、待确认问题、风险

## Quality Bar

- Write specifications, not implementation code.
- Be concrete enough for `plan-feature` and `generate-tasks`.
- Preserve requirement traceability so later implementation can justify decisions.
- Prefer the repo's existing architecture and terminology when known.
- Mark uncertain technical details as assumptions instead of presenting guesses as facts.
