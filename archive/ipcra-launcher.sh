#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# IPCRA Étendu v3.1 — Lanceur multi-provider
# Commandes : daily, weekly, monthly, close, sync, zettel, moc,
#             health, review, launch, menu
# Providers : Claude, Gemini, Codex, (Kilo via VS Code)
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

VERSION="3.1.0"
IPCRA_ROOT="${IPCRA_ROOT:-${HOME}/IPCRA}"
IPCRA_CONFIG="${IPCRA_ROOT}/.ipcra/config.yaml"
VAULT_NAME="$(basename "$IPCRA_ROOT")"

# ── Couleurs ──────────────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'

loginfo()  { printf '%b%s%b\n' "$GREEN"  "$*" "$NC"; }
logwarn()  { printf '%b%s%b\n' "$YELLOW" "$*" "$NC"; }
logerr()   { printf '%b%s%b\n' "$RED"    "$*" "$NC" >&2; }
section()  { printf '\n%b━━ %s ━━%b\n' "$BOLD" "$*" "$NC"; }

# ── Fichiers temp (cleanup auto) ─────────────────────────────
TEMP_FILES=()
cleanup_temps() { for f in "${TEMP_FILES[@]}"; do rm -f "$f"; done; }
trap cleanup_temps EXIT INT TERM

make_temp() {
  local f
  f=$(mktemp /tmp/ipcra.XXXXXX.md)
  TEMP_FILES+=("$f")
  printf '%s' "$f"
}

# ── Utilitaires ───────────────────────────────────────────────
iso_week() { date +%G-W%V; }
today()    { date +%F; }
year()     { date +%Y; }
yesterday() {
  date -d "yesterday" +%F 2>/dev/null || date -v-1d +%F 2>/dev/null || echo ""
}

need_root() {
  if [ ! -d "$IPCRA_ROOT" ]; then
    logerr "IPCRA_ROOT introuvable: $IPCRA_ROOT"
    exit 1
  fi
  cd "$IPCRA_ROOT"
}

urlencode() {
  python3 -c "import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))" "$1" 2>/dev/null || printf '%s' "$1"
}

# ── Obsidian / Éditeur ────────────────────────────────────────
obsidian_open_note() {
  local vault="$1" file="$2"
  command -v xdg-open >/dev/null 2>&1 || return 1
  local v f
  v="$(urlencode "$vault")"
  f="$(urlencode "$file")"
  xdg-open "obsidian://open?vault=${v}&file=${f}" >/dev/null 2>&1 || return 1
}

open_note() {
  local abs="$1" rel="$2"
  if obsidian_open_note "$VAULT_NAME" "$rel"; then
    loginfo "Ouvert dans Obsidian: $rel"
  else
    ${EDITOR:-nano} "$abs"
  fi
}

# ── Provider detection ────────────────────────────────────────
get_default_provider() {
  if [ -f "$IPCRA_CONFIG" ]; then
    local p
    p=$(grep -E '^default_provider:' "$IPCRA_CONFIG" 2>/dev/null | awk '{print $2}' | tr -d '"' || true)
    [ -n "$p" ] && printf '%s' "$p" && return
  fi
  for cmd in claude gemini codex; do
    command -v "$cmd" &>/dev/null && printf '%s' "$cmd" && return
  done
  printf 'none'
}

list_providers() {
  printf '%b📋 Providers :%b\n' "$BOLD" "$NC"
  local providers=("claude" "gemini" "codex" "kilo")
  local names=("Claude Code" "Gemini CLI" "Codex" "Kilo Code (VS Code)")
  for i in "${!providers[@]}"; do
    local p="${providers[$i]}" n="${names[$i]}"
    if [ "$p" = "kilo" ]; then
      printf '  %b•%b %-10s — %s\n' "$YELLOW" "$NC" "$p" "$n"
    elif command -v "$p" &>/dev/null; then
      printf '  %b✓%b %-10s — %s\n' "$GREEN" "$NC" "$p" "$n"
    else
      printf '  %b✗%b %-10s — %s (non installé)\n' "$RED" "$NC" "$p" "$n"
    fi
  done
}

