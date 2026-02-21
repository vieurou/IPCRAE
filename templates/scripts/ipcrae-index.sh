#!/usr/bin/env bash
set -euo pipefail
"$HOME/bin/ipcrae-tag-index" || ./ipcrae-tag-index.sh
echo "📊 Top 10 tags:"
jq '.tags | to_entries | sort_by(.value | length) | reverse | .[0:10][] | {tag: .key, count: (.value | length)}' "$IPCRAE_ROOT/.ipcrae/cache/tag-index.json" | jq -r '"\(.tag | lpad=10):\(.count)"'
chmod +x ipcrae-index.sh
