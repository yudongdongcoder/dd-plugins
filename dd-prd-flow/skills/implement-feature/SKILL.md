---
name: implement-feature
description: Implement the current uncompleted task for a feature from its spec and task breakdown. Use when the user asks to implement a named feature managed by the PRD flow.
---

# Implement Feature

Follow the PRD workflow for the feature named by the user.

## Workflow

1. Read `docs/specs/<feature-name>.md` for requirements.
2. Read `docs/tasks/<feature-name>-tasks.md` for the task breakdown.
3. Implement the current uncompleted task.
4. Write tests for the implementation.
5. Update task progress in the tasks file.
6. Build and test.

## Stopping Point

Complete one task at a time. After finishing the current task, summarize what changed, report verification results, and wait for the user's approval before taking the next task.
