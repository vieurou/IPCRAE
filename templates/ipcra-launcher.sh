#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# IPCRA Étendu v3.1 — Lanceur multi-provider
# Commandes : daily, weekly, monthly, close, sync, zettel, moc,
#             health, context, review, launch, menu
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

require_or_warn() {
  local cmd="$1"
  local msg="${2:-"Commande '$cmd' recommandée mais introuvable."}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    logwarn "$msg"
    return 1
  fi
  return 0
}

# Retourne 0 si memory/<domain>.md a au moins une valeur renseignée ("- Clé : valeur")
context_is_populated() {
  local domain="$1"
  local mem="${IPCRA_ROOT}/memory/${domain}.md"
  [ -f "$mem" ] || return 1
  grep -qE '^- [^:]+: .+' "$mem"
}

urlencode() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))" "$1" 2>/dev/null
  else
    printf '%s' "$1" | sed 's/ /%20/g; s/\[/%5B/g; s/\]/%5D/g'
  fi
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

  local prompt_file="${IPCRA_ROOT}/.ipcra/prompts/prompt_daily_prep.md"
  if [ ! -f "$prompt_file" ]; then
    logerr "Fichier de prompt introuvable : $prompt_file"
    return 1
  fi
  local prep_prompt
  prep_prompt=$(cat "$prompt_file")
  prep_prompt="${prep_prompt//\{\{date\}\}/$d}"

  # Lancer le provider
  case "$provider" in
    claude)
      claude --append-system-prompt-file "$ctx_file" "$prep_prompt"
      ;;
    gemini)
      if gemini --context "$ctx_file" "$prep_prompt" 2>/dev/null; then
        :
      else
        logwarn "Gemini: --context non supporté, lancement sans contexte fichier"
        gemini "$prep_prompt"
      fi
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
  local domain="${1:-}"
  local provider
  provider="$(get_default_provider)"
  local domain_hint=""
  [ -n "$domain" ] && domain_hint=" Utiliser spécifiquement le domaine: ${domain}."
  local prompt_file="${IPCRA_ROOT}/.ipcra/prompts/prompt_close.md"
  if [ ! -f "$prompt_file" ]; then
    logerr "Fichier de prompt introuvable : $prompt_file"
    return 1
  fi
  local close_prompt
  close_prompt=$(cat "$prompt_file")
  close_prompt="${close_prompt//\{\{domain_hint\}\}/$domain_hint}"
  launch_with_prompt "$provider" "$close_prompt"
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
  local abs="${IPCRA_ROOT}/${rel}"
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
  slug=$(printf '%s' "$theme" | iconv -t ASCII//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  [ -z "$slug" ] && slug="theme"
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

# ── Consolidation CDE ─────────────────────────────────────────
cmd_consolidate() {
  if [ ! -d ".ipcra-project/local-notes" ]; then
    logerr "Dossier .ipcra-project/local-notes introuvable."
    logwarn "Cette commande s'exécute à la racine d'un projet local (Architecture CDE)."
    return 1
  fi

  local domain="${1:-}"
  if [ -z "$domain" ]; then
    read -r -p "Domaine global cible (ex: devops, electronique) : " domain
    [ -z "$domain" ] && { logerr "Domaine requis"; return 1; }
  fi

  local memory_dir=".ipcra-memory/memory"
  local memory_file="${memory_dir}/${domain}.md"
  
  if [ ! -d "$memory_dir" ]; then
    logerr "Lien global .ipcra-memory introuvable ou brisé."
    return 1
  fi

  local local_content=""
  local has_notes=false
  for f in .ipcra-project/local-notes/*.md; do
    [ -e "$f" ] || continue
    [ "$(basename "$f")" = "README.md" ] && continue
    has_notes=true
    local_content+=$'\n\n--- Source: '"$(basename "$f")"$' ---\n'
    local_content+=$(cat "$f" 2>/dev/null)
  done

  if [ "$has_notes" = false ] || [ -z "$(echo "$local_content" | tr -d '[:space:]-')" ]; then
    logwarn "Aucun contenu Markdown local trouvé à consolider (hors README.md)."
    return 0
  fi

  loginfo "Génération de la synthèse IA (cela prend quelques secondes)..."
  local prompt_file="${IPCRA_ROOT}/.ipcra/prompts/prompt_consolidate.md"
  if [ ! -f "$prompt_file" ]; then
    logerr "Fichier de prompt introuvable : $prompt_file"
    return 1
  fi
  local prompt
  prompt=$(cat "$prompt_file")
  prompt="${prompt//\{\{domain\}\}/$domain}"
  prompt="${prompt//\{\{date\}\}/$(today)}"
  prompt="${prompt//\{\{local_content\}\}/$local_content}"

  local provider
  provider=$(get_default_provider)
  local draft=".ipcra-project/draft-consolidation.md"
  
  case "$provider" in
    claude) claude -p "$prompt" > "$draft" 2>/dev/null ;;
    gemini) gemini "$prompt" > "$draft" 2>/dev/null ;;
    codex) codex "$prompt" > "$draft" 2>/dev/null ;;
    *) logerr "Provider $provider non supporté en headless."; return 1 ;;
  esac

  if [ ! -s "$draft" ]; then
    logerr "La génération IA a échoué (réponse vide)."
    return 1
  fi

  loginfo "Brouillon généré."
  local editor="${EDITOR:-nano}"
  "$editor" "$draft"

  section "Validation de la consolidation"
  cat "$draft"
  echo ""
  
  if prompt_yes_no "Ce draft est-il correct ? L'injecter dans la mémoire globale ($domain) ?" "y"; then
    if [ ! -f "$memory_file" ]; then
      echo "# Mémoire — ${domain}" > "$memory_file"
    fi
    echo "" >> "$memory_file"
    cat "$draft" >> "$memory_file"
    loginfo "Injecté avec succès dans $memory_file"
    
    if prompt_yes_no "Vider les notes locales traitées pour ce projet ?" "y"; then
      for f in .ipcra-project/local-notes/*.md; do
        [ -e "$f" ] || continue
        [ "$(basename "$f")" = "README.md" ] && continue
        rm -f "$f"
      done
      echo "# Tâches en cours" > .ipcra-project/local-notes/todo.md
      loginfo "Dossier local-notes/ purgé."
    fi
  else
    logwarn "Injection annulée. Le draft reste disponible dans $draft"
    return 0
  fi
  
  rm -f "$draft" 2>/dev/null || true
}

# ── Ingest Project (Audit & Sync) ─────────────────────────────
cmd_ingest() {
  local domain="${1:-}"
  if [ -z "$domain" ]; then
    read -r -p "Domaine global cible (ex: devops, electronique) : " domain
    [ -z "$domain" ] && { logerr "Domaine requis"; return 1; }
  fi

  local memory_dir="${IPCRA_ROOT:-$HOME/IPCRA}/memory"
  [ -d ".ipcra-memory/memory" ] && memory_dir=".ipcra-memory/memory"
  
  if [ ! -d "$memory_dir" ]; then
    logerr "Dossier mémoire introuvable ($memory_dir). Êtes-vous dans un projet IPCRA ?"
    return 1
  fi

  if [ ! -d ".git" ] && [ ! -d "src" ] && [ ! -f "README.md" ]; then
    logwarn "Ceci ne ressemble pas à la racine d'un projet."
    prompt_yes_no "Lancer l'ingestion quand même ?" "y" || return 0
  fi

  local prompt_file="${IPCRA_ROOT}/.ipcra/prompts/prompt_ingest.md"
  if [ ! -f "$prompt_file" ]; then
    logerr "Fichier de prompt introuvable : $prompt_file"
    return 1
  fi
  local prompt
  prompt=$(cat "$prompt_file")
  prompt="${prompt//\{\{memory_dir\}\}/$memory_dir}"
  prompt="${prompt//\{\{domain\}\}/$domain}"
  prompt="${prompt//\{\{ipcra_root\}\}/${IPCRA_ROOT:-$HOME/IPCRA}}"
  prompt="${prompt//\{\{project_name\}\}/$(basename "$PWD")}"
  prompt="${prompt//\{\{date\}\}/$(today)}"

  local provider
  provider=$(get_default_provider)
  
  loginfo "Démarrage de la session d'ingestion interactive avec ${provider}..."
  loginfo "Démarrage de la session d'ingestion interactive avec ${provider}..."
  launch_with_prompt "$provider" "$prompt"
}

# ── Concept ───────────────────────────────────────────────────
cmd_concept() {
  local title="${1:-}"
  if [ -z "$title" ]; then
    read -r -p "Nom complet du concept : " title
    [ -z "$title" ] && { logerr "Nom requis"; return 1; }
  fi

  local base_dir="docs/conception"
  local concepts_dir="$base_dir/concepts"
  
  if [ ! -d "$concepts_dir" ]; then
    logwarn "Dossier $concepts_dir introuvable. Projet non initialisé avec IPCRA ?"
    prompt_yes_no "Le créer quand même ?" "y" || return 1
    mkdir -p "$concepts_dir"
  fi

  local count
  count=$(find "$concepts_dir" -maxdepth 1 -name "[0-9][0-9]_*.md" 2>/dev/null | wc -l)
  local next_num
  next_num=$(printf "%02d" $((count + 1)))
  
  # Slugify (fallback sur tr si sed/iconv manquent)
  local slug
  if command -v iconv >/dev/null && command -v sed >/dev/null; then
    slug=$(echo "$title" | iconv -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/-/g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//')
  else
    slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  fi

  local target="$concepts_dir/${next_num}_${slug}.md"
  
  if [ -f "$target" ]; then
    logerr "Le fichier $target existe déjà."
    return 1
  fi

  if [ -f "$concepts_dir/_TEMPLATE_CONCEPT.md" ]; then
    cp "$concepts_dir/_TEMPLATE_CONCEPT.md" "$target"
    # Remplacer le titre
    if command -v sed >/dev/null; then
       sed -i "s/\[Nom du Concept.*\]/$title/" "$target"
       sed -i "s/YYYY-MM-DD/$(today)/" "$target"
    fi
    loginfo "Concept créé : $target (depuis _TEMPLATE_CONCEPT.md)"
  else
    logwarn "Template $concepts_dir/_TEMPLATE_CONCEPT.md introuvable."
    echo "# Concept : $title" > "$target"
    echo "**Date** : $(today)" >> "$target"
    loginfo "Concept vide créé : $target"
  fi

  local editor="${EDITOR:-nano}"
  "$editor" "$target"
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

  # Contexte agents
  local ctx_domains=("devops" "electronique" "musique" "maison" "sante" "finance")
  local ctx_ok=0 ctx_missing=()
  for _d in "${ctx_domains[@]}"; do
    if context_is_populated "$_d" 2>/dev/null; then
      ctx_ok=$((ctx_ok + 1))
    else
      ctx_missing+=("$_d")
    fi
  done
  printf '🤖 Contexte agents: %s/%s renseignés' "$ctx_ok" "${#ctx_domains[@]}"
  if [ ${#ctx_missing[@]} -gt 0 ]; then
    printf ' %b(vides: %s)%b' "$YELLOW" "${ctx_missing[*]}" "$NC"
    printf ' → ipcra context <domaine>'
  fi
  printf '\n'

  # Dernière activité
  printf '\n%b📝 Modifié récemment (7j)%b\n' "$YELLOW" "$NC"
  find . -name "*.md" -type f -mtime -7 ! -path "*/Archives/*" ! -path "*/.ipcra/*" -print0 2>/dev/null \
    | xargs -0 ls -lt 2>/dev/null | head -5 | awk '{print "  • " $NF}' | sed 's|^\./||' || true
}

# ── Context collect ───────────────────────────────────────────
cmd_context_collect() {
  local domain="${1:-}"
  need_root
  if [ -z "$domain" ]; then
    printf 'Domaines disponibles: devops electronique musique maison sante finance\n'
    read -r -p "Domaine : " domain
    [ -z "$domain" ] && { logerr "Domaine requis"; return 1; }
  fi
  domain="${domain,,}"

  local mem="${IPCRA_ROOT}/memory/${domain}.md"
  local agent="${IPCRA_ROOT}/Agents/agent_${domain}.md"

  [ -f "$mem" ] || { logerr "Fichier mémoire introuvable: memory/${domain}.md"; return 1; }

  section "Contexte — ${domain}"

  if context_is_populated "$domain"; then
    loginfo "Contexte existant :"
    grep -E '^- [^:]+: .+' "$mem" | head -10
    printf '\n'
    prompt_yes_no "Mettre à jour ?" "n" || return 0
  else
    logwarn "Contexte vide. Quelques questions pour personnaliser les réponses."
  fi

  # Extraire les questions du fichier agent (lignes "> N. Question ?")
  local questions=()
  if [ -f "$agent" ]; then
    while IFS= read -r line; do
      [[ "$line" =~ ^\>\ [0-9]+\. ]] && questions+=("${line#> }")
    done < "$agent"
  fi
  [ ${#questions[@]} -eq 0 ] && questions=("Contexte général pour ${domain} ?")

  # Collecter les réponses
  local new_entries=()
  for q in "${questions[@]}"; do
    local label ans
    label=$(printf '%s' "$q" | sed 's/^[0-9]*\. //; s/ ?$//')
    printf '  %b→%b %s\n' "$BLUE" "$NC" "$q"
    read -r -p "    Réponse (Entrée pour passer) : " ans || true
    [ -n "$ans" ] && new_entries+=("- ${label} : ${ans}")
  done

  [ ${#new_entries[@]} -eq 0 ] && { logwarn "Aucune réponse — contexte inchangé."; return 0; }

  printf '\n%bEntrées à écrire :%b\n' "$BOLD" "$NC"
  printf '  %s\n' "${new_entries[@]}"
  printf '\n'

  prompt_yes_no "Écrire dans memory/${domain}.md ?" "y" || return 0

  # Injecter après la ligne "<!-- Collecté..."  dans la section Contexte
  local tmp
  tmp=$(mktemp /tmp/ipcra_ctx.XXXXXX)
  local in_ctx=false injected=false
  while IFS= read -r line; do
    printf '%s\n' "$line"
    if [[ "$line" =~ ^##\ Contexte ]] && ! $injected; then
      in_ctx=true
    fi
    if $in_ctx && ! $injected && [[ "$line" =~ ^\<\!--\ Collecté ]]; then
      printf '%s\n' "${new_entries[@]}"
      injected=true
      in_ctx=false
    fi
  done < "$mem" > "$tmp"

  if $injected; then
    cp "$tmp" "$mem"
    loginfo "Contexte '${domain}' mis à jour dans memory/${domain}.md"
  else
    logerr "Section '<!-- Collecté...' introuvable dans memory/${domain}.md — rien écrit."
  fi
  rm -f "$tmp"
}

# ── Doctor ────────────────────────────────────────────────────
cmd_doctor() {
  printf '%b🩺 IPCRA Doctor — Vérification des dépendances%b\n\n' "$BOLD" "$NC"

  local all_good=true

  check_dep() {
    local cmd="$1" msg="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
      printf '  %b✓%b %-10s : %s\n' "$GREEN" "$NC" "$cmd" "Présent"
    else
      printf '  %b✗%b %-10s : %s\n' "$RED" "$NC" "$cmd" "Manquant ($msg)"
      all_good=false
    fi
  }

  printf '%bOutils Core (Requis)%b\n' "$YELLOW" "$NC"
  check_dep "bash" "Shell principal"
  check_dep "git" "Pour le versioning de la mémoire"
  check_dep "grep" "Recherche dans les fichiers"
  check_dep "sed" "Manipulation de texte"
  
  printf '\n%bOutils Avancés (Recommandés)%b\n' "$YELLOW" "$NC"
  check_dep "python3" "Requis pour le streak daily et le bon formatage URL"
  check_dep "iconv" "Requis pour normaliser les accents en noms de fichiers Zettelkasten"
  check_dep "xdg-open" "Requis pour ouvrir visuellement les notes dans Obsidian sous Linux"

  printf '\n%bProviders IA Interactifs%b\n' "$YELLOW" "$NC"
  check_dep "claude" "Recommandé pour l'ingestion"
  check_dep "gemini" "Fallback rapide"
  check_dep "codex" "OpenAI CLI"

  echo ""
  if [ "$all_good" = false ]; then
    logwarn "Certaines dépendances ou outils recommandés sont manquants."
    echo "Le système fonctionnera en mode dégradé (ex: fallback sur sed au lieu de python3, slug sans iconv, ouverture dans nano au lieu d'Obsidian)."
  else
    loginfo "Tout est au vert ! Votre système est 100% opérationnel pour IPCRA."
  fi
}

# ── Review ────────────────────────────────────────────────────
cmd_review() {
  need_root
  local type="${1:-}"
  local provider="${2:-$(get_default_provider)}"

  case "$type" in
    phase)
      local prompt_file="${IPCRA_ROOT}/.ipcra/prompts/prompt_review_phase.md"
      [ ! -f "$prompt_file" ] && { logerr "Fichier introuvable: $prompt_file"; return 1; }
      launch_with_prompt "$provider" "$(cat "$prompt_file")" ;;
    project)
      local prompt_file="${IPCRA_ROOT}/.ipcra/prompts/prompt_review_project.md"
      [ ! -f "$prompt_file" ] && { logerr "Fichier introuvable: $prompt_file"; return 1; }
      launch_with_prompt "$provider" "$(cat "$prompt_file")" ;;
    quarter)
      local prompt_file="${IPCRA_ROOT}/.ipcra/prompts/prompt_review_quarter.md"
      [ ! -f "$prompt_file" ] && { logerr "Fichier introuvable: $prompt_file"; return 1; }
      launch_with_prompt "$provider" "$(cat "$prompt_file")" ;;
    *)
      logerr "Usage: ipcra review <phase|project|quarter>"
      return 1 ;;
  esac
}

# ── Process ───────────────────────────────────────────────────
cmd_process() {
  need_root
  local proc="${1:-}"
  local provider="${2:-$(get_default_provider)}"
  if [ -z "$proc" ]; then
    open_note "${IPCRA_ROOT}/Process/index.md" "Process/index.md"
    return
  fi
  local p="Process/${proc}.md"
  if [ ! -f "${IPCRA_ROOT}/${p}" ]; then
    if [ -f "${IPCRA_ROOT}/Process/_template_process.md" ]; then
      cp "${IPCRA_ROOT}/Process/_template_process.md" "${IPCRA_ROOT}/${p}"
      local safe_proc
      safe_proc=$(printf '%s' "$proc" | sed 's/[\/&]/\\&/g')
      sed -i "s/\[Nom\]/${safe_proc}/g" "${IPCRA_ROOT}/${p}"
    else
      printf '# Process — %s\n' "$proc" > "${IPCRA_ROOT}/${p}"
    fi
  fi
  
  local agent
  agent=$(grep -A1 "^## Agent IA recommandé" "${IPCRA_ROOT}/${p}" 2>/dev/null \
    | grep -v '^--$' | tail -n 1 | sed 's/^- *//')
  if [ -n "$agent" ] && [[ "$agent" != "(ex"* ]]; then
     printf '%b🤖 Agent recommandé détecté : %s%b\n' "$GREEN" "$agent" "$NC"
    if prompt_yes_no "Lancer l'IA avec cet agent sur ce process ?" "y"; then
      local prompt="Exécute le process défini dans ${p} avec l'expertise de l'agent ${agent}."
      launch_with_prompt "$provider" "$prompt"
      return
    fi
  fi
  
  open_note "${IPCRA_ROOT}/${p}" "$p"
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
    local domain="${expert,,}"
    if ! context_is_populated "$domain" 2>/dev/null; then
      logwarn "Contexte '${expert}' vide dans memory/${domain}.md"
      loginfo "→ Le LLM posera les questions en début de session."
      loginfo "→ Ou collecte maintenant : ipcra context ${domain}"
    fi
    local prompt="Mode expert: ${expert}. Lis d'abord .ipcra/context.md, Phases/index.md, memory/${domain}.md, la weekly courante et la daily du jour. Puis travaille."
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
    "Capture rapide (Inbox)" \
    "Consolider notes locales (Projet)" \
    "Ingérer projet existant (Audit & Sync)" \
    "Lancer session IA" \
    "Lancer session IA (mode expert)" \
    "Close session" \
    "Health check" \
    "Doctor (Vérifier outils)" \
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
      8)  cmd_consolidate; break ;;
      9)  read -r -p "Domaine global cible: " _d; cmd_ingest "$_d"; break ;;
      10) launch_ai "$(get_default_provider)"; break ;;
      11) read -r -p "Mode expert (DevOps, Electronique, Musique…): " m
          launch_ai "$(get_default_provider)" "$m"; break ;;
      12) cmd_close "${extra:-}"; break ;;
      13) cmd_health; break ;;
      14) cmd_doctor; break ;;
      15) sync_providers; break ;;
      16) list_providers; break ;;
      17) open_note "${IPCRA_ROOT}/Phases/index.md" "Phases/index.md"; break ;;
      18) open_note "${IPCRA_ROOT}/Process/index.md" "Process/index.md"; break ;;
      19) exit 0 ;;
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
  capture "texte"          Capturer une idée rapide dans Inbox
  close                    Clôturer la session (maj mémoire domaine)
  sync                     Régénérer CLAUDE.md, GEMINI.md, AGENTS.md, Kilo
  list                     Lister les providers disponibles
  zettel [titre]           Créer une note atomique Zettelkasten
  moc [thème]              Créer/ouvrir une Map of Content
  health                   Diagnostic du système IPCRA
  doctor                   Vérifier les dépendances (python, iconv, git...)
  review <type>            Revue adaptative (phase|project|quarter)
  phase|phases             Ouvrir Phases/index.md
  process [nom]            Ouvrir un process ou l'index
  <texte_libre>            Mode expert (ex: ipcra DevOps)

