---
type: conception
tags: [refactoring, task-management, architecture, ipcrae-v3.4]
status: draft
created: 2026-02-22
---

# Conception : Refactoring du Système de Tâches (v3.4)

## 1. Contexte et Problème

L'analyse de la méthode IPCRAE v3.3 a révélé plusieurs lacunes fondamentales dans la traçabilité et la gestion des tâches, menant à une confusion pour l'utilisateur et un manque de conformité de la part de l'agent IA.

### Diagnostic des Lacunes

1.  **Journalisation en Post-Mortem Uniquement :** L'agent IA ne journalise ses actions qu'en fin de session via `ipcrae close`. Il n'y a pas de log en temps réel, ce qui rend le débogage et le suivi d'une session active difficiles.
2.  **Capture Manuelle des Demandes :** La capture des intentions de l'utilisateur est une action manuelle (`ipcrae capture`). Les prompts bruts ne sont pas tracés, ce qui fait perdre le point d'entrée d'une séquence de travail.
3.  **Architecture de Tâches Implicite :** Le système actuel mélange la capture d'idées (`Inbox/`) et la gestion de connaissance, mais ne possède pas de système de gestion de tâches directionnel (Utilisateur->IA, IA->Utilisateur). Cela crée une confusion sur "qui doit faire quoi".

## 2. Vision et Objectifs

La v3.4 doit introduire un **système de gestion de tâches explicite, traçable et centralisé**, qui cohabite avec le système de gestion de connaissance (PARA).

### Principes Directeurs
- **Traçabilité Totale :** Chaque demande utilisateur et chaque action de l'IA doit laisser une trace.
- **Séparation Claire des Responsabilités :** Le "qui fait quoi" doit être évident depuis la structure des dossiers.
- **Automatisation Maximale :** L'agent IA doit être le principal acteur de la maintenance de ce système (capture, journalisation, mise à jour de statut).

## 3. Nouvelle Architecture Proposée

### 3.1. Le Hub de Tâches Centralisé

Création d'un nouveau dossier racine `Tasks/` dans le vault IPCRAE.

```
IPCRAE_ROOT/
├── Tasks/
│   ├── to_ai/          # Tâches pour l'IA (créées par l'utilisateur)
│   ├── to_user/        # Tâches pour l'utilisateur (créées par l'IA)
│   ├── history/        # Archives des tâches terminées
│   └── active_session.md # Journal en temps réel de la session en cours
└── ... (Projets, Casquettes, etc.)
```

### 3.2. Cycle de Vie d'une Tâche "Utilisateur -> IA"

1.  **Capture Automatique :** Un script wrapper (ex: `ipcrae-ask`) ou l'agent lui-même (via la Règle Zéro) capture le prompt brut de l'utilisateur et crée un fichier `Tasks/to_ai/task-<timestamp>.md`.
2.  **Enrichissement et Statut :** Le fichier de tâche contient des métadonnées YAML.
    ```yaml
    ---
    id: task-<timestamp>
    from: user
    to: agent
    status: pending
    created: 2026-02-22
    ---
    # Demande Brute
    {{prompt_utilisateur}}
    ```
3.  **Traitement :** L'agent prend la tâche, passe son statut à `in_progress`.
4.  **Journalisation :** Chaque action de l'agent est ajoutée dans `Tasks/active_session.md`.
5.  **Clôture :** Une fois la tâche terminée, son statut passe à `done` et le fichier est déplacé vers `Tasks/history/YYYY/MM/`. Le journal `active_session.md` est archivé et lié à la tâche.

### 3.3. Tâches "IA -> Utilisateur"

- Si l'IA a besoin d'une action de l'utilisateur (ex: lancer une commande `sudo`, donner un avis), elle crée un fichier `Tasks/to_user/request-<timestamp>.md`.
- L'interface CLI (`ipcrae status` ou `ipcrae health`) doit notifier l'utilisateur de la présence de tâches en attente dans ce dossier.

## 4. Plan d'Implémentation

1.  **[Fait]** Créer ce document de conception.
2.  **[À Faire]** Modifier le prompt `core_ai_functioning.md` pour inclure la "Règle Zéro" (audit, capture, journalisation).
3.  **[À Faire]** Créer la nouvelle arborescence `Tasks/`.
4.  **[À Faire]** Créer un nouveau script `ipcrae-task` pour gérer le cycle de vie des tâches (créer, lister, clôturer).
5.  **[À Faire]** Mettre à jour le script de lancement de l'agent pour qu'il intègre la capture automatique.
6.  **[À Faire]** Mettre à jour `ipcrae health` pour qu'il scanne les nouveaux dossiers de tâches.
7.  **[À Faire]** Documenter ce nouveau workflow dans `docs/workflows.md`.
