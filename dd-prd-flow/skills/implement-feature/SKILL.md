---
name: implement-feature
description: Implement the next unfinished task for a PRD-flow feature using its spec, optional plan, and task checklist under docs. Use when the user asks to code, continue, execute, or complete a feature task with tests, verification, task progress updates, and a concise implementation report.
---

# Implement Feature

Implement the next unfinished task for one PRD-flow feature. Default behavior: complete one clear task per run, then report status.

## Workflow

1. Identify the target `feature id`; ask only if it cannot be inferred.
2. Read `docs/specs/<feature-id>.md`.
3. Read `docs/tasks/<feature-id>-plan.md` if it exists.
4. Read `docs/tasks/<feature-id>-tasks.md` and select the first unchecked task unless the user names a task ID.
5. Inspect the relevant code and follow the repo's existing patterns.
6. Make the smallest code changes that satisfy the selected task.
7. Add or update focused tests when the task changes behavior.
8. Run appropriate build, test, lint, or manual verification commands.
9. Update the task checklist with completion status and brief verification notes.
10. Report changed files, verification results, and remaining next task.

## Guardrails

- Do not skip verification. If a command cannot run, explain why and state residual risk.
- Do not broaden scope beyond the selected task unless required to make it work.
- Do not overwrite unrelated user changes.
- If the task file is missing or too vague, stop and use `generate-tasks` or ask for clarification.
- If implementation reveals spec/task drift, update the task note and recommend `validate-flow`.
