#!/usr/bin/env bash
set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-$HOME/IPCRAE}"
CACHE_FILE="$IPCRAE_ROOT/.ipcrae/cache/tag-index.json"
TAG="${1:?Usage: ipcrae tag <tag> [grep-pattern]}"
GREP="${2:-}"

if [[ ! -f "$CACHE_FILE" ]]; then
  echo "❌ Cache absent → ipcrae index"
  exit 1
fi

jq -r --arg tag "$TAG" '.tags[$tag] // empty | .[]' "$CACHE_FILE" | \
if [[ -n "$GREP" ]]; then
  xargs grep -l "$GREP"
else
  cat
fi | head -10 | nl -w2 -s': '

echo "($(wc -l <(jq -r --arg tag "$TAG" '.tags[$tag] // empty | .[]' "$CACHE_FILE"))) fichiers)"
chmod +x ipcrae-tag.sh