# ── Sync : régénérer fichiers provider ────────────────────────
sync_providers() {
  loginfo "Synchronisation des fichiers provider..."
  local ctx="${IPCRA_ROOT}/.ipcra/context.md"
  local ins="${IPCRA_ROOT}/.ipcra/instructions.md"
  [ ! -f "$ctx" ] || [ ! -f "$ins" ] && { logerr "Sources manquantes (.ipcra/context.md ou instructions.md)"; exit 1; }

  local body
  body="$(cat "$ctx"; printf '\n\n---\n\n'; cat "$ins")"

  for target in "CLAUDE.md:Claude" "GEMINI.md:Gemini" "AGENTS.md:Codex"; do
    local file="${target%%:*}" name="${target##*:}"
    printf '# Instructions pour %s — IPCRA v3.1\n# ⚠ GÉNÉRÉ — éditer .ipcra/context.md + instructions.md\n# Régénérer : ipcra sync\n\n%s\n' \
      "$name" "$body" > "${IPCRA_ROOT}/${file}"
    printf '  ✓ %s\n' "$file"
  done

  mkdir -p "${IPCRA_ROOT}/.kilocode/rules"
  printf '# Instructions IPCRA pour Kilo Code\n# ⚠ GÉNÉRÉ\n\n%s\n' "$body" > "${IPCRA_ROOT}/.kilocode/rules/ipcra.md"
  printf '  ✓ .kilocode/rules/ipcra.md\n'
  loginfo "Sync terminée."
}

# ── Daily ─────────────────────────────────────────────────────
cmd_daily() {
  local prep="${1:-}"
  need_root
  local y d rel abs
  y="$(year)"; d="$(today)"
  rel="Journal/Daily/${y}/${d}.md"
  abs="${IPCRA_ROOT}/${rel}"
  mkdir -p "${IPCRA_ROOT}/Journal/Daily/${y}"

  if [ "$prep" = "--prep" ]; then
    cmd_daily_prep "$abs" "$rel" "$d"
    return
  fi

  if [ ! -f "$abs" ]; then
    if [ -f "${IPCRA_ROOT}/Journal/template_daily.md" ]; then
      sed "s/{{date}}/${d}/g" "${IPCRA_ROOT}/Journal/template_daily.md" > "$abs"
    else
      printf '# Daily — %s\n\n## Top 3\n- [ ] \n- [ ] \n- [ ] \n' "$d" > "$abs"
    fi
    loginfo "Daily créée: $rel"
  fi
  open_note "$abs" "$rel"
}

cmd_daily_prep() {
  local abs="$1" rel="$2" d="$3"
  local provider
  provider="$(get_default_provider)"

  if [ "$provider" = "none" ]; then
    logerr "Aucun provider IA disponible pour --prep"
    return 1
  fi

  loginfo "Préparation de la daily par IA ($provider)..."

  # Composer le contexte
  local ctx_file
  ctx_file="$(make_temp)"

  {
    printf '# Contexte pour préparer la daily du %s\n\n' "$d"

    # Daily d'hier
    local yd
    yd="$(yesterday)"
    if [ -n "$yd" ] && [ -f "${IPCRA_ROOT}/Journal/Daily/$(date -d "$yd" +%Y 2>/dev/null || date +%Y)/${yd}.md" ]; then
      printf '## Daily hier (%s)\n' "$yd"
      cat "${IPCRA_ROOT}/Journal/Daily/$(date -d "$yd" +%Y 2>/dev/null || date +%Y)/${yd}.md"
      printf '\n\n'
    fi

    # Weekly courante
    local w_file="${IPCRA_ROOT}/Journal/Weekly/$(date +%G)/$(iso_week).md"
    if [ -f "$w_file" ]; then
      printf '## Weekly courante (%s)\n' "$(iso_week)"
      cat "$w_file"
      printf '\n\n'
    fi

    # Waiting-for
    if [ -f "${IPCRA_ROOT}/Inbox/waiting-for.md" ]; then
      printf '## Waiting-for\n'
      cat "${IPCRA_ROOT}/Inbox/waiting-for.md"
      printf '\n\n'
    fi

    # Phase active
    if [ -f "${IPCRA_ROOT}/Phases/index.md" ]; then
      printf '## Phases actives\n'
      cat "${IPCRA_ROOT}/Phases/index.md"
      printf '\n\n'
    fi

    # Instructions
    [ -f "${IPCRA_ROOT}/.ipcra/instructions.md" ] && cat "${IPCRA_ROOT}/.ipcra/instructions.md"
  } > "$ctx_file"

  local prep_prompt="Prépare ma daily du ${d}. Lis le contexte fourni.
Génère un brouillon structuré avec :
- Les tâches non terminées d'hier (reportées)
- Les priorités de la phase active
- Les waiting-for qui arrivent à échéance
- 3 priorités suggérées pour aujourd'hui
Format : utilise le template standard daily (## Top 3, ## Agenda, ## Next actions par casquette)."

  # Lancer le provider
  case "$provider" in
    claude)
      claude --append-system-prompt-file "$ctx_file" "$prep_prompt"
      ;;
    gemini)
      gemini "$prep_prompt" < "$ctx_file"
      ;;
    codex)
      codex "$prep_prompt"
      ;;
  esac
}

