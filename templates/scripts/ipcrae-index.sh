#!/usr/bin/env bash
# ipcrae-index — Reconstruit tag-index.json ET link-index.json
# Couvre l'intégralité du cerveau (pas seulement Knowledge/ + Zettelkasten/)
set -euo pipefail

ROOT="${1:-${IPCRAE_ROOT:-$PWD}}"
cd "$ROOT"
mkdir -p .ipcrae/cache

# ── Tag-index (tous les dossiers, frontmatter YAML) ───────────
python3 - <<'PY'
import json
from datetime import datetime, timezone
from pathlib import Path

root = Path('.').resolve()
EXCLUDE = {'.git', '.ipcrae'}

def excluded(p):
    return any(part in EXCLUDE or part.startswith('.') for part in p.relative_to(root).parts)

def safe_rel(md):
    try:
        r = md.relative_to(root).as_posix()
        r.encode('utf-8')
        return r
    except (ValueError, UnicodeEncodeError):
        return None

tags = {}
total = 0
for md in root.rglob('*.md'):
    if excluded(md):
        continue
    rel = safe_rel(md)
    if rel is None:
        continue
    total += 1
    try:
        text = md.read_text(encoding='utf-8', errors='ignore')
    except Exception:
        continue
    lines = text.splitlines()
    if not lines or lines[0].strip() != '---':
        continue
    front = []
    for line in lines[1:]:
        if line.strip() == '---':
            break
        front.append(line)
    tag_line     = next((l for l in front if l.strip().startswith('tags:')), '')
    project_line = next((l for l in front if l.strip().startswith('project:')), '')
    found = []
    if '[' in tag_line and ']' in tag_line:
        inner = tag_line.split('[', 1)[1].rsplit(']', 1)[0]
        found.extend([t.strip().strip("\"'") for t in inner.split(',') if t.strip()])
    if project_line:
        project = project_line.split(':', 1)[1].strip().strip("\"'")
        if project:
            found.append(f'project:{project}')
    for t in found:
        tags.setdefault(t, []).append(rel)

for k in list(tags):
    tags[k] = sorted(set(tags[k]))

out = {
    'generated_at': datetime.now(timezone.utc).isoformat(),
    'version': '2',
    'stats': {'files_scanned': total, 'tags_count': len(tags)},
    'tags': dict(sorted(tags.items())),
}
Path('.ipcrae/cache/tag-index.json').write_text(
    json.dumps(out, ensure_ascii=False, indent=2) + '\n', encoding='utf-8'
)
print(f"Tag-index reconstruit: {total} fichiers, {len(tags)} tags")
PY

# ── Link-index ([[wikilinks]] + [text](path.md)) ──────────────
python3 - <<'PY'
import json, re
from pathlib import Path
from datetime import datetime, timezone

root = Path('.').resolve()
EXCLUDE = {'.git', '.ipcrae'}

def excluded(p):
    return any(part in EXCLUDE or part.startswith('.') for part in p.relative_to(root).parts)

def safe_rel(md, root):
    """Retourne le chemin relatif en str ou None si non-encodable."""
    try:
        r = md.relative_to(root).as_posix()
        r.encode('utf-8')
        return r
    except (ValueError, UnicodeEncodeError):
        return None

all_mds = [(f, safe_rel(f, root)) for f in root.rglob('*.md') if not excluded(f)]
all_mds = [(f, r) for f, r in all_mds if r is not None]

stem_map = {}
for md, rel in all_mds:
    stem = md.stem.lower()
    stem_map.setdefault(stem, []).append(rel)

wikilink_re = re.compile(r'\[\[([^\]|#\n]+?)(?:[|#][^\]]*)?\]\]')
mdlink_re   = re.compile(r'\[[^\]]*\]\(([^)#?\n]+\.md)(?:[#?][^)]*)?\)')

forward  = {}
back_raw = {}

for md, rel in all_mds:
    try:
        text = md.read_text(encoding='utf-8', errors='ignore')
    except Exception:
        continue
    targets = set()
    for m in wikilink_re.finditer(text):
        name = m.group(1).strip()
        stem = Path(name).stem.lower()
        for r in stem_map.get(stem, []):
            if r != rel:
                targets.add(r)
    for m in mdlink_re.finditer(text):
        href = m.group(1).strip()
        try:
            if href.startswith('/'):
                resolved = (root / href.lstrip('/')).resolve()
            else:
                resolved = (md.parent / href).resolve()
            r = resolved.relative_to(root).as_posix()
            r.encode('utf-8')  # skip non-encodable
            if r != rel:
                targets.add(r)
        except (ValueError, OSError, UnicodeEncodeError):
            pass
    if targets:
        forward[rel] = sorted(targets)
        for t in targets:
            back_raw.setdefault(t, set()).add(rel)

backlinks = {k: sorted(v) for k, v in sorted(back_raw.items())}
total_links = sum(len(v) for v in forward.values())

out = {
    'generated_at': datetime.now(timezone.utc).isoformat(),
    'version': '1',
    'stats': {
        'files_scanned': len(all_mds),
        'files_with_links': len(forward),
        'total_links': total_links,
    },
    'forward':   dict(sorted(forward.items())),
    'backlinks': backlinks,
}
Path('.ipcrae/cache/link-index.json').write_text(
    json.dumps(out, ensure_ascii=False, indent=2) + '\n', encoding='utf-8'
)
print(f"Link-index reconstruit: {len(all_mds)} fichiers, {total_links} liens")
PY
