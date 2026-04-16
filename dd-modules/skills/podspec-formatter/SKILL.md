---
name: podspec-formatter
description: Automatically format and optimize CocoaPods podspec files. Searches current directory for all .podspec files and updates version references, descriptions, homepage, license, and internal dependencies according to project standards.
disable-model-invocation: true
---

## Podspec Formatter

Automatically format and optimize all CocoaPods podspec files in the current directory.

### Tasks

1. **Find all podspec files** in the current directory and subdirectories

2. **Update version reference**
   - Change `s.version` to `s.version = \`scripts/version.sh\``

3. **Optimize descriptions**
   - Review `s.summary` and `s.description`
   - Rewrite based on the component's actual capabilities
   - Ensure clarity and accuracy

4. **Update homepage**
   - Extract git remote URL
   - Set `s.homepage` to the appropriate repository URL
   - Set `s.source` to the appropriate repository URL; use SSH first

5. **Standardize license**
   - Replace `s.license` with:
   ```ruby
   s.license = { :type => 'Copyright', :text => 'Copyright 2025 Boost VPN. All rights reserved.' }

6. **Fix internal dependencies**
   - Identify dependencies that reference the current library
   - Convert to dynamic version format:
s.dependency 'XXX', "= #{s.version}"
   - Ensure all internal dependencies use this pattern
### Output
Generate a summary of all changes made to each podspec file.
