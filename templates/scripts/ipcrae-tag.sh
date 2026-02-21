#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-}"
ROOT="${IPCRAE_ROOT:-$PWD}"
[ -z "$TAG" ] && { echo "Usage: ipcrae-tag <tag>" >&2; exit 1; }
cd "$ROOT"

if [ -f .ipcrae/cache/tag-index.json ]; then
  if python3 - "$TAG" <<'PY'
import json, sys
from pathlib import Path
needle = sys.argv[1]
idx = json.loads(Path('.ipcrae/cache/tag-index.json').read_text(encoding='utf-8'))
files = idx.get('tags', {}).get(needle, [])
if not files:
    raise SystemExit(1)
for f in files:
    print(f)
PY
  then
    exit 0
  fi
fi

rg -n --glob '*.md' "(^|[[:space:],\[])(tags:[^\n]*\b${TAG}\b|${TAG})([[:space:],\]]|$)" Knowledge Zettelkasten 2>/dev/null || {
  echo "Aucun résultat pour le tag: $TAG" >&2
  exit 1
}
