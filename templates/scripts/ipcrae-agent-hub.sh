#!/usr/bin/env bash
set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
HUB_DIR="${IPCRAE_ROOT}/.ipcrae/multi-agent"
TASKS_FILE="${HUB_DIR}/tasks.tsv"
NOTIFY_FILE="${HUB_DIR}/notifications.log"
STATE_FILE="${HUB_DIR}/state.env"
AGENTS_FILE="${HUB_DIR}/agents.tsv"
LOCKS_FILE="${HUB_DIR}/locks.tsv"
HUB_LOCK_FILE="${HUB_DIR}/.hub.lock"

TASK_STALE_MIN="${IPCRAE_HUB_TASK_STALE_MIN:-90}"
AGENT_STALE_MIN="${IPCRAE_HUB_AGENT_STALE_MIN:-30}"
LOCK_TTL_MIN="${IPCRAE_HUB_LOCK_TTL_MIN:-30}"
LOCK_WAIT_SEC="${IPCRAE_HUB_LOCK_WAIT_SEC:-5}"

usage() {
  cat <<'USAGE'
Usage: ipcrae-agent-hub <command> [args]

Commands:
  start <agent_id> [lead|assist]                       Start or join a shared session
  status                                               Show session state + tasks + agents + locks
  heartbeat <agent_id> [role] [status] [task] [branch] [note...]
                                                       Update agent heartbeat / current task / branch
  task-add <title> [owner]                             Add a task (status=todo)
  task-pick <task_id> <agent_id> [--force]             Mark task as in_progress (anti-collision)
  task-touch <task_id> <agent_id> [note...]            Heartbeat on an in_progress task
  task-release <task_id> <agent_id> [note...]          Release task back to todo
  task-done <task_id> <agent_id>                       Mark task as done (owner check)
  reserve <agent_id> <resource> [task_id|-] [ttl_min] [note...]
                                                       Reserve a file/resource (lease)
  release <agent_id> <resource> [note...]              Release a resource reservation
  notify <from> <to> <message>                         Add async notification
  stop <agent_id>                                      Stop session (lead only)

Notes:
- File-based protocol to let multiple providers coordinate in the same vault.
- Shared state: .ipcrae/multi-agent/ (tasks.tsv, agents.tsv, locks.tsv, notifications.log)
- Use `heartbeat` + `reserve` before editing shared files to reduce collisions.
USAGE
}

ensure_layout() {
  mkdir -p "$HUB_DIR"
  [ -s "$TASKS_FILE" ] || printf 'id\ttitle\towner\tstatus\tupdated_at\n' > "$TASKS_FILE"
  [ -f "$NOTIFY_FILE" ] || touch "$NOTIFY_FILE"
  [ -s "$AGENTS_FILE" ] || printf 'agent_id\trole\tstatus\tcurrent_task\tbranch\tlast_seen_at\tnote\n' > "$AGENTS_FILE"
  [ -s "$LOCKS_FILE" ] || printf 'resource\tagent_id\ttask_id\tstatus\tupdated_at\texpires_at\tnote\n' > "$LOCKS_FILE"
  [ -f "$STATE_FILE" ] || cat > "$STATE_FILE" <<'STATE'
SESSION_ACTIVE=false
LEAD_AGENT=
STARTED_AT=
UPDATED_AT=
STATE
}

now_utc() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
epoch_now() { date -u +%s; }
iso_to_epoch() {
  local iso="${1:-}"
  [ -n "$iso" ] || { echo 0; return 0; }
  date -u -d "$iso" +%s 2>/dev/null || echo 0
}
add_minutes_iso() {
  local minutes="${1:-$LOCK_TTL_MIN}"
  date -u -d "+${minutes} minutes" +"%Y-%m-%dT%H:%M:%SZ"
}

sanitize_cell() {
  printf '%s' "${1:-}" | tr '\t' ' ' | tr '\n' ' '
}

load_state() { source "$STATE_FILE"; }

