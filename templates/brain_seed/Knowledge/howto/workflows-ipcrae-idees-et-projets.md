---
type: knowledge
tags: [workflow, gtd, zettelkasten, automatisation, onboarding, ipcrae]
project: IPCRAE
domain: devops
status: stable
sources:
  - path: docs/workflows.md
created: 2026-02-21
updated: 2026-02-21
---

# Workflows IPCRAE : Idées et Projets

Ce document synthétise les processus d'intégration d'idées brutes et de création de nouveaux projets au sein de l'écosystème IPCRAE pour automatiser leur tri via les agents IA et les rituels.

## 1. Traitement d'une "Nouvelle Idée"
L'objectif est d'utiliser le Hub-and-Spoke entre GTD (Action) et Zettelkasten (Réflexion) pour éviter la perte d'informations.

1. **Capture** : Utiliser la capture rapide.
   ```bash
   ipcrae capture "Description de l'idée..."
   ```
   *(Créé dans `Inbox/` sous format raw)*

2. **Clarification** (via l'IA ou les itérations lors de rituels `daily`/`weekly`) :
   L'idée est dotée d'un frontmatter décrivant son statut :
   ```yaml
   ---
   type: fleeting
   status: inbox
   tags: [idee, tag1]
   ---
   ```

3. **Organisation & Routage Automatique** :
   - *Actionnable et avec une deadline/scope précis ?* → Transformé en **Projet** ou rattaché à un projet existant.
   - *Actionnable abstrait ou récurrent ?* → Va dans le tracking d'une **Casquette**.
   - *Matériel de référence isolé ?* → Rangé dans **Ressources/** (`Literature Note`).
   - *Connaissance fondamentale ou vision large ?* → Formalisé avec `ipcrae zettel "Sujet"` pour être lié dynamiquement via les `MOC` des **Zettelkasten**.

## 2. Créer un Nouveau Projet
Processus pour appliquer le CDE (Context Driven Engineering) de manière immédiate :
1. Préparer le dossier : `mkdir -p ~/DEV/NouveauProjet && cd ~/DEV/NouveauProjet`
2. Appliquer la méthodologie : `ipcrae-addProject`
3. Remplir le manifeste : `docs/conception/00_VISION.md`
4. Démarrer l'agent IA : `ipcrae sprint --project NouveauProjet`

## 3. Intégrer un Projet Existant
Processus non-destructif pour ajouter le CDE et faire ingérer le code existant aux agents IPCRAE.
1. Se placer dans le répertoire : `cd ~/DEV/ProjetExistant`
2. Initier la structure documentaire : `ipcrae-addProject`
3. À la fin du processus d'ajout, **accepter** de lancer l'agent IA pour une **Auto-ingestion** : l'agent va analyser le code source complet, générer `docs/conception/02_ARCHITECTURE.md` et déduire les conventions dans `01_AI_RULES.md`.
