---
name: generate-tasks
description: Break down a feature specification into implementable tasks. Use when the user asks to create tasks, a work breakdown, or implementation checklist for a named feature spec.
---

# Generate Task Breakdown

Read the specification at `docs/specs/<feature-name>.md` and create a detailed task breakdown.

## Workflow

1. Identify all implementation steps.
2. Order tasks by dependencies.
3. Estimate complexity.
4. Create `docs/tasks/<feature-name>-tasks.md`.

## Task Quality

- Each task should be completable in a single session.
- Include enough context that an implementer can start without rereading the whole spec.
- Make progress trackable with checkboxes or a clear status field.