save_state() {
  cat > "$STATE_FILE" <<STATE
SESSION_ACTIVE=$SESSION_ACTIVE
LEAD_AGENT=$LEAD_AGENT
STARTED_AT=$STARTED_AT
UPDATED_AT=$UPDATED_AT
STATE
}

touch_state_updated() {
  load_state
  UPDATED_AT="$(now_utc)"
  save_state
}

with_lock() {
  if command -v flock >/dev/null 2>&1; then
    (
      exec 9>"$HUB_LOCK_FILE"
      flock -w "$LOCK_WAIT_SEC" 9 || { echo "Hub lock busy: another agent is writing shared state."; exit 1; }
      "$@"
    )
  else
    "$@"
  fi
}

next_id() {
  awk -F'\t' '
    NR==1 { next }
    $1 ~ /^task-[0-9]+$/ {
      n = $1
      sub(/^task-/, "", n)
      n += 0
      if (n > max_task) max_task = n
      saw_task = 1
      next
    }
    $1 ~ /^[0-9]+$/ {
      n = $1 + 0
      if (n > max_num) max_num = n
    }
    END {
      if (saw_task) {
        printf("task-%03d\n", max_task + 1)
      } else {
        print max_num + 1
      }
    }
  ' "$TASKS_FILE"
}

task_row() {
  local task_id="$1"
  awk -F'\t' -v id="$task_id" 'NR>1 && $1==id {print; exit}' "$TASKS_FILE"
}

task_exists() {
  local task_id="$1"
  awk -F'\t' -v id="$task_id" 'NR>1 && $1==id {found=1} END{exit found?0:1}' "$TASKS_FILE"
}

is_task_stale() {
  local updated_at="${1:-}" now ts
  now="$(epoch_now)"
  ts="$(iso_to_epoch "$updated_at")"
  [ "$ts" -gt 0 ] || return 0
  [ $(( now - ts )) -ge $(( TASK_STALE_MIN * 60 )) ]
}

agent_upsert() {
  local agent_id="$1" role="${2:--}" status="${3:--}" current_task="${4:--}" branch="${5:--}" note="${6:-}"
  local now tmp
  now="$(now_utc)"
  note="$(sanitize_cell "$note")"
  tmp="$(mktemp)"
  awk -F'\t' -v OFS='\t' \
    -v id="$agent_id" -v role="$role" -v status="$status" -v current_task="$current_task" -v branch="$branch" -v now="$now" -v note="$note" '
    NR==1 { print; next }
    $1==id {
      if (role != "-" && role != "") $2 = role;
      if (status != "-" && status != "") $3 = status;
      if (current_task != "-" && current_task != "") $4 = current_task;
      if (branch != "-" && branch != "") $5 = branch;
      $6 = now;
      if (note != "") $7 = note;
      found = 1;
    }
    { print }
    END {
      if (!found) {
        print id, (role=="-"?"assist":role), (status=="-"?"active":status), (current_task=="-"?"-":current_task), (branch=="-"?"-":branch), now, note;
      }
    }
  ' "$AGENTS_FILE" > "$tmp"
  mv "$tmp" "$AGENTS_FILE"
}

agent_mark_offline_all() {
  local now tmp
  now="$(now_utc)"
  tmp="$(mktemp)"
  awk -F'\t' -v OFS='\t' -v now="$now" '
    NR==1 { print; next }
    { $3="offline"; $6=now; print }
  ' "$AGENTS_FILE" > "$tmp"
  mv "$tmp" "$AGENTS_FILE"
}

get_agent_field() {
  local agent_id="$1" col="$2"
  awk -F'\t' -v id="$agent_id" -v c="$col" 'NR>1 && $1==id {print $c; exit}' "$AGENTS_FILE"
}

