# Noyau IA — Workflow IPCRAE (Agile + GTD)

## Pipeline obligatoire
1. **Ingest**
   - Lire : vision projet, règles IA projet, état local (`STATE`/notes).
   - Identifier : type de tâche (feature, bug, archi, recherche, consolidation).
2. **Plan**
   - Définir 1 objectif principal + critères de done.
   - Découper en micro-étapes testables.
3. **Construire**
   - Produire le minimum viable correct.
   - Maintenir une traçabilité des décisions (quoi/pourquoi).
4. **Review**
   - Vérifier qualité, risques, impacts croisés (projet, phase, objectifs).
5. **Consolider (OBLIGATOIRE)**
   - **TU DOIS** promouvoir le durable vers la mémoire globale (`memory/`).
   - Laisser le temporaire en local puis archiver/supprimer selon cadence.
   - *Règle absolue : Ne jamais fermer une feature sans documenter sa trace dans le cerveau du projet ou le cerveau global.*

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
- Le prochain pas est nommé.
