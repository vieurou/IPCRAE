#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# IPCRAE Étendu v3.3 — Lanceur multi-provider
# Commandes : start, work, sprint, daily, weekly, monthly, close, sync,
#             zettel, moc, health, doctor, strict-check, review, launch, menu
# Providers : Claude, Gemini, Codex, (Kilo via VS Code)
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_VERSION="3.3.0"
METHOD_VERSION="3.3"
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


read_config_value() {
  local key="$1"
  if [ -f "$IPCRAE_CONFIG" ]; then
    grep -E "^${key}:" "$IPCRAE_CONFIG" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '"' || true
  fi
}

is_truthy() {
  case "${1:-}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

read_config_bool() {
  local key="$1" default="${2:-false}" val
  val="$(read_config_value "$key")"
  [ -z "$val" ] && val="$default"
  is_truthy "$val"
}


read_config_int() {
  local key="$1" default="$2" val
  val="$(read_config_value "$key")"
  case "$val" in
    ''|*[!0-9]*) printf '%s' "$default" ;;
    *) printf '%s' "$val" ;;
  esac
}

write_session_self_audit() {
  local domain="$1" project="$2" note="$3" changed="$4"
  local audit_dir="${IPCRAE_ROOT}/.ipcrae/auto/self-audits"
  mkdir -p "$audit_dir"

  local day stamp file
  day="$(date +%F)"
  stamp="$(date +'%Y-%m-%d %H:%M')"
  file="${audit_dir}/${day}-${domain:-global}.md"

  local capture_status="⚠"
  local capture_info="Aucune capture détectée"
  if [ -d "${IPCRAE_ROOT}/Tasks/to_ai" ]; then
    local task_count
    task_count=$(find "${IPCRAE_ROOT}/Tasks/to_ai" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    if [ "${task_count:-0}" -gt 0 ]; then
      capture_status="✓"
      capture_info="${task_count} tâche(s) disponible(s) dans Tasks/to_ai"
    fi
  fi

  local log_status="⚠"
  local log_info="Journal actif absent"
  local log_lines=0
  if [ -f "${IPCRAE_ROOT}/Tasks/active_session.md" ]; then
    log_lines=$(wc -l < "${IPCRAE_ROOT}/Tasks/active_session.md" | tr -d ' ')
    if [ "${log_lines:-0}" -gt 0 ]; then
      log_status="✓"
      log_info="${log_lines} ligne(s) dans Tasks/active_session.md"
    fi
  fi

  local sc_file="${IPCRAE_ROOT}/.ipcrae/session-context.md"
  local sc_bytes=0
  [ -f "$sc_file" ] && sc_bytes=$(wc -c < "$sc_file" | tr -d ' ')
  local changed_count=0
  [ -n "$changed" ] && changed_count=$(printf '%s
' "$changed" | sed '/^\s*$/d' | wc -l | tr -d ' ')

  local token_level="Bas"
  if [ "$sc_bytes" -gt 30000 ] || [ "$log_lines" -gt 80 ] || [ "$changed_count" -gt 20 ]; then
    token_level="Élevé"
  elif [ "$sc_bytes" -gt 12000 ] || [ "$log_lines" -gt 30 ] || [ "$changed_count" -gt 8 ]; then
    token_level="Moyen"
  fi

  local gratification="Bronze"
  [ "$token_level" = "Moyen" ] && gratification="Argent"
  [ "$token_level" = "Bas" ] && gratification="Or"

  {
    printf '# Self-audit session — %s

' "$stamp"
    printf -- '- Domaine: %s
' "${domain:-global}"
    printf -- '- Projet: %s
' "${project:-(non défini)}"
    printf -- '- Résumé: %s

' "${note:-(non fourni)}"

    printf '## Conformité IPCRAE
'
    printf -- '- %s Capture demande: %s
' "$capture_status" "$capture_info"
    printf -- '- %s Journalisation session: %s
' "$log_status" "$log_info"
    printf -- '- ✓ Consolidation mémoire: memory/%s.md

' "${domain:-global}"

    printf '## Coût tokens estimé
'
    printf -- '- Niveau: **%s**
' "$token_level"
    printf -- '- Taille session-context: %s octets
' "$sc_bytes"
    printf -- '- Fichiers modifiés détectés: %s

' "$changed_count"

    printf '## Optimisation recommandée
'
    if [ "$token_level" = "Élevé" ]; then
      printf -- '- Passer en mode contexte minimal: limiter mémoire/projet à 80 lignes via config.
'
    elif [ "$token_level" = "Moyen" ]; then
      printf -- '- Réduire le préchargement en utilisant uniquement session-context + tag ciblé.
'
    else
      printf -- '- Conserver ce format court et éviter la relecture globale du vault.
'
    fi

    printf -- '
## Gratification
- Badge session: **%s**
' "$gratification"
  } > "$file"

  printf '%b✓  Self-audit écrit: %s (badge: %s)%b
' "$GREEN" "${file#$IPCRAE_ROOT/}" "$gratification" "$NC"
}

# ── Remotes cerveau + projets ──────────────────────────────
get_brain_remote() {
  # Priorité : variable d'env > config > remote git existant
  local r="${IPCRAE_BRAIN_REMOTE:-}"
  if [ -z "$r" ] && [ -f "$IPCRAE_CONFIG" ]; then
    r=$(grep -E '^brain_remote:' "$IPCRAE_CONFIG" 2>/dev/null \
      | head -1 | awk -F'"' '{print $2}' || true)
    [ -z "$r" ] && r=$(grep -E '^brain_remote:' "$IPCRAE_CONFIG" 2>/dev/null \
      | head -1 | awk '{print $2}' | tr -d "'" || true)
  fi
  printf '%s' "$r"
}

get_project_remote() {
  local slug="$1"
  [ -z "$slug" ] && return 0
  [ -f "$IPCRAE_CONFIG" ] || return 0
  # Cherche `  <slug>: "url"` dans la section project_remotes
  grep -A50 '^project_remotes:' "$IPCRAE_CONFIG" 2>/dev/null \
    | grep -E "^\s+${slug}:" | head -1 \
    | awk -F'"' '{print $2}' || true
}

# S'assure que origin pointe vers brain_remote ; configure si absent/différent
ensure_brain_remote() {
  [ -d "${IPCRAE_ROOT}/.git" ] || return 0
  local wanted
  wanted="$(get_brain_remote)"
  [ -z "$wanted" ] && return 0

  local current
  current=$(git -C "${IPCRAE_ROOT}" remote get-url origin 2>/dev/null || true)

  if [ -z "$current" ]; then
    git -C "${IPCRAE_ROOT}" remote add origin "$wanted" \
      && loginfo "Remote brain ajouté: $wanted" \
      || logwarn "Impossible d'ajouter le remote brain."
  elif [ "$current" != "$wanted" ]; then
    git -C "${IPCRAE_ROOT}" remote set-url origin "$wanted" \
      && loginfo "Remote brain mis à jour: $wanted" \
      || logwarn "Impossible de mettre à jour le remote brain."
  fi
}

auto_git_stage_allowlist() {
  local -a paths=(
    "memory"
    "Journal"
    "Process"
    ".ipcrae/context.md"
    ".ipcrae/cache/tag-index.json"
  )
  local p
  for p in "${paths[@]}"; do
    [ -e "$p" ] && git add -A -- "$p"
  done
}

# ── Commande ipcrae remote ────────────────────────────────
cmd_remote() {
  local subcmd="${1:-list}"
  shift || true

  case "$subcmd" in
    set-brain)
      local url="${1:-}"
      [ -z "$url" ] && { logerr "Usage: ipcrae remote set-brain <url>"; return 1; }
      need_root
      # Mettre à jour config.yaml
      if grep -q '^brain_remote:' "$IPCRAE_CONFIG" 2>/dev/null; then
        sed -i "s|^brain_remote:.*|brain_remote: \"${url}\"|" "$IPCRAE_CONFIG"
      else
        printf 'brain_remote: "%s"\n' "$url" >> "$IPCRAE_CONFIG"
      fi
      ensure_brain_remote
      loginfo "brain_remote configuré: $url"
      ;;
    set-project)
      local slug="${1:-}" url="${2:-}"
      [ -z "$slug" ] || [ -z "$url" ] && { logerr "Usage: ipcrae remote set-project <slug> <url>"; return 1; }
      need_root
      # Insérer ou mettre à jour dans la section project_remotes
      if grep -q "^\s\+${slug}:" "$IPCRAE_CONFIG" 2>/dev/null; then
        sed -i "s|^\(\s*\)${slug}:.*|\1${slug}: \"${url}\"|" "$IPCRAE_CONFIG"
      elif grep -q '^project_remotes:' "$IPCRAE_CONFIG" 2>/dev/null; then
        sed -i "/^project_remotes:/a\\  ${slug}: \"${url}\"" "$IPCRAE_CONFIG"
      else
        printf '\nproject_remotes:\n  %s: "%s"\n' "$slug" "$url" >> "$IPCRAE_CONFIG"
      fi
      loginfo "Remote projet '${slug}' configuré: $url"
      ;;
    list)
      need_root
      printf '%bRemotes IPCRAE%b\n' "$BOLD" "$NC"
      local brain
      brain="$(get_brain_remote)"
      printf '  Cerveau (brain_remote) : %s\n' "${brain:-(non configuré)}"
      printf '  Git origin actuel      : %s\n' \
        "$(git -C "${IPCRAE_ROOT}" remote get-url origin 2>/dev/null || echo '(absent)')"
      printf '\n  Projets (project_remotes) :\n'
      if grep -q '^project_remotes:' "$IPCRAE_CONFIG" 2>/dev/null; then
        awk '/^project_remotes:/{p=1;next} p && /^[^ ]/{exit} p && /^\s+\S+:/{print "    " $0}' \
          "$IPCRAE_CONFIG" || true
      else
        printf '    (aucun)\n'
      fi
      ;;
    *) logerr "Sous-commande inconnue: $subcmd (set-brain|set-project|list)"; return 1 ;;
  esac
}

