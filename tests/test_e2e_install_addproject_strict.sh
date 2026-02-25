#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BRAIN_ROOT="$(mktemp -d)"
DUMMY_REPO="$(mktemp -d)"

cleanup() {
  rm -rf "$BRAIN_ROOT" "$DUMMY_REPO"
}
trap cleanup EXIT

bash "$REPO_ROOT/ipcrae-install.sh" -y "$BRAIN_ROOT" >/dev/null

mkdir -p "$DUMMY_REPO"
cd "$DUMMY_REPO"
git init -b main >/dev/null

IPCRAE_ROOT="$BRAIN_ROOT" bash "$REPO_ROOT/templates/ipcrae-addProject.sh" -y >/dev/null

# Invariants addProject + strict mode bootstrap
[ -L ".ipcrae-memory" ]
[ "$(readlink .ipcrae-memory)" = "$BRAIN_ROOT" ]
[ -f "$BRAIN_ROOT/.ipcrae/session-context.md" ]
[ -f "$BRAIN_ROOT/Tasks/active_session.md" ]
[ -d "$BRAIN_ROOT/.ipcrae/auto/self-audits" ]

expected_hook_line="_IPCRAE_ROOT=\"\${IPCRAE_ROOT:-$BRAIN_ROOT}\""
grep -Fq "$expected_hook_line" .git/hooks/post-commit

IPCRAE_ROOT="$BRAIN_ROOT" "$HOME/bin/ipcrae-strict-check" >/tmp/ipcrae-strict-e2e.log

echo "E2E install+addProject+strict-check: OK"
