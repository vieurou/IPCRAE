---
type: process
tags: [ipcrae, boot, session, inbox, auto-amelioration, process]
domain: all
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Process — Boot Session IPCRAE

## Déclencheur
**Automatique** : à chaque démarrage de session IA via `ipcrae start`
**Manuel** : `ipcrae-inbox-scan` seul pour vérifier sans démarrer de session

## Architecture boot (2 couches)

```
COUCHE 1 — Bash pur (zéro IA, immédiat)
  └─ ipcrae-inbox-scan
       ├─ Scanne Inbox/ (tous sous-dossiers)
       ├─ Génère .ipcrae/auto/inbox-pending.md
       ├─ Crée flag .ipcrae/auto/inbox-needs-processing
       └─ Exit 0 (rien) | 1 (items en attente)

COUCHE 2 — Agent IA (si flag présent)
  └─ L'agent lit inbox-pending.md au démarrage
       ├─ Traite les fichiers selon Process/inbox-scan.md
       ├─ Supprime le flag après traitement
       └─ Archive dans Inbox/<dossier>/traites/
```

## Checklist

### Phase 1 : Scan bash (automatique, < 1 seconde)
- [ ] `ipcrae-inbox-scan` appelé par `ipcrae start`
- [ ] Scanne tous les sous-dossiers de `Inbox/`
- [ ] Ignore `README.md` et dossiers `traites/`
- [ ] Si items détectés → crée `inbox-pending.md` + flag `inbox-needs-processing`
- [ ] Affiche le résumé dans le terminal

### Phase 2 : Traitement agent (si flag présent)
- [ ] Agent lit `.ipcrae/auto/inbox-pending.md`
- [ ] Lit les préférences d'agent : `.ipcrae/auto/inbox-agent-prefs.yaml`
- [ ] Traite chaque fichier selon `Process/inbox-scan.md`
- [ ] Supprime le flag après traitement complet
- [ ] Commit le vault (`ipcrae close`)

### Phase 3 : Session normale
- [ ] Lire `.ipcrae/context.md` → projets en cours, working set
- [ ] Lire `memory/<domaine>.md` → contraintes, décisions
- [ ] Lire `Projets/<slug>/tracking.md` → backlog, tâches en cours
- [ ] Capturer la demande brute : `ipcrae-capture-request "..."` (si demande complexe)

## Sorties attendues
- `inbox-pending.md` mis à jour (ou supprimé si rien)
- Flag supprimé après traitement
- Session démarrée avec contexte chargé

## Implémentation actuelle
- Script : `~/bin/ipcrae-inbox-scan` ✅
- Intégré dans `cmd_start` de `~/bin/ipcrae` ✅
- Préférences agent : `.ipcrae/auto/inbox-agent-prefs.yaml` (créé au 1er scan)
- Capture demande : `~/bin/ipcrae-capture-request` ✅

## Évolutions prévues
- [ ] Cron quotidien : `ipcrae-inbox-scan` à 08h00 (ajouter à crontab)
- [ ] Hook Claude Code : capture automatique de la demande initiale (settings.json)
- [ ] `ipcrae inbox scan` → commande intégrée dans le launcher

## Agent IA recommandé
Agent adapté au contenu détecté (défaut: `claude`)
Préférences stockées dans `.ipcrae/auto/inbox-agent-prefs.yaml`
