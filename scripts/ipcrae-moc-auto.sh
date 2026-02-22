#!/bin/bash
# ===========================================================================
# ipcrae-moc-auto — Génération automatique de MOC Zettelkasten
# ===========================================================================
# Détecte les clusters de tags (≥ min_notes sans MOC existant) et
# crée ou met à jour les Maps of Content dans Zettelkasten/MOC/.
#
# Usage : ipcrae-moc-auto [OPTIONS] [IPCRAE_ROOT]
# Options :
#   --min-notes N    Seuil minimum de notes par tag (défaut: 3)
#   --update         Mettre à jour les MOC existants avec les nouvelles notes
#   --dry-run        Afficher le plan sans créer de fichiers
#   --quiet          Sortie minimale (pour intégration dans ipcrae close)
#   --tag <tag>      Forcer la création pour un tag spécifique
#
# Exit : 0 = OK | 1 = erreur
# ===========================================================================

set -euo pipefail

# ── Couleurs ──────────────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

# ── Options ───────────────────────────────────────────────────────────────
MIN_NOTES=3
UPDATE=false
DRY_RUN=false
QUIET=false
FORCE_TAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --min-notes)  MIN_NOTES="${2:-3}"; shift 2 ;;
    --update|-u)  UPDATE=true; shift ;;
    --dry-run|-n) DRY_RUN=true; shift ;;
    --quiet|-q)   QUIET=true; shift ;;
    --tag)        FORCE_TAG="${2:-}"; shift 2 ;;
    -*) echo -e "${RED}Option inconnue: $1${NC}" >&2; exit 1 ;;
    *)  IPCRAE_ROOT="$1"; shift ;;
  esac
done

IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"

# ── Vérifications ─────────────────────────────────────────────────────────
if [[ ! -d "$IPCRAE_ROOT" ]]; then
  echo -e "${RED}[moc-auto] IPCRAE_ROOT introuvable: $IPCRAE_ROOT${NC}" >&2
  exit 1
fi

TAG_INDEX="${IPCRAE_ROOT}/.ipcrae/cache/tag-index.json"
MOC_DIR="${IPCRAE_ROOT}/Zettelkasten/MOC"
mkdir -p "$MOC_DIR"

# Reconstruire le cache si absent ou stale (> 1h)
if [[ ! -f "$TAG_INDEX" ]] || [[ -n "$(find "$TAG_INDEX" -mmin +60 2>/dev/null)" ]]; then
  $QUIET || echo -e "${CYAN}[moc-auto] Cache tags absent/stale — reconstruction...${NC}"
  if command -v ipcrae &>/dev/null; then
    IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae index &>/dev/null || true
  fi
fi

[[ ! -f "$TAG_INDEX" ]] && { echo -e "${RED}[moc-auto] tag-index.json introuvable${NC}" >&2; exit 1; }

# ── Logique principale (Python3 embarqué) ─────────────────────────────────
python3 - "$IPCRAE_ROOT" "$MIN_NOTES" "$DRY_RUN" "$UPDATE" "$QUIET" "$FORCE_TAG" <<'PYEOF'
import json
import re
import sys
from pathlib import Path
from datetime import date

root       = Path(sys.argv[1])
min_notes  = int(sys.argv[2])
dry_run    = sys.argv[3].lower() in ('true', '1', 'yes')
do_update  = sys.argv[4].lower() in ('true', '1', 'yes')
quiet      = sys.argv[5].lower() in ('true', '1', 'yes')
force_tag  = sys.argv[6] if sys.argv[6] else None

tag_index_path = root / '.ipcrae' / 'cache' / 'tag-index.json'
moc_dir        = root / 'Zettelkasten' / 'MOC'
moc_index_path = moc_dir / 'index.md'

with open(tag_index_path, encoding='utf-8') as f:
    idx = json.load(f)
tags = idx.get('tags', {})

# Tags à ignorer (méta-tags, génériques, formats spéciaux)
SKIP_TAGS = {
    'example-tag', 'moc', 'type', 'status', 'knowledge',
    'process', 'runbook', 'howto', 'pattern', 'daily', 'weekly',
    'monthly', 'template', 'demande-brute', 'analysis'
}

TODAY = date.today().isoformat()

# ── Helpers ────────────────────────────────────────────────────────────────
def slugify(text: str) -> str:
    text = text.lower().strip()
    # Translitérer accents communs
    trans = str.maketrans('àâäéèêëïîôùûüç', 'aaaeeeeiioouuc')
    text = text.translate(trans)
    text = re.sub(r'[^a-z0-9-]', '-', text)
    text = re.sub(r'-+', '-', text).strip('-')
    return text or 'tag'

def get_note_title(note_path: str) -> str:
    """Extraire le premier # titre du fichier"""
    try:
        content = (root / note_path).read_text(encoding='utf-8')
        for line in content.splitlines():
            line = line.strip()
            if line.startswith('# ') and not line.startswith('# ---'):
                return line[2:].strip()
    except Exception:
        pass
    return Path(note_path).stem

def make_wikilink(note_path: str) -> str:
    """Créer un wikilink depuis un chemin relatif"""
    p = Path(note_path)
    rel = str(p.with_suffix('')) if p.suffix == '.md' else str(p)
    # Garder seulement le nom de fichier pour les wikilinks (convention Obsidian)
    return f'[[{p.stem}]]'

