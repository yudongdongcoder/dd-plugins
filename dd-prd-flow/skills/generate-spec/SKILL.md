---
name: generate-spec
description: Generate a detailed feature specification from docs/PRD.md. Use when the user asks to create a spec for a named feature from an existing PRD.
---

# Generate Feature Specification

Read the PRD at `docs/PRD.md` and create a detailed specification for the feature named by the user.

## Workflow

1. Extract relevant user stories and requirements.
2. Define acceptance criteria.
3. Design the technical architecture.
4. Create the spec file at `docs/specs/<feature-name>.md`.

## Codex Notes

- Ask for the feature name only if it cannot be inferred from the user's request.
- Think carefully about the technical design before writing.
- Preserve traceability from PRD requirements to spec decisions.
