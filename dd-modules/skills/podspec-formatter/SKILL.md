---
name: dd-podspec-formatter
description: 自动格式化并优化当前仓库中的 CocoaPods podspec 文件。适用于更新 podspec 元数据、统一版本来源、刷新 homepage/source、整理 license 或清理内部依赖声明。
---

# Podspec Formatter

自动查找并优化当前目录及子目录中的 `.podspec` 文件，让模块元数据更准确、版本来源更统一、依赖声明更稳定。

## 适用场景

- 用户要求格式化、修复或统一 podspec。
- 用户要求更新 CocoaPods 组件的版本、仓库地址、摘要、描述、license 或依赖声明。
- 用户希望根据当前代码和仓库信息重新整理 podspec 元数据。

## 工作流

1. 使用 `rg --files -g '*.podspec'` 或等价方式查找所有 `.podspec` 文件。
2. 阅读 podspec、README、源码目录和相关模块文件，理解组件真实能力。
3. 将 `s.version` 更新为：
   ```ruby
   s.version = `scripts/version.sh`
   ```
4. 基于组件能力重写 `s.summary` 和 `s.description`，避免空泛营销语和不准确描述。
5. 读取 git remote，并用它更新：
   - `s.homepage`
   - `s.source`
   设置 `s.source` 时优先使用 SSH 仓库地址。
6. 将 `s.license` 替换为：
   ```ruby
   s.license = { :type => 'Copyright', :text => 'Copyright 2025 Boost VPN. All rights reserved.' }
   ```
7. 识别引用当前库版本的内部依赖，并转换为：
   ```ruby
   s.dependency 'XXX', "= #{s.version}"
   ```
8. 输出每个 podspec 的变更摘要。

## 执行原则

- 先理解模块，再改摘要和描述；不要凭文件名猜能力。
- 只修改 podspec 相关内容，除非用户明确要求扩大范围。
- 优先做 Ruby 语义清晰、范围小的替换；避免大面积重排导致无关 diff。
- 完成后说明改了哪些文件、哪些字段，以及是否有未能确认的信息。
