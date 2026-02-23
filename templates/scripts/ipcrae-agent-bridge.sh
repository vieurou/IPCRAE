#!/usr/bin/env bash
set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
CACHE_DIR_DEFAULT="${IPCRAE_ROOT}/.ipcrae/cache/agent-bridge"
CACHE_DIR="$CACHE_DIR_DEFAULT"
CACHE_TTL_SECONDS="${CACHE_TTL_SECONDS:-86400}"
USE_CACHE=true
HARD_CAP_WORDS="${HARD_CAP_WORDS:-260}"
METRICS_FILE=""
ROUTING_FILE=""
QUALITY_COST_FILE=""
CONTEXT_FINGERPRINT_FILES="${CONTEXT_FINGERPRINT_FILES:-${IPCRAE_ROOT}/.ipcrae/context.md:${IPCRAE_ROOT}/.ipcrae/instructions.md:${IPCRAE_ROOT}/Phases/index.md:${IPCRAE_ROOT}/Inbox/waiting-for.md}"

usage() {
  cat <<'USAGE'
Usage: ipcrae-agent-bridge.sh [options] <question>

Options:
  --all                Query all available providers (legacy compare mode)
  --provider <name>    Force provider (claude|gemini|codex)
  --no-cache           Disable cache read/write
  --ttl <seconds>      Cache TTL in seconds (default: 86400)
  --cache-dir <path>   Override cache directory
  --hard-cap <words>   Enforce a max word count on provider output
  -h, --help           Show help

Behavior:
- Detects available AI CLIs among claude/gemini/codex.
- Routes automatically to the best provider based on task intent and past outcomes.
- Uses cached responses per (provider + prompt + context fingerprint) when fresh.
- Scores quality/cost and records metrics for continuous routing improvement.
USAGE
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

classify_task_type() {
  local question_lc="$1"
  if [[ "$question_lc" =~ (debug|bug|test|refactor|shell|bash|script|infra|docker|ci|cd|logs|stacktrace|error|terminal|commande) ]]; then
    printf 'debug'
  elif [[ "$question_lc" =~ (architecture|arbitrage|strategy|stratégie|tradeoff|design|spec|spécification|decision|décision) ]]; then
    printf 'archi'
  elif [[ "$question_lc" =~ (workflow|checklist|synthese|synthèse|résumé|resume|plan|étapes|etapes|automation|automatisation) ]]; then
    printf 'synthese'
  else
    printf 'general'
  fi
}

budget_for_task_type() {
  local task_type="$1"
  case "$task_type" in
    debug) printf '180' ;;
    archi) printf '260' ;;
    synthese) printf '140' ;;
    *) printf '180' ;;
  esac
}

cap_words() {
  local text="$1" word_cap="$2"
  awk -v cap="$word_cap" '
    {
      for (i=1; i<=NF; i++) {
        count++
        if (count <= cap) {
          printf "%s%s", (count==1?"":" "), $i
        }
      }
    }
    END {
      if (count > cap) printf "\n[TRUNCATED to %d words by hard cap]", cap
      printf "\n"
    }
  ' <<< "$text"
}

context_fingerprint() {
  local joined=""
  IFS=':' read -r -a files <<< "$CONTEXT_FINGERPRINT_FILES"
  local f
  for f in "${files[@]}"; do
    if [ -f "$f" ]; then
      joined+="FILE:${f}\n"
      joined+="$(sha256sum "$f" | awk '{print $1}')\n"
    else
      joined+="MISSING:${f}\n"
    fi
  done
  printf '%b' "$joined" | hash_text
}

dynamic_score_boost() {
  local provider="$1" task_type="$2"
  [ -f "$ROUTING_FILE" ] || { printf '0'; return; }

  awk -F'|' -v p="$provider" -v t="$task_type" '
    $1==p && $2==t {
      runs=$3+0
      success=$4+0
      avg_value=$7+0
      if (runs <= 0) { print 0; exit }
      # feedback blend: success rate + value ratio
      rate = success / runs
      boost = int((rate * 3.0) + (avg_value * 2.0))
      print boost
      exit
    }
    END { if (NR==0) print 0 }
  ' "$ROUTING_FILE"
}