Options:
  -p, --provider PROVIDER  Choisir le provider (claude|gemini|codex)
  -h|--help                Aide
  -V|--version             Version

Exemples:
  ipcra                    # menu
  ipcra daily              # daily note
  ipcra daily --prep       # daily pré-rédigée par l'IA
  ipcra zettel "Idée X"   # nouvelle note Zettelkasten
  ipcra moc "DevOps"       # Map of Content DevOps
  ipcra concept "titre"   # Créer un nouveau concept agile dans un projet local
  ipcra health            # diagnostic système
  ipcra doctor            # vérifie Outils requis
  ipcra review phase       # revue de phase
  ipcra close              # clôture session (mémoire globale -> IPCRA_ROOT)
  ipcra consolidate        # consolide notes du projet CDE -> mémoire globale
  ipcra ingest [domaine]   # analyse / audit projet existant vers mémoire
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
    capture)         cmd_capture "${extra:-}" ;;
    close)           cmd_close "${extra:-}" ;;
    consolidate)     cmd_consolidate "${extra:-}" ;;
    ingest|audit)    cmd_ingest "${extra:-}" ;;
    sync)            sync_providers ;;
    list)            list_providers ;;
    zettel)          cmd_zettel "$extra" ;;
    moc)             cmd_moc "$extra" ;;
    concept)         cmd_concept "$extra" ;;
    health)          cmd_health ;;
    context)         cmd_context_collect "${extra:-}" ;;
    doctor)          cmd_doctor ;;
    review)          cmd_review "$extra" "$provider" ;;
    phase|phases)    need_root; open_note "${IPCRA_ROOT}/Phases/index.md" "Phases/index.md" ;;
    process|processes) cmd_process "${extra:-}" "$provider" ;;
    *)
      # Texte libre = mode expert
      need_root; show_dashboard
      printf '%b🤖 Provider: %s | 🎯 Expert: %s%b\n\n' "$BOLD" "$provider" "$cmd" "$NC"
      launch_ai "$provider" "$cmd" ;;
  esac
}

main "$@"
