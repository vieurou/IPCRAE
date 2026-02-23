#!/usr/bin/env bash
set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-$HOME/IPCRAE}"
MODE="summary"
[ "${1:-}" = "--json" ] && MODE="json"

ok=0
warn=0
fail=0

pass() { ok=$((ok+1)); [ "$MODE" = "summary" ] && printf '✓ %s\n' "$1"; }
warning() { warn=$((warn+1)); [ "$MODE" = "summary" ] && printf '⚠ %s\n' "$1"; }
error() { fail=$((fail+1)); [ "$MODE" = "summary" ] && printf '✗ %s\n' "$1"; }

if [ -d "$IPCRAE_ROOT" ]; then
  pass "IPCRAE_ROOT accessible: $IPCRAE_ROOT"
else
  error "IPCRAE_ROOT inaccessible: $IPCRAE_ROOT"
fi

if [ -d "$IPCRAE_ROOT/Tasks/to_ai" ]; then
  count=$(find "$IPCRAE_ROOT/Tasks/to_ai" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  if [ "${count:-0}" -gt 0 ]; then
    pass "Capture user tasks available (${count})"
  else
    warning "No task files in Tasks/to_ai"
  fi
else
  warning "Tasks/to_ai missing"
fi

if [ -f "$IPCRAE_ROOT/Tasks/active_session.md" ]; then
  lines=$(wc -l < "$IPCRAE_ROOT/Tasks/active_session.md" | tr -d ' ')
  if [ "${lines:-0}" -gt 0 ]; then
    pass "Active session log present (${lines} lines)"
  else
    warning "Tasks/active_session.md is empty"
  fi
else
  warning "Tasks/active_session.md missing"
fi

if [ -f "$IPCRAE_ROOT/.ipcrae/session-context.md" ]; then
  size=$(wc -c < "$IPCRAE_ROOT/.ipcrae/session-context.md" | tr -d ' ')
  if [ "${size:-0}" -le 30000 ]; then
    pass "Session context bounded (${size} bytes)"
  else
    warning "Session context too large (${size} bytes)"
  fi
else
  error "Missing .ipcrae/session-context.md"
fi

if [ -d "$IPCRAE_ROOT/.ipcrae/auto/self-audits" ]; then
  latest=$(find "$IPCRAE_ROOT/.ipcrae/auto/self-audits" -maxdepth 1 -type f -name '*.md' | sort | tail -1)
  if [ -n "$latest" ]; then
    pass "Self-audit exists: ${latest#$IPCRAE_ROOT/}"
  else
    warning "No self-audit files found"
  fi
else
  warning "Self-audit directory missing"
fi

score=$(( ok*2 - fail*2 - warn ))
[ $score -lt 0 ] && score=0

if [ "$MODE" = "json" ]; then
  printf '{"ok":%d,"warn":%d,"fail":%d,"score":%d}\n' "$ok" "$warn" "$fail" "$score"
else
  printf 'Score strict: %d (ok=%d, warn=%d, fail=%d)\n' "$score" "$ok" "$warn" "$fail"
fi

if [ "$fail" -gt 0 ]; then
  exit 1
fi
