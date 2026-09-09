#!/usr/bin/env bash
# 校验 dd-plugins 三端（Claude Code / Codex / Pi）元数据一致性。
# 用法：./scripts/check-plugins.sh
# 依赖：jq
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

fail=0
ok()   { printf '  ok    %s\n' "$1"; }
bad()  { printf '  FAIL  %s\n' "$1"; fail=1; }
head_() { printf '\n== %s\n' "$1"; }

command -v jq >/dev/null || { echo "需要 jq"; exit 1; }

CLAUDE_MARKET=.claude-plugin/marketplace.json
CODEX_MARKET=.agents/plugins/marketplace.json

head_ "JSON 合法性"
while IFS= read -r f; do
  if jq empty "$f" 2>/dev/null; then ok "$f"; else bad "$f 不是合法 JSON"; fi
done < <(find . -name '*.json' -not -path './.git/*' -not -path './.claude/settings.local.json' | sort)

head_ "市场入口"
for m in "$CLAUDE_MARKET" "$CODEX_MARKET"; do
  [ -f "$m" ] && ok "$m 存在" || { bad "$m 缺失"; continue; }
done

claude_plugins=$(jq -r '.plugins[].name' "$CLAUDE_MARKET" 2>/dev/null | sort)
codex_plugins=$(jq -r '.plugins[].name' "$CODEX_MARKET" 2>/dev/null | sort)
if [ "$claude_plugins" = "$codex_plugins" ]; then
  ok "两端插件列表一致：$(echo "$claude_plugins" | tr '\n' ' ')"
else
  bad "两端插件列表不一致"
  diff <(echo "$claude_plugins") <(echo "$codex_plugins") | sed 's/^/        /'
fi

# 市场声明的路径必须真实存在
while read -r p; do
  [ -d "$p" ] && ok "Claude 市场路径 $p" || bad "Claude 市场路径 $p 不存在"
done < <(jq -r '.plugins[].source' "$CLAUDE_MARKET" 2>/dev/null)
while read -r p; do
  [ -d "$p" ] && ok "Codex 市场路径 $p" || bad "Codex 市场路径 $p 不存在"
done < <(jq -r '.plugins[].source.path' "$CODEX_MARKET" 2>/dev/null)

# 磁盘上的插件目录必须都被两端市场收录
for dir in */; do
  dir=${dir%/}
  [ -d "$dir/skills" ] || continue
  echo "$claude_plugins" | grep -qx "$dir" || bad "插件目录 $dir 未收录进 $CLAUDE_MARKET"
  echo "$codex_plugins"  | grep -qx "$dir" || bad "插件目录 $dir 未收录进 $CODEX_MARKET"
done

for plugin in $claude_plugins; do
  head_ "插件 $plugin"
  cp=$plugin/.claude-plugin/plugin.json
  xp=$plugin/.codex-plugin/plugin.json

  for f in "$cp" "$xp"; do
    [ -f "$f" ] && ok "$f 存在" || bad "$f 缺失"
  done
  [ -f "$cp" ] && [ -f "$xp" ] || continue

  # 两端同名字段必须一致，否则安装后显示的版本/描述会分叉
  for field in name version description; do
    cv=$(jq -r --arg k "$field" '.[$k] // "«缺失»"' "$cp")
    xv=$(jq -r --arg k "$field" '.[$k] // "«缺失»"' "$xp")
    if [ "$cv" = "$xv" ]; then ok "$field 两端一致（$cv）"
    else bad "$field 两端不一致：Claude=$cv / Codex=$xv"; fi
  done
  [ "$(jq -r '.name' "$cp")" = "$plugin" ] || bad "plugin.json 的 name 与目录名 $plugin 不符"

  # Codex interface 引用的资源必须真实存在
  for key in composerIcon logo; do
    v=$(jq -r --arg k "$key" '.interface[$k] // empty' "$xp")
    [ -n "$v" ] || continue
    [ -f "$plugin/${v#./}" ] && ok "interface.$key -> $v" || bad "interface.$key 指向不存在的 $v"
  done

  for skill in "$plugin"/skills/*/; do
    skill=${skill%/}
    name=$(basename "$skill")
    md=$skill/SKILL.md
    if [ ! -f "$md" ]; then bad "$name 缺少 SKILL.md"; continue; fi

    fm=$(awk 'NR==1 && /^---[[:space:]]*$/{p=1;next} p && /^---[[:space:]]*$/{exit} p' "$md")
    fm_name=$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1)
    fm_desc=$(printf '%s\n' "$fm" | sed -n 's/^description:[[:space:]]*//p' | head -1)

    [ -n "$fm_desc" ] || bad "$name/SKILL.md frontmatter 缺少 description"
    if [ "$fm_name" = "$name" ]; then ok "$name SKILL.md frontmatter"
    else bad "$name/SKILL.md 的 name=\"$fm_name\" 与目录名不符"; fi

    # Codex 的 skill 展示元数据
    [ -f "$skill/agents/openai.yaml" ] && ok "$name agents/openai.yaml" \
      || bad "$name 缺少 agents/openai.yaml（Codex 展示元数据）"
  done
done

head_ "结果"
if [ "$fail" -eq 0 ]; then echo "  全部通过"; else echo "  存在失败项，见上方 FAIL"; fi
exit "$fail"
