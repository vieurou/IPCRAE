#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# IPCRAE Étendu v3.1 — Lanceur multi-provider
# Commandes : daily, weekly, monthly, close, sync, zettel, moc,
#             health, review, launch, menu
# Providers : Claude, Gemini, Codex, (Kilo via VS Code)
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

VERSION="3.1.0"
IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
IPCRAE_CONFIG="${IPCRAE_ROOT}/.ipcrae/config.yaml"
VAULT_NAME="$(basename "$IPCRAE_ROOT")"

# ── Couleurs ──────────────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'

loginfo()  { printf '%b%s%b\n' "$GREEN"  "$*" "$NC"; }
logwarn()  { printf '%b%s%b\n' "$YELLOW" "$*" "$NC"; }
logerr()   { printf '%b%s%b\n' "$RED"    "$*" "$NC" >&2; }
section()  { printf '\n%b━━ %s ━━%b\n' "$BOLD" "$*" "$NC"; }

prompt_yes_no() {
  local q="$1" d="${2:-y}" a
  while true; do
    if [ "$d" = "y" ]; then
      read -r -p "$q [Y/n] " a || a="y"
      a=${a:-y}
    else
      read -r -p "$q [y/N] " a || a="n"
      a=${a:-n}
    fi
    case "$a" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "y ou n." ;;
    esac
  done
}

# ── Fichiers temp (cleanup auto) ─────────────────────────────
TEMP_FILES=()
cleanup_temps() { for f in "${TEMP_FILES[@]}"; do rm -f "$f"; done; }
trap cleanup_temps EXIT INT TERM

make_temp() {
  local f
  f=$(mktemp /tmp/ipcrae.XXXXXX.md)
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
  if [ ! -d "$IPCRAE_ROOT" ]; then
    logerr "IPCRAE_ROOT introuvable: $IPCRAE_ROOT"
    exit 1
  fi
  cd "$IPCRAE_ROOT"
}

open_note() {
  local abs="$1" rel="$2"
  ${EDITOR:-nano} "$abs"
}

# ── Provider detection ────────────────────────────────────────
get_default_provider() {
  if [ -f "$IPCRAE_CONFIG" ]; then
    local p
    p=$(grep -E '^default_provider:' "$IPCRAE_CONFIG" 2>/dev/null | awk '{print $2}' | tr -d '"' || true)
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
  local ctx="${IPCRAE_ROOT}/.ipcrae/context.md"
  local ins="${IPCRAE_ROOT}/.ipcrae/instructions.md"
  if [ ! -f "$ctx" ] || [ ! -f "$ins" ]; then
    logerr "Sources manquantes (.ipcrae/context.md ou instructions.md)"
    exit 1
  fi

  local body
  body="$(cat "$ctx"; printf '\n\n---\n\n'; cat "$ins")"

  for target in "CLAUDE.md:Claude" "GEMINI.md:Gemini" "AGENTS.md:Codex"; do
    local file="${target%%:*}" name="${target##*:}"
    printf '# Instructions pour %s — IPCRAE v3.1\n# ⚠ GÉNÉRÉ — éditer .ipcrae/context.md + instructions.md\n# Régénérer : ipcrae sync\n\n%s\n' \
      "$name" "$body" > "${IPCRAE_ROOT}/${file}"
    printf '  ✓ %s\n' "$file"
  done

  mkdir -p "${IPCRAE_ROOT}/.kilocode/rules"
  printf '# Instructions IPCRAE pour Kilo Code\n# ⚠ GÉNÉRÉ\n\n%s\n' "$body" > "${IPCRAE_ROOT}/.kilocode/rules/ipcrae.md"
  printf '  ✓ .kilocode/rules/ipcrae.md\n'
  loginfo "Sync terminée."
}

# ── Daily ─────────────────────────────────────────────────────
cmd_daily() {
  local prep="${1:-}"
  need_root
  local y d rel abs
  y="$(year)"; d="$(today)"
  rel="Journal/Daily/${y}/${d}.md"
  abs="${IPCRAE_ROOT}/${rel}"
  mkdir -p "${IPCRAE_ROOT}/Journal/Daily/${y}"

  if [ "$prep" = "--prep" ]; then
    logerr "--prep nécessite une implémentation spécifique du prompt"
    return 1
  fi

  if [ ! -f "$abs" ]; then
    printf '# Daily — %s\n\n## Top 3\n- [ ] \n- [ ] \n- [ ] \n' "$d" > "$abs"
    loginfo "Daily créée: $rel"
  fi
  open_note "$abs" "$rel"
}