# ── Weekly ────────────────────────────────────────────────────
cmd_weekly() {
  need_root
  local y w rel abs
  y="$(date +%G)"; w="$(iso_week)"
  rel="Journal/Weekly/${y}/${w}.md"
  abs="${IPCRA_ROOT}/${rel}"
  mkdir -p "${IPCRA_ROOT}/Journal/Weekly/${y}"
  if [ ! -f "$abs" ]; then
    if [ -f "${IPCRA_ROOT}/Journal/template_weekly.md" ]; then
      sed "s/{{iso_week}}/${w}/g" "${IPCRA_ROOT}/Journal/template_weekly.md" > "$abs"
    else
      printf '# Weekly — %s\n\n## Objectifs semaine\n- [ ] \n- [ ] \n- [ ] \n' "$w" > "$abs"
    fi
    loginfo "Weekly créée: $rel"
  fi
  open_note "$abs" "$rel"
}

# ── Monthly ───────────────────────────────────────────────────
cmd_monthly() {
  need_root
  local y m rel abs
  y="$(year)"; m="$(date +%Y-%m)"
  rel="Journal/Monthly/${y}/${m}.md"
  abs="${IPCRA_ROOT}/${rel}"
  mkdir -p "${IPCRA_ROOT}/Journal/Monthly/${y}"
  if [ ! -f "$abs" ]; then
    if [ -f "${IPCRA_ROOT}/Journal/template_monthly.md" ]; then
      sed "s/{{month}}/${m}/g" "${IPCRA_ROOT}/Journal/template_monthly.md" > "$abs"
    else
      printf '# Revue mensuelle — %s\n\n## Bilan objectifs\n\n## Ajustements\n\n## Mois prochain\n' "$m" > "$abs"
    fi
    loginfo "Monthly créée: $rel"
  fi
  open_note "$abs" "$rel"
}

# ── Close session ─────────────────────────────────────────────
cmd_close() {
  need_root
  local provider="${1:-$(get_default_provider)}"
  local close_prompt
  close_prompt='PROCÉDURE CLOSE SESSION:
1) Lire: Journal/Daily (aujourd'"'"'hui), Journal/Weekly (courante), Phases/index.md, memory/, .ipcra/context.md.
2) Résumer ce qui a été fait/décidé dans cette session.
3) Identifier le domaine principal (devops, electronique, musique, maison, sante, finance).
4) Écrire une entrée structurée dans memory/<domaine>.md correspondant.
5) Mettre à jour .ipcra/context.md section "Projets en cours" si nécessaire.
6) Proposer (sans exécuter) les déplacements vers Archives/ pour les projets marqués Terminé.'

  launch_with_prompt "$provider" "$close_prompt"
}