auto_git_sync_event() {
  local reason="${1:-update}"

  # Priorité: variable d'env > config > défaut(false)
  local mode="${IPCRAE_AUTO_GIT:-}"
  if [ -z "$mode" ]; then
    mode="$(read_config_value auto_git_sync)"
  fi
  mode="${mode:-false}"

  if ! is_truthy "$mode"; then
    return 0
  fi

  if [ ! -d "${IPCRAE_ROOT}/.git" ]; then
    logwarn "Auto Git activé mais ${IPCRAE_ROOT} n'est pas un dépôt Git."
    return 0
  fi

  # S'assurer que origin est configuré depuis brain_remote
  ensure_brain_remote

  (
    cd "${IPCRAE_ROOT}"
    git add -A
    if git diff --cached --quiet; then
      return 0
    fi

    git commit -m "chore(ipcrae): ${reason} ($(date +'%Y-%m-%d %H:%M:%S'))" || return 0

    local allow_push="${IPCRAE_AUTO_GIT_PUSH:-}"
    if [ -z "$allow_push" ] && [ -f "$IPCRAE_CONFIG" ]; then
      allow_push="$(read_config_value auto_git_push)"
    fi
    allow_push="${allow_push:-false}"

    if is_truthy "$allow_push"; then
      local origin_url wanted_url
      origin_url=$(git remote get-url origin 2>/dev/null || true)
      wanted_url=$(get_brain_remote)
      if [ -n "$wanted_url" ] && [ -n "$origin_url" ] && [ "$origin_url" != "$wanted_url" ]; then
        logwarn "Auto-push bloqué: origin != brain_remote (sécurité)."
      elif git symbolic-ref -q HEAD >/dev/null 2>&1 && [ -n "$origin_url" ]; then
        git push || logwarn "Auto-push échoué (commit local conservé)."
      else
        logwarn "Auto-push ignoré (branche détachée ou remote origin absent)."
      fi
    else
      loginfo "Auto-commit effectué (auto_git_push=false: push ignoré)."
    fi
  )
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
    printf "# Instructions pour %s — IPCRAE v%s\n# ⚠ GÉNÉRÉ — éditer .ipcrae/context.md + instructions.md\n# Régénérer : ipcrae sync\n\n%s\n" \
      "$name" "$METHOD_VERSION" "$body" > "${IPCRAE_ROOT}/${file}"
    printf '  ✓ %s\n' "$file"
  done

  mkdir -p "${IPCRAE_ROOT}/.kilocode/rules"
  printf '# Instructions IPCRAE pour Kilo Code\n# ⚠ GÉNÉRÉ\n\n%s\n' "$body" > "${IPCRAE_ROOT}/.kilocode/rules/ipcrae.md"
  printf '  ✓ .kilocode/rules/ipcrae.md\n'

  # ── Propager règles KiloCode dans tous les projets DEV connus ──────────
  local dev_paths
  dev_paths=$(grep -oP '\(`\K[^`]+(?=`\))' "${IPCRAE_ROOT}/.ipcrae/context.md" 2>/dev/null \
    | grep "^/home" | sort -u || true)
  if [ -n "$dev_paths" ]; then
    while IFS= read -r dev_path; do
      if [ -d "$dev_path/.kilocode" ] || [ -d "$dev_path" ]; then
        mkdir -p "$dev_path/.kilocode/rules"
        printf '# Instructions IPCRAE pour Kilo Code — projet: %s\n# ⚠ GÉNÉRÉ par ipcrae sync depuis %s\n# IPCRAE_ROOT=%s\n\n%s\n' \
          "$(basename "$dev_path")" "$IPCRAE_ROOT" "$IPCRAE_ROOT" "$body" \
          > "$dev_path/.kilocode/rules/ipcrae.md"
        printf '  ✓ %s/.kilocode/rules/ipcrae.md\n' "$(basename "$dev_path")"
      fi
    done <<< "$dev_paths"
  fi

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
    if [ ! -f "$abs" ]; then
      local yd yrel wrel waiting_rel phase_rel
      yd="$(yesterday)"
      yrel=""
      [ -n "$yd" ] && yrel="Journal/Daily/${y}/${yd}.md"
      wrel="Journal/Weekly/$(date +%G)/$(iso_week).md"
      waiting_rel="Inbox/waiting-for.md"
      phase_rel="Phases/index.md"

      {
        printf '# Daily — %s\n\n' "$d"
        printf '## Contexte automatique\n'
        [ -n "$yrel" ] && printf -- '- Hier: [[%s]]\n' "$yrel"
        printf -- '- Semaine: [[%s]]\n' "$wrel"
        printf -- '- En attente: [[%s]]\n' "$waiting_rel"
        printf -- '- Phase active: [[%s]]\n\n' "$phase_rel"
        printf '## Top 3\n- [ ] \n- [ ] \n- [ ] \n\n'
        printf '## Next actions par casquette\n- [ ] \n\n'
        printf '## Décisions\n- \n\n'
        printf '## Journal\n- \n'
      } > "$abs"
      loginfo "Daily préparée: $rel"
      auto_git_sync_event "prepare daily ${rel}"
    fi
    open_note "$abs" "$rel"
    return 0
  fi

  if [ ! -f "$abs" ]; then
    printf '# Daily — %s\n\n## Top 3\n- [ ] \n- [ ] \n- [ ] \n' "$d" > "$abs"
    loginfo "Daily créée: $rel"
    auto_git_sync_event "create daily ${rel}"
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
    auto_git_sync_event "create weekly ${rel}"
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
    auto_git_sync_event "create monthly ${rel}"
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
  local domain=""
  local project=""
  local note=""
  local dry_run=false

  while [ $# -gt 0 ]; do
    case "$1" in
      --project) project="${2:-}"; shift ;;
      --note) note="${2:-}"; shift ;;
      --dry-run) dry_run=true ;;
      -*) logerr "Option inconnue pour close: $1"; return 1 ;;
      *)
        if [ -z "$domain" ]; then domain="$1"
        elif [ -z "$note" ]; then note="$1"
        fi ;;
    esac
    shift
  done

  [ -z "$domain" ] && { logerr 'Usage: ipcrae close <domaine> [--project <slug>] [--note "résumé"] [--dry-run]'; return 1; }

  if [ "$dry_run" = true ]; then
    loginfo "[DRY-RUN] ipcrae close ${domain}$([ -n "$project" ] && echo " --project ${project}")"
    printf '\n--- Entrée mémoire qui serait ajoutée à memory/%s.md ---\n' "$domain"
    printf '## %s - Session close\n' "$(date +'%Y-%m-%d %H:%M')"
    printf '**Contexte** : domaine=%s%s\n' "$domain" "$([ -n "$project" ] && echo ", project=${project}" || true)"
    printf '**Décision** : consolidation de fin de session.\n'
    printf '\n--- Fichiers qui seraient commités ---\n'
    git -C "$IPCRAE_ROOT" status --short 2>/dev/null || printf '(aucun)\n'
    printf '\n--- Tag qui serait créé ---\n'
    printf 'session-%s-%s\n' "$(date +%Y%m%d)" "$domain"
    return 0
  fi

  local memory_file="${IPCRAE_ROOT}/memory/${domain}.md"
  if [ ! -f "$memory_file" ]; then
    logwarn "memory/${domain}.md absent, création."
    mkdir -p "${IPCRAE_ROOT}/memory"
    printf '# Mémoire — %s\n\n' "$domain" > "$memory_file"
  fi

  local changed=""
  if command -v git >/dev/null 2>&1 && [ -d "${IPCRAE_ROOT}/.git" ]; then
    changed="$(git -C "$IPCRAE_ROOT" status --short 2>/dev/null | awk '{print $2}' | head -20 || true)"
  fi
    printf '# Mémoire — %s

' "$domain" > "$memory_file"
  fi

  local changed
  changed="$(git -C "$IPCRAE_ROOT" status --short 2>/dev/null | awk '{print $2}' | head -20 || true)"
  local timestamp
  timestamp="$(date +'%Y-%m-%d %H:%M')"

  {
    printf '
## %s - Session close
' "$timestamp"
    printf '**Contexte** : domaine=%s' "$domain"
    [ -n "$project" ] && printf ', project=%s' "$project"
    printf '
'
    printf '**Décision** : consolidation de fin de session.
'
    if [ -n "$note" ]; then
      printf '**Résultat** : %s
' "$note"
    elif [ -n "$changed" ]; then
      printf '**Résultat** : fichiers touchés récents:
'
      printf '%s
' "$changed" | sed 's/^/- /'
    else
      printf '**Résultat** : session clôturée, pas de delta détecté.\n'
    fi
  } >> "$memory_file"

  python3 - "$IPCRAE_ROOT" "$domain" "$project" <<'PYCTX'
import re
import sys
from datetime import datetime
from pathlib import Path

root = Path(sys.argv[1])
domain = sys.argv[2]
project = sys.argv[3]
ctx = root / '.ipcrae' / 'context.md'
if not ctx.exists():
    raise SystemExit(0)

text = ctx.read_text(encoding='utf-8')
now = datetime.now().strftime('%Y-%m-%d %H:%M')
block = (
    '## Working set (dynamique)\n\n'
    f'- Dernière clôture: {now}\n'
    f'- Domaine actif: {domain}\n'
    f'- Projet actif: {project or "(non défini)"}\n'
    '- Phase active: voir Phases/index.md\n\n'
    '## Projets actifs\n\n'
    f'- {project or "(à renseigner)"}\n\n'
)

pattern = re.compile(r'## Working set \(dynamique\).*', re.S)
if pattern.search(text):
    text = pattern.sub(block.rstrip('\n'), text)
else:
    if not text.endswith('\n'):
        text += '\n'
    text += '\n' + block