task_rewrite_row() {
  local task_id="$1" owner="$2" status="$3"
  local now tmp
  now="$(now_utc)"
  tmp="$(mktemp)"
  awk -F'\t' -v OFS='\t' -v id="$task_id" -v owner="$owner" -v status="$status" -v now="$now" '
    NR==1 { print; next }
    $1==id { $3=owner; $4=status; $5=now }
    { print }
  ' "$TASKS_FILE" > "$tmp"
  mv "$tmp" "$TASKS_FILE"
}

notify_append() {
  local from="$1" to="$2"; shift 2
  printf '%s\t%s\t%s\t%s\n' "$(now_utc)" "$from" "$to" "$*" >> "$NOTIFY_FILE"
}

lock_row() {
  local resource="$1"
  awk -F'\t' -v r="$resource" 'NR>1 && $1==r {print; exit}' "$LOCKS_FILE"
}

lock_is_active() {
  local status="$1" expires_at="$2" now ts
  [ "$status" = "locked" ] || return 1
  now="$(epoch_now)"
  ts="$(iso_to_epoch "$expires_at")"
  [ "$ts" -gt "$now" ]
}

lock_upsert() {
  local resource="$1" agent_id="$2" task_id="$3" status="$4" ttl_min="${5:-$LOCK_TTL_MIN}" note="${6:-}"
  local now expires_at tmp
  now="$(now_utc)"
  expires_at="$(add_minutes_iso "$ttl_min")"
  note="$(sanitize_cell "$note")"
  tmp="$(mktemp)"
  awk -F'\t' -v OFS='\t' \
    -v resource="$resource" -v agent_id="$agent_id" -v task_id="$task_id" -v status="$status" -v now="$now" -v expires_at="$expires_at" -v note="$note" '
    NR==1 { print; next }
    $1==resource {
      $2=agent_id; $3=task_id; $4=status; $5=now; $6=expires_at;
      if (note != "") $7=note;
      found=1;
    }
    { print }
    END {
      if (!found) print resource, agent_id, task_id, status, now, expires_at, note;
    }
  ' "$LOCKS_FILE" > "$tmp"
  mv "$tmp" "$LOCKS_FILE"
}

cmd_start_locked() {
  local agent_id="${1:-}" role="${2:-lead}"
  [ -n "$agent_id" ] || { echo "Missing <agent_id>"; exit 1; }
  load_state
  if [ "$SESSION_ACTIVE" = "true" ]; then
    if [ "$role" = "lead" ] && [ "$agent_id" != "$LEAD_AGENT" ]; then
      echo "Session active (lead=$LEAD_AGENT). Join as assistant instead."
      role="assist"
    fi
    agent_upsert "$agent_id" "$role" "active" "-" "-" "joined active session"
    UPDATED_AT="$(now_utc)"
    save_state
    notify_append "SYSTEM" "$agent_id" "Session join (role=${role})"
    echo "Session active (lead=$LEAD_AGENT). Registered $agent_id as $role."
    return 0
  fi

  SESSION_ACTIVE=true
  LEAD_AGENT="$agent_id"
  STARTED_AT="$(now_utc)"
  UPDATED_AT="$STARTED_AT"
  save_state
  agent_upsert "$agent_id" "${role:-lead}" "active" "-" "-" "session start"
  notify_append "SYSTEM" "$agent_id" "Session started (role=${role:-lead})"
  echo "Session started. lead=$agent_id"
}

cmd_start() {
  with_lock cmd_start_locked "$@"
}

