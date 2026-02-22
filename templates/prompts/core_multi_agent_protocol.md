# IPCRAE — Protocole Multi-Agents (Lead + Assistants)

## Objectif
Permettre à plusieurs agents IA (providers différents) de collaborer sur le même vault sans collisions.

## Démarrage standard
1. Exécuter `ipcrae-agent-hub status`.
2. Si session active:
   - passer en mode **assistant**,
   - prendre une tâche via `ipcrae-agent-hub task-pick <id> <agent_id>`.
3. Sinon:
   - démarrer la session en **lead** avec `ipcrae-agent-hub start <agent_id>`.

## Contrat d'échange
- Une tâche = un owner explicite + un statut (`todo`, `in_progress`, `done`).
- Chaque résultat est écrit dans les fichiers du projet (source de vérité).
- Chaque passage de relais génère une notification `ipcrae-agent-hub notify`.

## Fin de session
- Le lead consolide les changements.
- Le lead clôture avec `ipcrae-agent-hub stop <agent_id>`.
