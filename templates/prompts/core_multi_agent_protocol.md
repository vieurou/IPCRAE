# IPCRAE — Protocole Multi-Agents (Lead + Assistants)

## Objectif
Permettre à plusieurs agents IA (providers différents) de collaborer sur le même vault sans collisions.

## Démarrage standard
1. Exécuter `ipcrae-agent-hub status`.
2. Si session active:
   - passer en mode **assistant**,
   - prendre une tâche via `ipcrae-agent-hub task-pick <id> <agent_id>`.
   - annoncer son état via `ipcrae-agent-hub heartbeat <agent_id> assist active - - "joined"`.
3. Sinon:
   - démarrer la session en **lead** avec `ipcrae-agent-hub start <agent_id>`.
   - créer/déléguer les tâches puis notifier les assistants.

## Contrat d'échange
- Une tâche = un owner explicite + un statut (`todo`, `in_progress`, `done`).
- Chaque résultat est écrit dans les fichiers du projet (source de vérité).
- Chaque passage de relais génère une notification `ipcrae-agent-hub notify`.
- Pour les tâches longues : maintenir un heartbeat (`task-touch` et/ou `heartbeat`).
- Avant d'éditer un fichier/ressource partagé(e) : réserver via `ipcrae-agent-hub reserve`.
- Une reprise de tâche d'un autre agent n'est autorisée que si la tâche est stale et explicitement forcée (`task-pick ... --force`).

## Règle Git par dépôt (anti-collision)
- **Repo code (`~/DEV/IPCRAE`)** : feature branch par changement logique, déclarée dans `heartbeat` (champ `branch`).
- **Vault (`~/IPCRAE`)** : pas de feature branch ; utiliser ownership de tâche + réservations (`locks.tsv`) + consolidation lead.

## Fin de session
- Le lead consolide les changements.
- Le lead clôture avec `ipcrae-agent-hub stop <agent_id>`.