# ── Zettelkasten ──────────────────────────────────────────────
cmd_zettel() {
  need_root
  local title="${1:-}"
  if [ -z "$title" ]; then
    read -r -p "Titre de la note: " title
    [ -z "$title" ] && { logerr "Titre requis"; return 1; }
  fi

  local id
  id="$(date +%Y%m%d%H%M)"
  local slug
  slug=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  local filename="${id}-${slug}.md"
  local rel="Zettelkasten/_inbox/${filename}"
  local abs="${IPCRA_ROOT}/${rel}"

  if [ -f "${IPCRA_ROOT}/Zettelkasten/_template.md" ]; then
    sed -e "s/{{id}}/${id}/g" \
        -e "s/{{date}}/$(today)/g" \
        -e "s/{{titre}}/${title}/g" \
        "${IPCRA_ROOT}/Zettelkasten/_template.md" > "$abs"
  else
    cat > "$abs" <<ZEOF
---
id: ${id}
tags: []
liens: []
source:
created: $(today)
---
# ${title}

<!-- Une seule idée, formulée dans tes mots -->


## Liens
- [[]] — raison du lien

## Source
-
ZEOF
  fi

  loginfo "Zettel créée: $rel"
  open_note "$abs" "$rel"
}

# ── MOC (Map of Content) ─────────────────────────────────────
cmd_moc() {
  need_root
  local theme="${1:-}"
  if [ -z "$theme" ]; then
    read -r -p "Thème du MOC: " theme
    [ -z "$theme" ] && { logerr "Thème requis"; return 1; }
  fi

  local slug
  slug=$(printf '%s' "$theme" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  local filename="MOC-${slug}.md"
  local rel="Zettelkasten/MOC/${filename}"
  local abs="${IPCRA_ROOT}/${rel}"

  if [ ! -f "$abs" ]; then
    cat > "$abs" <<MEOF
# MOC — ${theme}

## Notes liées
<!-- Lister les notes [[permanents/YYYYMMDDHHMM-slug]] reliées à ce thème -->

## Sous-thèmes
-

## Résumé
<!-- Synthèse de ce que tu sais sur ce thème -->

MEOF
    loginfo "MOC créé: $rel"
  fi
  open_note "$abs" "$rel"
}

# ── Health ────────────────────────────────────────────────────
cmd_health() {
  need_root
  printf '%b📊 Health Check — %s%b\n\n' "$BOLD" "$(today)" "$NC"

  # Inbox
  local inbox_count inbox_stale
  inbox_count=$(find Inbox/ -maxdepth 1 -name "*.md" ! -name "waiting*" 2>/dev/null | wc -l)
  inbox_stale=$(find Inbox/ -maxdepth 1 -name "*.md" ! -name "waiting*" -mtime +7 2>/dev/null | wc -l)
  printf '📥 Inbox: %s notes' "$inbox_count"
  if [ "$inbox_stale" -gt 0 ]; then
    printf ' %b(⚠ %s > 7 jours)%b' "$RED" "$inbox_stale" "$NC"
  fi
  printf '\n'

  # Waiting-for
  if [ -f "Inbox/waiting-for.md" ]; then
    local wf_count
    wf_count=$(grep -c '^|[^-|]' "Inbox/waiting-for.md" 2>/dev/null || echo 0)
    wf_count=$((wf_count > 0 ? wf_count - 1 : 0))  # soustraire l'en-tête
    printf '⏳ Waiting-for: %s items\n' "$wf_count"
  fi

  # Projets actifs
  local proj_count
  proj_count=$(find Projets/ -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
  printf '🚀 Projets: %s\n' "$proj_count"

  # Zettelkasten
  local zk_inbox zk_perm zk_moc
  zk_inbox=$(find Zettelkasten/_inbox/ -name "*.md" 2>/dev/null | wc -l)
  zk_perm=$(find Zettelkasten/permanents/ -name "*.md" 2>/dev/null | wc -l)
  zk_moc=$(find Zettelkasten/MOC/ -name "*.md" 2>/dev/null | wc -l)
  printf '🗃️  Zettelkasten: %s inbox | %s permanents | %s MOC\n' "$zk_inbox" "$zk_perm" "$zk_moc"

  # Mémoire
  local mem_count
  mem_count=$(find memory/ -name "*.md" ! -name "index.md" -exec grep -l '^## ' {} \; 2>/dev/null | wc -l)
  printf '🧠 Mémoire: %s domaines avec entrées\n' "$mem_count"

  # Casquettes sans activité
  local stale_hats
  stale_hats=$(find Casquettes/ -name "*.md" -mtime +30 2>/dev/null | wc -l)
  if [ "$stale_hats" -gt 0 ]; then
    printf '%b⚠  Casquettes sans activité > 30j: %s%b\n' "$YELLOW" "$stale_hats" "$NC"
  fi

  # Daily streak
  local streak=0 check_date
  check_date="$(today)"
  while [ -f "Journal/Daily/$(date -d "$check_date" +%Y 2>/dev/null || date +%Y)/${check_date}.md" ]; do
    streak=$((streak + 1))
    check_date=$(date -d "$check_date - 1 day" +%F 2>/dev/null || break)
  done
  printf '📝 Streak daily: %s jours consécutifs\n' "$streak"

  # Dernière activité
  printf '\n%b📝 Modifié récemment (7j)%b\n' "$YELLOW" "$NC"
  find . -name "*.md" -type f -mtime -7 ! -path "*/Archives/*" ! -path "*/.ipcra/*" -print0 2>/dev/null \
    | xargs -0 ls -lt 2>/dev/null | head -5 | awk '{print "  • " $NF}' | sed 's|^\./||' || true
}

# ── Review ────────────────────────────────────────────────────
cmd_review() {
  need_root
  local type="${1:-}"
  local provider="${2:-$(get_default_provider)}"

  case "$type" in
    phase)
      local prompt="REVUE DE PHASE:
1) Lire Phases/index.md
2) Lire les projets actifs dans Projets/
3) Évaluer: la phase actuelle est-elle toujours pertinente?
4) Proposer des ajustements de priorités
5) Identifier ce qui devrait être mis en pause ou accéléré"
      launch_with_prompt "$provider" "$prompt" ;;
    project)
      local prompt="RÉTROSPECTIVE PROJET:
