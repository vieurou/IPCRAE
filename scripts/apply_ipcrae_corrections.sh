#!/bin/bash
# Corrections IPCRAE — suggestions actionnables réelles
# Usage: ipcrae-auto-apply [--auto] [--verbose]
#
# --auto    : n'exécute que les corrections sûres (sans interaction)
# --verbose : affiche les détails de chaque étape

# --- Config ---
IPCRAE_ROOT="${IPCRAE_ROOT:-$HOME/IPCRAE}"
AUTO_MODE="false"
VERBOSE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --auto)    AUTO_MODE="true"; shift ;;
    --verbose|-v) VERBOSE="true"; shift ;;
    *) shift ;;
  esac
done

# --- Couleurs ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Résolution du launcher ipcrae ---
IPCRAE_BIN="${HOME}/bin/ipcrae"
[[ -x "$IPCRAE_BIN" ]] || IPCRAE_BIN="$(command -v ipcrae 2>/dev/null || echo '')"

# --- Helpers ---
log_info()  { echo -e "  ${BLUE}→${NC} $*"; }
log_ok()    { echo -e "  ${GREEN}✓${NC} $*"; }
log_skip()  { echo -e "  ${YELLOW}⊘${NC} $*"; }
log_warn()  { echo -e "  ${YELLOW}⚠${NC} $*"; }
log_manual(){ echo -e "  ${RED}✎${NC} $*"; }

run_ipcrae() {
  if [[ -x "$IPCRAE_BIN" ]]; then
    IPCRAE_ROOT="$IPCRAE_ROOT" "$IPCRAE_BIN" "$@"
  else
    log_warn "Launcher ipcrae introuvable — commande suggérée: ipcrae $*"
    return 1
  fi
}

confirm() {
  # En mode auto, skip les confirmations
  [[ "$AUTO_MODE" == "true" ]] && return 1
  local msg="$1"
  echo -ne "  ${CYAN}Appliquer : ${msg} ? [o/N]${NC} "
  read -r ans
  [[ "$ans" =~ ^[oOyY]$ ]]
}

file_age_hours() {
  local f="$1"
  [[ -f "$f" ]] || { echo 99999; return; }
  local ft
  ft=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)
  echo $(( ($(date +%s) - ft) / 3600 ))
}

# ══════════════════════════════════════════════
# Corrections AUTO (sûres, sans side-effects irréversibles)
# ══════════════════════════════════════════════
apply_auto() {
  echo -e "\n${BOLD}${GREEN}── Corrections auto-applicables ──${NC}"

  # A1 — Reconstruire tag-index si stale > 24h
  local tag_index="$IPCRAE_ROOT/.ipcrae/cache/tag-index.json"
  local age_h
  age_h=$(file_age_hours "$tag_index")
  if [[ "$age_h" -ge 24 ]]; then
    log_info "tag-index.json stale (${age_h}h) → reconstruction..."
    if run_ipcrae index 2>/dev/null; then
      log_ok "tag-index.json reconstruit"
    else
      log_warn "ipcrae index a échoué — vérifier le launcher"
    fi
  else
    log_skip "tag-index.json OK (${age_h}h < 24h)"
  fi

  # A2 — Synchroniser CLAUDE.md si context.md plus récent
  local claude_md="$IPCRAE_ROOT/CLAUDE.md"
  local ctx="$IPCRAE_ROOT/.ipcrae/context.md"
  if [[ -f "$ctx" && -f "$claude_md" ]]; then
    local age_claude age_ctx
    age_claude=$(stat -c %Y "$claude_md" 2>/dev/null || echo 0)
    age_ctx=$(stat -c %Y "$ctx" 2>/dev/null || echo 0)
    if [[ "$age_ctx" -gt "$age_claude" ]]; then
      log_info "context.md plus récent que CLAUDE.md → ipcrae sync..."
      if run_ipcrae sync 2>/dev/null; then
        log_ok "CLAUDE.md synchronisé"
      else
        log_warn "ipcrae sync a échoué — relancer manuellement"
      fi
    else
      log_skip "CLAUDE.md déjà synchronisé"
    fi
  fi
}

