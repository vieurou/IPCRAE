#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# IPCRA Unified Installer v3.1.1
# Unifie l'arborescence, le launcher CLI et la conception agile.
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

VERSION="3.1.1"
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
AUTO_YES=false
IPCRA_ROOT=""

# ── Utilitaires ───────────────────────────────────────────────────────────
loginfo()  { printf '%b→ %s%b\n' "$GREEN"  "$1" "$NC"; }
logwarn()  { printf '%b⚠ %s%b\n' "$YELLOW" "$1" "$NC"; }
logerr()   { printf '%b✗ %s%b\n' "$RED"    "$1" "$NC" >&2; }
section()  { printf '\n%b━━ %s ━━%b\n' "$BOLD" "$1" "$NC"; }

prompt_yes_no() {
  local q="$1" d="$2" a
  [ "$AUTO_YES" = true ] && return 0
  while true; do
    if [ "$d" = "y" ]; then read -r -p "$q [Y/n] " a || a="y"; a=${a:-y}
    else read -r -p "$q [y/N] " a || a="n"; a=${a:-n}; fi
    case "$a" in [Yy]*) return 0;; [Nn]*) return 1;; *) echo "y ou n.";; esac
  done
}

backup_if_exists() {
  local f="$1"
  [ -f "$f" ] && { local t; t=$(date +%Y%m%d-%H%M%S); mv "$f" "${f}.bak-${t}"; } || true
}

write_safe() {
  local f="$1" c="$2"
  mkdir -p "$(dirname "$f")"
  # backup_if_exists "$f" # Removed backup here to avoid clutter, using explicit backup if needed
  printf '%s\n' "$c" > "$f"
}

usage() {
  cat <<EOF
IPCRA v3.1 — Installateur Unifié
Usage: $(basename "$0") [OPTIONS] [CHEMIN]
  -y, --yes       Mode non-interactif
  -h, --help      Aide
  -V, --version   Version
EOF
}

# ── Parsing ───────────────────────────────────────────────────────────────
while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) AUTO_YES=true;; -h|--help) usage; exit 0;;
    -V|--version) echo "IPCRA Install v$VERSION"; exit 0;;
    -*) logerr "Option inconnue: $1"; usage; exit 1;; *) [ -z "$IPCRA_ROOT" ] && IPCRA_ROOT="$1";;
  esac; shift
done

if [ -z "$IPCRA_ROOT" ]; then
  local_default="$HOME/IPCRA"
  if [ "$AUTO_YES" = true ]; then IPCRA_ROOT="$local_default"
  else printf 'Dossier racine IPCRA:\n'; read -r -p "→ [$local_default] " IPCRA_ROOT
    IPCRA_ROOT=${IPCRA_ROOT:-$local_default}; fi
fi

printf '%b╔═══════════════════════════════════════════╗%b\n' "$BLUE" "$NC"
printf '%b║     IPCRA v3.1 — Installateur Unifié      ║%b\n' "$BLUE" "$NC"
printf '%b╚═══════════════════════════════════════════╝%b\n\n' "$BLUE" "$NC"
loginfo "Cible: $IPCRA_ROOT"

[ -d "$IPCRA_ROOT" ] && { logwarn "Le dossier existe déjà."; prompt_yes_no "Mettre à jour / Réinstaller ?" "y" || exit 1; }
mkdir -p "$IPCRA_ROOT"

# ── Git Init ──────────────────────────────────────────────────────────────
if [ ! -d "$IPCRA_ROOT/.git" ]; then
  if prompt_yes_no "Initialiser Git dans le Vault IPCRA ?" "y"; then
    git init "$IPCRA_ROOT"
    loginfo "Git initialisé."
  fi
fi

cd "$IPCRA_ROOT"

# ── 1) ARBORESCENCE ───────────────────────────────────────────────────────
section "Structure des dossiers"
mkdir -p Inbox Projets Casquettes Ressources Archives Agents Scripts Process Phases Objectifs .ipcra
mkdir -p Journal/{Daily,Weekly,Monthly}
mkdir -p Zettelkasten/{_inbox,permanents,MOC}
mkdir -p memory
loginfo "Arborescence créée."

# ── 2) FICHIERS SOURCE (.ipcra/) ───────────────────────────────────────────
section "Fichiers de base"
if [ ! -f ".ipcra/context.md" ] || prompt_yes_no "Écraser context.md et instructions.md ?" "n"; then
write_safe ".ipcra/context.md" '# Contexte Global — IPCRA v3

## Pourquoi ce système
- La mémoire des chats est bruitée → la vérité est dans des fichiers locaux versionnables.
- L'\''IA travaille sur un contexte structuré, mis à jour par les cycles daily/weekly/close.

## Identité
- (À remplir : Qui es-tu ? Quelles sont tes technos de prédilection ?)

