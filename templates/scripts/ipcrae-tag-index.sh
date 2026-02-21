#!/usr/bin/env bash
set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-$HOME/IPCRAE}"
CACHE_FILE="$IPCRAE_ROOT/.ipcrae/cache/tag-index.json"

mkdir -p "$(dirname "$CACHE_FILE")"

find "$IPCRAE_ROOT"/{Knowledge,Zettelkasten/permanents} -name "*.md" -not -path "*/_*" | \
awk '/^---/ { in_front=1; next } /^---/ && in_front { in_front=0; next } /tags: *\[(.*)\]/ && in_front { gsub(/["\[\] ]/, "", $0); gsub(/tags: *\[/, "", $0); print FILENAME, $0 } /project: *(.*)/ && in_front { print FILENAME, "project:" $2 } /domain: *(.*)/ && in_front { print FILENAME, "domain:" $2 }' | sort | uniq | \
jq -n --slurpfile lines /dev/stdin '{ generated_at: "'$(date -Iseconds)'", version: "1", tags: (reduce .[] as $line ({}; if ($line[1] | test("^project:|^domain:")) then .[$line[1]] += [$line[0]] else .[$line[1]] += [$line[0]] end) | del(.[""]) ) }' > "$CACHE_FILE"

echo "✓ Cache reconstruit ($(jq '.tags | length' "$CACHE_FILE")) tags"
chmod +x ipcrae-tag-index.sh  # Test local