cmd_status() {
  local now stale_cutoff
  load_state
  echo "SESSION_ACTIVE=$SESSION_ACTIVE"
  echo "LEAD_AGENT=$LEAD_AGENT"
  echo "STARTED_AT=$STARTED_AT"
  echo "UPDATED_AT=$UPDATED_AT"
  echo
  echo "Open tasks:"
  awk -F'\t' 'NR==1{next} $4!="done"{printf("- #%s [%s] %s (owner=%s, updated=%s)\n",$1,$4,$2,$3,$5)}' "$TASKS_FILE"

  echo
  echo "Agents (last heartbeat):"
  now="$(epoch_now)"
  stale_cutoff=$(( AGENT_STALE_MIN * 60 ))
  awk -F'\t' -v now="$now" -v cutoff="$stale_cutoff" '
    function iso2epoch(s, cmd, out) {
      gsub(/"/, "", s)
      if (s == "" || s == "-") return 0
      cmd = "date -u -d \"" s "\" +%s 2>/dev/null"
      cmd | getline out
      close(cmd)
      return out+0
    }
    NR==1{next}
    {
      ts=iso2epoch($6)
      state = ((ts>0 && (now-ts)<=cutoff) ? "fresh" : "stale")
      printf("- %s role=%s status=%s task=%s branch=%s heartbeat=%s (%s)\n",$1,$2,$3,$4,$5,$6,state)
      found=1
    }
    END { if (!found) print "- (none)" }
  ' "$AGENTS_FILE"

  echo
  echo "Active reservations:"
  awk -F'\t' -v now="$now" '
    function iso2epoch(s, cmd, out) {
      gsub(/"/, "", s)
      if (s == "" || s == "-") return 0
      cmd = "date -u -d \"" s "\" +%s 2>/dev/null"
      cmd | getline out
      close(cmd)
      return out+0
    }
    NR==1{next}
    {
      expiry=iso2epoch($6)
      if ($4=="locked" && expiry>now) {
        printf("- %s (agent=%s, task=%s, expires=%s)\n",$1,$2,$3,$6)
        found=1
      }
    }
    END { if (!found) print "- (none)" }
  ' "$LOCKS_FILE"
}

cmd_task_add_locked() {
  local title="${1:-}" owner="${2:-unassigned}" id now
  [ -n "$title" ] || { echo "Missing <title>"; exit 1; }
  title="$(sanitize_cell "$title")"
  owner="$(sanitize_cell "$owner")"
  id="$(next_id)"
  now="$(now_utc)"
  printf '%s\t%s\t%s\ttodo\t%s\n' "$id" "$title" "$owner" "$now" >> "$TASKS_FILE"
  notify_append "SYSTEM" "ALL" "Task #${id} added (${title})"
  touch_state_updated
  echo "Task #$id added."
}

cmd_task_add() {
  with_lock cmd_task_add_locked "$@"
}

cmd_task_pick_locked() {
  [ $# -ge 2 ] || { echo "Usage: task-pick <task_id> <agent_id> [--force]"; exit 1; }
  local task_id="$1" agent_id="$2" force="${3:-}" row owner status updated_at title
  row="$(task_row "$task_id")"
  [ -n "$row" ] || { echo "Task #$task_id not found."; exit 1; }

  IFS=$'\t' read -r _id title owner status updated_at <<< "$row"
  if [ "$status" = "done" ] && [ "$force" != "--force" ]; then
    echo "Task #$task_id is already done. Use --force to reopen ownership."
    exit 1
  fi
  if [ "$status" = "in_progress" ] && [ "$owner" != "$agent_id" ]; then
    if is_task_stale "$updated_at"; then
      if [ "$force" != "--force" ]; then
        echo "Task #$task_id is owned by $owner but appears stale (updated=$updated_at). Re-run with --force to take over."
        exit 1
      fi
    else
      echo "Task #$task_id is already in progress by $owner (updated=$updated_at)."
      exit 1
    fi
  fi

  task_rewrite_row "$task_id" "$agent_id" "in_progress"
  agent_upsert "$agent_id" "-" "busy" "$task_id" "-" "task-pick"
  notify_append "$agent_id" "ALL" "Task #${task_id} -> in_progress"
  touch_state_updated
  echo "Task #$task_id picked by $agent_id"
}

cmd_task_pick() {
  with_lock cmd_task_pick_locked "$@"
}

cmd_task_touch_locked() {
  [ $# -ge 2 ] || { echo "Usage: task-touch <task_id> <agent_id> [note...]"; exit 1; }
  local task_id="$1" agent_id="$2"; shift 2
  local note="${*:-heartbeat}" row owner status updated_at title
  row="$(task_row "$task_id")"
  [ -n "$row" ] || { echo "Task #$task_id not found."; exit 1; }
  IFS=$'\t' read -r _id title owner status updated_at <<< "$row"
  [ "$status" = "in_progress" ] || { echo "Task #$task_id is not in_progress (status=$status)."; exit 1; }
  [ "$owner" = "$agent_id" ] || { echo "Task #$task_id is owned by $owner, not $agent_id."; exit 1; }

  task_rewrite_row "$task_id" "$agent_id" "in_progress"
  agent_upsert "$agent_id" "-" "busy" "$task_id" "-" "$note"
  notify_append "$agent_id" "ALL" "Task #${task_id} heartbeat: $(sanitize_cell "$note")"
  touch_state_updated
  echo "Task #$task_id heartbeat updated by $agent_id"
}

cmd_task_touch() {
  with_lock cmd_task_touch_locked "$@"
}

cmd_task_release_locked() {
  [ $# -ge 2 ] || { echo "Usage: task-release <task_id> <agent_id> [note...]"; exit 1; }
  local task_id="$1" agent_id="$2"; shift 2
  local note="${*:-released}" row owner status updated_at title
  row="$(task_row "$task_id")"
  [ -n "$row" ] || { echo "Task #$task_id not found."; exit 1; }
  IFS=$'\t' read -r _id title owner status updated_at <<< "$row"
  [ "$owner" = "$agent_id" ] || { echo "Task #$task_id is owned by $owner, not $agent_id."; exit 1; }

  task_rewrite_row "$task_id" "unassigned" "todo"
  agent_upsert "$agent_id" "-" "idle" "-" "-" "task-release"
  notify_append "$agent_id" "ALL" "Task #${task_id} released: $(sanitize_cell "$note")"
  touch_state_updated
  echo "Task #$task_id released by $agent_id"
}

cmd_task_release() {
  with_lock cmd_task_release_locked "$@"
}

cmd_task_done_locked() {
  [ $# -eq 2 ] || { echo "Usage: task-done <task_id> <agent_id>"; exit 1; }
  local task_id="$1" agent_id="$2" row owner status updated_at title
  row="$(task_row "$task_id")"
  [ -n "$row" ] || { echo "Task #$task_id not found."; exit 1; }
  IFS=$'\t' read -r _id title owner status updated_at <<< "$row"
  [ "$owner" = "$agent_id" ] || { echo "Task #$task_id is owned by $owner, not $agent_id."; exit 1; }

  task_rewrite_row "$task_id" "$agent_id" "done"
  agent_upsert "$agent_id" "-" "idle" "-" "-" "task-done"
  notify_append "$agent_id" "ALL" "Task #${task_id} -> done"
  touch_state_updated
  echo "Task #$task_id completed by $agent_id"
}

cmd_task_done() {
  with_lock cmd_task_done_locked "$@"
}

cmd_reserve_locked() {
  [ $# -ge 2 ] || { echo "Usage: reserve <agent_id> <resource> [task_id|-] [ttl_min] [note...]"; exit 1; }
  local agent_id="$1" resource="$2"; shift 2
  local task_id="${1:--}" ttl="${2:-$LOCK_TTL_MIN}"
  local note="" row existing_agent existing_task existing_status existing_updated existing_exp existing_note
  if [ $# -ge 1 ]; then shift; fi
  if [ $# -ge 1 ]; then shift; fi
  note="${*:-}"
  resource="$(sanitize_cell "$resource")"
  [ -n "$resource" ] || { echo "Missing <resource>"; exit 1; }

  row="$(lock_row "$resource" || true)"
  if [ -n "$row" ]; then
    IFS=$'\t' read -r _r existing_agent existing_task existing_status existing_updated existing_exp existing_note <<< "$row"
    if [ "$existing_agent" != "$agent_id" ] && lock_is_active "$existing_status" "$existing_exp"; then
      echo "Resource already reserved by $existing_agent until $existing_exp: $resource"
      exit 1
    fi
  fi

  lock_upsert "$resource" "$agent_id" "$task_id" "locked" "$ttl" "$note"
  agent_upsert "$agent_id" "-" "busy" "${task_id:--}" "-" "reserve $(basename "$resource")"
  notify_append "$agent_id" "ALL" "Reserved ${resource} (task=${task_id:-"-"})"
  touch_state_updated
  echo "Reserved: $resource"
}

cmd_reserve() {
  with_lock cmd_reserve_locked "$@"
}

cmd_release_locked() {
  [ $# -ge 2 ] || { echo "Usage: release <agent_id> <resource> [note...]"; exit 1; }
  local agent_id="$1" resource="$2"; shift 2
  local note="${*:-released}" row existing_agent existing_task existing_status existing_updated existing_exp existing_note
  resource="$(sanitize_cell "$resource")"
  row="$(lock_row "$resource" || true)"
  [ -n "$row" ] || { echo "No reservation for: $resource"; exit 1; }

  IFS=$'\t' read -r _r existing_agent existing_task existing_status existing_updated existing_exp existing_note <<< "$row"
  if [ "$existing_agent" != "$agent_id" ] && lock_is_active "$existing_status" "$existing_exp"; then
    echo "Resource reserved by $existing_agent until $existing_exp: $resource"
    exit 1
  fi

  lock_upsert "$resource" "$agent_id" "${existing_task:--}" "released" "1" "$note"
  agent_upsert "$agent_id" "-" "active" "-" "-" "release $(basename "$resource")"
  notify_append "$agent_id" "ALL" "Released ${resource}"
  touch_state_updated
  echo "Released: $resource"
}

cmd_release() {
  with_lock cmd_release_locked "$@"
}

cmd_heartbeat_locked() {
  [ $# -ge 1 ] || { echo "Usage: heartbeat <agent_id> [role] [status] [task] [branch] [note...]"; exit 1; }
  local agent_id="$1" role="${2:--}" status="${3:--}" task="${4:--}" branch="${5:--}"
  shift || true
  [ $# -ge 1 ] && shift || true
  [ $# -ge 1 ] && shift || true
  [ $# -ge 1 ] && shift || true
  [ $# -ge 1 ] && shift || true
  local note="${*:-heartbeat}"
  agent_upsert "$agent_id" "$role" "$status" "$task" "$branch" "$note"
  touch_state_updated
  echo "Heartbeat updated for $agent_id"
}

cmd_heartbeat() {
  with_lock cmd_heartbeat_locked "$@"
}

cmd_notify_locked() {
  [ $# -ge 3 ] || { echo "Usage: notify <from> <to> <message>"; exit 1; }
  local from="$1" to="$2"; shift 2
  notify_append "$from" "$to" "$*"
  touch_state_updated
  echo "Notification written."
}

cmd_notify() {
  with_lock cmd_notify_locked "$@"
}

cmd_stop_locked() {
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
  agent_mark_offline_all
  notify_append "SYSTEM" "$agent_id" "Session stopped"
  echo "Session stopped."
}

cmd_stop() {
  with_lock cmd_stop_locked "$@"
}

main() {
  ensure_layout
  local cmd="${1:-}"
  shift || true
  case "$cmd" in
    start) cmd_start "$@" ;;
    status) cmd_status ;;
    heartbeat) cmd_heartbeat "$@" ;;
    task-add) cmd_task_add "$@" ;;
    task-pick) cmd_task_pick "$@" ;;
    task-touch) cmd_task_touch "$@" ;;
    task-release) cmd_task_release "$@" ;;
    task-done) cmd_task_done "$@" ;;
    reserve) cmd_reserve "$@" ;;
    release) cmd_release "$@" ;;
    notify) cmd_notify "$@" ;;
    stop) cmd_stop "$@" ;;
    -h|--help|help|"") usage ;;
    *) echo "Unknown command: $cmd"; usage; exit 1 ;;
  esac
}

main "$@"