ctx.write_text(text, encoding='utf-8')
PYCTX

  cmd_index
  loginfo "Clôture dynamique effectuée: memory/${domain}.md + context.md + cache tags"

  # ── MOC auto-détection (bash + python3, propose les MOC manquants) ─────
  if command -v ipcrae-moc-auto &>/dev/null; then
    ipcrae-moc-auto --min-notes 3 --update --quiet "$IPCRAE_ROOT" || true
  fi

  # ── Audit pre-commit (score ≥ 30/40 recommandé avant push) ───────────
  if command -v ipcrae-audit-check &>/dev/null; then
    local audit_score
    audit_score=$(IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae-audit-check 2>/dev/null \
      | grep -oP 'Score:\s*\K[0-9]+' | tail -1 || echo "?")
    if [ "$audit_score" != "?" ] && [ "$audit_score" -lt 30 ] 2>/dev/null; then
      printf '%b⚠  Audit score: %s/40 (< 30) — commit quand même (non bloquant)%b\n' \
        "$YELLOW" "$audit_score" "$NC"
      printf '   → Lancer: ipcrae-audit-check pour voir les gaps\n'
    elif [ "$audit_score" != "?" ]; then
      printf '%b✓  Audit pre-commit: %s/40%b\n' "$GREEN" "$audit_score" "$NC"
    fi
  fi

  auto_git_sync_event "close session"
  write_session_self_audit "$domain" "$project" "$note" "$changed"

  if read_config_bool strict_mode false; then
    cmd_strict_check || logwarn "Strict-check en warning après close."
  fi

  # ── Git tag de session (jalon temporel dans l'historique du vault) ──────
  # Crée un tag annoté après le commit auto_git_sync pour marquer l'état du
  # cerveau à la fin de cette session. Permet de retrouver "ce qui était connu
  # à cette date" via `git show session-YYYYMMDD-domaine`.
  if [ -d "${IPCRAE_ROOT}/.git" ]; then
    local tag_name
    tag_name="session-$(date +%Y%m%d)-${domain}"
    local tag_msg="Session close: domaine=${domain}"
    [ -n "$project" ] && tag_msg="${tag_msg}, projet=${project}"
    # Tag idempotent : si le tag existe déjà (double close), on le skip
    if ! GIT_DIR="${IPCRAE_ROOT}/.git" git rev-parse "$tag_name" >/dev/null 2>&1; then
      GIT_DIR="${IPCRAE_ROOT}/.git" GIT_WORK_TREE="${IPCRAE_ROOT}" \
        git tag -a "$tag_name" -m "$tag_msg" 2>/dev/null \
        && loginfo "Tag vault créé: ${tag_name}" \
        || logwarn "Création du tag vault échouée (non bloquant)"
    else
      loginfo "Tag vault déjà présent: ${tag_name} (skipped)"
    fi
  fi
}


cmd_start() {
  need_root
  local project="" domain="" phase=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --project) project="${2:-}"; shift ;;
      --domain)  domain="${2:-}"; shift ;;
      --phase)   phase="${2:-}"; shift ;;
    esac
    shift
  done

  # ── Bootstrap agent — log session + bannière règles ──────────────────
  if command -v ipcrae-agent-bootstrap &>/dev/null; then
    ipcrae-agent-bootstrap --auto --project "${project:-}" 2>/dev/null || true
  fi

  section "Start session"
  [ -n "$project" ] && printf 'Projet: %s\n' "$project"
  [ -n "$phase" ] && printf 'Phase: %s\n' "$phase"
  printf 'Weekly: %s\n' "$(iso_week)"
  [ -f "Phases/index.md" ] && printf 'Phase index: Phases/index.md\n'
  [ -f "Journal/Weekly/$(date +%G)/$(iso_week).md" ] || cmd_weekly

  # ── Auto-détection domaine depuis hub projet ──────────────────────────
  if [ -z "$domain" ] && [ -n "$project" ]; then
    local proj_idx="${IPCRAE_ROOT}/Projets/${project}/index.md"
    if [ -f "$proj_idx" ]; then
      domain=$(grep -E '^domain:|^domaine:' "$proj_idx" 2>/dev/null \
        | head -1 | awk -F': ' '{print $2}' | tr -d '"' || true)
    fi
  fi
  # Fallback : domaine actif dans context.md (Working set)
  if [ -z "$domain" ]; then
    domain=$(grep -E '^- Domaine actif:' "${IPCRAE_ROOT}/.ipcrae/context.md" 2>/dev/null \
      | head -1 | awk -F': ' '{print $2}' | tr -d ' ' || true)
  fi

  # ── Génération session-context.md (chargement sélectif) ──────────────
  local mem_max_lines proj_max_lines phase_max_lines
  mem_max_lines="$(read_config_int session_context_memory_max_lines 140)"
  proj_max_lines="$(read_config_int session_context_project_max_lines 120)"
  phase_max_lines="$(read_config_int session_context_phase_max_lines 40)"

  local sc_path="${IPCRAE_ROOT}/.ipcrae/session-context.md"
  {
    printf '# Contexte session — %s / %s\n' "${domain:-global}" "${project:-tous}"
    printf '> Généré par `ipcrae start` le %s\n' "$(date '+%Y-%m-%d %H:%M')"
    printf '> **Chargement sélectif actif** : lire ce fichier EN PREMIER ; éviter les autres memory/\n'
    printf '> Pour les autres domaines → `ipcrae tag <tag>`\n\n'

    local mem="${IPCRAE_ROOT}/memory/${domain}.md"
    if [ -n "$domain" ] && [ -f "$mem" ]; then
      printf '%s\n\n## Mémoire domaine : %s\n\n' "---" "$domain"
      head -n "$mem_max_lines" "$mem"
      printf '\n'
    fi

    if [ -n "$project" ]; then
      local tracking="${IPCRAE_ROOT}/Projets/${project}/tracking.md"
      if [ -f "$tracking" ]; then
        printf '\n%s\n\n## État projet : %s\n\n' "---" "$project"
        head -n "$proj_max_lines" "$tracking"
        printf '\n'
      fi
    fi

    local phases="${IPCRAE_ROOT}/Phases/index.md"
    if [ -f "$phases" ]; then
      printf '\n%s\n\n## Phase active (résumé)\n\n' "---"
      head -n "$phase_max_lines" "$phases"
      printf '\n'
    fi
  } > "$sc_path"

  local sc_kb
  sc_kb=$(( $(wc -c < "$sc_path") / 1024 ))
  printf '%b✓  session-context.md généré (%s Ko — domaine: %s, projet: %s)%b\n' \
    "$GREEN" "$sc_kb" "${domain:-global}" "${project:-(tous)}" "$NC"
  printf '   → Fichier à charger EN PREMIER dans votre session IA\n'
  printf '   → Autres domaines → ipcrae tag <tag>\n'
  printf '   → Limites contexte: mémoire=%s, projet=%s, phases=%s lignes\n' "$mem_max_lines" "$proj_max_lines" "$phase_max_lines"

  # ── Sync providers (régénère CLAUDE.md) ──────────────────────────────
  sync_providers

  # ── Vérification multi-agent (session hub) ───────────────────────────
  if command -v ipcrae-agent-hub &>/dev/null; then
    local hub_active
    hub_active=$(IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae-agent-hub status 2>/dev/null \
      | grep 'SESSION_ACTIVE=' | awk -F= '{print $2}' || echo "false")
    if [ "$hub_active" = "true" ]; then
      printf '%b🤝 Multi-agent : session active — vérifier les tâches partagées%b\n' "$CYAN" "$NC"
      IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae-agent-hub status 2>/dev/null | grep -E "LEAD_AGENT|in_progress|todo" || true
    else
      printf '%b   Multi-agent : aucune session active (ipcrae-agent-hub start <id> pour démarrer)%b\n' "$NC" "$NC"
    fi
  fi

  # ── Détection activité agents dans projets DEV (hors hub) ────────────
  local dev_paths
  dev_paths=$(grep -oP '\(`\K[^`]+(?=`\))' "${IPCRAE_ROOT}/.ipcrae/context.md" 2>/dev/null \
    | grep "^/home" | sort -u || true)
  if [ -n "$dev_paths" ]; then
    local agent_activity=""
    while IFS= read -r dev_path; do
      # Fichiers .ipcrae-memory/ modifiés dans les 60 dernières minutes
      local recent
      recent=$(find "$dev_path/.ipcrae-memory" -name "*.md" -newer \
        "${IPCRAE_ROOT}/.ipcrae/multi-agent/state.env" 2>/dev/null | head -3 || true)
      if [ -n "$recent" ]; then
        agent_activity="${agent_activity}  $(basename "$dev_path"): $(echo "$recent" | wc -l | tr -d ' ') fichier(s) récent(s)\n"
      fi
    done <<< "$dev_paths"
    if [ -n "$agent_activity" ]; then
      printf '%b⚡ Activité détectée dans projets DEV (autre agent probable) :%b\n' "$YELLOW" "$NC"
      printf "%b" "$agent_activity"
      printf '   → Vérifier avec: ipcrae-agent-hub status\n'
    fi
  fi

  # ── Vérification inbox ────────────────────────────────────────────────
  if command -v ipcrae-inbox-scan &>/dev/null; then
    ipcrae-inbox-scan --verbose "$IPCRAE_ROOT" || true
  elif [ -f "${IPCRAE_ROOT}/.ipcrae/auto/inbox-needs-processing" ]; then
    local flag_date
    flag_date=$(cat "${IPCRAE_ROOT}/.ipcrae/auto/inbox-needs-processing" 2>/dev/null || echo "?")
    printf '%b⚠  Inbox: fichiers en attente (dernière détection: %s)%b\n' \
      "$YELLOW" "$flag_date" "$NC"
    printf '   → Lire: %s/.ipcrae/auto/inbox-pending.md\n' "$IPCRAE_ROOT"
  fi
}

