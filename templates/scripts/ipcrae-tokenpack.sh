#!/usr/bin/env bash
set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
MAX_CHARS="${MAX_CHARS:-12000}"
MAX_LINES_PER_FILE="${MAX_LINES_PER_FILE:-120}"
MODE="${1:-core}"
PROJECT_NAME="${2:-}"

usage() {
  cat <<'USAGE'
Usage: ipcrae-tokenpack.sh [core|project] [project_name]

Build a compact context pack optimized for token efficiency.
Per file, extractive summary prioritizes sections about objectifs, contraintes, décisions.
USAGE
}

if [ "$MODE" = "-h" ] || [ "$MODE" = "--help" ]; then
  usage
  exit 0
fi

TMP_OUT=$(mktemp)
TMP_SUMMARY=$(mktemp)
trap 'rm -f "$TMP_OUT" "$TMP_SUMMARY"' EXIT

extractive_summary() {
  local file="$1" out_file="$2"

  awk -v max_lines="$MAX_LINES_PER_FILE" '
    function trimmed(s) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
      return s
    }
    function lower(s) {
      return tolower(s)
    }
    function flush_section(    key,score,section_text) {
      if (current_header == "") {
        return
      }
      section_text = trimmed(section_body)
      if (section_text == "") {
        current_header = ""
        section_body = ""
        return
      }

      score = 1
      key = lower(current_header "\n" section_text)
      if (key ~ /(objectif|objectifs|goal|goals|résultat attendu|resultat attendu)/) score += 8
      if (key ~ /(contrainte|contraintes|blocker|bloquant|must|doit|limite|restriction)/) score += 7
      if (key ~ /(décision|decision|tradeoff|arbitrage|choix|why|pourquoi)/) score += 6
      if (key ~ /(risque|risk|impact|validation|test|command)/) score += 2

      section_count++
      section_score[section_count] = score
      section_header[section_count] = current_header
      section_content[section_count] = section_text

      current_header = ""
      section_body = ""
    }

    BEGIN {
      section_count = 0
      current_header = ""
      section_body = ""
      fallback_count = 0
    }

    {
      line = $0
      if (line ~ /^<!--.*-->$/ || line ~ /^[[:space:]]*$/) next
      if (line ~ /^#/) {
        flush_section()
        current_header = line
        next
      }

      if (current_header == "") {
        fallback_count++
        fallback[fallback_count] = line
      } else {
        section_body = section_body line "\n"
      }
    }

    END {
      flush_section()

      # Tri simple par score décroissant (bubble sort, volume très petit)
      for (i = 1; i <= section_count; i++) {
        for (j = i + 1; j <= section_count; j++) {
          if (section_score[j] > section_score[i]) {
            t = section_score[i]; section_score[i] = section_score[j]; section_score[j] = t
            th = section_header[i]; section_header[i] = section_header[j]; section_header[j] = th
            tc = section_content[i]; section_content[i] = section_content[j]; section_content[j] = tc
          }
        }
      }

      emitted = 0
      for (i = 1; i <= section_count && emitted < max_lines; i++) {
        print section_header[i]
        emitted++

        n = split(section_content[i], lines, /\n/)
        for (k = 1; k <= n && emitted < max_lines; k++) {
          l = trimmed(lines[k])
          if (l == "") continue
          print l
          emitted++
        }
        if (emitted < max_lines) {
          print ""
          emitted++
        }
      }

      if (emitted == 0) {
        for (i = 1; i <= fallback_count && emitted < max_lines; i++) {
          l = trimmed(fallback[i])
          if (l == "") continue
          print l
          emitted++
        }
      }
    }
  ' "$file" > "$out_file"
}

emit_file() {
  local title="$1" file="$2"
  [ -f "$file" ] || return 0
  extractive_summary "$file" "$TMP_SUMMARY"
  {
    printf '\n### %s (%s)\n' "$title" "${file#${IPCRAE_ROOT}/}"
    cat "$TMP_SUMMARY"
  } >> "$TMP_OUT"
}

{
  printf '# IPCRAE TokenPack\n'
  printf 'mode: %s\n' "$MODE"
  printf 'generated_at: %s\n' "$(date -Iseconds)"
  printf 'summary_mode: extractive-objectifs-contraintes-decisions\n'
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