# ── Weekly ────────────────────────────────────────────────────
cmd_weekly() {
  need_root
  local y w rel abs
  y="$(date +%G)"; w="$(iso_week)"
  rel="Journal/Weekly/${y}/${w}.md"
  abs="${IPCRAE_ROOT}/${rel}"
  mkdir -p "${IPCRAE_ROOT}/Journal/Weekly/${y}"
  if [ ! -f "$abs" ]; then
    printf '# Weekly — %s\n\n## Objectifs semaine\n- [ ] \n- [ ] \n- [ ] \n' "$w" > "$abs"
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
  abs="${IPCRAE_ROOT}/${rel}"
  mkdir -p "${IPCRAE_ROOT}/Journal/Monthly/${y}"
  if [ ! -f "$abs" ]; then
    printf '# Revue mensuelle — %s\n\n## Bilan objectifs\n\n## Ajustements\n\n## Mois prochain\n' "$m" > "$abs"
    loginfo "Monthly créée: $rel"
  fi
  open_note "$abs" "$rel"
}

# ── Launch IA with Prompt ─────────────────────────────────────
launch_with_prompt() {
  local p="$1" prompt="$2"
  case "$p" in
    claude) claude "$prompt" ;;
    gemini) gemini "$prompt" ;;
    codex)  codex "$prompt" ;;
    *)      logerr "Provider inconnu: $p"; exit 1 ;;
  esac
}

launch_ai() {
  local p="$1" m="${2:-}"
  if [ -n "$m" ]; then
    launch_with_prompt "$p" "MODE EXPERT: ${m}. Analyser le contexte IPCRAE et aider sur ce domaine."
  else
    launch_with_prompt "$p" "Bonjour. Je suis prêt à travailler sur IPCRAE."
  fi
}

# ── Close session ─────────────────────────────────────────────
cmd_close() {
  need_root
  local domain="${1:-}"
  local provider
  provider="$(get_default_provider)"
  local prompt="CLÔTURE DE SESSION :
1) Synthétiser les avancées du jour.
2) Mettre à jour memory/${domain}.md si pertinent.
3) Préparer la transition pour demain."
  launch_with_prompt "$provider" "$prompt"
}

