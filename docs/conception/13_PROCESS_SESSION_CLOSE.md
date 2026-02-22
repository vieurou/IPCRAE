---
type: process
tags: [ipcrae, session, workflow, devops]
status: active
created: 2026-02-22
---

# Processus Canonique de Clôture de Session

Ce document décrit la procédure standard et obligatoire pour terminer une session de travail dans l'écosystème IPCRAE. Son but est de garantir qu'aucun travail n'est perdu, que la mémoire de l'IA est mise à jour, et que l'état du projet est propre.

## Checklist de Clôture

- [ ] **1. Mise à jour du suivi de projet :**
  - S'assurer que le fichier `tracking.md` du projet est à jour avec les `Next Actions` claires.

- [ ] **2. Finalisation du journal quotidien :**
  - Compléter le fichier `Journal/Daily/YYYY/MM-DD.md` avec les tâches accomplies, les décisions prises et les observations de la journée.

- [ ] **3. Exécution de la commande de clôture IPCRAE :**
  - Lancer la commande `ipcrae close <domaine> --project <slug>` pour que l'IA synthétise la session et mette à jour sa mémoire long-terme (`memory/<domaine>.md`).
  - *`<domaine>`* : Le domaine de compétence principal (ex: `devops`, `writing`).
  - *`<slug>`* : L'identifiant du projet.

- [ ] **4. Validation Git (Commit) :**
  - Vérifier les changements avec `git status`.
  - Ajouter les fichiers pertinents avec `git add .`.
  - Créer un commit atomique avec un message standardisé : `feat(scope): Description concise` ou `fix(scope): ...`.

- [ ] **5. Synchronisation (Push & Tag) :**
  - Pousser les changements vers le dépôt distant : `git push`.
  - (Optionnel) Si la session clôture une version ou une étape majeure, créer un tag : `git tag -a vX.Y.Z -m "Description du tag" && git push --tags`.

- [ ] **6. Vérification finale :**
  - Lancer `ipcrae health` pour s'assurer que l'état du vault est sain (Inbox vide, etc.).
