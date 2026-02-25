#!/usr/bin/env bash
set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
CACHE_DIR_DEFAULT="${IPCRAE_ROOT}/.ipcrae/cache/agent-bridge"
CACHE_DIR="$CACHE_DIR_DEFAULT"
CACHE_TTL_SECONDS="${CACHE_TTL_SECONDS:-86400}"
USE_CACHE=true

usage() {
  cat <<'USAGE'
Usage: ipcrae-agent-bridge.sh [options] <question>

Options:
  --all                Query all available providers (legacy compare mode)
  --provider <name>    Force provider (claude|gemini|codex)
  --no-cache           Disable cache read/write
  --ttl <seconds>      Cache TTL in seconds (default: 86400)
  --cache-dir <path>   Override cache directory
  -h, --help           Show help

Behavior:
- Detects available AI CLIs among claude/gemini/codex.
- Routes automatically to the best provider based on task intent.
- Uses cached responses per (provider + prompt) when fresh.
- Stores fresh responses to reduce repeated token usage.
USAGE
}

score_provider_for_question() {
  local provider="$1" question_lc="$2" score=0
  case "$provider" in
    codex)
      [[ "$question_lc" =~ (debug|bug|test|refactor|shell|bash|script|infra|docker|ci|cd|logs|stacktrace|error|terminal|commande) ]] && score=$((score + 3))
      ;;
    claude)
      [[ "$question_lc" =~ (architecture|arbitrage|strategy|stratégie|tradeoff|design|spec|spécification|decision|décision) ]] && score=$((score + 3))
      ;;
    gemini)
      [[ "$question_lc" =~ (workflow|checklist|synthese|synthèse|résumé|resume|plan|étapes|etapes|automation|automatisation) ]] && score=$((score + 3))
      ;;
  esac
  printf '%s' "$score"
}

pick_best_provider() {
  local question_lc="$1"
  shift
  local candidates=("$@")
  local best="${candidates[0]}" best_score=-1
  local p s
  for p in "${candidates[@]}"; do
    s="$(score_provider_for_question "$p" "$question_lc")"
    if [ "$s" -gt "$best_score" ]; then
      best_score="$s"
      best="$p"
    fi
  done
  printf '%s' "$best"
}

hash_text() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

now_epoch() {
  date +%s
}

cache_key() {
  local provider="$1" prompt="$2"
  printf '%s\n%s' "$provider" "$prompt" | hash_text
}

cache_file_for() {
  local key="$1"
  printf '%s/%s.txt' "$CACHE_DIR" "$key"
}

cache_meta_for() {
  local key="$1"
  printf '%s/%s.meta' "$CACHE_DIR" "$key"
}

cache_get() {
  local provider="$1" prompt="$2"
  local key data meta ts now age

  [ "$USE_CACHE" = true ] || return 1

  key="$(cache_key "$provider" "$prompt")"
  data="$(cache_file_for "$key")"
  meta="$(cache_meta_for "$key")"

  [ -f "$data" ] || return 1
  [ -f "$meta" ] || return 1

  ts="$(cat "$meta" 2>/dev/null || true)"
  [[ "$ts" =~ ^[0-9]+$ ]] || return 1

  now="$(now_epoch)"
  age=$(( now - ts ))
  [ "$age" -le "$CACHE_TTL_SECONDS" ] || return 1

  cat "$data"
}

cache_set() {
  local provider="$1" prompt="$2" response="$3"
  local key data meta

  [ "$USE_CACHE" = true ] || return 0

  mkdir -p "$CACHE_DIR"
  key="$(cache_key "$provider" "$prompt")"
  data="$(cache_file_for "$key")"
  meta="$(cache_meta_for "$key")"

  printf '%s\n' "$response" > "$data"
  now_epoch > "$meta"
}

run_provider() {
  local provider="$1" prompt="$2"
  case "$provider" in
    claude) claude "$prompt" ;;
    gemini) gemini "$prompt" ;;
    codex) codex "$prompt" ;;
    *) return 1 ;;
  esac
}

parse_args() {
  QUESTION=""
  QUERY_ALL=false
  FORCED_PROVIDER=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --all)
        QUERY_ALL=true
        shift
        ;;
      --provider)
        [ $# -ge 2 ] || { echo "Missing value for --provider"; exit 1; }
        FORCED_PROVIDER="$2"
        shift 2
        ;;
      --no-cache)
        USE_CACHE=false
        shift
        ;;
      --ttl)
        [ $# -ge 2 ] || { echo "Missing value for --ttl"; exit 1; }
        CACHE_TTL_SECONDS="$2"
        shift 2
        ;;
      --cache-dir)
        [ $# -ge 2 ] || { echo "Missing value for --cache-dir"; exit 1; }
        CACHE_DIR="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        QUESTION="$*"
        break
        ;;
      *)
        QUESTION="${QUESTION:+$QUESTION }$1"
        shift
        ;;
    esac
  done

  if [ -z "$QUESTION" ]; then
    echo "Usage: ipcrae-agent-bridge.sh [options] <question>"
    exit 1
  fi

  [[ "$CACHE_TTL_SECONDS" =~ ^[0-9]+$ ]] || { echo "Invalid --ttl value: $CACHE_TTL_SECONDS"; exit 1; }
}

parse_args "$@"

providers=()
for cmd in claude gemini codex; do
  if command -v "$cmd" >/dev/null 2>&1; then
    providers+=("$cmd")
  fi
done

if [ "${#providers[@]}" -eq 0 ]; then
  echo "No supported AI CLI found (claude/gemini/codex)."
  exit 2
fi

if [ -n "$FORCED_PROVIDER" ]; then
  if ! printf '%s\n' "${providers[@]}" | grep -qx "$FORCED_PROVIDER"; then
    echo "Requested provider not available: $FORCED_PROVIDER"
    exit 1
  fi
  providers=("$FORCED_PROVIDER")
elif [ "$QUERY_ALL" = false ]; then
  question_lc="$(printf '%s' "$QUESTION" | tr '[:upper:]' '[:lower:]')"
  routed_provider="$(pick_best_provider "$question_lc" "${providers[@]}")"
  providers=("$routed_provider")
fi

compact_prompt="IPCRAE mode. Réponse concise. Donne seulement actions + risques + prochaine commande.\nQuestion: ${QUESTION}"

for p in "${providers[@]}"; do
  printf "\n===== %s =====\n" "${p^^}"

  if cached_response="$(cache_get "$p" "$compact_prompt" 2>/dev/null)"; then
    echo "[CACHE HIT] provider=$p ttl=${CACHE_TTL_SECONDS}s"
    printf '%s\n' "$cached_response"
    continue
  fi

  if response="$(run_provider "$p" "$compact_prompt")"; then
    printf '%s\n' "$response"
    cache_set "$p" "$compact_prompt" "$response"
    echo "[CACHE WRITE] provider=$p"
  else
    echo "[WARN] provider failed: $p"
  fi
done