# ══════════════════════════════════════════════
# Corrections GUIDÉES (affiche commande + confirmation)
# ══════════════════════════════════════════════
apply_guided() {
  echo -e "\n${BOLD}${YELLOW}── Corrections guidées ──${NC}"
  [[ "$AUTO_MODE" == "true" ]] && echo -e "  ${CYAN}(mode --auto : corrections guidées skippées)${NC}" && return

  local today yesterday daily_dir
  today=$(date '+%Y-%m-%d')
  yesterday=$(date -d 'yesterday' '+%Y-%m-%d' 2>/dev/null || date -v-1d '+%Y-%m-%d' 2>/dev/null || echo "")
  daily_dir="$IPCRAE_ROOT/Journal/Daily"

  # G1 — Daily manquante
  if [[ ! -d "$daily_dir/$today" && ! -f "$daily_dir/${today}.md" && ! -d "$daily_dir/$yesterday" && ! -f "$daily_dir/${yesterday}.md" ]]; then
    log_warn "Daily manquante pour ${today}"
    if confirm "ipcrae daily"; then
      run_ipcrae daily && log_ok "Daily créée" || log_warn "Erreur ipcrae daily"
    else
      log_skip "Daily ignorée — lancer: ipcrae daily"
    fi
  else
    log_skip "Daily OK"
  fi

  # G2 — Vault non commité
  local uncommitted
  uncommitted=$(git -C "$IPCRAE_ROOT" status --porcelain 2>/dev/null | grep "^[MADRCU?]" | wc -l | tr -d ' \t')
  if [[ "$uncommitted" -gt 0 ]]; then
    log_warn "Vault : ${uncommitted} fichier(s) non commité(s)"
    if confirm "git add -A && git commit (vault)"; then
      git -C "$IPCRAE_ROOT" add -A && \
        git -C "$IPCRAE_ROOT" commit -m "chore(ipcrae): auto-apply sync $(date '+%Y-%m-%d %H:%M')" && \
        log_ok "Vault commité" || log_warn "Erreur git commit"
    else
      log_skip "Commit ignoré — lancer: git -C $IPCRAE_ROOT commit"
    fi
  else
    log_skip "Vault propre (0 fichier non commité)"
  fi

  # G3 — Mémoire domaine non mise à jour
  local mem_dir="$IPCRAE_ROOT/memory"
  local recent_mem=0
  if [[ -d "$mem_dir" ]]; then
    while IFS= read -r f; do
      local age_d=$(( $(file_age_hours "$f") / 24 ))
      [[ "$age_d" -le 7 ]] && recent_mem=1 && break
    done < <(find "$mem_dir" -maxdepth 1 -type f -name "*.md" ! -name "MEMORY.md" 2>/dev/null)
  fi
  if [[ "$recent_mem" -eq 0 ]]; then
    log_warn "Mémoire domaine non mise à jour depuis > 7j"
    log_manual "Lancer: ipcrae close <domaine> --project <slug>"
  else
    log_skip "Mémoire domaine OK"
  fi

  # G4 — Inbox stale
  local stale_count
  stale_count=$(find "$IPCRAE_ROOT/Inbox" -maxdepth 1 -type f -name "*.md" -mtime +7 2>/dev/null | wc -l)
  if [[ "$stale_count" -gt 0 ]]; then
    log_warn "${stale_count} fichier(s) Inbox stale > 7j"
    log_manual "Clarifier avec GTD : capturer, organiser ou supprimer"
    log_manual "Inbox: $IPCRAE_ROOT/Inbox/"
  else
    log_skip "Inbox OK (0 fichier stale)"
  fi
}

# ══════════════════════════════════════════════
# Corrections MANUELLES (rapport uniquement)
# ══════════════════════════════════════════════
report_manual() {
  echo -e "\n${BOLD}${RED}── Actions manuelles requises ──${NC}"

  # M1 — Permanents Zettelkasten vides
  local perm_dir="$IPCRAE_ROOT/Zettelkasten/permanents"
  local perm_count=0
  [[ -d "$perm_dir" ]] && perm_count=$(find "$perm_dir" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l)
  if [[ "$perm_count" -eq 0 ]]; then
    log_manual "Zettelkasten/permanents/ vide"
    log_manual "→ Workflow : lire _inbox/, valider 1 note, déplacer vers permanents/, ajouter [[liens]]"
  fi

  # M2 — Phase non définie
  local phases_idx="$IPCRAE_ROOT/Phases/index.md"
  local lines=0
  [[ -f "$phases_idx" ]] && lines=$(grep -v "^#\|^---\|^$\|\[\[" "$phases_idx" 2>/dev/null | wc -l)
  if [[ "$lines" -lt 3 ]]; then
    log_manual "Phases/index.md : phase active non définie"
    log_manual "→ Créer depuis Process/ ou définir la phase courante"
  fi

  # M3 — Objectifs manquants
  local obj_ok=0
  for f in "$IPCRAE_ROOT/Objectifs/vision.md" "$IPCRAE_ROOT/Objectifs/Vision.md"; do
    [[ -f "$f" && -s "$f" ]] && obj_ok=1 && break
  done
  [[ "$obj_ok" -eq 0 ]] && find "$IPCRAE_ROOT/Objectifs" -name "quarterly-*.md" -size +0c 2>/dev/null | grep -q . && obj_ok=1
  if [[ "$obj_ok" -eq 0 ]]; then
    log_manual "Objectifs/vision.md (ou quarterly-*.md) absent ou vide"
    log_manual "→ Créer Objectifs/vision.md avec votre vision personnelle et professionnelle"
  fi
}

# ══════════════════════════════════════════════
# Main
# ══════════════════════════════════════════════
main() {
  # Guard : vault doit être un dépôt git valide
  if ! git -C "$IPCRAE_ROOT" rev-parse --git-dir &>/dev/null; then
    echo -e "\n${RED}ERREUR: IPCRAE_ROOT=$IPCRAE_ROOT n'est pas un dépôt git — vault invalide${NC}" >&2
    echo -e "${YELLOW}Conseil: export IPCRAE_ROOT=\$HOME/IPCRAE${NC}\n" >&2
    exit 2
  fi

  echo -e "\n${BOLD}${CYAN}━━ Corrections IPCRAE — $(date '+%Y-%m-%d %H:%M') ━━${NC}"
  echo -e "${CYAN}Vault: ${IPCRAE_ROOT}${NC}"
  [[ "$AUTO_MODE" == "true" ]] && echo -e "${CYAN}Mode: automatique (--auto)${NC}"

  # Lancer l'audit pour lire les gaps (via le binaire ipcrae-audit-check)
  local audit_bin
  SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  audit_bin="${SELF_DIR}/ipcrae-audit-check"
  [[ ! -x "$audit_bin" ]] && audit_bin="$(command -v ipcrae-audit-check 2>/dev/null || echo '')"

  if [[ -x "$audit_bin" ]]; then
    echo -e "\n${BLUE}Lecture du rapport d'audit...${NC}"
    "$audit_bin" 2>/dev/null | grep -E "^  (✗|⚠|GAPS)" | head -20
  fi

  apply_auto
  apply_guided
  report_manual

  echo -e "\n${GREEN}✓ Cycle de corrections terminé${NC}"
  echo -e "${BLUE}Relancer ipcrae-audit-check pour mesurer l'amélioration.${NC}\n"
}

main
