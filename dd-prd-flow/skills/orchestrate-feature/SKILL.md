---
name: orchestrate-feature
description: Decide and execute the next step in the dd-prd-flow workflow for a product idea or feature. Use when the user asks what to do next, to run the PRD workflow end to end, to continue a feature, or to coordinate create-prd, generate-spec, plan-feature, generate-tasks, validate-flow, and implement-feature based on which docs already exist.
---

# Orchestrate Feature

Act as the controller for the PRD-driven workflow. Inspect the repository, choose the next appropriate stage, and either perform that stage or clearly report the missing prerequisite.

## Decision Order

1. If `docs/PRD.md` is missing or the user is still at product-idea level, use the `create-prd` workflow.
2. If the target feature lacks `docs/specs/<feature-id>.md`, use the `generate-spec` workflow.
3. If the feature lacks `docs/tasks/<feature-id>-plan.md`, use the `plan-feature` workflow.
4. If the feature lacks `docs/tasks/<feature-id>-tasks.md`, use the `generate-tasks` workflow.
5. If docs exist but may be stale, use the `validate-flow` workflow.
6. If the checklist has unfinished tasks and the user asks to build or continue, use the `implement-feature` workflow.
7. If all tasks are complete, summarize completion and suggest final verification or release steps.

## Workflow

1. Determine whether the user provided a product idea, a feature name, a task ID, or a request to continue.
2. Inspect existing PRD-flow files under `docs/`.
3. Choose exactly one next stage unless the user explicitly asks for an end-to-end generation pass.
4. Follow the output contract of the selected stage.
5. End with a short state summary: current stage, created or updated files, next recommended command or skill.

## Rules

- Prefer the canonical order: PRD -> spec -> plan -> tasks -> validation -> implementation.
- Treat `feature id` as the stable key across all files.
- Do not invent a feature ID that conflicts with the PRD feature map.
- Do not implement code before a spec and task checklist exist, unless the user explicitly bypasses the flow.
- If several features are possible, ask the user to choose only when the PRD cannot disambiguate.
