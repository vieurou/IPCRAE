#!/usr/bin/env bash
set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
MAX_CHARS="${MAX_CHARS:-12000}"
MODE="${1:-core}"
PROJECT_NAME="${2:-}"

usage() {
  cat <<'USAGE'
Usage: ipcrae-tokenpack.sh [core|project] [project_name]

Build a compact context pack optimized for token efficiency.
USAGE
}

if [ "$MODE" = "-h" ] || [ "$MODE" = "--help" ]; then
  usage
  exit 0
fi

emit_file() {
  local title="$1" file="$2"
  [ -f "$file" ] || return 0
  {
    printf '\n### %s (%s)\n' "$title" "${file#${IPCRAE_ROOT}/}"
    sed -E '/^\s*$/d;/^<!--.*-->$/d' "$file" | head -n 80
  } >> "$TMP_OUT"
}

TMP_OUT=$(mktemp)
trap 'rm -f "$TMP_OUT"' EXIT

{
  printf '# IPCRAE TokenPack\n'
  printf 'mode: %s\n' "$MODE"
  printf 'generated_at: %s\n' "$(date -Iseconds)"
} > "$TMP_OUT"

emit_file "Global Context" "${IPCRAE_ROOT}/.ipcrae/context.md"
emit_file "Global Instructions" "${IPCRAE_ROOT}/.ipcrae/instructions.md"
emit_file "Active Phase" "${IPCRAE_ROOT}/Phases/index.md"
emit_file "Waiting For" "${IPCRAE_ROOT}/Inbox/waiting-for.md"

if [ "$MODE" = "project" ] && [ -n "$PROJECT_NAME" ]; then
  emit_file "Project Hub" "${IPCRAE_ROOT}/Projets/${PROJECT_NAME}/index.md"
  emit_file "Project Tracking" "${IPCRAE_ROOT}/Projets/${PROJECT_NAME}/tracking.md"
  emit_file "Project Memory" "${IPCRAE_ROOT}/Projets/${PROJECT_NAME}/memory.md"
fi

cat >> "$TMP_OUT" <<'CONTRACT'

## Prompt Contract (short)
- Répondre en bullets actionnables.
- Ne pas répéter le contexte brut.
- Donner: 1 quick win + 1 plan robuste.
- Si incertitude: signaler "non vérifié en live".
CONTRACT

head -c "$MAX_CHARS" "$TMP_OUT"
printf '\n'