cmd_session() {
  need_root
  local mode="run"
  local project=""
  local phase=""
  local domain="devops"
  local note=""
  local run_audit=true

  while [ $# -gt 0 ]; do
    case "$1" in
      start|end|run) mode="$1" ;;
      --project) project="${2:-}"; shift ;;
      --phase) phase="${2:-}"; shift ;;
      --domain) domain="${2:-}"; shift ;;
      --note) note="${2:-}"; shift ;;
      --skip-audit) run_audit=false ;;
      -*) logerr "Option inconnue pour session: $1"; return 1 ;;
      *) logerr "Argument inconnu pour session: $1"; return 1 ;;
    esac
    shift
  done

  local -a start_args=()
  [ -n "$project" ] && start_args+=(--project "$project")
  [ -n "$phase" ] && start_args+=(--phase "$phase")

  local -a end_args=("$domain")
  [ -n "$project" ] && end_args+=(--project "$project")
  [ -n "$note" ] && end_args+=(--note "$note")

  case "$mode" in
    start)
      cmd_start "${start_args[@]}"
      if [ "$run_audit" = true ] && [ -x "scripts/audit_ipcrae.sh" ]; then
        section "Audit de session (start)"
        bash "scripts/audit_ipcrae.sh" || logwarn "audit_ipcrae.sh en warning (non bloquant)"
      fi
      ;;
    end)
      cmd_close "${end_args[@]}"
      if [ "$run_audit" = true ] && [ -x "scripts/audit_non_regression.sh" ]; then
        section "Audit de clôture"
        bash "scripts/audit_non_regression.sh" || logwarn "audit_non_regression.sh en warning (non bloquant)"
      fi
      ;;
    run)
      cmd_start "${start_args[@]}"
      [ "$run_audit" = true ] && [ -x "scripts/audit_ipcrae.sh" ] && bash "scripts/audit_ipcrae.sh" || true
      cmd_close "${end_args[@]}"
      [ "$run_audit" = true ] && [ -x "scripts/audit_non_regression.sh" ] && bash "scripts/audit_non_regression.sh" || true
      ;;
    *)
      logerr "Mode session inconnu: $mode (start|end|run)"
      return 1
      ;;
  esac
}

cmd_memory() {
  need_root
  local subcmd="${1:-}"; shift || true
  case "$subcmd" in
    gc)
      local domain=""
      local ttl_days=180
      while [ $# -gt 0 ]; do
        case "$1" in
          --domain) domain="${2:-}"; shift ;;
          --ttl-days) ttl_days="${2:-180}"; shift ;;
          -*) logerr "Option inconnue pour memory gc: $1"; return 1 ;;
        esac
        shift
      done
      [ -z "$domain" ] && { logerr "Usage: ipcrae memory gc --domain <domaine> [--ttl-days 180]"; return 1; }

      local src="memory/${domain}.md"
      [ -f "$src" ] || { logerr "Mémoire introuvable: $src"; return 1; }

      local today_epoch cutoff_epoch
      today_epoch=$(date +%s)
      cutoff_epoch=$(( today_epoch - ttl_days*86400 ))

      local archive_dir="Archives/memory"
      mkdir -p "$archive_dir"
      local archive_file="${archive_dir}/${domain}-$(date +%Y%m%d)-ttl${ttl_days}.md"

      python3 - "$src" "$archive_file" "$cutoff_epoch" <<'PYGC'
import re, sys
from datetime import datetime
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
cutoff = int(sys.argv[3])
text = src.read_text(encoding='utf-8')

header, body = "", text
if text.startswith('---\n'):
    m = re.search(r'^---\n.*?\n---\n', text, re.S)
    if m:
        header = m.group(0)
        body = text[m.end():]

pattern = re.compile(r'(^##\s+(\d{4}-\d{2}-\d{2})\s+-\s+.*?)(?=^##\s+\d{4}-\d{2}-\d{2}\s+-\s+|\Z)', re.M | re.S)
old_blocks, keep_blocks = [], []

for block, d in pattern.findall(body):
    ts = int(datetime.strptime(d, '%Y-%m-%d').timestamp())
    if ts < cutoff:
        old_blocks.append(block.strip() + '\n')
    else:
        keep_blocks.append(block.strip() + '\n')

if not old_blocks:
    print('NOOP')
    sys.exit(0)

archive_content = f"# Archive mémoire TTL\n\n- Source: {src}\n- Date GC: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n" + '\n'.join(old_blocks).rstrip() + '\n'
dst.write_text(archive_content, encoding='utf-8')

new_body = '\n'.join(keep_blocks).rstrip() + ('\n' if keep_blocks else '\n')
src.write_text((header + new_body).rstrip() + '\n', encoding='utf-8')
print('MOVED')
PYGC
      if [ -f "$archive_file" ]; then
        loginfo "GC mémoire terminé: ${src} -> ${archive_file} (TTL ${ttl_days} jours)"
        cmd_index
      else
        loginfo "GC mémoire: aucune entrée à archiver (TTL ${ttl_days} jours)"
      fi
      ;;
    *)
      logerr "Usage: ipcrae memory gc --domain <domaine> [--ttl-days 180]"
      return 1
      ;;
  esac
}

# ── Sprint autonome ───────────────────────────────────────────
# Collecte les tâches non terminées (projet courant en priorité),
# affiche la liste et lance l'agent en boucle autonome.
cmd_sprint() {
  local orig_cwd="$PWD"
  need_root
  local project="" domain="" max_tasks=3 dry_run=false confirm=true

  while [ $# -gt 0 ]; do
    case "$1" in
      --project)   project="${2:-}"; shift ;;
      --domain)    domain="${2:-}"; shift ;;
      --max-tasks) max_tasks="${2:-3}"; shift ;;
      --dry-run)   dry_run=true ;;
      --auto)      confirm=false ;;
      --confirm)   confirm=true ;;
      -*) logerr "Option inconnue pour sprint: $1"; return 1 ;;
    esac
    shift
  done

  # ── 1. Détecter le projet courant (depuis CWD d'origine) ─
  if [ -z "$project" ]; then
    # Chercher .ipcrae-project/project.md en remontant depuis CWD d'origine
    local dir="$orig_cwd"
    while [ "$dir" != "/" ]; do
      if [ -f "${dir}/.ipcrae-project/project.md" ]; then
        project=$(grep -E '^slug:' "${dir}/.ipcrae-project/project.md" 2>/dev/null \
          | head -1 | awk '{print $2}' | tr -d '"' || true)
        [ -z "$project" ] && project=$(basename "$dir")
        break
      fi
      dir=$(dirname "$dir")
    done
    # Fallback : nom du CWD d'origine si un hub Projets/ correspond
    if [ -z "$project" ]; then
      local cwd_name
      cwd_name=$(basename "$orig_cwd")
      [ -d "${IPCRAE_ROOT}/Projets/${cwd_name}" ] && project="$cwd_name"
    fi
  fi

  # ── 2. Détecter le domaine ────────────────────────────────
  if [ -z "$domain" ] && [ -n "$project" ]; then
    local proj_idx="${IPCRAE_ROOT}/Projets/${project}/index.md"
    if [ -f "$proj_idx" ]; then
      domain=$(grep -E '^domain:|^domaine:' "$proj_idx" 2>/dev/null \
        | head -1 | awk -F': ' '{print $2}' | tr -d '"' || true)
    fi
  fi
  [ -z "$domain" ] && domain="devops"

  # ── 3. Collecter les tâches (section-aware) ───────────────
  collect_tasks_from_section() {
    local file="$1" section_pattern="$2"
    [ -f "$file" ] || return 0
    awk -v pat="$section_pattern" '
      /^## / { in_section = ($0 ~ pat) }
      in_section && /^- \[ \]/ { sub(/^- \[ \] /, ""); print }
    ' "$file" 2>/dev/null
  }

  local -a tasks=()

  # Priorité 1 : projet courant — In Progress
  if [ -n "$project" ]; then
    local tracking="${IPCRAE_ROOT}/Projets/${project}/tracking.md"
    while IFS= read -r line; do
      [ -n "$line" ] && tasks+=("$line")
    done < <(collect_tasks_from_section "$tracking" "In Progress")

    # Priorité 2 : projet courant — Backlog court terme
    while IFS= read -r line; do
      [ -n "$line" ] && tasks+=("$line")
    done < <(collect_tasks_from_section "$tracking" "Backlog")
  fi

  # Priorité 3 : phases actives (si pas assez de tâches projet)
  if [ "${#tasks[@]}" -lt "$max_tasks" ]; then
    local phase_idx="${IPCRAE_ROOT}/Phases/index.md"
    while IFS= read -r line; do
      [ -n "$line" ] && tasks+=("$line")
    done < <(collect_tasks_from_section "$phase_idx" "Actions|Next|En cours")
  fi

  # Priorité 4 (global, pas de projet détecté) : tous les tracking In Progress
  if [ -z "$project" ] && [ "${#tasks[@]}" -lt "$max_tasks" ]; then
    local tf
    while IFS= read -r tf; do
      while IFS= read -r line; do
        [ -n "$line" ] && tasks+=("$line")
      done < <(collect_tasks_from_section "$tf" "In Progress")
    done < <(find "${IPCRAE_ROOT}/Projets" -name "tracking.md" 2>/dev/null)
  fi

  # ── 4. Limiter à max-tasks ────────────────────────────────
  local -a selected=()
  local i=0
  for t in "${tasks[@]}"; do
    [ "$i" -ge "$max_tasks" ] && break
    selected+=("$t")
    i=$((i + 1))
  done

  # ── 5. Affichage ──────────────────────────────────────────
  section "Sprint IPCRAE"
  printf 'Projet  : %b%s%b\n' "$BOLD" "${project:-(global)}" "$NC"
  printf 'Domaine : %s\n' "$domain"
  printf 'Tâches  : %d/%d collectées (max %d)\n' "${#selected[@]}" "${#tasks[@]}" "$max_tasks"
  printf '\n'

  if [ "${#selected[@]}" -eq 0 ]; then
    logwarn "Aucune tâche [ ] trouvée. Vérifier les tracking.md / Phases/index.md."
    return 0
  fi

  local n=1
  for t in "${selected[@]}"; do
    printf '  %b[%d]%b %s\n' "$YELLOW" "$n" "$NC" "$t"
    n=$((n + 1))
  done
  printf '\n'

  # ── 6. Dry-run → stop ────────────────────────────────────
  if [ "$dry_run" = true ]; then
    loginfo "Dry-run : sprint affiché, aucune IA lancée."
    return 0
  fi

  # ── 7. Confirmation ───────────────────────────────────────
  if [ "$confirm" = true ]; then
    prompt_yes_no "Lancer le sprint avec ces ${#selected[@]} tâches ?" "y" || {
      loginfo "Sprint annulé."
      return 0
    }
  fi

  # ── 8. Construire le prompt sprint ────────────────────────
  local task_list=""
  local idx=1
  for t in "${selected[@]}"; do
    task_list="${task_list}${idx}. ${t}
