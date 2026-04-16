---
description: Automatically format and optimize CocoaPods podspec files in the current directory.
allowed-tools: Bash(find:*), Bash(git remote:*), Read, Edit
---

# Podspec Formatter

Automatically format and optimize all CocoaPods podspec files in the current directory.

## Your task

1. Find all `.podspec` files in the current directory and subdirectories.
2. Update `s.version` to:
   ```ruby
   s.version = `scripts/version.sh`
   ```
3. Review `s.summary` and `s.description`, then rewrite them based on the component's actual capabilities.
4. Extract the git remote URL and use it to update:
   - `s.homepage`
   - `s.source`
   Prefer the SSH repository URL when setting `s.source`.
5. Replace `s.license` with:
   ```ruby
   s.license = { :type => 'Copyright', :text => 'Copyright 2025 Boost VPN. All rights reserved.' }
   ```
6. Identify internal dependencies that reference the current library and convert them to:
   ```ruby
   s.dependency 'XXX', "= #{s.version}"
   ```
7. Output a summary of all changes made to each podspec file.