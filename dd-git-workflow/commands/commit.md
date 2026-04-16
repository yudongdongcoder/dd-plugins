---
description: Create a repository-specific git commit for plugin changes
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git commit:*)
---

# Commit Plugin Changes

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Create a single git commit for the current plugin-related changes in this repository.

Requirements:
1. Focus on plugin changes only. Stage only files relevant to the plugin work the user is currently doing, and avoid unrelated changes.
2. If the changed plugin adds, removes, or renames commands, check whether related plugin metadata files should be included in the same commit, especially `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.
3. Follow the repository's recent commit style when writing the message.
4. Create exactly one commit and do not do anything else.

You have the capability to call multiple tools in a single response. Stage and create the commit using a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.
