# Orchestration Multi-Agents (providers parallèles)

## Pourquoi
IPCRAE est déjà multi-provider (Claude/Gemini/Codex). Cette extension formalise le mode **collaboratif parallèle** :
- 1 agent principal (lead/orchestrateur),
- N agents assistants,
- coordination par fichiers partagés dans le vault.

## Principes alignés avec IPCRAE
1. **Source de vérité dans les fichiers** : pas de dépendance à la mémoire de chat.
2. **Process-first** : tâches explicites, statut explicite, handoff explicite.
3. **Système léger** : protocole shell + TSV/LOG, sans dépendance lourde.

## Structure proposée

```text
.ipcrae/multi-agent/
├── state.env           # état de session (active, lead, timestamps)
├── tasks.tsv           # backlog partagé (id, title, owner, status, updated_at)
└── notifications.log   # messages asynchrones inter-agents
```

## Commandes
Le script `ipcrae-agent-hub` gère le protocole:

```bash
ipcrae-agent-hub start claude-main
ipcrae-agent-hub task-add "Comparer méthode IPCRAE aux principes vidéos" claude-main
ipcrae-agent-hub task-pick 1 gemini-research
ipcrae-agent-hub notify gemini-research claude-main "Extraction terminée"
ipcrae-agent-hub task-done 1 gemini-research
ipcrae-agent-hub status
ipcrae-agent-hub stop claude-main
```

## Règles de fonctionnement
- Si `SESSION_ACTIVE=true`, tout nouvel agent passe en mode assistant.
- Une tâche ne change de statut qu'avec une commande explicite.
- Le lead reste responsable de la consolidation finale (`ipcrae close ...`).

## Intégration avec le workflow existant
- `ipcrae start`: prépare le contexte.
- `ipcrae-agent-hub`: distribue le travail en parallèle.
- `ipcrae work`: exécution par chaque agent.
- `ipcrae close`: consolidation mémoire/décisions.

## Limites connues
- Verrouillage optimiste (pas de lock distribué).
- Pas d'historique structuré JSON natif (format texte volontairement simple).
- Les providers sans CLI locale doivent être pilotés manuellement.