1) Demander quel projet
2) Lire le dossier du projet
3) Évaluer: objectifs atteints? Leçons apprises?
4) Proposer l'archivage si terminé
5) Écrire un résumé dans memory/<domaine>.md"
      launch_with_prompt "$provider" "$prompt" ;;
    quarter)
      local prompt="REVUE TRIMESTRIELLE:
1) Lire Objectifs/, Phases/index, memory/
2) Bilan: quels objectifs atteints? Lesquels abandonnés?
3) Évaluer les phases de vie actuelles
4) Proposer les objectifs du trimestre suivant
5) Revoir Objectifs/someday.md: quelque chose à activer?"
      launch_with_prompt "$provider" "$prompt" ;;
    *)
      logerr "Usage: ipcra review <phase|project|quarter>"
      return 1 ;;
  esac
}

# ── Launch AI provider ────────────────────────────────────────
launch_with_prompt() {
  local provider="$1" prompt="${2:-}"

  case "$provider" in
    claude)
      command -v claude &>/dev/null || { logerr "claude introuvable"; exit 1; }
      if [ -n "$prompt" ]; then
        claude --append-system-prompt-file "${IPCRA_ROOT}/CLAUDE.md" "$prompt"
      else
        claude --append-system-prompt-file "${IPCRA_ROOT}/CLAUDE.md"
      fi ;;
    gemini)
      command -v gemini &>/dev/null || { logerr "gemini introuvable"; exit 1; }
      if [ -n "$prompt" ]; then
        gemini "$prompt"
      else
        gemini
      fi ;;
    codex)
      command -v codex &>/dev/null || { logerr "codex introuvable"; exit 1; }
      if [ -n "$prompt" ]; then
        codex "$prompt"
      else
        codex
      fi ;;
    *)
      logerr "Provider inconnu: $provider (claude|gemini|codex)"
      exit 1 ;;
  esac
}

