#!/usr/bin/env bash
# ipcrae-link-index — Construit .ipcrae/cache/link-index.json
# Parse tous les [[wikilinks]] et [text](path.md) du cerveau.
# Produit : forward (fichier → liens sortants) + backlinks (fichier → qui le cite)
set -euo pipefail

ROOT="${1:-${IPCRAE_ROOT:-$PWD}}"
cd "$ROOT"
mkdir -p .ipcrae/cache

python3 - <<'PY'
import json, re
from pathlib import Path
from datetime import datetime, timezone

root = Path('.').resolve()
EXCLUDE = {'.git', '.ipcrae'}

def excluded(p):
    return any(part in EXCLUDE or part.startswith('.') for part in p.relative_to(root).parts)

def safe_rel(md, root):
    try:
        r = md.relative_to(root).as_posix()
        r.encode('utf-8')
        return r
    except (ValueError, UnicodeEncodeError):
        return None

all_mds = [(f, safe_rel(f, root)) for f in root.rglob('*.md') if not excluded(f)]
all_mds = [(f, r) for f, r in all_mds if r is not None]

# Map stem (minuscule) → liste de chemins relatifs (pour résolution [[wikilink]])
stem_map = {}
for md, rel in all_mds:
    stem = md.stem.lower()
    stem_map.setdefault(stem, []).append(rel)

wikilink_re = re.compile(r'\[\[([^\]|#\n]+?)(?:[|#][^\]]*)?\]\]')
mdlink_re   = re.compile(r'\[[^\]]*\]\(([^)#?\n]+\.md)(?:[#?][^)]*)?\)')

forward  = {}   # rel → [rel, ...]
back_raw = {}   # rel → {rel, ...}

for md, rel in all_mds:
    try:
        text = md.read_text(encoding='utf-8', errors='ignore')
    except Exception:
        continue

    targets = set()

    # [[wikilinks]] — résolution par stem
    for m in wikilink_re.finditer(text):
        name = m.group(1).strip()
        stem = Path(name).stem.lower()
        for r in stem_map.get(stem, []):
            if r != rel:
                targets.add(r)

    # [text](path.md) — résolution relative au fichier courant
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

backlinks   = {k: sorted(v) for k, v in sorted(back_raw.items())}
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
stats = out['stats']
print(f"Link-index reconstruit: {stats['files_scanned']} fichiers scannés, "
      f"{stats['files_with_links']} avec liens, {stats['total_links']} liens totaux")
PY
