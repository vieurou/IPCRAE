---
type: knowledge
tags: [ipcrae, runbook, audit, auto-amelioration]
project: IPCRAE
domain: devops
status: stable
sources:
  - path: scripts/ipcrae-audit-check.sh
  - path: scripts/auto_audit.sh
  - path: templates/prompts/template_auto_amelioration.md
created: 2026-02-23
updated: 2026-02-23
---

# Runbook — Audit & Auto-amélioration

## Activation
`ipcrae-auto auto-activate --agent codex --frequency quotidien`

## Audit
`ipcrae-audit-check`

## Cycle forcé
`ipcrae-auto auto-audit --agent codex --verbose --force`

## Lecture des résultats
- Score global
- gaps critiques/importants/mineurs
- plan de correction priorisé
