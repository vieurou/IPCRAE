---
type: knowledge
tags: [ipcrae, multi-agent, coordination, protocol, collaboration, hub]
domain: devops
status: stable
sources: [project:IPCRAE/templates/scripts/ipcrae-agent-hub.sh, project:IPCRAE/templates/prompts/core_multi_agent_protocol.md]
created: 2026-02-22
updated: 2026-02-23
---

# Multi-Agent IPCRAE — Protocole de Coordination

## Problème

Plusieurs agents IA (Claude, Gemini, Codex...) peuvent travailler sur le même vault simultanément.
Sans coordination, risques : conflits d'écriture, duplication de travail, tâches non suivies.

## Solution : ipcrae-agent-hub

Hub basé sur fichiers dans `.ipcrae/multi-agent/` — source de vérité partagée.

```
.ipcrae/multi-agent/
├── state.env         # SESSION_ACTIVE, LEAD_AGENT, STARTED_AT, UPDATED_AT
├── tasks.tsv         # id | title | owner | status | updated_at
├── agents.tsv        # heartbeats agents (role, status, task, branch, last_seen)
├── locks.tsv         # réservations de ressources (file/zone) avec TTL (lease)
└── notifications.log # messages asynchrones entre agents
```

## Rôles

| Rôle | Responsabilités |
|------|-----------------|
| **Lead** | Démarre/stoppe la session, consolide, clôture (`ipcrae close`) |
| **Assistant** | Prend des tâches, travaille, notifie lead quand terminé |

## Workflow Standard

### Agent qui démarre (Lead)
```bash
IPCRAE_ROOT=~/IPCRAE ipcrae-agent-hub start claude lead
# → Déclare la session, devient lead
# → Ajouter les tâches partagées
ipcrae-agent-hub task-add "Créer Knowledge/patterns/foo.md" claude
ipcrae-agent-hub task-add "Mettre à jour tracking USW" gemini
```

### Agent qui arrive (Assistant)
```bash
ipcrae-agent-hub status
# → Voit la session active + tâches disponibles
ipcrae-agent-hub task-pick <id> gemini
# → Prend la tâche, travaille, écrit dans les fichiers vault
ipcrae-agent-hub heartbeat gemini assist busy <id> - "work started"
ipcrae-agent-hub reserve gemini path/to/file.md <id> 30 "édition"
ipcrae-agent-hub task-touch <id> gemini "toujours actif"
ipcrae-agent-hub release gemini path/to/file.md
ipcrae-agent-hub task-done <id> gemini
ipcrae-agent-hub notify gemini claude "tracking USW mis à jour"
```

### Clôture (Lead)
```bash
ipcrae-agent-hub stop claude
# → Ferme la session
ipcrae close devops --project IPCRAE
```

## Commandes Référence

```bash
ipcrae-agent-hub status                    # État session + tâches ouvertes
ipcrae-agent-hub start <id> [lead|assist]  # Rejoindre/démarrer session
ipcrae-agent-hub task-add <titre> [owner]  # Créer tâche
ipcrae-agent-hub task-pick <id> <agent>    # Prendre tâche (refuse collision)
ipcrae-agent-hub task-pick <id> <agent> --force # Reprise explicite si tâche stale
ipcrae-agent-hub task-touch <id> <agent>   # Heartbeat de tâche en cours
ipcrae-agent-hub task-release <id> <agent> # Relâcher tâche vers todo
ipcrae-agent-hub task-done <id> <agent>    # Marquer terminée
ipcrae-agent-hub heartbeat <agent> ...     # Heartbeat agent (task/branch)
ipcrae-agent-hub reserve <agent> <resource> [task] [ttl] [note]  # Lease ressource
ipcrae-agent-hub release <agent> <resource>                      # Fin de lease
ipcrae-agent-hub notify <from> <to> <msg>  # Notification async
ipcrae-agent-hub stop <id>                 # Stopper session (lead seulement)
```

## Intégration dans `ipcrae start`

`ipcrae start` vérifie automatiquement l'état du hub :
- Session active → affiche `🤝 Multi-agent : session active`
- Pas de session → message d'invitation à démarrer

## Règles Anti-Collision

1. **Source de vérité = fichiers vault** (pas le contexte IA)
2. **1 tâche = 1 owner** à la fois (enforcement via `task-pick`)
3. **Heartbeats obligatoires** sur tâches longues : `task-touch` + `heartbeat`
4. **Réserver la ressource avant édition** (`reserve <resource>`) pour les fichiers partagés
5. **Takeover explicite seulement si stale** (`task-pick ... --force`)
6. **Lead consolide** toujours en dernier avant `ipcrae close`

## Règle Git par type de dépôt (important)

- **Repo code (`~/DEV/IPCRAE`)** : **feature branch par changement logique** (oui, cette règle existe toujours).
  - Déclarer la branche dans `agents.tsv` via `heartbeat ... <branch>`
  - Exemple : `feature/hub-task-reservation-leases`
- **Vault/cerveau (`~/IPCRAE`)** : **pas de feature branch** (commits directs sur `main`), donc la protection contre collisions se fait par :
  - `tasks.tsv` (ownership),
  - `agents.tsv` (heartbeat / signalement),
  - `locks.tsv` (réservation fichier/ressource),
  - consolidation lead en fin de session.

## Erreurs connues / récupération

- Si un agent tombe sans `stop` → `state.env` peut rester `SESSION_ACTIVE=true`
- Si une tâche reste `in_progress` sans heartbeat récent → elle devient **stale** (reprise possible avec `task-pick ... --force`)
- Si une réservation expire → un autre agent peut reprendre la ressource (TTL/lease)

## Liens

- [[core_multi_agent_protocol]] — Prompt pour agents (dans `.ipcrae/prompts/`)
- [[ipcrae-sync-providers]] — Sync CLAUDE.md après changements instructions
- [[session-start IPCRAE]] — Workflow démarrage session
