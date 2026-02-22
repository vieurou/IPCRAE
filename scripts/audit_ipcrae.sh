#!/bin/bash
# Audit réel du vault IPCRAE — score dynamique 0-45
# Usage: ipcrae-audit-check [--verbose]

# --- Config ---
IPCRAE_ROOT="${IPCRAE_ROOT:-$HOME/IPCRAE}"
VERBOSE="${VERBOSE:-false}"
[[ "$1" == "--verbose" || "$1" == "-v" ]] && VERBOSE="true"

# --- Couleurs ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- État global ---
TOTAL_SCORE=0
MAX_SCORE=45
declare -a GAPS=()
CRITIQUES=0
IMPORTANTS=0
MINEURS=0

# --- Helpers ---
now() { date +%s; }

file_age_hours() {
  local f="$1"
  [[ -f "$f" ]] || { echo 99999; return; }
  local ft
  ft=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)
  echo $(( ($(now) - ft) / 3600 ))
}

file_age_days() {
  echo $(( $(file_age_hours "$1") / 24 ))
}

dir_count() {
  local d="$1"
  [[ -d "$d" ]] || { echo 0; return; }
  find "$d" -maxdepth 1 -type f -name "*.md" | wc -l
}

stale_files_count() {
  # Fichiers .md modifiés il y a plus de $2 jours dans $1
  local dir="$1" days="$2"
  [[ -d "$dir" ]] || { echo 0; return; }
  find "$dir" -maxdepth 1 -type f -name "*.md" -mtime +$days | wc -l
}

has_frontmatter_field() {
  # Vérifie qu'au moins un fichier .md dans $1 contient le champ $2 en frontmatter
  local dir="$1" field="$2"
  [[ -d "$dir" ]] || return 1
  grep -rl "^${field}:" "$dir" --include="*.md" -l 2>/dev/null | head -1 | grep -q .
}

vault_uncommitted_count() {
  git -C "$IPCRAE_ROOT" status --porcelain 2>/dev/null | grep "^[MADRCU?]" | wc -l | tr -d ' \t'
}

vault_last_commit_age_hours() {
  local ts
  ts=$(git -C "$IPCRAE_ROOT" log -1 --format="%ct" 2>/dev/null || echo 0)
  [[ "$ts" =~ ^[0-9]+$ ]] || ts=0
  echo $(( ($(now) - ts) / 3600 ))
}

phase_is_real() {
  local f="$IPCRAE_ROOT/Phases/index.md"
  [[ -f "$f" ]] || return 1
  # Stratégie 1 : un [[lien]] pointe vers un fichier de phase existant et non vide
  local linked
  while IFS= read -r linked; do
    local phase_file="$IPCRAE_ROOT/Phases/${linked}.md"
    [[ -f "$phase_file" && -s "$phase_file" ]] && return 0
  done < <(grep -oP '\[\[\K[^\]]+' "$f" 2>/dev/null)
  # Stratégie 2 : fallback — au moins 3 lignes de contenu non-header non-vides
  local lines
  lines=$(grep -v "^#\|^---\|^$" "$f" 2>/dev/null | wc -l)
  [[ "$lines" -ge 3 ]]
}

config_has_fields() {
  local cfg="$IPCRAE_ROOT/.ipcrae/config.yaml"
  [[ -f "$cfg" ]] || return 1
  grep -q "^ipcrae_root:" "$cfg" && grep -q "^default_provider:" "$cfg"
}

# --- Fonctions de suivi des profils ---