# ── Capture ───────────────────────────────────────────────────
cmd_capture() {
  need_root
  local text="${1:-}"
  if [ -z "$text" ]; then
    read -r -p "Note à capturer: " text
    [ -z "$text" ] && { logerr "Texte requis"; return 1; }
  fi
  local ts
  ts=$(date +%Y%m%d%H%M%S)
  local rel="Inbox/capture-${ts}.md"
  local abs="${IPCRAE_ROOT}/${rel}"
  printf '# Capture %s\n\n%s\n' "$(date +'%Y-%m-%d %H:%M')" "$text" > "$abs"
  loginfo "Note capturée dans $rel"
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
  slug=$(printf '%s' "$title" | iconv -t ASCII//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  [ -z "$slug" ] && slug="note"
  local filename="${id}-${slug}.md"
  local rel="Zettelkasten/_inbox/${filename}"
  local abs="${IPCRAE_ROOT}/${rel}"

  if [ -f "${IPCRAE_ROOT}/Zettelkasten/_template.md" ]; then
    sed -e "s/{{id}}/${id}/g" \
        -e "s/{{date}}/$(today)/g" \
        -e "s/{{titre}}/${title}/g" \
        "${IPCRAE_ROOT}/Zettelkasten/_template.md" > "$abs"
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
  slug=$(printf '%s' "$theme" | iconv -t ASCII//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  [ -z "$slug" ] && slug="theme"
  local filename="MOC-${slug}.md"
  local rel="Zettelkasten/MOC/${filename}"
  local abs="${IPCRAE_ROOT}/${rel}"

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
  local zk_inbox zk_perm zk_moc zk_inbox_stale
  zk_inbox=$(find Zettelkasten/_inbox/ -name "*.md" 2>/dev/null | wc -l)
  zk_inbox_stale=$(find Zettelkasten/_inbox/ -name "*.md" -mtime +7 2>/dev/null | wc -l)
  zk_perm=$(find Zettelkasten/permanents/ -name "*.md" 2>/dev/null | wc -l)
  zk_moc=$(find Zettelkasten/MOC/ -name "*.md" 2>/dev/null | wc -l)
  printf '🗃️  Zettelkasten: %s inbox ' "$zk_inbox"
  if [ "$zk_inbox_stale" -gt 0 ]; then
    printf '%b(⚠ %s > 7j)%b | ' "$RED" "$zk_inbox_stale" "$NC"
  else
    printf '| '
  fi
  printf '%s permanents | %s MOC\n' "$zk_perm" "$zk_moc"

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
    check_date=$(python3 -c "import datetime; d=datetime.date.fromisoformat('$check_date'); print((d-datetime.timedelta(days=1)).isoformat())" 2>/dev/null || break)
  done
  printf '📝 Streak daily: %s jours consécutifs\n' "$streak"

  # Dernière activité
  printf '\n%b📝 Modifié récemment (7j)%b\n' "$YELLOW" "$NC"
  find . -name "*.md" -type f -mtime -7 ! -path "*/Archives/*" ! -path "*/.ipcrae/*" -print0 2>/dev/null \
    | xargs -0 ls -lt 2>/dev/null | head -5 | awk '{print "  • " $NF}' | sed 's|^\./||' || true
}

cmd_doctor() {
  need_root
  local verbose=false
  if [ "${1:-}" = "--verbose" ] || [ "${1:-}" = "-v" ]; then verbose=true; fi
  
  section "Doctor — Environnement"

  local missing=0
  for c in git find sed awk python3 curl iconv; do
    if command -v "$c" >/dev/null 2>&1; then
      [ "$verbose" = true ] && printf '  ✓ %s\n' "$c"
    else
      printf '  ✗ %s (manquant)\n' "$c"
      missing=$((missing + 1))
    fi
  done
  [ "$verbose" = false ] && [ "$missing" -eq 0 ] && printf '  ✓ Dépendances système OK\n'

  printf '\n%bProviders%b\n' "$YELLOW" "$NC"
  for c in claude gemini codex; do
    if command -v "$c" >/dev/null 2>&1; then
      printf '  ✓ %s\n' "$c"
    else
      printf '  ✗ %s\n' "$c"
    fi
  done

  printf '\n%bFichiers IPCRAE%b\n' "$YELLOW" "$NC"
  for f in \
    "$IPCRAE_ROOT/.ipcrae/context.md" \
    "$IPCRAE_ROOT/.ipcrae/instructions.md" \
    "$IPCRAE_ROOT/CLAUDE.md" \
    "$IPCRAE_ROOT/GEMINI.md" \
    "$IPCRAE_ROOT/AGENTS.md"; do
    if [ -f "$f" ]; then
      printf '  ✓ %s\n' "${f#$IPCRAE_ROOT/}"
    else
      printf '  ✗ %s\n' "${f#$IPCRAE_ROOT/}"
    fi
  done

  if [ "$missing" -gt 0 ]; then
    logwarn "Doctor: dépendances de base manquantes: $missing"
    return 1
  fi
  loginfo "Doctor: environnement de base OK"
}


# ── Review ───────────────────────────────────────────────────
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
 1) Lister les domaines memory/
 2) Évaluer les avancées long terme
 3) Définir les objectifs pour les 3 prochains mois"
      launch_with_prompt "$provider" "$prompt" ;;
    *) logerr "Type de revue inconnu: $type (attendu: phase|project|quarter)"; return 1 ;;
  esac
}

# ── Consolidation ─────────────────────────────────────────────
cmd_consolidate() {
  need_root
  local domain="${1:-}"
  if [ -z "$domain" ]; then
    read -r -p "Domaine à consolider (ex: devops, electronique) : " domain
    [ -z "$domain" ] && { logerr "Domaine requis"; return 1; }
  fi
  local prompt="CONSOLIDATION GLOBALE :
1) Lis memory/${domain}.md pour connaître l'état actuel.
2) Cherche les notes locales via 'find .ipcrae-project/local-notes/' ou 'find Projets/'.
3) Propose une mise à jour synthétique et structurée de memory/${domain}.md sans effacer l'historique pertinent."
  
  launch_with_prompt "$(get_default_provider)" "$prompt"
}