launch_ai() {
  local provider="$1" expert="${2:-}"
  if [ -n "$expert" ]; then
    local prompt="Mode expert: ${expert}. Lis d'abord .ipcra/context.md, Phases/index.md, memory/, la weekly courante et la daily du jour. Puis travaille."
    launch_with_prompt "$provider" "$prompt"
  else
    launch_with_prompt "$provider" ""
  fi
}

# ── Dashboard ─────────────────────────────────────────────────
show_dashboard() {
  need_root
  printf '%b╔═══════════════════════════════════════╗%b\n' "$BLUE" "$NC"
  printf '%b║     🧠 IPCRA v3.1 — CLI               ║%b\n' "$BLUE" "$NC"
  printf '%b╚═══════════════════════════════════════╝%b\n\n' "$BLUE" "$NC"

  local ic pc rc zc
  ic=$(find Inbox/ -maxdepth 1 -name "*.md" ! -name "README*" ! -name "waiting*" ! -name "someday*" 2>/dev/null | wc -l || echo 0)
  pc=$(find Projets/ -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l || echo 0)
  rc=$(find Ressources/ -name "*.md" 2>/dev/null | wc -l || echo 0)
  zc=$(find Zettelkasten/permanents/ -name "*.md" 2>/dev/null | wc -l || echo 0)

  printf '%b📊 État%b\n' "$GREEN" "$NC"
  printf '├─ 📥 Inbox        : %s notes\n' "$ic"
  printf '├─ 🚀 Projets      : %s\n' "$pc"
  printf '├─ 📚 Ressources   : %s docs\n' "$rc"
  printf '└─ 🗃️  Zettelkasten : %s permanents\n\n' "$zc"

  if [ -f "Phases/index.md" ]; then
    printf '%b🎯 Phase active%b\n' "$YELLOW" "$NC"
    grep -E '^\- ' Phases/index.md 2>/dev/null | head -3 || printf '  (aucune)\n'
    printf '\n'
  fi

  printf '%b📝 Modifié récemment (7j)%b\n' "$YELLOW" "$NC"
  find . -name "*.md" -type f -mtime -7 ! -path "*/Archives/*" ! -path "*/.ipcra/*" -print0 2>/dev/null \
    | xargs -0 ls -lt 2>/dev/null | head -5 | awk '{print "  • " $NF}' | sed 's|^\./||' || true
  printf '\n'
}

# ── Menu interactif ───────────────────────────────────────────
cmd_menu() {
  show_dashboard
  PS3="Choix> "
  select choice in \
    "Daily" \
    "Daily --prep (IA)" \
    "Weekly (ISO)" \
    "Monthly" \
    "Zettelkasten (nouvelle note)" \
    "MOC (Map of Content)" \
    "Lancer session IA" \
    "Lancer session IA (mode expert)" \
    "Close session" \
    "Health check" \
    "Sync providers" \
    "Lister providers" \
    "Ouvrir Phases/index" \
    "Ouvrir Process/index" \
    "Quitter"; do
    case "$REPLY" in
      1)  cmd_daily; break ;;
      2)  cmd_daily "--prep"; break ;;
      3)  cmd_weekly; break ;;
      4)  cmd_monthly; break ;;
      5)  read -r -p "Titre: " _t; cmd_zettel "$_t"; break ;;
      6)  read -r -p "Thème: " _t; cmd_moc "$_t"; break ;;
      7)  launch_ai "$(get_default_provider)"; break ;;
      8)  read -r -p "Mode expert (DevOps, Electronique, Musique…): " m
          launch_ai "$(get_default_provider)" "$m"; break ;;
      9)  cmd_close; break ;;
      10) cmd_health; break ;;
      11) sync_providers; break ;;
      12) list_providers; break ;;
      13) open_note "${IPCRA_ROOT}/Phases/index.md" "Phases/index.md"; break ;;
      14) open_note "${IPCRA_ROOT}/Process/index.md" "Process/index.md"; break ;;
      15) exit 0 ;;
      *)  echo "Choix invalide." ;;
    esac
  done
}