# Obtenir les rôles actuels depuis l'environnement ou les arguments
get_current_roles() {
  local roles=()
  
  # Rôle principal depuis AGENT_TYPE ou variable d'environnement
  if [[ -n "${AGENT_TYPE:-}" ]]; then
    roles+=("$AGENT_TYPE")
  fi
  
  # Rôles secondaires depuis AGENT_ROLES
  if [[ -n "${AGENT_ROLES:-}" ]]; then
    IFS=',' read -ra SECONDARY_ROLES <<< "$AGENT_ROLES"
    for role in "${SECONDARY_ROLES[@]}"; do
      roles+=("$role")
    done
  fi
  
  # Fallback: détecter depuis les arguments de la commande
  if [[ ${#roles[@]} -eq 0 ]]; then
    # Analyser les arguments pour détecter les rôles
    for arg in "$@"; do
      case "$arg" in
        *architect*) roles+=("Architect") ;;
        *code*) roles+=("Code") ;;
        *ask*) roles+=("Ask") ;;
        *debug*) roles+=("Debug") ;;
        *orchestrator*) roles+=("Orchestrator") ;;
        *review*) roles+=("Review") ;;
      esac
    done
  fi
  
  # Si toujours vide, utiliser un rôle par défaut
  [[ ${#roles[@]} -eq 0 ]] && roles=("Architect")
  
  printf '%s\n' "${roles[@]}"
}

# Enregistrer l'utilisation des rôles dans le fichier de suivi
log_roles_usage() {
  local primary_role="${1:-Architect}"
  shift
  local secondary_roles=("$@")
  
  local profiles_file="$IPCRAE_ROOT/.ipcrae/memory/profils-usage.md"
  local date=$(date '+%Y-%m-%d')
  local time=$(date '+%H:%M')
  local session_id="${date}_${time}_$$"
  
  # Créer le fichier s'il n'existe pas
  [[ ! -f "$profiles_file" ]] && mkdir -p "$(dirname "$profiles_file")" && touch "$profiles_file"
  
  # Ajouter l'entrée de session
  local session_entry="### ${date} - ${time}
---
date: ${date}
time: ${time}
session_id: ${session_id}
roles_used:
  - ${primary_role}
"
  
  for role in "${secondary_roles[@]}"; do
    session_entry="${session_entry}
  - ${role}"
  done
  
  session_entry="${session_entry}
project: IPCRAE
score_ipcrae: ${TOTAL_SCORE}/${MAX_SCORE}
duration: 0
---
"
  
  # Ajouter au fichier
  echo "$session_entry" >> "$profiles_file"
}

# Calculer les statistiques d'utilisation des rôles
get_roles_statistics() {
  local profiles_file="$IPCRAE_ROOT/.ipcrae/memory/profils-usage.md"
  [[ ! -f "$profiles_file" ]] && return 0
  
  # Compter les sessions par rôle
  local architect=0 code=0 ask=0 debug=0 orchestrator=0 review=0
  
  # Utiliser grep pour compter les occurrences de chaque rôle
  architect=$(grep "Architect" "$profiles_file" 2>/dev/null | wc -l | tr -d ' \t')
  code=$(grep "Code" "$profiles_file" 2>/dev/null | wc -l | tr -d ' \t')
  ask=$(grep "Ask" "$profiles_file" 2>/dev/null | wc -l | tr -d ' \t')
  debug=$(grep "Debug" "$profiles_file" 2>/dev/null | wc -l | tr -d ' \t')
  orchestrator=$(grep "Orchestrator" "$profiles_file" 2>/dev/null | wc -l | tr -d ' \t')
  review=$(grep "Review" "$profiles_file" 2>/dev/null | wc -l | tr -d ' \t')
  
  # Afficher les statistiques
  echo -e "\n${BOLD}${BLUE}Statistiques d'Utilisation des Rôles${NC}"
  echo -e "  Architect: ${architect} sessions"
  echo -e "  Code: ${code} sessions"
  echo -e "  Ask: ${ask} sessions"
  echo -e "  Debug: ${debug} sessions"
  echo -e "  Orchestrator: ${orchestrator} sessions"
  echo -e "  Review: ${review} sessions"
}

waiting_for_stale_count() {
  local f="$IPCRAE_ROOT/Inbox/waiting-for.md"
  [[ -f "$f" ]] || { echo 0; return; }
  # Compte les lignes avec une date > 14j (format YYYY-MM-DD)
  local count=0
  local cutoff
  cutoff=$(date -d '-14 days' '+%Y-%m-%d' 2>/dev/null || date -v-14d '+%Y-%m-%d' 2>/dev/null || echo "0000-00-00")
  while IFS= read -r line; do
    local d
    d=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
    [[ -n "$d" && "$d" < "$cutoff" ]] && ((count++))
  done < "$f"
  echo "$count"
}

# --- Affichage ---
section_header() {
  echo -e "\n${BOLD}${BLUE}$1${NC}"
}

check_line() {
  local ok="$1" label="$2" pts_got="$3" pts_max="$4" hint="$5"
  if [[ "$ok" == "ok" ]]; then
    printf "  ${GREEN}✓${NC} %-45s [%s/%s]\n" "$label" "$pts_got" "$pts_max"
  else
    printf "  ${RED}✗${NC} %-45s [0/%s]\n" "$label" "$pts_max"
    [[ -n "$hint" ]] && GAPS+=("$hint")
  fi
}

add_score() { TOTAL_SCORE=$(( TOTAL_SCORE + $1 )); }

# ══════════════════════════════════════════════
# Section 1 — Synchronisation système (9 pts)
# ══════════════════════════════════════════════
audit_section1() {
  section_header "Section 1 — Synchronisation système"
  local s=0

  # 1.1 CLAUDE.md présent et non vide (1 pt)
  local claude_md="$IPCRAE_ROOT/CLAUDE.md"
  if [[ -f "$claude_md" && -s "$claude_md" ]]; then
    check_line ok "CLAUDE.md présent et non vide" 1 1
    s=$(( s + 1 ))
  else
    check_line ko "CLAUDE.md présent et non vide" 0 1 "CLAUDE.md absent ou vide → lancer: ipcrae sync"
    CRITIQUES=$(( CRITIQUES + 1 ))
  fi

  # 1.2 CLAUDE.md synchronisé avec context.md (2 pts)
  # Logique directionnelle : CLAUDE.md doit être >= context.md (plus récent ou égal)
  # Tolérance 600s : context.md peut être légèrement plus récent (race condition ipcrae sync)
  local ctx="$IPCRAE_ROOT/.ipcrae/context.md"
  if [[ -f "$claude_md" && -f "$ctx" ]]; then
    local age_claude age_ctx
    age_claude=$(stat -c %Y "$claude_md" 2>/dev/null || echo 0)
    age_ctx=$(stat -c %Y "$ctx" 2>/dev/null || echo 0)
    local lag=$(( age_ctx - age_claude ))  # positif si context.md plus récent (désynchronisé)
    if [[ "$lag" -le 600 ]]; then
      check_line ok "CLAUDE.md synchronisé avec context.md" 2 2
      s=$(( s + 2 ))
    else
      check_line ko "CLAUDE.md synchronisé avec context.md" 0 2 "CLAUDE.md désynchronisé (context.md plus récent de ${lag}s) → lancer: ipcrae sync"
      IMPORTANTS=$(( IMPORTANTS + 1 ))
    fi
  else
    check_line ko "CLAUDE.md synchronisé avec context.md" 0 2 "context.md introuvable → créer .ipcrae/context.md"
    IMPORTANTS=$(( IMPORTANTS + 1 ))
  fi

  # 1.3 tag-index.json présent et < 24h (2 pts)
  local tag_index="$IPCRAE_ROOT/.ipcrae/cache/tag-index.json"
  local age_h
  age_h=$(file_age_hours "$tag_index")
  if [[ "$age_h" -lt 24 ]]; then
    check_line ok "tag-index.json présent et < 24h" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "tag-index.json présent et < 24h (${age_h}h)" 0 2 "tag-index.json stale (${age_h}h) → lancer: ipcrae index"
    MINEURS=$(( MINEURS + 1 ))
  fi

  # 1.4 config.yaml valide (2 pts)
  if config_has_fields; then
    check_line ok "config.yaml valide (ipcrae_root + default_provider)" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "config.yaml valide (ipcrae_root + default_provider)" 0 2 "config.yaml invalide ou absent → vérifier .ipcrae/config.yaml"
    IMPORTANTS=$(( IMPORTANTS + 1 ))
  fi

  # 1.5 Mode auto-amélioration activé (2 pts)
  local auto_dir="$IPCRAE_ROOT/.ipcrae/auto"
  if ls "$auto_dir"/last_audit_*.txt 2>/dev/null | grep -q .; then
    check_line ok "Mode auto-amélioration actif (last_audit_*.txt)" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "Mode auto-amélioration actif (last_audit_*.txt)" 0 2 "Auto-amélioration non activée → lancer: ipcrae-auto auto-activate --agent claude"
    MINEURS=$(( MINEURS + 1 ))
  fi

  echo -e "  ${CYAN}Score section: ${s}/9${NC}"
  add_score "$s"
}

# ══════════════════════════════════════════════
# Section 2 — Rythme de capture (8 pts)
# ══════════════════════════════════════════════
audit_section2() {
  section_header "Section 2 — Rythme de capture"
  local s=0

  # 2.1 Daily du jour ou hier (3 pts)
  local today yesterday daily_dir
  today=$(date '+%Y-%m-%d')
  yesterday=$(date -d 'yesterday' '+%Y-%m-%d' 2>/dev/null || date -v-1d '+%Y-%m-%d' 2>/dev/null || echo "")
  daily_dir="$IPCRAE_ROOT/Journal/Daily"
  if [[ -d "$daily_dir/$today" || -f "$daily_dir/${today}.md" || -d "$daily_dir/$yesterday" || -f "$daily_dir/${yesterday}.md" ]]; then
    check_line ok "Daily du jour ou hier présente" 3 3
    s=$(( s + 3 ))
  else
    check_line ko "Daily du jour ou hier présente" 0 3 "Daily manquante → lancer: ipcrae daily"
    IMPORTANTS=$(( IMPORTANTS + 1 ))
  fi

  # 2.2 Weekly ISO en cours (2 pts)
  local week_label weekly_dir
  week_label=$(date '+%Y-W%V')
  weekly_dir="$IPCRAE_ROOT/Journal/Weekly"
  if find "$weekly_dir" -name "*${week_label}*" 2>/dev/null | grep -q .; then
    check_line ok "Weekly ISO ${week_label} présente" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "Weekly ISO ${week_label} présente" 0 2 "Weekly manquante → lancer: ipcrae weekly"
    MINEURS=$(( MINEURS + 1 ))
  fi

  # 2.3 Inbox/ : 0 fichiers stale > 7j (2 pts)
  local stale_inbox
  stale_inbox=$(stale_files_count "$IPCRAE_ROOT/Inbox" 7)
  if [[ "$stale_inbox" -eq 0 ]]; then
    check_line ok "Inbox/ : 0 fichiers stale > 7j" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "Inbox/ : ${stale_inbox} fichier(s) stale > 7j" 0 2 "${stale_inbox} fichier(s) Inbox stale → clarifier avec GTD: capturer ou supprimer"
    MINEURS=$(( MINEURS + 1 ))
  fi

  # 2.4 Waiting-for.md : aucun item > 14j (1 pt)
  local stale_wf
  stale_wf=$(waiting_for_stale_count)
  if [[ "$stale_wf" -eq 0 ]]; then
    check_line ok "Waiting-for.md : aucun item > 14j" 1 1
    s=$(( s + 1 ))
  else
    check_line ko "Waiting-for.md : ${stale_wf} item(s) > 14j" 0 1 "${stale_wf} item(s) waiting-for expirés → relancer ou clore"
    MINEURS=$(( MINEURS + 1 ))
  fi

  echo -e "  ${CYAN}Score section: ${s}/8${NC}"
  add_score "$s"
}

# ══════════════════════════════════════════════
# Section 3 — Mémoire & Knowledge (10 pts)
# ══════════════════════════════════════════════
audit_section3() {
  section_header "Section 3 — Mémoire & Knowledge"
  local s=0

  # 3.1 memory/<domaine>.md actif mis à jour < 7j (3 pts)
  local mem_dir="$IPCRAE_ROOT/memory"
  local recent_mem=0
  if [[ -d "$mem_dir" ]]; then
    while IFS= read -r f; do
      local age
      age=$(file_age_days "$f")
      [[ "$age" -le 7 ]] && recent_mem=1 && break
    done < <(find "$mem_dir" -maxdepth 1 -type f -name "*.md" ! -name "MEMORY.md" 2>/dev/null)
  fi
  if [[ "$recent_mem" -eq 1 ]]; then
    check_line ok "memory/<domaine>.md actif mis à jour < 7j" 3 3
    s=$(( s + 3 ))
  else
    check_line ko "memory/<domaine>.md actif mis à jour < 7j" 0 3 "Mémoire domaine non mise à jour → lancer: ipcrae close <domaine>"
    IMPORTANTS=$(( IMPORTANTS + 1 ))
  fi

  # 3.2 Projets actifs listés dans context.md (2 pts)
  local ctx="$IPCRAE_ROOT/.ipcrae/context.md"
  if [[ -f "$ctx" ]] && grep -q "Projets en cours\|projets actifs\|## Projets" "$ctx" 2>/dev/null; then
    check_line ok "Projets actifs dans context.md" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "Projets actifs dans context.md" 0 2 "context.md sans section projets → mettre à jour .ipcrae/context.md"
    IMPORTANTS=$(( IMPORTANTS + 1 ))
  fi

  # 3.3 Knowledge/ : ≥ 1 note avec frontmatter complet type+tags+domain (3 pts)
  local know_dir="$IPCRAE_ROOT/Knowledge"
  local know_ok=0
  if [[ -d "$know_dir" ]]; then
    while IFS= read -r f; do
      if grep -q "^type:" "$f" 2>/dev/null && grep -q "^tags:" "$f" 2>/dev/null && grep -q "^domain:" "$f" 2>/dev/null; then
        know_ok=1
        break
      fi
    done < <(find "$know_dir" -type f -name "*.md" 2>/dev/null)
  fi
  if [[ "$know_ok" -eq 1 ]]; then
    check_line ok "Knowledge/ : ≥1 note avec frontmatter complet" 3 3
    s=$(( s + 3 ))
  else
    check_line ko "Knowledge/ : ≥1 note avec frontmatter complet" 0 3 "Aucune note Knowledge avec frontmatter type+tags+domain → créer via: ipcrae zettel"
    MINEURS=$(( MINEURS + 1 ))
  fi

  # 3.4 Zettelkasten/_inbox/ : < 15 notes non migrées (2 pts)
  local zettel_inbox="$IPCRAE_ROOT/Zettelkasten/_inbox"
  local inbox_count
  inbox_count=$(dir_count "$zettel_inbox")
  if [[ "$inbox_count" -lt 15 ]]; then
    check_line ok "Zettelkasten/_inbox/ : ${inbox_count} note(s) (< 15)" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "Zettelkasten/_inbox/ : ${inbox_count} notes (≥ 15)" 0 2 "${inbox_count} notes Zettel en attente → migrer vers permanents/"
    MINEURS=$(( MINEURS + 1 ))
  fi

  echo -e "  ${CYAN}Score section: ${s}/10${NC}"
  add_score "$s"
}

# ══════════════════════════════════════════════
# Section 4 — Git & Workflow (13 pts)
# ══════════════════════════════════════════════
audit_section4() {
  section_header "Section 4 — Git & Workflow"
  local s=0

  # 4.1 Vault : 0 fichiers modifiés non commités (4 pts — CRITIQUE)
  local uncommitted
  uncommitted=$(vault_uncommitted_count)
  if [[ "$uncommitted" -eq 0 ]]; then
    check_line ok "Vault : 0 fichiers non commités" 4 4
    s=$(( s + 4 ))
  else
    check_line ko "Vault : ${uncommitted} fichier(s) non commité(s)" 0 4 "Vault non commité (${uncommitted} fichiers) → lancer: ipcrae sync-git ou git commit"
    CRITIQUES=$(( CRITIQUES + 1 ))
  fi

  # 4.2 Dernier commit vault < 48h (3 pts — CRITIQUE)
  local commit_age_h
  commit_age_h=$(vault_last_commit_age_hours)
  if [[ "$commit_age_h" -lt 48 ]]; then
    check_line ok "Dernier commit vault < 48h (${commit_age_h}h)" 3 3
    s=$(( s + 3 ))
  else
    local commit_age_d=$(( commit_age_h / 24 ))
    check_line ko "Dernier commit vault (${commit_age_d}j — dépasse 48h)" 0 3 "Vault non commité depuis ${commit_age_d}j → commiter maintenant"
    CRITIQUES=$(( CRITIQUES + 1 ))
  fi

  # 4.3 Zettelkasten/permanents/ non vide (2 pts)
  local perm_count
  perm_count=$(dir_count "$IPCRAE_ROOT/Zettelkasten/permanents")
  if [[ "$perm_count" -ge 1 ]]; then
    check_line ok "Zettelkasten/permanents/ : ${perm_count} note(s)" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "Zettelkasten/permanents/ : vide" 0 2 "Permanents Zettelkasten vides → initier workflow de validation depuis _inbox/"
    MINEURS=$(( MINEURS + 1 ))
  fi

  # 4.4 Phases/index.md : phase active définie (2 pts)
  if phase_is_real; then
    check_line ok "Phases/index.md : phase active définie" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "Phases/index.md : phase active absente ou placeholder" 0 2 "Phase non définie → créer depuis Process/templates/"
    MINEURS=$(( MINEURS + 1 ))
  fi

  # 4.5 Objectifs : vision.md OU quarterly présent et non vide (2 pts)
  local obj_dir="$IPCRAE_ROOT/Objectifs"
  local obj_ok=0
  for f in "$obj_dir/vision.md" "$obj_dir"/quarterly-*.md "$obj_dir"/Vision.md; do
    [[ -f "$f" && -s "$f" ]] && obj_ok=1 && break
  done
  if [[ "$obj_ok" -eq 1 ]]; then
    check_line ok "Objectifs : vision.md / quarterly présent et non vide" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "Objectifs : vision.md / quarterly absent ou vide" 0 2 "Objectifs manquants → créer Objectifs/vision.md ou quarterly"
    MINEURS=$(( MINEURS + 1 ))
  fi

  echo -e "  ${CYAN}Score section: ${s}/13${NC}"
  add_score "$s"
}

# ══════════════════════════════════════════════
# Section 5 — Suivi des Profils (5 pts)
# ══════════════════════════════════════════════
audit_section5() {
  section_header "Section 5 — Suivi des Profils"
  local s=0
  
  # 5.1 Fichier de suivi des profils présent (2 pts)
  local profiles_file="$IPCRAE_ROOT/.ipcrae/memory/profils-usage.md"
  if [[ -f "$profiles_file" ]]; then
    check_line ok "Fichier de suivi des profils présent" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "Fichier de suivi des profils présent" 0 2 "Fichier manquant → créé automatiquement"
    MINEURS=$(( MINEURS + 1 ))
  fi
  
  # 5.2 Au moins 1 session enregistrée dans le fichier (2 pts)
  local session_count=0
  if [[ -f "$profiles_file" ]]; then
    session_count=$(grep "^session_id:" "$profiles_file" 2>/dev/null | wc -l | tr -d ' \t')
  fi
  if [[ "$session_count" -ge 1 ]]; then
    check_line ok "Sessions enregistrées : ${session_count} session(s)" 2 2
    s=$(( s + 2 ))
  else
    check_line ko "Sessions enregistrées : aucune" 0 2 "Aucune session encore enregistrée (sera logée à la fin de cet audit)"
    MINEURS=$(( MINEURS + 1 ))
  fi

  # 5.3 Enregistrement de session automatique (1 pt) — auto-log de cette session
  log_roles_usage "Architect"
  check_line ok "Enregistrement de session automatique (session logée)" 1 1
  s=$(( s + 1 ))
  
  # Afficher les statistiques si disponibles
  if [[ -f "$profiles_file" ]]; then
    get_roles_statistics
  fi
  
  echo -e "  ${CYAN}Score section: ${s}/5${NC}"
  add_score "$s"
}

# ══════════════════════════════════════════════
# Main
# ══════════════════════════════════════════════
main() {
  local date_label
  date_label=$(date '+%Y-%m-%d')

  echo -e "\n${BOLD}${CYAN}━━ Audit IPCRAE — ${date_label} ━━${NC}"
  echo -e "${CYAN}Vault: ${IPCRAE_ROOT}${NC}"

  audit_section1
  audit_section2
  audit_section3
  audit_section4
  audit_section5
  
  # Résumé
  local pct=$(( TOTAL_SCORE * 100 / MAX_SCORE ))
  local color_score
  if [[ "$pct" -ge 80 ]]; then color_score="$GREEN"
  elif [[ "$pct" -ge 60 ]]; then color_score="$YELLOW"
  else color_score="$RED"
  fi

  echo -e "\n${BOLD}${color_score}Score Global: ${TOTAL_SCORE}/${MAX_SCORE} (${pct}%)${NC}"
  echo -e "Critiques: ${RED}${CRITIQUES}${NC}  Importants: ${YELLOW}${IMPORTANTS}${NC}  Mineurs: ${CYAN}${MINEURS}${NC}"

  if [[ "${#GAPS[@]}" -gt 0 ]]; then
    echo -e "\n${BOLD}GAPS DÉTECTÉS:${NC}"
    for gap in "${GAPS[@]}"; do
      echo -e "  ${YELLOW}⚠${NC} $gap"
    done
  fi

  echo ""
  # Code de retour : 0 si score >= 25, 1 sinon
  [[ "$TOTAL_SCORE" -ge 25 ]]
}

main