"
    idx=$((idx + 1))
  done

  local template="${IPCRAE_ROOT}/.ipcrae/prompts/prompt_sprint.md"
  local sprint_prompt
  if [ -f "$template" ]; then
    sprint_prompt=$(sed \
      -e "s|{{project}}|${project:-(global)}|g" \
      -e "s|{{domain}}|${domain}|g" \
      -e "s|{{max_tasks}}|${max_tasks}|g" \
      -e "s|{{task_list}}|${task_list}|g" \
      "$template")
  else
    sprint_prompt="SPRINT AUTONOME IPCRAE\nProjet : ${project:-(global)} | Domaine : ${domain} | Max tâches : ${max_tasks}\n\nTÂCHES À EXÉCUTER (dans cet ordre) :\n${task_list}\nSOURCES DE CONTEXTE :\n- \$IPCRAE_ROOT/Projets/${project}/memory.md\n- \$IPCRAE_ROOT/memory/${domain}.md\n- \$IPCRAE_ROOT/Projets/${project}/tracking.md\n\nPROTOCOLE : pour chaque tâche, annoncer [n/total], exécuter, marquer [x] dans tracking.md, ajouter décision datée dans memory/${domain}.md.\nRAPPORT FINAL : tâches faites, tâches restantes, prochaine action recommandée.\nRÈGLE : si bloqué sur une tâche, passer et continuer."
  fi

  # ── 9. Lancer l'IA ───────────────────────────────────────
  local provider
  provider="$(get_default_provider)"
  launch_with_prompt "$provider" "$sprint_prompt"
}

cmd_work() {
  need_root
  local objective="${1:-}"
  [ -z "$objective" ] && { logerr 'Usage: ipcrae work "<objectif>"'; return 1; }
  local provider
  provider="$(get_default_provider)"

  local tags_hint=""
  if [ -f "${IPCRAE_ROOT}/.ipcrae/cache/tag-index.json" ]; then
    tags_hint="$(python3 - "$objective" <<'PYWORK'
import json, re, sys
from pathlib import Path
objective = sys.argv[1].lower()
tokens = {t for t in re.findall(r'[a-z0-9-]{3,}', objective)}
idx = json.loads(Path('.ipcrae/cache/tag-index.json').read_text(encoding='utf-8'))
tags = idx.get('tags', {})
matches = [t for t in tags if t in tokens or any(tok in t for tok in tokens)]
print(', '.join(sorted(matches)[:8]))
PYWORK
)"
  fi

  local prompt
  prompt="MODE WORK IPCRAE (contexte minimisé):
Objectif: ${objective}
Sources de vérité:
1) .ipcrae/context.md
2) .ipcrae/instructions.md
3) memory/<domaine>.md et notes Knowledge/Zettelkasten
Tags pertinents: ${tags_hint:-aucun}

Travaille uniquement sur l'objectif et propose un plan d'action concret."
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
  auto_git_sync_event "capture ${rel}"
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
  auto_git_sync_event "create zettel ${rel}"
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
    auto_git_sync_event "create moc ${rel}"
  fi
  open_note "$abs" "$rel"
}


cmd_strict_check() {
  need_root
  section "Strict mode check"

  local checker=""
  if command -v ipcrae-strict-check >/dev/null 2>&1; then
    checker="ipcrae-strict-check"
  elif [ -x "$HOME/bin/ipcrae-strict-check" ]; then
    checker="$HOME/bin/ipcrae-strict-check"
  elif [ -x "${IPCRAE_ROOT}/scripts/ipcrae-strict-check.sh" ]; then
    checker="${IPCRAE_ROOT}/scripts/ipcrae-strict-check.sh"
  else
    logwarn "ipcrae-strict-check introuvable."
    return 0
  fi

  if IPCRAE_ROOT="$IPCRAE_ROOT" "$checker"; then
    loginfo "Strict mode: conforme"
  else
    logwarn "Strict mode: écarts détectés"
    return 1
  fi
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
    wf_count=$(grep '^|[^-|]' "Inbox/waiting-for.md" 2>/dev/null | wc -l | tr -d ' \t')
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
  local mem_count mem_sparse=0
  mem_count=$(find memory/ -name "*.md" ! -name "index.md" -exec grep -l '^## ' {} \; 2>/dev/null | wc -l)
  printf '🧠 Mémoire: %s domaines avec entrées' "$mem_count"
  # Détecter les mémoires creuses (< 20 lignes non-vides)
  while IFS= read -r mf; do
    local lines; lines=$(grep -cv '^\s*$\|^#\|^---\|^<!--' "$mf" 2>/dev/null || echo 0)
    if [ "${lines:-0}" -lt 20 ]; then
      mem_sparse=$(( mem_sparse + 1 ))
    fi
  done < <(find memory/ -name "*.md" ! -name "index.md" 2>/dev/null)
  if [ "$mem_sparse" -gt 0 ]; then
    printf ' %b(⚠ %s mémoire(s) creuse(s) < 20 lignes → ipcrae consolidate <domaine>)%b' \
      "$YELLOW" "$mem_sparse" "$NC"
  fi
  printf '\n'

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
  local orig_cwd="$PWD"
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

  printf '\n%bDépendances soft%b\n' "$YELLOW" "$NC"
  for c in git rg curl; do
    if command -v "$c" >/dev/null 2>&1; then
      printf '  ✓ %s\n' "$c"
    else
      printf '  ⚠ %s (optionnel, fonctionnalités réduites)\n' "$c"
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

  printf '\n%bInvariants v3.3%b\n' "$YELLOW" "$NC"
  [ -f "$IPCRAE_ROOT/.ipcrae/cache/tag-index.json" ] && printf '  ✓ .ipcrae/cache/tag-index.json\n' || printf '  ✗ .ipcrae/cache/tag-index.json\n'

  local ctx ins body
  ctx="$IPCRAE_ROOT/.ipcrae/context.md"
  ins="$IPCRAE_ROOT/.ipcrae/instructions.md"
  if [ -f "$ctx" ] && [ -f "$ins" ]; then
    body="$(cat "$ctx"; printf '\n\n---\n\n'; cat "$ins")"
    for t in "CLAUDE.md:Claude" "GEMINI.md:Gemini" "AGENTS.md:Codex"; do
      local f="${t%%:*}" n="${t##*:}" tmp
      tmp="$(mktemp)"
      printf '# Instructions pour %s — IPCRAE v%s\n# ⚠ GÉNÉRÉ — éditer .ipcrae/context.md + instructions.md\n# Régénérer : ipcrae sync\n\n%s\n' "$n" "$METHOD_VERSION" "$body" > "$tmp"
      if [ -f "$IPCRAE_ROOT/$f" ] && cmp -s "$tmp" "$IPCRAE_ROOT/$f"; then
        printf '  ✓ %s à jour\n' "$f"
      else
        printf '  ✗ %s non synchronisé (lancer: ipcrae sync)\n' "$f"
      fi
      rm -f "$tmp"
    done
  fi

  printf "\n%bContrat d'injection de contexte (CDE)%b\n" "$YELLOW" "$NC"
  [ -d "$orig_cwd/docs/conception" ] && printf '  ✓ docs/conception/\n' || printf '  ✗ docs/conception/\n'
  [ -f "$orig_cwd/docs/conception/03_IPCRAE_BRIDGE.md" ] && printf '  ✓ docs/conception/03_IPCRAE_BRIDGE.md\n' || printf '  ✗ docs/conception/03_IPCRAE_BRIDGE.md\n'

  if [ -L "$orig_cwd/.ipcrae-memory" ]; then
    printf '  ✓ .ipcrae-memory (symlink)\n'
  else
    printf '  ⚠ .ipcrae-memory absent ou non-symlink (mode dégradé)\n'
  fi

  local project_name hub_dir
  project_name="$(basename "$orig_cwd")"
  hub_dir="${IPCRAE_ROOT}/Projets/${project_name}"
  [ -d "$hub_dir" ] && printf '  ✓ hub projet: %s\n' "${hub_dir#$IPCRAE_ROOT/}" || printf '  ⚠ hub projet manquant: %s\n' "${hub_dir#$IPCRAE_ROOT/}"

  if [ "$missing" -gt 0 ]; then
    logwarn "Doctor: dépendances de base manquantes: $missing"
    return 1
  fi
  loginfo "Doctor: environnement de base OK"
}


cmd_index() {
  need_root
  if [ -x "${IPCRAE_ROOT}/Scripts/ipcrae-index.sh" ]; then
    "${IPCRAE_ROOT}/Scripts/ipcrae-index.sh" "$IPCRAE_ROOT"
    return 0
  fi
  mkdir -p "${IPCRAE_ROOT}/.ipcrae/cache"

  python3 - <<'PYIDX'
import json
from pathlib import Path
from datetime import datetime, timezone

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
            inner = tag_line.split('[',1)[1].rsplit(']',1)[0]
            found.extend([t.strip().strip("\"'") for t in inner.split(',') if t.strip()])
        if project_line:
            project = project_line.split(':',1)[1].strip().strip("\"'")
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
PYIDX

  loginfo "Cache tags reconstruit: .ipcrae/cache/tag-index.json"
}