# ── Process ───────────────────────────────────────────────────
cmd_process() {
  need_root
  local nom="${1:-}"
  if [ -z "$nom" ]; then
    open_note "${IPCRAE_ROOT}/Process/index.md" "Process/index.md"
    return 0
  fi
  local slug
  slug=$(printf '%s' "$nom" | iconv -t ASCII//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  [ -z "$slug" ] && slug="process"
  local filename="Process-${slug}.md"
  local abs="${IPCRAE_ROOT}/Process/${filename}"
  
  if [ ! -f "$abs" ] && [ -f "${IPCRAE_ROOT}/Process/_template_process.md" ]; then
    cp "${IPCRAE_ROOT}/Process/_template_process.md" "$abs"
    sed -i "s/\[Nom\]/${nom}/g" "$abs"
    loginfo "Process créé: Process/${filename}"
  fi
  open_note "$abs" "Process/${filename}"
}

# ── Update ────────────────────────────────────────────────────
cmd_update() {
  need_root
  section "Mise à jour IPCRAE"
  if [ -d "${IPCRAE_ROOT}/.git" ]; then
    loginfo "Vérification des mises à jour..."
    (cd "${IPCRAE_ROOT}" && git pull) || logwarn "Échec du git pull."
  else
    logwarn "${IPCRAE_ROOT} n'est pas un dépôt Git."
  fi
  
  if prompt_yes_no "Relancer l'installateur (ipcrae-install.sh) ?" "y"; then
    if [ -f "${IPCRAE_ROOT}/ipcrae-install.sh" ]; then
      bash "${IPCRAE_ROOT}/ipcrae-install.sh"
    else
      logwarn "Installateur introuvable dans ${IPCRAE_ROOT}"
    fi
  fi
}

# ── Git Vault Sync ────────────────────────────────────────────
cmd_sync_git() {
  need_root
  section "Sauvegarde Vault (Git Sync)"
  if [ -d "${IPCRAE_ROOT}/.git" ]; then
    loginfo "Synchronisation Git du Vault en cours..."
    (
      cd "${IPCRAE_ROOT}"
      git add -A
      git commit -m "Auto-sync $(date +"%Y-%m-%d %H:%M:%S")" || true
      git push
    ) && loginfo "✅ Sauvegarde terminée avec succès." || logwarn "Échec de la sauvegarde Git."
  else
    logwarn "${IPCRAE_ROOT} n'est pas un dépôt Git. Impossible de synchroniser."
  fi
}

# ── Dashboard ─────────────────────────────────────────────────
show_dashboard() {
  need_root
  section "Tableau de Bord IPCRAE [${VAULT_NAME}]"
  
  # Daily status
  local today_file="Journal/Daily/$(year)/$(today).md"
  if [ -f "$today_file" ]; then
    printf '📅 Daily : %b✓ OK%b\n' "$GREEN" "$NC"
    grep '\- \[ \]' "$today_file" | head -3 | awk '{print "  - " $0}' || true
  else
    printf '📅 Daily : %b✗ Absente (ipcrae daily)%b\n' "$RED" "$NC"
  fi

  # Inbox status
  local in_count
  in_count=$(find Inbox/ -name "*.md" ! -name "waiting*" 2>/dev/null | wc -l)
  if [ "$in_count" -gt 0 ]; then
    printf '📥 Inbox : %b%s notes en attente%b\n' "$YELLOW" "$in_count" "$NC"
  fi

  # Weekly status
  local week_file="Journal/Weekly/$(date +%G)/$(iso_week).md"
  if [ ! -f "$week_file" ]; then
    printf '🗓️  Weekly : %b✗ Pas encore créée%b\n' "$YELLOW" "$NC"
  fi

  printf '\n%b📝 Modifié récemment (7j)%b\n' "$YELLOW" "$NC"
  find . -name "*.md" -type f -mtime -7 ! -path "*/Archives/*" ! -path "*/.ipcrae/*" -print0 2>/dev/null \
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
    "Capture rapide (Inbox)" \
    "Lancer session IA" \
    "Lancer session IA (mode expert)" \
    "Consolidation des notes" \
    "Update IPCRAE" \
    "Sauvegarde Git du Vault (Push)" \
    "Close session" \
    "Health check" \
    "Doctor environnement" \
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
      7)  read -r -p "Note: " _n; cmd_capture "$_n"; break ;;
      8)  launch_ai "$(get_default_provider)"; break ;;
      9)  read -r -p "Mode expert (DevOps, Electronique, Musique…): " m
          launch_ai "$(get_default_provider)" "$m"; break ;;
      10) cmd_consolidate; break ;;
      11) cmd_update; break ;;
      12) cmd_sync_git; break ;;
      13) cmd_close "${extra:-}"; break ;;
      14) cmd_health; break ;;
      15) cmd_doctor; break ;;
      16) sync_providers; break ;;
      17) list_providers; break ;;
      18) open_note "${IPCRAE_ROOT}/Phases/index.md" "Phases/index.md"; break ;;
      19) cmd_process; break ;;
      20) exit 0 ;;
      *)  echo "Choix invalide." ;;
    esac
  done
}

