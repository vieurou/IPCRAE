# Vision et Objectifs du Projet IPCRAE

**Dernière mise à jour** : 2026-02-20
**Statut global** : 🟢 En Production

## 1. Pitch du Projet
IPCRAE (Intelligent Project Conception & Resource Assistant Extended) est un système de gestion de notes, de conception dynamique et de mémoire partagée pour les LLMs. Il orchestre les instructions globales, la journalisation atomique (Zettelkasten), et l'exécution CLI permettant une communication asynchrone entre un utilisateur et divers IA (Claude, Gemini, Codex).

## 2. Objectifs Business / Métier
- **Objectif 1** : Fournir une "Source Unique de Vérité" (SSOT) via `~/IPCRAE` pour éviter l'amnésie des agents IA.
- **Objectif 2** : Séparer strictement le contexte court-terme (`.ipcrae-project/local-notes/`) de l'historique durable (`.ipcrae-memory/memory/`).
- **Objectif 3** : Faciliter le "CDE" (Conception Driven Execution) avec des templates structurés orientant l'IA vers l'autonomie.

## 3. Personas / Utilisateurs cibles
- **Développeurs expérimentés** : Désirant de la transparence totale (fichiers Markdown plats) sans dépendances lourdes (juste Bash).

## 4. Ce que le projet N'EST PAS (Anti-objectifs)
- Ce n'est pas une application SaaS lourde.
- Ce n'est pas un IDE de code (il s'interface avec les IDEs via les fichiers `.clinerules`, `.claude.md`, etc.).