# ── Usage ─────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: ipcra [COMMANDE] [OPTIONS]

Commandes:
  (rien)|menu              Menu interactif
  daily                    Créer/ouvrir la daily du jour
  daily --prep             Daily pré-rédigée par l'IA
  weekly                   Créer/ouvrir la weekly ISO en cours
  monthly                  Créer/ouvrir la revue mensuelle
  close                    Clôturer la session (maj mémoire domaine)
  sync                     Régénérer CLAUDE.md, GEMINI.md, AGENTS.md, Kilo
  list                     Lister les providers disponibles
  zettel [titre]           Créer une note atomique Zettelkasten
  moc [thème]              Créer/ouvrir une Map of Content
  health                   Diagnostic du système IPCRA
  review <type>            Revue adaptative (phase|project|quarter)
  phase|phases             Ouvrir Phases/index.md
  process [nom]            Ouvrir un process ou l'index
  <texte_libre>            Mode expert (ex: ipcra DevOps)

Options:
  -p, --provider PROVIDER  Choisir le provider (claude|gemini|codex)
  -h, --help               Aide
  -V, --version            Version

Exemples:
  ipcra                    # menu
  ipcra daily              # daily note
  ipcra daily --prep       # daily pré-rédigée par l'IA
  ipcra zettel "Idée X"   # nouvelle note Zettelkasten
  ipcra moc "DevOps"       # Map of Content DevOps
  ipcra health             # diagnostic système
  ipcra review phase       # revue de phase
  ipcra close              # clôture session
  ipcra DevOps             # mode expert DevOps
  ipcra -p gemini Musique  # Gemini en mode expert musique
  ipcra sync               # régénérer fichiers provider
EOF
}

# ── Main ──────────────────────────────────────────────────────
main() {
  local provider="" cmd="" extra=""

  while [ $# -gt 0 ]; do
    case "$1" in
      -p|--provider) provider="${2:-}"; shift ;;
      -h|--help)     usage; exit 0 ;;
      -V|--version)  printf 'IPCRA Launcher v%s\n' "$VERSION"; exit 0 ;;
      -*)            # Options attachées à une commande (ex: --prep)
        if [ -n "$cmd" ]; then extra="$1"
        else logerr "Option inconnue: $1"; usage; exit 1; fi ;;
      *)
        if [ -z "$cmd" ]; then cmd="$1"
        else extra="$1"; fi ;;
    esac
    shift
  done

  [ -z "$provider" ] && provider="$(get_default_provider)"

  case "${cmd:-menu}" in
    menu)            cmd_menu ;;
    daily)           cmd_daily "$extra" ;;
    weekly)          cmd_weekly ;;
    monthly)         cmd_monthly ;;
    close)           cmd_close "$provider" ;;
    sync)            sync_providers ;;
    list)            list_providers ;;
    zettel)          cmd_zettel "$extra" ;;
    moc)             cmd_moc "$extra" ;;
    health)          cmd_health ;;
    review)          cmd_review "$extra" "$provider" ;;
    phase|phases)    need_root; open_note "${IPCRA_ROOT}/Phases/index.md" "Phases/index.md" ;;
    process|processes)
      need_root
      if [ -n "$extra" ]; then
        local p="Process/${extra}.md"
        [ ! -f "${IPCRA_ROOT}/${p}" ] && printf '# Process — %s\n' "$extra" > "${IPCRA_ROOT}/${p}"
        open_note "${IPCRA_ROOT}/${p}" "$p"
      else
        open_note "${IPCRA_ROOT}/Process/index.md" "Process/index.md"
      fi ;;
    *)
      # Texte libre = mode expert
      need_root; show_dashboard
      printf '%b🤖 Provider: %s | 🎯 Expert: %s%b\n\n' "$BOLD" "$provider" "$cmd" "$NC"
      launch_ai "$provider" "$cmd" ;;
  esac
}

main "$@"