score_provider_for_question() {
  local provider="$1" question_lc="$2" task_type="$3" score=0 dyn=0
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

  dyn="$(dynamic_score_boost "$provider" "$task_type")"
  [[ "$dyn" =~ ^-?[0-9]+$ ]] || dyn=0
  score=$((score + dyn))
  printf '%s' "$score"
}

pick_best_provider() {
  local question_lc="$1" task_type="$2"
  shift 2
  local candidates=("$@")
  local best="${candidates[0]}" best_score=-999
  local p s
  for p in "${candidates[@]}"; do
    s="$(score_provider_for_question "$p" "$question_lc" "$task_type")"
    if [ "$s" -gt "$best_score" ]; then
      best_score="$s"
      best="$p"
    fi
  done
  printf '%s' "$best"
}

cache_key() {
  local provider="$1" prompt="$2" fingerprint="$3"
  printf '%s\n%s\n%s' "$provider" "$fingerprint" "$prompt" | hash_text
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
  local provider="$1" prompt="$2" fingerprint="$3"
  local key data meta ts now age

  [ "$USE_CACHE" = true ] || return 1

  key="$(cache_key "$provider" "$prompt" "$fingerprint")"
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
  local provider="$1" prompt="$2" fingerprint="$3" response="$4"
  local key data meta

  [ "$USE_CACHE" = true ] || return 0

  mkdir -p "$CACHE_DIR"
  key="$(cache_key "$provider" "$prompt" "$fingerprint")"
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

compute_quality_score() {
  local response="$1"
  local quality=0
  local lower
  lower="$(printf '%s' "$response" | tr '[:upper:]' '[:lower:]')"

  [[ "$lower" =~ (quick\ win|plan|next|prochaine\ commande|action|étape|etape|risque|validation|test) ]] && quality=$((quality + 4))
  [[ "$lower" =~ ("non vérifié"|incertitude|hypothèse|hypothese|limite) ]] && quality=$((quality + 1))
  [[ "$lower" =~ (je\ ne\ sais\ pas|impossible) ]] && quality=$((quality - 2))

  local lines
  lines=$(printf '%s\n' "$response" | sed '/^\s*$/d' | wc -l | tr -d ' ')
  if [ "$lines" -ge 4 ] && [ "$lines" -le 40 ]; then
    quality=$((quality + 2))
  fi

  [ "$quality" -lt 0 ] && quality=0
  printf '%s' "$quality"
}

compute_cost_proxy() {
  local response="$1"
  local chars words
  chars=$(printf '%s' "$response" | wc -c | tr -d ' ')
  words=$(printf '%s' "$response" | wc -w | tr -d ' ')
  # proxy simple: 1 point per 220 chars + 1 per 60 words
  printf '%s' $(( (chars / 220) + (words / 60) + 1 ))
}

record_feedback() {
  local provider="$1" task_type="$2" success="$3" quality="$4" cost="$5"
  mkdir -p "$CACHE_DIR"

  local tmp_stats
  tmp_stats=$(mktemp)
  trap 'rm -f "$tmp_stats"' RETURN

  if [ -f "$ROUTING_FILE" ]; then
    awk -F'|' -v p="$provider" -v t="$task_type" -v s="$success" -v q="$quality" -v c="$cost" '
      BEGIN { updated=0 }
      {
        if ($1==p && $2==t) {
          runs=$3+1
          succ=$4+s
          qsum=$5+q
          csum=$6+c
          avg=(csum>0)?(qsum/csum):0
          printf "%s|%s|%d|%d|%d|%d|%.4f\n", p,t,runs,succ,qsum,csum,avg
          updated=1
        } else {
          print $0
        }
      }
      END {
        if (!updated) {
          runs=1; succ=s; qsum=q; csum=c; avg=(csum>0)?(qsum/csum):0
          printf "%s|%s|%d|%d|%d|%d|%.4f\n", p,t,runs,succ,qsum,csum,avg
        }
      }
    ' "$ROUTING_FILE" > "$tmp_stats"
  else
    avg=$(awk -v q="$quality" -v c="$cost" 'BEGIN{ if(c>0) printf "%.4f", q/c; else printf "0" }')
    printf '%s|%s|1|%s|%s|%s|%s\n' "$provider" "$task_type" "$success" "$quality" "$cost" "$avg" > "$tmp_stats"
  fi

  mv "$tmp_stats" "$ROUTING_FILE"

  printf '%s|%s|%s|%s|%s|%s\n' "$(date -Iseconds)" "$provider" "$task_type" "$success" "$quality" "$cost" >> "$METRICS_FILE"
  avg_value=$(awk -v q="$quality" -v c="$cost" 'BEGIN{ if(c>0) printf "%.4f", q/c; else printf "0" }')
  printf '%s|%s|%s|%s|%s|%s\n' "$(date -Iseconds)" "$provider" "$task_type" "$quality" "$cost" "$avg_value" >> "$QUALITY_COST_FILE"
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
      --hard-cap)
        [ $# -ge 2 ] || { echo "Missing value for --hard-cap"; exit 1; }
        HARD_CAP_WORDS="$2"
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
  [[ "$HARD_CAP_WORDS" =~ ^[0-9]+$ ]] || { echo "Invalid --hard-cap value: $HARD_CAP_WORDS"; exit 1; }
}

parse_args "$@"

mkdir -p "$CACHE_DIR"
METRICS_FILE="$CACHE_DIR/metrics.log"
ROUTING_FILE="$CACHE_DIR/routing-feedback.tsv"
QUALITY_COST_FILE="$CACHE_DIR/quality-cost.log"

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

question_lc="$(printf '%s' "$QUESTION" | tr '[:upper:]' '[:lower:]')"
task_type="$(classify_task_type "$question_lc")"
soft_budget="$(budget_for_task_type "$task_type")"
if [ "$soft_budget" -gt "$HARD_CAP_WORDS" ]; then
  soft_budget="$HARD_CAP_WORDS"
fi

if [ -n "$FORCED_PROVIDER" ]; then
  if ! printf '%s\n' "${providers[@]}" | grep -qx "$FORCED_PROVIDER"; then
    echo "Requested provider not available: $FORCED_PROVIDER"
    exit 1
  fi
  providers=("$FORCED_PROVIDER")
elif [ "$QUERY_ALL" = false ]; then
  routed_provider="$(pick_best_provider "$question_lc" "$task_type" "${providers[@]}")"
  providers=("$routed_provider")
fi

ctx_fp="$(context_fingerprint)"
compact_prompt="IPCRAE mode. Réponse concise et actionnable. Type de tâche: ${task_type}. Réponse <= ${soft_budget} mots (hard cap ${HARD_CAP_WORDS}). Donne seulement actions + risques + prochaine commande.\nQuestion: ${QUESTION}"

for p in "${providers[@]}"; do
  printf "\n===== %s =====\n" "${p^^}"

  if cached_response="$(cache_get "$p" "$compact_prompt" "$ctx_fp" 2>/dev/null)"; then
    echo "[CACHE HIT] provider=$p ttl=${CACHE_TTL_SECONDS}s ctx_fp=${ctx_fp:0:12}"
    printf '%s\n' "$cached_response"

    q="$(compute_quality_score "$cached_response")"
    c="$(compute_cost_proxy "$cached_response")"
    record_feedback "$p" "$task_type" 1 "$q" "$c"
    continue
  fi

  if response="$(run_provider "$p" "$compact_prompt")"; then
    capped="$(cap_words "$response" "$HARD_CAP_WORDS")"
    printf '%s\n' "$capped"
    cache_set "$p" "$compact_prompt" "$ctx_fp" "$capped"
    echo "[CACHE WRITE] provider=$p ctx_fp=${ctx_fp:0:12} task_type=$task_type budget=$soft_budget"

    q="$(compute_quality_score "$capped")"
    c="$(compute_cost_proxy "$capped")"
    record_feedback "$p" "$task_type" 1 "$q" "$c"
  else
    echo "[WARN] provider failed: $p"
    record_feedback "$p" "$task_type" 0 0 1
  fi
done
