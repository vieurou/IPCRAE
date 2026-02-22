#!/usr/bin/env bash
set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
HUB_DIR="${IPCRAE_ROOT}/.ipcrae/multi-agent"
TASKS_FILE="${HUB_DIR}/tasks.tsv"
NOTIFY_FILE="${HUB_DIR}/notifications.log"
STATE_FILE="${HUB_DIR}/state.env"

usage() {
  cat <<'USAGE'
Usage: ipcrae-agent-hub <command> [args]

Commands:
  start <agent_id> [role]          Start or resume a shared session
  status                           Show current session state + open tasks
  task-add <title> [owner]         Add a task (status=todo)
  task-pick <task_id> <agent_id>   Mark task as in_progress
  task-done <task_id> <agent_id>   Mark task as done
  notify <from> <to> <message>     Add async notification
  stop <agent_id>                  Stop session (only lead can stop)

Notes:
- File-based protocol to let multiple providers coordinate in the same vault.
- Shared state: .ipcrae/multi-agent/
USAGE
}

ensure_layout() {
  mkdir -p "$HUB_DIR"
  [ -f "$TASKS_FILE" ] || printf 'id\ttitle\towner\tstatus\tupdated_at\n' > "$TASKS_FILE"
  [ -f "$NOTIFY_FILE" ] || touch "$NOTIFY_FILE"
  [ -f "$STATE_FILE" ] || cat > "$STATE_FILE" <<'STATE'
SESSION_ACTIVE=false
LEAD_AGENT=
STARTED_AT=
UPDATED_AT=
STATE
}

now_utc() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

load_state() { source "$STATE_FILE"; }

save_state() {
  cat > "$STATE_FILE" <<STATE
SESSION_ACTIVE=$SESSION_ACTIVE
LEAD_AGENT=$LEAD_AGENT
STARTED_AT=$STARTED_AT
UPDATED_AT=$UPDATED_AT
STATE
}

next_id() {
  awk -F'\t' 'NR==1{next} {if($1>m)m=$1} END{print (m+1)}' "$TASKS_FILE"
}

cmd_start() {
  local agent_id="${1:-}" role="${2:-lead}"
  [ -n "$agent_id" ] || { echo "Missing <agent_id>"; exit 1; }
  load_state
  if [ "$SESSION_ACTIVE" = "true" ]; then
    echo "Session active (lead=$LEAD_AGENT). $agent_id should run in assistant mode."
    exit 0
  fi
  SESSION_ACTIVE=true
  LEAD_AGENT="$agent_id"
  STARTED_AT="$(now_utc)"
  UPDATED_AT="$STARTED_AT"
  save_state
  printf '%s\tSYSTEM\t%s\tSession started (role=%s)\n' "$(now_utc)" "$agent_id" "$role" >> "$NOTIFY_FILE"
  echo "Session started. lead=$agent_id"
}

cmd_status() {
  load_state
  echo "SESSION_ACTIVE=$SESSION_ACTIVE"
  echo "LEAD_AGENT=$LEAD_AGENT"
  echo "STARTED_AT=$STARTED_AT"
  echo "UPDATED_AT=$UPDATED_AT"
  echo
  echo "Open tasks:"
  awk -F'\t' 'NR==1{next} $4!="done"{printf("- #%s [%s] %s (owner=%s, updated=%s)\n",$1,$4,$2,$3,$5)}' "$TASKS_FILE"
}

cmd_task_add() {
  local title="${1:-}" owner="${2:-unassigned}" id now
  [ -n "$title" ] || { echo "Missing <title>"; exit 1; }
  id="$(next_id)"
  now="$(now_utc)"
  printf '%s\t%s\t%s\ttodo\t%s\n' "$id" "$title" "$owner" "$now" >> "$TASKS_FILE"
  echo "Task #$id added."
}

rewrite_task() {
  local task_id="$1" agent_id="$2" target_status="$3" now tmp
  now="$(now_utc)"
  tmp="$(mktemp)"
  awk -F'\t' -v OFS='\t' -v id="$task_id" -v owner="$agent_id" -v status="$target_status" -v now="$now" '
    NR==1{print; next}
    $1==id{$3=owner; $4=status; $5=now}
    {print}
  ' "$TASKS_FILE" > "$tmp"
  mv "$tmp" "$TASKS_FILE"
  printf '%s\t%s\tALL\tTask #%s -> %s\n' "$now" "$agent_id" "$task_id" "$target_status" >> "$NOTIFY_FILE"
}

cmd_task_pick() {
  [ $# -eq 2 ] || { echo "Usage: task-pick <task_id> <agent_id>"; exit 1; }
  rewrite_task "$1" "$2" "in_progress"
  echo "Task #$1 picked by $2"
}

cmd_task_done() {
  [ $# -eq 2 ] || { echo "Usage: task-done <task_id> <agent_id>"; exit 1; }
  rewrite_task "$1" "$2" "done"
  echo "Task #$1 completed by $2"
}

cmd_notify() {
  [ $# -ge 3 ] || { echo "Usage: notify <from> <to> <message>"; exit 1; }
  local from="$1" to="$2"; shift 2
  printf '%s\t%s\t%s\t%s\n' "$(now_utc)" "$from" "$to" "$*" >> "$NOTIFY_FILE"
  echo "Notification written."
}

cmd_stop() {
  local agent_id="${1:-}"
  [ -n "$agent_id" ] || { echo "Missing <agent_id>"; exit 1; }
  load_state
  [ "$SESSION_ACTIVE" = "true" ] || { echo "No active session."; exit 0; }
  if [ "$agent_id" != "$LEAD_AGENT" ]; then
    echo "Only lead agent ($LEAD_AGENT) can stop this session."
    exit 1
  fi
  SESSION_ACTIVE=false
  UPDATED_AT="$(now_utc)"
  save_state
  printf '%s\tSYSTEM\t%s\tSession stopped\n' "$(now_utc)" "$agent_id" >> "$NOTIFY_FILE"
  echo "Session stopped."
}

main() {
  ensure_layout
  local cmd="${1:-}"
  shift || true
  case "$cmd" in
    start) cmd_start "$@" ;;
    status) cmd_status ;;
    task-add) cmd_task_add "$@" ;;
    task-pick) cmd_task_pick "$@" ;;
    task-done) cmd_task_done "$@" ;;
    notify) cmd_notify "$@" ;;
    stop) cmd_stop "$@" ;;
    -h|--help|help|"") usage ;;
    *) echo "Unknown command: $cmd"; usage; exit 1 ;;
  esac
}

main "$@"
