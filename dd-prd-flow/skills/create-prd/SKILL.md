---
name: create-prd
description: Create or rewrite a concise Chinese Product Requirements Document from product ideas, requirement discussions, drafts, or existing project notes. Use when the user asks to draft, merge, update, or normalize a PRD; define MVP scope, non-goals, user flows, feature IDs, acceptance criteria, and implementation-ready product boundaries for later PRD-flow specs and tasks.
---

# Create PRD

Create the authoritative product document for the project. Default output: `docs/PRD.md`.

## Workflow

1. Read the conversation and any user-provided requirement drafts or notes.
2. If updating an existing project PRD, read `docs/PRD.md` first.
3. Merge inputs into one clear PRD instead of lightly editing an old structure.
4. Ask only when product direction, target users, core value, or MVP boundary is too unclear to proceed.
5. When reasonable assumptions are enough, proceed and record them in the PRD.
6. Save or update `docs/PRD.md`.

## Required Structure

1. 产品概述
2. 问题背景与目标用户
3. 产品目标与非目标
4. MVP 范围、后续范围、不在范围
5. 核心用户流程
6. 功能地图
7. 用户故事与验收标准
8. 关键概念、数据对象或内容模型
9. 成功指标
10. 非功能需求
11. 技术、资源与独立开发者约束
12. 假设、待确认问题、风险

## Feature Map Contract

Every core feature must include:

- `feature id`: stable English kebab-case, usable as a filename, such as `auth-login`.
- Priority: `P0`, `P1`, or `P2`.
- User value: what the user can accomplish and why it matters.
- Dependencies: preceding features, data objects, third-party services, or `无`.
- Spec target: suggested path like `docs/specs/<feature-id>.md`.

## Quality Bar

- Write in practical Chinese for an independent developer and AI coding agent.
- Keep the PRD about product intent, scope, boundaries, and acceptance, not detailed code design.
- Separate MVP, later improvements, and explicit non-goals.
- Make user stories testable with concrete acceptance criteria.
- Include realistic solo-developer constraints: time, maintenance, dependency risk, data complexity, and validation cost.
- Ensure the PRD can directly feed `generate-spec`.