## Structure IPCRA
| Dossier | Rôle |
|---------|------|
| Inbox/ | Capture brute |
| Projets/ | Travail actif |
| Zettelkasten/ | Notes atomiques |
| memory/ | Mémoire IA par domaine |

## Commandes CLI
- `ipcra daily --prep` : préparer journalier
- `ipcra capture "note"` : capture rapide
- `ipcra new-project <nom>` : initialiser projet agile
- `ipcra sync` : synchroniser instructions IA'

write_safe ".ipcra/instructions.md" '# Instructions IA — IPCRA v3

## Rôle
Tu es un assistant personnel expert. Respecte .ipcra/context.md.

## Exigences
- **CONCISION** : Pas de blabla, juste la solution.
- **VÉRIFICATION** : Ne jamais inventer une commande ou une version.
- **ÉCRITURE** : Toute décision doit finir dans un fichier markdown (Journal, memory, Projets).'

write_safe ".ipcra/config.yaml" "# IPCRA Configuration
ipcra_root: \"${IPCRA_ROOT}\"
version: \"${VERSION}\"
default_provider: claude

providers:
  claude: {enabled: true, command: claude}
  gemini: {enabled: true, command: gemini}
  codex:  {enabled: true, command: codex}"
fi

# ── 3) LAUNCHER & COMMANDS (The core script) ──────────────────────────────
section "Installation du Launcher CLI"

# On génère le contenu du script launcher 'ipcra'
LAUNCHER_CONTENT=$(cat << 'EOF_LAUNCHER'
#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# IPCRA Launcher v3.1.1 — Unified CLI
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

IPCRA_ROOT="${IPCRA_ROOT:-__IPCRA_ROOT_PLACEHOLDER__}"
IPCRA_CONFIG="${IPCRA_ROOT}/.ipcra/config.yaml"
VAULT_NAME="$(basename "$IPCRA_ROOT")"

GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'

loginfo()  { printf '%b%s%b\n' "$GREEN"  "$*" "$NC"; }
logwarn()  { printf '%b%s%b\n' "$YELLOW" "$*" "$NC"; }
logerr()   { printf '%b%s%b\n' "$RED"    "$*" "$NC" >&2; }

# ── Utilitaires Portables ─────────────────────────────────────
today() { date +%Y-%m-%d; }
iso_week() { date +%G-W%V; }
yesterday() {
  if date -d "yesterday" +%F &>/dev/null; then date -d "yesterday" +%F
  elif date -v-1d +%F &>/dev/null; then date -v-1d +%F
  else python3 -c 'import datetime; print((datetime.date.today()-datetime.timedelta(days=1)).isoformat())' 2>/dev/null || echo ""; fi
}

urlencode() {
  python3 -c "import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))" "$1" 2>/dev/null || printf '%s' "$1"
}

# ── Nettoyage auto ────────────────────────────────────────────
TEMP_FILES=()
cleanup() { for f in "${TEMP_FILES[@]}"; do rm -f "$f"; done; }
trap cleanup EXIT INT TERM

make_temp() {
  local f
  f=$(mktemp /tmp/ipcra.XXXXXX.md)
  TEMP_FILES+=("$f")
  printf '%s' "$f"
}

# ── Commandes ─────────────────────────────────────────────────

cmd_capture() {
  local note="$*"
  [ -z "$note" ] && { read -r -p "Note à capturer: " note; }
  [ -z "$note" ] && return
  local f="Inbox/$(date +%Y%m%d%H%M)-capture.md"
  printf '# Capture — %s\n\n%s\n' "$(date '+%Y-%m-%d %H:%M')" "$note" > "${IPCRA_ROOT}/$f"
  loginfo "Capturé dans $f"
}

cmd_sync() {
  loginfo "Synchronisation des instructions IA..."
  local ctx="${IPCRA_ROOT}/.ipcra/context.md"
  local ins="${IPCRA_ROOT}/.ipcra/instructions.md"
  [ ! -f "$ctx" ] || [ ! -f "$ins" ] && { logerr "Sources manquantes"; return 1; }

  local body
  {
    echo "# Project-Specific AI Instructions"
    cat "$ctx"
    echo -e "\n---\n"
    cat "$ins"
  } > .tmp_rules

  for f in CLAUDE.md GEMINI.md AGENTS.md .clinerules .ai-instructions.md; do
    cp .tmp_rules "$IPCRA_ROOT/$f"
  done
  rm .tmp_rules
  loginfo "Instructions synchronisées."
}

cmd_zettel() {
  local title="${1:-}"
  [ -z "$title" ] && { read -r -p "Titre Zettel: " title; }
  [ -z "$title" ] && return
  local id=$(date +%Y%m%d%H%M)
  # Slug avec gestion accents
  local slug=$(printf '%s' "$title" | iconv -t ASCII//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  local f="Zettelkasten/_inbox/${id}-${slug}.md"
  printf -- "---\nid: %s\ncreated: %s\ntags: []\n---\n# %s\n\n" "$id" "$(today)" "$title" > "${IPCRA_ROOT}/$f"
  loginfo "Zettel créé: $f"
}

cmd_health() {
  loginfo "Vérification du système IPCRA..."
  # Inbox stale check
  local stale=$(find Inbox/ -name "*.md" -mtime +7 | wc -l)
  [ "$stale" -gt 0 ] && logwarn "$stale notes en Inbox depuis > 7 jours."
  
  # Streak daily (fix loop)
  local streak=0 d=$(today)
  while true; do
      local y=$(echo $d | cut -d'-' -f1)
      [ -f "Journal/Daily/$y/$d.md" ] || break
      streak=$((streak + 1))
      local next_d=$(python3 -c "import datetime; d=datetime.date.fromisoformat('$d'); print((d-datetime.timedelta(days=1)).isoformat())" 2>/dev/null || break)
      [ "$next_d" = "$d" ] && break
      d=$next_d
  done
  loginfo "Streak Daily: $streak jours."
}

cmd_daily_prep() {
  local provider=$(grep 'default_provider' "$IPCRA_CONFIG" | awk '{print $2}' || echo "claude")
  loginfo "Préparation Daily via $provider..."
  local ctx_file=$(make_temp)
  {
    echo "## Contexte pour Daily $(today)"
    [ -f "Journal/Weekly/$(date +%G)/$(date +%G-W%V).md" ] && cat "Journal/Weekly/$(date +%G)/$(date +%G-W%V).md"
    echo -e "\n## Instructions\n"
    cat .ipcra/instructions.md
  } > "$ctx_file"
  
  local prompt="Génère un brouillon pour ma daily du $(today) en te basant sur le contexte. Utilise les priorités actives."
  
  case "$provider" in
    claude) claude --append-system-prompt-file "$ctx_file" "$prompt" ;;
    gemini) gemini "$prompt" < "$ctx_file" || echo "$prompt" | gemini ;; # Fallback
    *) logerr "Provider non supporté pour --prep" ;;
  esac
}

