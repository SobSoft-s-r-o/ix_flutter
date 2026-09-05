#!/usr/bin/env bash
# One-way sync of canonical documents into a wiki checkout. Usage: tool/wiki_sync.sh [--dry-run] <wiki-dir>
set -euo pipefail
cd "$(dirname "$0")/.."
dry=0; [ "${1:-}" = "--dry-run" ] && { dry=1; shift; }
wiki="${1:?wiki checkout dir required}"

repo_base="https://github.com/SobSoft-s-r-o/ix_flutter"

# Prints the wiki page name (no .md) mapped from repo-root-relative path $1;
# fails if $1 is not a sync source.
map_dst() {
  local path="$1" line s d
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    s="${line%% -> *}"; d="${line##* -> }"
    [ "$path" = "$s" ] && { printf '%s' "${d%.md}"; return 0; }
  done < tool/wiki_sync_map.txt
  return 1
}

# Resolves link path $2 relative to directory $1 into a repo-root-relative
# path, collapsing "." and ".." segments.
resolve_path() {
  local base="$1" rel="$2" combined seg result
  local -a parts=() out=()
  local IFS=/
  case "$rel" in
    /*) combined="${rel#/}" ;;
    *) if [ "$base" = "." ]; then combined="$rel"; else combined="$base/$rel"; fi ;;
  esac
  read -r -a parts <<< "$combined"
  for seg in "${parts[@]}"; do
    case "$seg" in
      ""|".") ;;
      "..")
        if [ "${#out[@]}" -gt 0 ]; then
          unset "out[$(( ${#out[@]} - 1 ))]"
        fi
        ;;
      *) out+=("$seg") ;;
    esac
  done
  result="${out[*]}"
  printf '%s' "$result"
}

# Escapes $1 for safe use as a bash `${var//pattern/repl}` glob pattern.
glob_escape() {
  local s="$1" out="" i c
  for (( i = 0; i < ${#s}; i++ )); do
    c="${s:i:1}"
    case "$c" in
      '\'|'*'|'?'|'[') out+="\\$c" ;;
      *) out+="$c" ;;
    esac
  done
  printf '%s' "$out"
}

# Rewrites local markdown link targets in file $1 to wiki page names (mapped
# sources) or absolute GitHub URLs (everything else), preserving #anchors,
# and prints the resulting content.
rewrite_links() {
  local file="$1" srcdir target path anchor resolved dst new content old_pat
  srcdir="$(dirname "$file")"
  content="$(cat "$file"; printf x)"; content="${content%x}"
  while IFS= read -r target; do
    [ -z "$target" ] && continue
    case "$target" in
      http://*|https://*|mailto:*|'#'*) continue ;;
    esac
    case "$target" in
      *'#'*) path="${target%%#*}"; anchor="#${target#*#}" ;;
      *) path="$target"; anchor='' ;;
    esac
    [ -z "$path" ] && continue
    resolved="$(resolve_path "$srcdir" "$path")"
    if dst="$(map_dst "$resolved")"; then
      new="${dst}${anchor}"
    elif [ -d "$resolved" ]; then
      new="${repo_base}/tree/main/${resolved}${anchor}"
    else
      new="${repo_base}/blob/main/${resolved}${anchor}"
    fi
    [ "$target" = "$new" ] && continue
    old_pat="$(glob_escape "(${target})")"
    content="${content//$old_pat/(${new})}"
  done < <(grep -oE '\]\([^)]+\)' "$file" | sed -E 's/^\]\(//; s/\)$//' | sort -u)
  printf '%s' "$content"
}

while IFS= read -r line; do
  [ -z "$line" ] && continue
  src="${line%% -> *}"; dst="${line##* -> }"
  [ -f "$src" ] || { echo "missing source: $src"; exit 1; }
  if [ "$dry" = 1 ]; then
    echo "would copy $src -> $wiki/$dst"
  else
    rewrite_links "$src" > "$wiki/$dst"
  fi
done < tool/wiki_sync_map.txt
echo "sync done (dry-run=$dry)"
