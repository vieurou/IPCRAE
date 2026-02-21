#!/usr/bin/env bash
set -euo pipefail

ROOT="$(mktemp -d)"
trap 'rm -rf "$ROOT"' EXIT

mkdir -p "$ROOT/.ipcrae" "$ROOT/Knowledge" "$ROOT/Process/manual"
cat > "$ROOT/Knowledge/note.md" <<'MD'
---
tags: [process, project:ipcrae]
project: ipcrae
---

# Note
MD

cat > "$ROOT/Process/manual/inbox-triage.md" <<'MD'
# Process — Inbox triage

## 7) Paramètres d’exécution (agent spec)
- **Agent** : agent_devops
- **Context tags** : [process, project:ipcrae]
- **Output path** : Journal/Daily/YYYY/YYYY-MM-DD-process-[slug].md
- **Collector script (optionnel)** :

## 8) Dernière exécution
- **Date** :
- **Résumé** :
- **Fichier produit** :
MD

IPCRAE_ROOT="$ROOT" EDITOR=true bash templates/ipcrae-launcher.sh index >/dev/null
out=$(IPCRAE_ROOT="$ROOT" EDITOR=true bash templates/ipcrae-launcher.sh tag process)
[[ "$out" == *"Knowledge/note.md"* ]]
out=$(IPCRAE_ROOT="$ROOT" EDITOR=true bash templates/ipcrae-launcher.sh search process)
[[ "$out" == *"Knowledge/note.md"* ]]
out=$(IPCRAE_ROOT="$ROOT" EDITOR=true bash templates/ipcrae-launcher.sh process run --dry-run inbox-triage)
[[ "$out" == *"Agent recommandé: agent_devops"* ]]

echo "smoke ok"