def build_moc_content(tag: str, notes: list) -> str:
    tag_display = tag.replace('-', ' ').title()
    note_lines = []
    for note_path in sorted(notes):
        title = get_note_title(note_path)
        wl = make_wikilink(note_path)
        note_lines.append(f'- {wl} — {title}')
    notes_block = '\n'.join(note_lines)

    return f"""---
type: moc
tags: [{tag}, moc]
domain: all
status: active
created: {TODAY}
updated: {TODAY}
---

# MOC — {tag_display}

## Notes liées
{notes_block}

## Sous-thèmes
-

## Résumé
<!-- Synthèse de ce que tu sais sur le thème "{tag}" ({len(notes)} notes) -->
"""

# ── Scan et génération ────────────────────────────────────────────────────
created = []
updated_mocs = []
skipped = []

# Filtrer et trier les tags candidats
candidates = []
for tag, notes in tags.items():
    # Forçage d'un tag spécifique
    if force_tag and tag != force_tag:
        continue
    # Ignorer les tags avec : (ex: project:IPCRAE)
    if ':' in tag:
        continue
    # Ignorer les méta-tags
    if tag in SKIP_TAGS:
        continue
    # Ignorer les tags trop rares
    if len(notes) < min_notes and not force_tag:
        continue
    candidates.append((tag, notes))

# Trier par nombre de notes décroissant
candidates.sort(key=lambda x: -len(x[1]))

for tag, notes in candidates:
    slug   = slugify(tag)
    moc_file = moc_dir / f'MOC-{slug}.md'

    if not moc_file.exists():
        content = build_moc_content(tag, notes)
        if not dry_run:
            moc_file.write_text(content, encoding='utf-8')
        created.append({
            'tag': tag,
            'count': len(notes),
            'file': str(moc_file.relative_to(root))
        })
        if not quiet:
            marker = '[DRY-RUN] ' if dry_run else ''
            print(f"  ✅ {marker}MOC créé: Zettelkasten/MOC/MOC-{slug}.md ({len(notes)} notes)")

    elif do_update:
        # Chercher les notes manquantes dans le MOC existant
        content = moc_file.read_text(encoding='utf-8')
        missing_lines = []
        for note_path in sorted(notes):
            stem = Path(note_path).stem
            wl = f'[[{stem}]]'
            if wl not in content:
                title = get_note_title(note_path)
                missing_lines.append(f'- {wl} — {title}')

        if missing_lines:
            insert = '\n'.join(missing_lines)
            # Insérer après la ligne "## Notes liées"
            new_content = re.sub(
                r'(## Notes liées\n)',
                f'\\1{insert}\n',
                content
            )
            # Mettre à jour la date
            new_content = re.sub(
                r'updated: \d{4}-\d{2}-\d{2}',
                f'updated: {TODAY}',
                new_content
            )
            if not dry_run:
                moc_file.write_text(new_content, encoding='utf-8')
            updated_mocs.append({
                'tag': tag,
                'added': len(missing_lines),
                'file': str(moc_file.relative_to(root))
            })
            if not quiet:
                marker = '[DRY-RUN] ' if dry_run else ''
                print(f"  🔄 {marker}MOC mis à jour: MOC-{slug}.md (+{len(missing_lines)} notes)")
        else:
            skipped.append(tag)
    else:
        skipped.append(tag)

# ── Mise à jour de Zettelkasten/MOC/index.md ─────────────────────────────
if created and not dry_run:
    if moc_index_path.exists():
        index_content = moc_index_path.read_text(encoding='utf-8')
    else:
        index_content = "# MOC — Index général\n\n"

    # Vérifier si la section auto-générés existe déjà
    section_header = '\n## Auto-générés\n'
    if section_header not in index_content:
        if not index_content.endswith('\n'):
            index_content += '\n'
        index_content += f'\n## Auto-générés\n*Générés par ipcrae-moc-auto ({TODAY})*\n'

    # Ajouter les nouveaux MOC dans la section
    new_entries = []
    for m in created:
        tag_display = m['tag'].replace('-', ' ').title()
        slug_val = slugify(m['tag'])
        entry = f"- [[MOC-{slug_val}]] — {tag_display} ({m['count']} notes)"
        # Ne pas dupliquer
        if entry not in index_content and f'MOC-{slug_val}' not in index_content:
            new_entries.append(entry)

    if new_entries:
        insert_block = '\n'.join(new_entries) + '\n'
        index_content = re.sub(
            r'(## Auto-générés\n\*[^\n]*\n)',
            f'\\1{insert_block}',
            index_content
        )
        index_content = re.sub(
            r'updated: \d{4}-\d{2}-\d{2}',
            f'updated: {TODAY}',
            index_content
        )
        moc_index_path.write_text(index_content, encoding='utf-8')

# ── Résumé ────────────────────────────────────────────────────────────────
total = len(created) + len(updated_mocs)
if total == 0 and not quiet:
    print("  ℹ️  Aucun nouveau MOC nécessaire (tous les clusters ont déjà leur MOC)")
elif not quiet:
    print(f"\n  📊 Résumé: {len(created)} créé(s), {len(updated_mocs)} mis à jour, {len(skipped)} ignoré(s)")

if dry_run and candidates:
    print("\n  [DRY-RUN] Candidats détectés:")
    for tag, notes in candidates:
        slug_val = slugify(tag)
        exists = (moc_dir / f'MOC-{slug_val}.md').exists()
        status = "EXISTE" if exists else "À CRÉER"
        print(f"    {status}  {tag} ({len(notes)} notes)")

sys.exit(0)
PYEOF
