---
name: generate-spec
description: Generate feature specification from PRD. Activates when user wants to create a detailed spec from PRD requirements.
argument-hint: <feature-name>
allowed-tools: Read, Write
---

# Generate Feature Specification

Read the PRD at `docs/PRD.md` and create a detailed specification for: $ARGUMENTS

1. Extract relevant user stories and requirements
2. Define acceptance criteria
3. Design technical architecture
4. Create the spec file at `docs/specs/$ARGUMENTS.md`

ultrathink about the technical design before writing.