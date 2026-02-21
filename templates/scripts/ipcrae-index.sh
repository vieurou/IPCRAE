#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-${IPCRAE_ROOT:-$PWD}}"
cd "$ROOT"
mkdir -p .ipcrae/cache

python3 - <<'PY'
import json
from datetime import datetime, timezone
from pathlib import Path

root = Path('.').resolve()
scan_dirs = [root / 'Knowledge', root / 'Zettelkasten']
tags = {}
for base in scan_dirs:
    if not base.exists():
        continue
    for md in base.rglob('*.md'):
        text = md.read_text(encoding='utf-8', errors='ignore')
        lines = text.splitlines()
        if not lines or lines[0].strip() != '---':
            continue
        front = []
        for line in lines[1:]:
            if line.strip() == '---':
                break
            front.append(line)
        tag_line = next((l for l in front if l.strip().startswith('tags:')), '')
        project_line = next((l for l in front if l.strip().startswith('project:')), '')
        found = []
        if '[' in tag_line and ']' in tag_line:
            inner = tag_line.split('[', 1)[1].rsplit(']', 1)[0]
            found.extend([t.strip().strip("\"'") for t in inner.split(',') if t.strip()])
        if project_line:
            project = project_line.split(':', 1)[1].strip().strip("\"'")
            if project:
                found.append(f'project:{project}')
        rel = md.relative_to(root).as_posix()
        for t in found:
            tags.setdefault(t, []).append(rel)
for k in list(tags):
    tags[k] = sorted(set(tags[k]))
out = {
    'generated_at': datetime.now(timezone.utc).isoformat(),
    'version': '1',
    'tags': dict(sorted(tags.items())),
}
Path('.ipcrae/cache/tag-index.json').write_text(json.dumps(out, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
PY

echo "Cache tags reconstruit: .ipcrae/cache/tag-index.json"
