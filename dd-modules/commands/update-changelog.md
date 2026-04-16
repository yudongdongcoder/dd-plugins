---
description: Automatically creates user-facing changelogs from git commits by analyzing commit history, categorizing changes, and transforming technical commits into clear, customer-friendly release notes.
---

# Changelog Generator

This command transforms technical git commits into polished, user-friendly changelogs that customers and users can understand.

## When to Use

- Preparing release notes for a new version
- Creating weekly or monthly product update summaries
- Documenting changes for customers
- Writing changelog entries for app store submissions
- Generating update notifications
- Creating internal release documentation
- Maintaining a public changelog or product updates page

## Your task

1. Analyze git history based on the last git tag unless the user gives a different range.
2. Group commits into logical categories such as features, improvements, bug fixes, breaking changes, and security changes.
3. Rewrite technical commit messages into customer-facing language.
4. Exclude internal-only noise such as refactors and test-only changes unless they matter to users.
5. Produce a clean, structured changelog draft.
6. Prefer interacting in Chinese.

## Example output

```markdown
## ✨ 1.0.1
Released on 2024-10-13

- **Team Workspaces**: Create separate workspaces for different projects. Invite team members and keep everything organized.
- **Keyboard Shortcuts**: Press ? to see all available shortcuts. Navigate faster without touching your mouse.

## 🔧 Improvements

- **Faster Sync**: Files now sync 2x faster across devices
- **Better Search**: Search now includes file contents, not just titles

## 🐛 Fixes

- Fixed issue where large images wouldn't upload
- Resolved timezone confusion in scheduled posts
- Corrected notification badge count
```