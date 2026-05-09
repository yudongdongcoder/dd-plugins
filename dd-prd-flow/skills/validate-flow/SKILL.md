---
name: validate-flow
description: Validate consistency and readiness across dd-prd-flow documents for one feature or the whole PRD. Use when the user asks to review, audit, check, verify, or reconcile docs/PRD.md, feature specs, implementation plans, and task checklists before implementation, after changes, or when requirements drift is suspected.
---

# Validate Flow

Check whether PRD-flow documents are consistent, complete, and ready for implementation. Default output: update docs only when the user asks; otherwise report findings.

## Workflow

1. Identify the target `feature id`, or validate the whole flow if no single feature is named.
2. Read `docs/PRD.md`.
3. For each target feature, read existing spec, plan, and task files.
4. Compare feature IDs, priorities, scope, non-goals, acceptance criteria, dependencies, and validation steps.
5. Inspect code only when validating implementation readiness or when docs reference existing modules.
6. Report blocking issues first, then warnings, then optional improvements.
7. If the user asks to fix docs, update the smallest affected PRD-flow files.

## Checks

- PRD feature map contains stable feature IDs and matching spec paths.
- Spec scope and non-goals match the PRD.
- Acceptance criteria appear in spec and are represented by tasks or verification steps.
- Plan references real modules or clearly marked assumptions.
- Task checklist is ordered by dependency and each task has acceptance and verification.
- Implementation is not scheduled before unresolved blockers.
- Open questions and risks are visible instead of silently dropped.

## Report Format

Use this order:

1. 阻塞问题
2. 重要风险
3. 可改进项
4. 已确认一致的部分
5. 建议下一步

If no issues are found, say the flow is ready and list any remaining test or implementation risks.
