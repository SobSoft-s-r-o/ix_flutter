#!/usr/bin/env bash
# One-way sync of canonical documents into a wiki checkout. Usage: tool/wiki_sync.sh [--dry-run] <wiki-dir>
set -euo pipefail
cd "$(dirname "$0")/.."
dry=0; [ "${1:-}" = "--dry-run" ] && { dry=1; shift; }
wiki="${1:?wiki checkout dir required}"
while IFS= read -r line; do
  [ -z "$line" ] && continue
  src="${line%% -> *}"; dst="${line##* -> }"
  [ -f "$src" ] || { echo "missing source: $src"; exit 1; }
  # relative links doc/x.md -> x (wiki names), root X.md -> X
  if [ "$dry" = 1 ]; then echo "would copy $src -> $wiki/$dst"; else sed -E 's#\((doc/)?([A-Za-z0-9_]+)\.md\)#(\2)#g' "$src" > "$wiki/$dst"; fi
done < tool/wiki_sync_map.txt
echo "sync done (dry-run=$dry)"