cmd_new_project() {
  local name="${1:-}"
  [ -z "$name" ] && { read -r -p "Nom du projet: " name; }
  [ -z "$name" ] && return
  local dir="Projets/$name"
  mkdir -p "$dir/docs/conception/concepts"
  
  # Integration of conception scaffolding
  cat << EOF > "$dir/docs/conception/00_VISION.md"
# Vision: $name
## Objectifs
- 
EOF
  cat << EOF > "$dir/docs/conception/01_AI_RULES.md"
# Règles Techniques
- Effort estimé: 
- Tests requis: 
EOF
  
  # Create local AI instructions link
  ln -sfn "$IPCRA_ROOT" "$dir/.ipcra-memory"
  
  # Concatenate project-specific rules
  {
    echo "# IPCRA BASE"
    cat "$IPCRA_ROOT/.ipcra/context.md"
    echo -e "\n---\n# PROJECT VISION"
    cat "$dir/docs/conception/00_VISION.md"
  } > "$dir/.claude.md"
  
  loginfo "Projet $name initialisé dans $dir"
}

# ── Main ──────────────────────────────────────────────────────
case "${1:-menu}" in
  capture) shift; cmd_capture "$@" ;;
  sync)    cmd_sync ;;
  zettel)  shift; cmd_zettel "$@" ;;
  health)  cmd_health ;;
  daily)   [ "${2:-}" = "--prep" ] && cmd_daily_prep || loginfo "Ouvre Journal/Daily/$(date +%Y)/$(today).md" ;;
  new-project) shift; cmd_new_project "$@" ;;
  *) echo "Usage: ipcra {capture|sync|zettel|health|daily [--prep]|new-project}";;
esac
EOF_LAUNCHER
)

# Replace placeholder in launcher
LAUNCHER_FINAL=$(echo "$LAUNCHER_CONTENT" | sed "s|__IPCRA_ROOT_PLACEHOLDER__|${IPCRA_ROOT}|g")

# Install launcher
mkdir -p "$HOME/bin"
write_safe "$HOME/bin/ipcra" "$LAUNCHER_FINAL"
chmod +x "$HOME/bin/ipcra"

# Add to PATH if missing
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  logwarn "~/bin n'est pas dans ton PATH."
  echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
  loginfo "Ajouté à ~/.bashrc. Redémarre ton shell ou 'source ~/.bashrc'."
fi

section "Installation terminée !"
loginfo "Tu peux maintenant lancer 'ipcra help' (après avoir sourcé ton .bashrc)."
loginfo "Vault : $IPCRA_ROOT"
