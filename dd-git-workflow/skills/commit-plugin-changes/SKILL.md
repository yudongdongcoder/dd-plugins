---
name: commit-plugin-changes
description: Create a repository-specific git commit for plugin changes. Use when the user asks to commit current plugin-related changes in this repository.
---

# Commit Plugin Changes

Create a single git commit for the current plugin-related changes in this repository.

## Workflow

1. Inspect the current git status.
2. Inspect staged and unstaged diffs.
3. Check the current branch.
4. Review recent commits to match the repository's commit message style.
5. Stage only files relevant to the plugin work the user is currently doing.
6. If the changed plugin adds, removes, or renames skills, include related metadata files in the same commit when appropriate, especially `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `.agents/plugins/marketplace.json`.
7. Create exactly one commit.

## Constraints

- Focus on plugin changes only.
- Avoid unrelated changes.
- Do not make additional edits unless they are required to create a coherent plugin commit.