cmd_tag() {
  need_root
  local needle="${1:-}"
  [ -z "$needle" ] && { logerr "Usage: ipcrae tag <tag>"; return 1; }
  if [ -x "${IPCRAE_ROOT}/Scripts/ipcrae-tag.sh" ]; then
    "${IPCRAE_ROOT}/Scripts/ipcrae-tag.sh" "$needle"
    return $?
  fi
  [ -f "${IPCRAE_ROOT}/.ipcrae/cache/tag-index.json" ] || cmd_index
  python3 - "$needle" <<'PYTAG'
import json, sys
from pathlib import Path
needle = sys.argv[1]
idx = json.loads(Path('.ipcrae/cache/tag-index.json').read_text(encoding='utf-8'))
files = idx.get('tags', {}).get(needle, [])
if not files:
    print(f"Aucun résultat pour le tag: {needle}")
    raise SystemExit(1)
for f in files:
    print(f)
PYTAG
}

cmd_search() {
  need_root
  local query="${1:-}"
  [ -z "$query" ] && { logerr "Usage: ipcrae search <mots|tags>"; return 1; }

  local normalized="$query"
  normalized="${normalized#\#}"

  if [ -f "${IPCRAE_ROOT}/.ipcrae/cache/tag-index.json" ]; then
    if cmd_tag "$normalized" >/dev/null 2>&1; then
      cmd_tag "$normalized"
      return 0
    fi
  fi

  if [[ "$query" == *:* ]]; then
    cmd_tag "$query" && return 0
  fi

  local -a targets=()
  for d in Knowledge Zettelkasten memory docs; do
    [ -d "$d" ] && targets+=("$d")
  done

  [ "${#targets[@]}" -eq 0 ] && { logwarn "Aucun dossier de recherche présent (Knowledge/Zettelkasten/memory/docs)."; return 1; }

  if command -v rg >/dev/null 2>&1; then
    rg -n --glob '*.md' --glob '!Archives/**' "$query" "${targets[@]}" \
      || { logwarn "Aucun résultat via grep pour: $query"; return 1; }
  else
    logwarn "rg absent: fallback via find+grep (plus lent)."
    find "${targets[@]}" -type f -name '*.md' ! -path '*/Archives/*' -print0 2>/dev/null       | xargs -0 grep -n -- "$query"       || { logwarn "Aucun résultat via grep pour: $query"; return 1; }
  fi
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
  local prompt="CONSOLIDATION GLOBALE :\n1) Lis memory/${domain}.md pour connaître l'état actuel.\n2) Cherche les notes locales via 'find .ipcrae-project/local-notes/' ou 'find Projets/'.\n3) Propose une mise à jour synthétique et structurée de memory/${domain}.md sans effacer l'historique pertinent."
  
  launch_with_prompt "$(get_default_provider)" "$prompt"
}

# ── Prompt build — compilation des couches de prompts ─────────
cmd_prompt_build() {
  need_root
  local agent="" output="" list_only=false subcmd="build"
  # Détection sous-commande positionnelle
  case "${1:-}" in
    check) subcmd="check"; shift ;;
    build) shift ;;
  esac
  while [ $# -gt 0 ]; do
    case "$1" in
      --agent|-a) agent="${2:-}"; shift ;;
      --output|-o) output="${2:-}"; shift ;;
      --list)  list_only=true ;;
    esac
    shift
  done

  local prompts_dir="${IPCRAE_ROOT}/.ipcrae/prompts"
  local compiled_dir="${IPCRAE_ROOT}/.ipcrae/compiled"

  # --list : affiche les agents disponibles
  if [ "$list_only" = true ]; then
    printf 'Agents disponibles :\n'
    find "$prompts_dir" -name "agent_*.md" | sed 's|.*/agent_||;s|\.md||' | sort
    return 0
  fi

  # Sous-commande check : audit cohérence de tous les agents
  if [ "$subcmd" = "check" ]; then
    local ok=0 warn=0
    printf '\n%s\n' "─── Cohérence prompts agents ───"
    for af in "${prompts_dir}"/agent_*.md; do
      local aname miss=""
      aname=$(basename "$af" .md | sed 's/^agent_//')
      for sec in "## Rôle" "## Workflow" "## Contrat"; do
        grep -qi "^${sec}" "$af" 2>/dev/null || miss="${miss} [${sec}]"
      done
      if [ -z "$miss" ]; then
        printf '  \033[0;32m✓\033[0m %s\n' "$aname"; ok=$(( ok + 1 ))
      else
        printf '  \033[0;31m✗\033[0m %s — manque :%s\n' "$aname" "$miss"; warn=$(( warn + 1 ))
      fi
    done
    printf '\nRésultat : %d OK, %d avec sections manquantes\n\n' "$ok" "$warn"
    return 0
  fi

  if [ -z "$agent" ]; then
    logerr "Usage: ipcrae prompt build --agent <domaine> [--output <fichier>]"
    logerr "       ipcrae prompt check"
    logerr "       ipcrae prompt --list"
    return 1
  fi

  local agent_file="${prompts_dir}/agent_${agent}.md"
  if [ ! -f "$agent_file" ]; then
    logerr "Agent introuvable: $agent_file"
    logerr "Agents disponibles: $(find "$prompts_dir" -name "agent_*.md" | sed 's|.*/agent_||;s|\.md||' | tr '\n' ' ')"
    return 1
  fi

  mkdir -p "$compiled_dir"
  local out="${output:-${compiled_dir}/prompt_${agent}.md}"

  {
    printf '# Prompt compilé — agent: %s\n' "$agent"
    printf '# Généré par `ipcrae prompt build` le %s\n' "$(date '+%Y-%m-%d %H:%M')"
    printf '# Couches : core_ai_functioning + core_ai_workflow + core_ai_memory + agent_%s\n\n' "$agent"
    printf '%s\n\n' "---"

    for core in core_ai_functioning core_ai_workflow_ipcra core_ai_memory_method; do
      local cf="${prompts_dir}/${core}.md"
      if [ -f "$cf" ]; then
        printf '<!-- COUCHE: %s -->\n\n' "$core"
        cat "$cf"
        printf '\n\n%s\n\n' "---"
      else
        logwarn "Couche manquante: $cf"
      fi
    done

    printf '<!-- COUCHE: agent_%s -->\n\n' "$agent"
    cat "$agent_file"
  } > "$out"

  local lines
  lines=$(wc -l < "$out" | tr -d ' ')
  loginfo "Prompt compilé → ${out} (${lines} lignes)"

  # Vérification cohérence sections obligatoires dans l'agent
  local missing=""
  for section in "## Rôle" "## Workflow" "## Contrat"; do
    grep -q "^${section}" "$agent_file" 2>/dev/null || missing="${missing} '${section}'"
  done
  [ -n "$missing" ] && logwarn "Sections manquantes dans agent_${agent}.md :${missing}"
}

