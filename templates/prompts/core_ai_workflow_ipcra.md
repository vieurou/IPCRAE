# Noyau IA — Workflow IPCRAE (Agile + GTD)

## Pipeline obligatoire
1. **Ingest**
   - Lire : vision projet, règles IA projet, état local (`STATE`/notes).
   - Identifier : type de tâche (feature, bug, archi, recherche, consolidation).
2. **Prompt Optimization (OBLIGATOIRE)**
   - Transformer la demande utilisateur en prompt enrichi (contexte projet + mémoire/Knowledge + contraintes + format attendu).
   - Si disponible, utiliser `ipcrae-prompt-optimize` comme base puis adapter au cas réel.
3. **Brain-First Rendering (recommandé pour tâches techniques durables)**
   - Avant de rédiger un document final, écrire d'abord les éléments durables dans le cerveau (`memory/`, `Knowledge/`, `Process/`, tracking, journal) quand c'est pertinent.
   - Considérer le document final comme un **rendu** (vue) construit depuis ces données + le contexte existant.
   - Si la tâche est triviale / non durable, texte d'abord toléré (puis extraction minimale si nécessaire).
   - Référence : [[Knowledge/patterns/brain-first-rendering-ipcrae]]
4. **Plan**
   - Définir 1 objectif principal + critères de done.
   - Découper en micro-étapes testables.
5. **Construire**
   - Produire le minimum viable correct.
   - Maintenir une traçabilité des décisions (quoi/pourquoi).
6. **Review**
   - Vérifier qualité, risques, impacts croisés (projet, phase, objectifs).
7. **Consolider et Commiter (OBLIGATOIRE)**
   - **TU DOIS** promouvoir le durable vers la mémoire globale (`memory/`).
   - Laisser le temporaire en local puis archiver/supprimer selon cadence.
   - *Règle absolue 1 : Ne jamais fermer une feature sans documenter sa trace dans le cerveau du projet ou le cerveau global.*
   - *Règle absolue 2 : **TU DOIS SYSTÉMATIQUEMENT** créer un `git commit` détaillé sur le dépôt du projet pour tes modifications de code ou de documentation.*

## Cadence recommandée
- **Daily** : prochaine action claire + blocage principal.
- **Weekly** : nettoyer backlog, aligner phase active.
- **Monthly** : consolider patterns réutilisables et décisions structurantes.

## Définition de Done IA (STRICTE)
- Le livrable répond à la demande.
- Les vérifications sont exécutées ou l'absence est justifiée.
- **OBLIGATION ABSOLUE : Tu as EXPLICITEMENT documenté ton travail dans le système de fichiers, en respectant la matrice :**
  - Si c'est en cours (WIP, debug, todo) ➔ `.ipcrae-project/local-notes/`.
  - Si c'est une décision technique clé ou une fin de feature ➔ `.ipcrae-project/memory/` (spécifique) ou `.ipcrae-memory/memory/` (global).
- **BRAIN-FIRST (si tâche durable)** : les éléments durables ont été écrits dans le cerveau avant ou pendant la rédaction du document final (pas uniquement extraits après coup).
- **MISE À JOUR DU TRACKING** : Tu as impérativement coché `[x]` la tâche correspondante dans `tracking.md` (Projet) ou `Phases/index.md` (Global), et remonté le backlog si nécessaire.
- **TOUS LES FICHIERS MODIFIÉS** dans le répertoire du projet ont été commités (`git add . && git commit -m "..."`).
- Le prochain pas est nommé.
