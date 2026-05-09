---
name: update-changelog
description: Create user-facing changelogs from git commits by analyzing commit history, categorizing changes, and transforming technical commits into clear release notes. Use when the user asks for release notes, changelog entries, app store update text, or customer-facing change summaries.
---

# Changelog Generator

Transform technical git commits into polished, user-friendly changelogs that customers and users can understand.

## When To Use

- Preparing release notes for a new version.
- Creating weekly or monthly product update summaries.
- Documenting changes for customers.
- Writing changelog entries for app store submissions.
- Generating update notifications.
- Creating internal release documentation.
- Maintaining a public changelog or product updates page.

## Workflow

1. Analyze git history based on the last git tag unless the user gives a different range.
2. Group commits into logical categories such as features, improvements, bug fixes, breaking changes, and security changes.
3. Rewrite technical commit messages into customer-facing language.
4. Exclude internal-only noise such as refactors and test-only changes unless they matter to users.
5. Produce a clean, structured changelog draft.
6. Prefer interacting in Chinese.

## Output Style

Use clear Markdown. Prefer concise, user-facing language over raw commit wording.

```markdown
## 1.0.1
Released on 2024-10-13

### New

- Team Workspaces: Create separate workspaces for different projects and invite team members.

### Improvements

- Faster Sync: Files now sync faster across devices.

### Fixes

- Fixed an issue where large images could fail to upload.
```