# ── AddProject — créer un hub projet dans le vault ────────────
cmd_add_project() {
  need_root
  local slug="" domain="" path="" desc=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --slug|-s)    slug="${2:-}";   shift ;;
      --domain|-d)  domain="${2:-}"; shift ;;
      --path|-p)    path="${2:-}";   shift ;;
      --desc)       desc="${2:-}";   shift ;;
    esac
    shift
  done

  # Prompt interactif si args manquants
  if [ -z "$slug" ]; then
    read -r -p "Nom du projet (slug, ex: mon-projet) : " slug
    [ -z "$slug" ] && { logerr "Slug requis"; return 1; }
  fi
  slug=$(printf '%s' "$slug" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  if [ -z "$domain" ]; then
    read -r -p "Domaine (devops/electronique/musique/maison/finance/sante) : " domain
    domain="${domain:-devops}"
  fi
  [ -z "$path" ] && path="${HOME}/DEV/${slug}"
  [ -z "$desc" ] && desc="Projet ${slug}"

  local hub_dir="${IPCRAE_ROOT}/Projets/${slug}"
  if [ -d "$hub_dir" ]; then
    logwarn "Hub déjà existant : ${hub_dir}"
    return 1
  fi

  local today
  today=$(date '+%Y-%m-%d')

  mkdir -p "${hub_dir}/demandes"

  # index.md
  cat > "${hub_dir}/index.md" << ENDOFFILE
---
type: hub
project: ${slug}
domain: ${domain}
status: active
tags: [${domain}]
created: ${today}
updated: ${today}
---

# ${slug}

## Métadonnées
- **Domaine** : ${domain}
- **Statut** : 🚀 Actif
- **Priorité** : 🟠 Haute
- **Chemin Local** : \`${path}\`

## Objectif

${desc}

## Next Actions
- [ ]

## Architecture / Stack

## Décisions importantes
| Date | Décision | Raison |
|------|----------|--------|

## Liens
- Tracking : [[${slug}/tracking]]
- Mémoire  : [[${slug}/memory]]
ENDOFFILE

  # tracking.md
  cat > "${hub_dir}/tracking.md" << ENDOFFILE
# Kanban Tracking — ${slug}
<!-- Géré par : ipcrae close, ipcrae start -->

---

## ▶️ In Progress (max 3)

## ⏳ Waiting For

---

## 🎯 Backlog — Court terme
- [ ]

## 🗂️ Backlog — Moyen terme

## 🔭 Backlog — Long terme

---

## ✅ Done

---

## Milestones
- [ ] **M1** :
ENDOFFILE

  # memory.md
  cat > "${hub_dir}/memory.md" << ENDOFFILE
---
type: memory
project: ${slug}
domain: ${domain}
tags: [${domain}, memory, ${slug}]
created: ${today}
updated: ${today}
---

# Mémoire projet — ${slug}

## Contraintes connues

## Décisions passées

### ${today} — Création du projet
**Contexte** : Initialisation du hub IPCRAE
**Décision** : Projet créé via \`ipcrae addProject\`
**Résultat** : Hub opérationnel
ENDOFFILE

  loginfo "Hub créé : ${hub_dir}"
  loginfo "  index.md | tracking.md | memory.md | demandes/"

  # Auto-commit vault
  auto_git_sync_event "addProject ${slug}"

  # Tag Git annoté — jalon de création projet
  if [ -d "${IPCRAE_ROOT}/.git" ]; then
    local tag_name="project-${slug}-$(date '+%Y%m%d')"
    (cd "${IPCRAE_ROOT}" && git tag -a "$tag_name" -m "Projet créé: ${slug} (domaine: ${domain})" 2>/dev/null \
      && loginfo "Tag Git annoté: ${tag_name}") || true
  fi
}

# ── Archive — archiver un projet terminé ──────────────────────
cmd_archive() {
  need_root
  local slug="" dry_run=false

  while [ $# -gt 0 ]; do
    case "$1" in
      --slug|-s)   slug="${2:-}"; shift ;;
      --dry-run)   dry_run=true ;;
      -*)          logerr "Option inconnue: $1"; return 1 ;;
      *)           [ -z "$slug" ] && slug="$1" ;;
    esac
    shift
  done

  if [ -z "$slug" ]; then
    logerr "Usage: ipcrae archive <slug> [--dry-run]"
    return 1
  fi

  local src_dir="${IPCRAE_ROOT}/Projets/${slug}"
  local dst_dir="${IPCRAE_ROOT}/Archives/${slug}"
  local today; today=$(date '+%Y-%m-%d')

  if [ ! -d "$src_dir" ]; then
    logerr "Projet introuvable: Projets/${slug}"
    return 1
  fi
  if [ -d "$dst_dir" ]; then
    logerr "Archive déjà existante: Archives/${slug}"
    return 1
  fi

  local rel="${abs#${IPCRAE_ROOT}/}"
  section "Process run: ${rel}"

  local agent context_tags output_path collector
  agent=$(awk -F': ' '/^- \*\*Agent\*\* :/{print $2; exit}' "$abs" 2>/dev/null || true)
  context_tags=$(awk -F': ' '/^- \*\*Context tags\*\* :/{print $2; exit}' "$abs" 2>/dev/null || true)
  output_path=$(awk -F': ' '/^- \*\*Output path\*\* :/{print $2; exit}' "$abs" 2>/dev/null || true)
  collector=$(awk -F': ' '/^- \*\*Collector script \(optionnel\)\*\* :/{print $2; exit}' "$abs" 2>/dev/null || true)

  local today_s y w
  today_s="$(today)"; y="$(year)"; w="$(iso_week)"
  local context_file="Journal/Daily/${y}/${today_s}.md"
  local weekly_file="Journal/Weekly/$(date +%G)/${w}.md"

  printf 'Mode: %s\n' "$mode"
  printf 'Fiche: %s\n' "$rel"
  printf 'Contexte minimal:\n'
  printf '  - %s\n' ".ipcrae/context.md"
  [ -f "$context_file" ] && printf '  - %s\n' "$context_file"
  [ -f "$weekly_file" ] && printf '  - %s\n' "$weekly_file"
  [ -n "$agent" ] && printf 'Agent recommandé: %s\n' "$agent"
  [ -n "$context_tags" ] && printf 'Context tags: %s\n' "$context_tags"
  [ -n "$collector" ] && printf 'Collector: %s\n' "$collector"

  if [ -n "$context_tags" ] && [ -f "${IPCRAE_ROOT}/.ipcrae/cache/tag-index.json" ]; then
    printf 'Fichiers liés par tags:\n'
    local tags_clean
    tags_clean=$(printf '%s' "$context_tags" | tr -d '[]' | tr ',' '\n' | sed 's/^ *//;s/ *$//')
    while IFS= read -r t; do
      [ -z "$t" ] && continue
      printf '  - [%s]\n' "$t"
      cmd_tag "$t" 2>/dev/null | sed 's/^/    · /' || true
    done <<< "$tags_clean"
  fi

  if [ "$dry_run" = "true" ]; then
    logwarn "[dry-run] mv \"${src_dir}\" \"${dst_dir}\""
    logwarn "[dry-run] Mise à jour status: archived dans index.md"
    logwarn "[dry-run] Suppression de la ligne projet dans context.md"
    logwarn "[dry-run] auto_git_sync_event (pas de commit)"
    return 0
  fi

  local out_file=""
  if [ -n "$output_path" ]; then
    out_file="$output_path"
    out_file="${out_file//YYYY-MM-DD/$today_s}"
    out_file="${out_file//YYYY/$y}"
    out_file="${out_file//\[slug\]/$(slugify "$slug")}"
  else
    local out_dir="Journal/Daily/${y}"
    out_file="${out_dir}/${today_s}-process-$(slugify "$slug").md"
  fi
  mkdir -p "$(dirname "$out_file")"
  # 1. Déplacer le hub
  mkdir -p "${IPCRAE_ROOT}/Archives"
  mv "$src_dir" "$dst_dir"

  # 2. Mettre à jour status dans index.md
  local idx="${dst_dir}/index.md"
  if [ -f "$idx" ]; then
    sed -i "s/^status: .*/status: archived/" "$idx"
    sed -i "s/^updated: .*/updated: ${today}/" "$idx"
    sed -i "s/- \*\*Statut\*\* :.*/- **Statut** : 📦 Archivé (${today})/" "$idx"
  fi

  # 3. Retirer le projet de context.md "Projets en cours"
  local ctx="${IPCRAE_ROOT}/.ipcrae/context.md"
  if [ -f "$ctx" ]; then
    sed -i "/^\- \*\*${slug}\*\*/d" "$ctx"
    sed -i "/^- ${slug}$/d" "$ctx"
  fi

  loginfo "Archivé: Projets/${slug} → Archives/${slug}"
  loginfo "Status: archived | context.md mis à jour"

cmd_process_gc() {
  need_root
  local ttl_days="${1:-180}"
  [[ "$ttl_days" =~ ^[0-9]+$ ]] || { logerr "Usage: ipcrae process gc [ttl-days]"; return 1; }

  section "Process GC (TTL=${ttl_days} jours)"
  local now epoch_limit
  now="$(date +%s)"
  epoch_limit=$(( now - ttl_days*86400 ))

  find "${IPCRAE_ROOT}/Process" -maxdepth 3 -type f -name '*.md'     ! -name 'map.md' ! -name 'priorites.md' ! -name '_template_process.md'     | while read -r f; do
        mtime="$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)"
        if [ "$mtime" -lt "$epoch_limit" ]; then
          local age_days
          age_days=$(( (now-mtime)/86400 ))
          printf '⚠ Process stale: %s (age=%sj)\n' "${f#${IPCRAE_ROOT}/}" "$age_days"
        fi
      done
  auto_git_sync_event "archive ${slug}"
}

# ── AllContext — pipeline analyse/ingestion universel ─────────
cmd_allcontext() {
  need_root
  local request="${1:-}"
  if [ -z "$request" ]; then
    logerr "Usage: ipcrae allcontext \"<texte de la demande>\" [--dry-run] [--show-all]"
    return 1
  fi
  # Script dans DEV/IPCRAE/scripts/ (installé) ou fallback inline
  local script_path="${HOME}/DEV/IPCRAE/scripts/ipcrae-allcontext.sh"
  if [ -f "$script_path" ]; then
    bash "$script_path" "$@"
  else
    cmd_process_run inbox-triage
  fi
}

# ── Demandes — suivi automatique de l'état des demandes ───────
cmd_demandes() {
  need_root
  local subcmd="${1:-status}"
  shift 2>/dev/null || true
  local mark_file=""

  case "$subcmd" in
    status|list)
      local inbox_dir="${IPCRAE_ROOT}/Inbox/demandes-brutes"
      local traites_dir="${inbox_dir}/traites"
      local total=0 pending=0 done_count=0

      section "Suivi des demandes brutes"

      if [ ! -d "$inbox_dir" ]; then
        logwarn "Dossier introuvable: Inbox/demandes-brutes/"
        return 0
      fi

      # Compter les demandes
      while IFS= read -r f; do
        [[ "$f" == *traites* ]] && continue
        total=$(( total + 1 ))
        local st
        st=$(awk '/^---$/{fm++; next} fm==1 && /^status:/{print; exit} fm>=2{exit}' "$f" 2>/dev/null \
             | sed 's/^status: *//')
        if [[ "$st" == "traite"* ]]; then
          done_count=$(( done_count + 1 ))
        else
          pending=$(( pending + 1 ))
        fi
      done < <(find "$inbox_dir" -maxdepth 1 -name "*.md" 2>/dev/null)

      local traites_n
      traites_n=$(find "$traites_dir" -name "*.md" 2>/dev/null | wc -l | tr -d ' \t')
      done_count=$(( done_count + ${traites_n:-0} ))
      local grand_total=$(( total + ${traites_n:-0} ))

      printf '  Demandes brutes : %d total | %d en attente | %d traitées\n' \
        "$grand_total" "$pending" "$done_count"
      echo ""

      if [ "$pending" -gt 0 ]; then
        logwarn "Demandes en attente de traitement :"
        while IFS= read -r f; do
          [[ "$f" == *traites* ]] && continue
          local st
          st=$(awk '/^---$/{fm++; next} fm==1 && /^status:/{print; exit} fm>=2{exit}' "$f" 2>/dev/null \
               | sed 's/^status: *//')
          if [[ "$st" != "traite"* ]]; then
            local fname; fname=$(basename "$f")
            printf '  • [%s] %s\n' "${st:-?}" "$fname"
          fi
        done < <(find "$inbox_dir" -maxdepth 1 -name "*.md" 2>/dev/null)
        echo ""
        loginfo "Pour marquer traité: ipcrae demandes done <nom-fichier>"
      else
        loginfo "Toutes les demandes sont traitées ✓"
      fi
      ;;

    done|mark-done)
      mark_file="${1:-}"
      if [ -z "$mark_file" ]; then
        logerr "Usage: ipcrae demandes done <nom-fichier>"
        return 1
      fi
      local inbox_dir="${IPCRAE_ROOT}/Inbox/demandes-brutes"
      local traites_dir="${inbox_dir}/traites"
      local full_path="${inbox_dir}/${mark_file}"
      [ ! -f "$full_path" ] && full_path="${mark_file}"
      if [ ! -f "$full_path" ]; then
        logerr "Fichier introuvable: ${mark_file}"
        return 1
      fi
      mkdir -p "$traites_dir"
      sed -i "s/^status: .*/status: traite/" "$full_path"
      mv "$full_path" "${traites_dir}/$(basename "$full_path")"
      loginfo "Demande marquée traitée et déplacée dans traites/"
      auto_git_sync_event "demandes done $(basename "$mark_file")"
      ;;

    *)
      local nom="$sub"
      local slug freq
      slug="$(slugify "$nom")"
      [ -z "$slug" ] && slug="process"
      freq="manual"
      local abs="${IPCRAE_ROOT}/Process/${freq}/${slug}.md"
      if [ ! -f "$abs" ]; then
        local tpl="${IPCRAE_ROOT}/Process/_template_process.md"
        [ -f "$tpl" ] || tpl="${IPCRAE_ROOT}/templates/prompts/template_process.md"
        if [ -f "$tpl" ]; then
          cp "$tpl" "$abs"
          sed -i "s/\[Nom\]/${nom}/g" "$abs"
          loginfo "Process créé: Process/${freq}/${slug}.md"
        else
          logwarn "Template process introuvable (_template_process.md)."
          printf '# Process — %s\n' "$nom" > "$abs"
        fi
      fi
      open_note "$abs" "Process/${freq}/${slug}.md"
      ;;
  esac
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
      
      # Vérifier si un dépôt distant ('origin') existe
      if ! git remote | grep -q "^origin$"; then
          logwarn "Aucun dépôt distant (remote) configuré."
          read -r -p "Veuillez entrer l'URL de votre dépôt Git (ex: https://github.com/vieurou/vault.git) : " remote_url
          if [ -n "$remote_url" ]; then
              git remote add origin "$remote_url"
              git branch -M main
              git push -u origin main && loginfo "✅ Remote ajouté et sauvegarde terminée avec succès." || logwarn "Échec du push initial."
          else
              logwarn "URL vide, sauvegarde distante annulée (les commits restent locaux)."
              exit 1
          fi
      else
          git push && loginfo "✅ Sauvegarde terminée avec succès." || logwarn "Échec de la sauvegarde Git."
      fi
    )
  else
    logwarn "${IPCRAE_ROOT} n'est pas un dépôt Git. Impossible de synchroniser."
  fi
}



# ── Safe migration (no data loss) ─────────────────────────────
cmd_migrate_safe() {
  need_root
  section "Migration safe IPCRAE"

  local migrator="${HOME}/bin/ipcrae-migrate-safe"
  if [ ! -x "$migrator" ]; then
    logwarn "ipcrae-migrate-safe introuvable dans ~/bin. Tentative locale..."
    if [ -x "${IPCRAE_ROOT}/templates/ipcrae-migrate-safe.sh" ]; then
      migrator="${IPCRAE_ROOT}/templates/ipcrae-migrate-safe.sh"
    else
      logerr "Script de migration safe introuvable. Réinstaller IPCRAE pour l'obtenir."
      return 1
    fi
  fi

  IPCRAE_ROOT="$IPCRAE_ROOT" "$migrator"
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
    "Strict check" \
    "Reconstruire index tags" \
    "Chercher par tag" \
    "Sync providers" \
    "Migration safe" \
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
      13) read -r -p "Domaine: " _d; cmd_close "$_d"; break ;;
      14) cmd_health; break ;;
      15) cmd_doctor; break ;;
      16) cmd_strict_check; break ;;
      17) cmd_index; break ;;
      18) read -r -p "Tag: " _tag; cmd_tag "$_tag"; break ;;
      19) sync_providers; break ;;
      20) cmd_migrate_safe; break ;;
      21) list_providers; break ;;
      22) open_note "${IPCRAE_ROOT}/Phases/index.md" "Phases/index.md"; break ;;
      23) cmd_process; break ;;
      24) break ;;
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
  start [--project --phase] Initialiser le contexte de session
  work "objectif"          Lancer l'agent avec contexte minimisé
  sprint [OPTIONS]         Sprint autonome : collecte tâches + lance l'IA
  close <domaine>          Clôturer la session (mémoire + context + tags)
  remote list              Afficher les remotes git configurés (cerveau + projets)
  remote set-brain <url>  Configurer le remote du cerveau dans config.yaml
  remote set-project <s> <url>  Configurer le remote d'un projet
  sync                     Régénérer CLAUDE.md, GEMINI.md, AGENTS.md, Kilo
  list                     Lister les providers disponibles
  zettel [titre]           Créer une note atomique Zettelkasten
  moc [thème]              Créer/ouvrir une Map of Content
  health                   Diagnostic du système IPCRAE
  doctor [-v]              Vérifier dépendances + contrat d'injection de contexte
  index                    Reconstruit le cache tags (.ipcrae/cache/tag-index.json)
  tag <tag>                Liste les fichiers liés à un tag
  search <mots|tags>       Recherche (cache tags + fallback grep)
  review <type>            Revue adaptative (phase|project|quarter)
  phase|phases             Ouvrir Phases/index.md
  process [nom]            Créer/ouvrir un process ou l'index
  consolidate <domaine>    Lancer une IA pour compacter la mémoire
  allcontext "<texte>"     Pipeline d'analyse/ingestion universel (rôles + contexte + tracking)
  addProject --slug <s>    Créer un hub projet vault (index + tracking + memory + demandes/)
  archive <slug>           Archiver un projet terminé (Projets/ → Archives/, context.md nettoyé)
  demandes [status|done]   Suivi de l'état des demandes brutes (Inbox/demandes-brutes/)
  prompt build --agent <d> Compiler les couches prompts en un seul fichier (.ipcrae/compiled/)
  prompt check             Vérifier la cohérence des sections obligatoires dans tous les agents
  prompt --list            Lister les agents disponibles
  update                   Met à jour via git pull puis relance l'installateur
  sync-git                 Sauvegarde Git du vault entier (add, commit, push)
  migrate-safe             Upgrade IPCRAE sans perte (backup + merge non destructif)
  <texte_libre>            Mode expert (ex: ipcrae DevOps)

Variables utiles:
  IPCRAE_AUTO_GIT=true     Auto-commit/push après nouvelles entrées mémoire

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
  ipcrae sprint --dry-run   # afficher les tâches sans lancer l'IA
  ipcrae sprint --project IPCRAE --max-tasks 1 --dry-run
  ipcrae sprint --auto      # lancer sans confirmation (mode CI)
  ipcrae DevOps             # mode expert DevOps
  ipcrae sync               # régénérer fichiers provider
  ipcrae index              # rebuild du cache tags
  ipcrae tag devops         # lister les notes liées à un tag
EOF
}

# ── Main ──────────────────────────────────────────────────────
main() {
  if [ $# -eq 0 ]; then
    show_dashboard
    return 0
  fi
  local provider="" cmd=""
  local -a cmd_args=()

  while [ $# -gt 0 ]; do
    case "$1" in
      -p|--provider) provider="${2:-}"; shift ;;
      -h|--help)     usage; exit 0 ;;
      -V|--version)  printf 'IPCRAE Launcher script v%s (method v%s)
' "$SCRIPT_VERSION" "$METHOD_VERSION"; exit 0 ;;
      -*)
        if [ -n "$cmd" ]; then cmd_args+=("$1")
        else logerr "Option inconnue: $1"; usage; exit 1; fi ;;
      *)
        if [ -z "$cmd" ]; then cmd="$1"
        else cmd_args+=("$1"); fi ;;
    esac
    shift
  done

  case "$cmd" in
    start)       cmd_start "$@" ;;
    work)        cmd_work "$@" ;;
    sprint)      cmd_sprint "$@" ;;
    daily)       cmd_daily "$@" ;;
    weekly)      cmd_weekly ;;
    monthly)     cmd_monthly ;;
    close)       cmd_close "$@" ;;
    sync)        sync_providers ;;
    zettel)      cmd_zettel "$@" ;;
    moc)         cmd_moc "$@" ;;
    health)      cmd_health ;;
    doctor)      cmd_doctor "$@" ;;
    strict-check) cmd_strict_check ;;
    review)      cmd_review "$@" ;;
    capture)     cmd_capture "$@" ;;
    consolidate) cmd_consolidate "$@" ;;
    process)     cmd_process "$@" ;;
    index)       cmd_index ;;
    tag)         cmd_tag "$@" ;;
    search)      cmd_search "$@" ;;
    update)      cmd_update ;;
    "sync-git")  cmd_sync_git ;;
    "migrate-safe") cmd_migrate_safe ;;
    remote)      cmd_remote "$@" ;;
    menu)        cmd_menu ;;
    launch)
      shift || true
      launch_ai "$(get_default_provider)" "$@"
      ;;
    --version|-v)
      printf 'IPCRAE launcher v%s (méthode v%s)\n' "$SCRIPT_VERSION" "$METHOD_VERSION"
      ;;
    --help|-h)
      usage
      ;;
    *)
      need_root; show_dashboard
      printf '%b🤖 Provider: %s | 🎯 Expert: %s%b

' "$BOLD" "$provider" "$cmd" "$NC"
      launch_ai "$provider" "$cmd" ;;
  esac
}

main "$@"