# ── Usage ─────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: ipcrae [COMMANDE] [OPTIONS]

Commandes:
  (rien)|menu              Menu interactif
  daily                    Créer/ouvrir la daily du jour
  daily --prep             Daily pré-rédigée par l'IA
  weekly                   Créer/ouvrir la weekly ISO en cours
  monthly                  Créer/ouvrir la revue mensuelle
  capture "texte"          Capturer une idée rapide dans Inbox
  close                    Clôturer la session (maj mémoire domaine)
  sync                     Régénérer CLAUDE.md, GEMINI.md, AGENTS.md, Kilo
  list                     Lister les providers disponibles
  zettel [titre]           Créer une note atomique Zettelkasten
  moc [thème]              Créer/ouvrir une Map of Content
  health                   Diagnostic du système IPCRAE
  doctor [-v]              Vérifier dépendances + fichiers IPCRAE
  review <type>            Revue adaptative (phase|project|quarter)
  phase|phases             Ouvrir Phases/index.md
  process [nom]            Créer/ouvrir un process ou l'index
  consolidate <domaine>    Lancer une IA pour compacter la mémoire
  update                   Met à jour via git pull puis relance l'installateur
  sync-git                 Sauvegarde Git du vault entier (add, commit, push)
  <texte_libre>            Mode expert (ex: ipcrae DevOps)

Options:
  -p, --provider PROVIDER  Choisir le provider (claude|gemini|codex)
  -h, --help               Aide
  -V, --version            Version

Exemples:
  ipcrae                    # menu
  ipcrae process facturation # crée/ouvre Process-facturation.md
  ipcrae consolidate devops # compacte la mémoire DevOps
  ipcrae update             # mise à jour système
  ipcrae doctor -v          # diagnostic complet
  ipcrae DevOps             # mode expert DevOps
  ipcrae sync               # régénérer fichiers provider
EOF
}

# ── Main ──────────────────────────────────────────────────────
main() {
  local provider="" cmd="" extra=""

  while [ $# -gt 0 ]; do
    case "$1" in
      -p|--provider) provider="${2:-}"; shift ;;
      -h|--help)     usage; exit 0 ;;
      -V|--version)  printf 'IPCRAE Launcher v%s\n' "$VERSION"; exit 0 ;;
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
    capture)         cmd_capture "${extra:-}" ;;
    close)           cmd_close "${extra:-}" ;;
    sync)            sync_providers ;;
    sync-git)        cmd_sync_git ;;
    list)            list_providers ;;
    zettel)          cmd_zettel "$extra" ;;
    moc)             cmd_moc "$extra" ;;
    health)          cmd_health ;;
    doctor)          cmd_doctor "$extra" ;;
    review)          cmd_review "$extra" "$provider" ;;
    update)          cmd_update ;;
    consolidate)     cmd_consolidate "$extra" ;;
    phase|phases)    need_root; open_note "${IPCRAE_ROOT}/Phases/index.md" "Phases/index.md" ;;
    process|processes) cmd_process "$extra" ;;
    *)
      # Texte libre = mode expert
      need_root; show_dashboard
      printf '%b🤖 Provider: %s | 🎯 Expert: %s%b\n\n' "$BOLD" "$provider" "$cmd" "$NC"
      launch_ai "$provider" "$cmd" ;;
  esac
}

main "$@"
