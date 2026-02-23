#!/usr/bin/env bash
set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-$HOME/IPCRAE}"
HISTORY_FILE="$IPCRAE_ROOT/.ipcrae/auto/strict-check-history.md"
LIMIT="${1:-10}"

if ! [[ "$LIMIT" =~ ^[0-9]+$ ]]; then
  LIMIT=10
fi

if [ ! -f "$HISTORY_FILE" ]; then
  echo "Aucun historique strict-check trouvé: $HISTORY_FILE"
  exit 0
fi

python3 - "$HISTORY_FILE" "$LIMIT" <<'PY'
import re
import sys
from pathlib import Path

history = Path(sys.argv[1]).read_text(encoding='utf-8', errors='ignore')
limit = int(sys.argv[2])

blocks = [b.strip() for b in history.split('## ') if b.strip()]
entries = []
for block in blocks:
    lines = block.splitlines()
    ts = lines[0].strip() if lines else '?'
    score = None
    owf = None
    rec = ''
    for ln in lines[1:]:
        m = re.search(r'- Score:\s*(\d+)', ln)
        if m:
            score = int(m.group(1))
        m = re.search(r'- OK/WARN/FAIL:\s*(\d+)/(\d+)/(\d+)', ln)
        if m:
            owf = tuple(map(int, m.groups()))
        if ln.startswith('- Recommandation:'):
            rec = ln.split(':', 1)[1].strip()
    entries.append((ts, score, owf, rec))

if not entries:
    print('Historique strict-check vide.')
    sys.exit(0)

entries = entries[-limit:]
valid_scores = [e[1] for e in entries if isinstance(e[1], int)]
if not valid_scores:
    print('Scores introuvables dans l\'historique.')
    sys.exit(0)

first = valid_scores[0]
last = valid_scores[-1]
delta = last - first
trend = 'stable'
if delta > 0:
    trend = 'amélioration'
elif delta < 0:
    trend = 'régression'

avg = sum(valid_scores) / len(valid_scores)

print('=== Strict Report ===')
print(f'Entrées analysées: {len(entries)} (fenêtre={limit})')
print(f'Score moyen: {avg:.2f}')
print(f'Dernier score: {last}')
print(f'Delta période: {delta:+d} ({trend})')
print('\nDernières exécutions:')
for ts, score, owf, rec in entries[-5:]:
    owf_txt = f"OK/WARN/FAIL={owf[0]}/{owf[1]}/{owf[2]}" if owf else 'OK/WARN/FAIL=?'
    print(f'- {ts} | score={score if score is not None else "?"} | {owf_txt}')

if entries[-1][3]:
    print(f'\nRecommandation actuelle: {entries[-1][3]}')
PY
