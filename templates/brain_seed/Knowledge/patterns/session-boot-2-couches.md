---
type: knowledge
tags: [session, boot, bash, automatisation, ipcrae, pattern]
domain: devops
status: active
sources:
  - project:IPCRAE/Process/session-boot.md
  - project:IPCRAE/scripts/ipcrae-inbox-scan.sh
created: 2026-02-22
updated: 2026-02-22
---

# Pattern : Boot session IPCRAE en 2 couches

## Concept
Tout démarrage de session IA doit passer par 2 couches séparées : d'abord une vérification bash **sans IA** (rapide, fiable), puis si nécessaire une couche IA (lente, coûteuse). Ne jamais appeler l'IA pour des tâches purement mécaniques.

## Pattern

```
COUCHE 1 — Bash pur (0 tokens, < 1s)
  Rôle : vérifier l'état du système
  Outils : scripts shell, find, stat, jq/python3
  Outputs : flags, rapports JSON/Markdown

COUCHE 2 — Agent IA (si flag levé)
  Rôle : analyser + décider + agir
  Déclencheur : flag présent dans .ipcrae/auto/
  Inputs : rapport de la couche 1
```

## Implémentation IPCRAE

```bash
# Couche 1 (dans cmd_start) :
ipcrae-inbox-scan --quiet "$IPCRAE_ROOT"
# → crée .ipcrae/auto/inbox-needs-processing si items détectés

# Couche 2 (l'agent lit le flag au démarrage) :
if [ -f "$IPCRAE_ROOT/.ipcrae/auto/inbox-needs-processing" ]; then
  # Traiter Inbox selon Process/inbox-scan.md
fi
```

## Généralisation du pattern
Ce pattern s'applique à tout mécanisme de "détection avant action" :
- **inbox-scan** : détecte fichiers → agent traite
- **moc-auto** : détecte clusters → crée MOC
- **audit-check** : mesure score → agent corrige si < seuil
- **health-check** : détecte anomalies → agent résout

## Avantages
- Couche 1 jamais bloquée par quotas API
- Couche 2 toujours informée (contexte pré-chargé)
- Idempotent : re-run donne même résultat
- Testable unitairement (bash pur = bats-core)

## Liens
- [[inbox-scan-automatique]] — Implémentation pour l'Inbox
- [[moc-generation-automatique]] — Implémentation pour les MOC
- [[Process/session-boot]] — Process de boot complet
