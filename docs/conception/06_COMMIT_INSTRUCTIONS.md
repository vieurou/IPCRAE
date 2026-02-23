---
type: documentation
tags: [commit, pr, instructions, workflow]
project: ipcrae
domain: system
version: 3.2.1
status: implemented
created: 2026-02-21
---

# Instructions de Commit et Pull Request

## 📋 Vue d'ensemble

Ce document fournit les instructions pour créer des commits et des Pull Requests (PR) conformes aux standards IPCRAE.

## 🎯 Règles de Commit

### 1. Format du Commit Message

Chaque commit doit suivre le format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 2. Types de Commit

- **feat**: Nouvelle fonctionnalité
- **fix**: Correction de bug
- **docs**: Documentation
- **style**: Formatage (pas de changement de fonctionnalité)
- **refactor**: Refactoring
- **perf**: Optimisation de performance
- **test**: Ajout de tests
- **chore**: Maintenance du projet
- **ci**: Configuration CI/CD

### 3. Exemples de Commits

#### Nouvelle fonctionnalité
```
feat(tags): ajouter système de tags v3.2.1

- Créer ipcrae-tag-index.sh pour l'indexation
- Créer ipcrae-tag.sh pour la recherche
- Créer ipcrae-index.sh pour l'analyse
- Intégrer dans ipcrae-install.sh
- Documenter le système de tags
```

#### Correction de bug
```
fix(audit): corriger comparaison de dates dans audit_ipcrae.sh

- Utiliser stat -c %Y au lieu de date -d
- Éviter les problèmes de locale
- Résout le bug de comparaison des timestamps
```

#### Documentation
```
docs(tags): documenter système de tags v3.2.1

- Créer 05_TAGS_SYSTEM.md
- Documenter les 3 scripts
- Expliquer le format du cache
- Ajouter exemples d'utilisation
```

## 📝 Structure d'une Pull Request

### 1. Titre de la PR

```
[type]: <subject>
```

### 2. Description de la PR

#### Résumé
- Description courte de la PR
- Objectif principal

#### Changements
- Liste des fichiers modifiés
- Liste des fichiers créés

#### Tests
- Résultats des tests
- Screenshots (si applicable)

#### Instructions de test
- Comment tester les changements
- Commandes à exécuter

#### Checklist
- [ ] Code compilé
- [ ] Tests passés
- [ ] Documentation mise à jour (**obligatoire** si scripts/commandes/workflows changent)
- [ ] Commits bien formattés
- [ ] Aucun warning
- [ ] Compatible avec la version actuelle

### 3. Exemple de PR

```markdown
# feat(tags): ajouter système de tags v3.2.1

## Résumé
Ajout d'un système de tags pour indexer et rechercher efficacement les fichiers markdown dans le cerveau IPCRAE.

## Changements
- Créé `ipcrae-tag-index.sh` pour l'indexation des tags
- Créé `ipcrae-tag.sh` pour la recherche par tag
- Créé `ipcrae-index.sh` pour l'analyse des tags
- Intégré dans `ipcrae-install.sh`
- Documenté dans `05_TAGS_SYSTEM.md`

## Tests
```bash
# Reconstruire le cache
ipcrae-tag-index

# Rechercher par tag
ipcrae-tag system

# Voir les tags les plus utilisés
ipcrae-index
```

## Instructions de test
1. Installer IPCRAE v3.2.1
2. Créer des fichiers avec tags dans Knowledge/
3. Exécuter `ipcrae-tag-index`
4. Tester les recherches avec `ipcrae-tag`
5. Vérifier l'analyse avec `ipcrae-index`

## Checklist
- [x] Code compilé
- [x] Tests passés
- [x] Documentation mise à jour
- [x] Commits bien formattés
- [x] Aucun warning
- [x] Compatible avec la version actuelle
```

## 🔄 Workflow de Commit

### 1. Préparation du Commit

Règle IPCRAE: avant `git add`, vérifier et mettre à jour la documentation impactée (`docs/workflows.md`, `docs/conception/08_COMMANDS_REFERENCE.md`, docs de conception ciblées).

```bash
# Vérifier le statut des fichiers
git status

# Vérifier les changements
git diff

# Ajouter les fichiers
git add <fichiers>

# Vérifier ce qui sera commité
git status
```

### 2. Création du Commit

```bash
# Créer le commit avec message formaté
git commit -m "feat(tags): ajouter système de tags v3.2.1

- Créer ipcrae-tag-index.sh pour l'indexation
- Créer ipcrae-tag.sh pour la recherche
- Créer ipcrae-index.sh pour l'analyse
- Intégrer dans ipcrae-install.sh
- Documenter le système de tags"
```

### 3. Vérification du Commit

```bash
# Vérifier le commit
git log -1 --stat

# Vérifier le format
git log -1 --pretty=format:"%h - %s"

# Vérifier les fichiers modifiés
git show --name-only
```

## 📊 Git Hooks (Optionnel)

### Pré-commit Hook

Créer `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Vérifier le format du commit message
if ! git log -1 --pretty=format:"%s" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|chore|ci):'; then
  echo "❌ Erreur: Le commit message doit commencer par un type (feat, fix, docs, etc.)"
  exit 1
fi
```

### Commit-msg Hook

Créer `.git/hooks/commit-msg`:

```bash
#!/bin/bash
# Vérifier la longueur du commit message
COMMIT_MSG=$(cat "$1")
if [ ${#COMMIT_MSG} -lt 10 ]; then
  echo "❌ Erreur: Le commit message doit contenir au moins 10 caractères"
  exit 1
fi
```

## 🚀 Création d'une Pull Request

### 1. Push vers le repository distant

```bash
# Créer une branche
git checkout -b feat/tags-system-v3.2.1

# Commit les changements
git add .
git commit -m "feat(tags): ajouter système de tags v3.2.1"

# Push vers le repository distant
git push origin feat/tags-system-v3.2.1
```

### 2. Créer la PR sur GitHub/GitLab

- Aller sur le repository
- Cliquer sur "New Pull Request"
- Sélectionner la branche
- Remplir la description
- Ajouter les labels
- Assigner les reviewers

### 3. Review et Merge

- Attendre les reviews
- Appliquer les feedbacks
- Mettre à jour la PR
- Valider le merge

## 📋 Checklist IPCRAE pour Commits et PRs

### Pour les Commits
- [ ] Message formaté correctement
- [ ] Type de commit approprié
- [ ] Subject clair et concis
- [ ] Body détaillé (si nécessaire)
- [ ] Footer (si nécessaire)
- [ ] Aucun fichier inutile
- [ ] Git status clean

### Pour les PRs
- [ ] Titre formaté correctement
- [ ] Description complète
- [ ] Liste des changements
- [ ] Instructions de test
- [ ] Checklist remplie
- [ ] Tests passés
- [ ] Documentation mise à jour
- [ ] Aucun conflit de merge

## 📚 Ressources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Commit Guidelines](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#commit)
- [How to Write a Git Commit Message](https://cbea.ms/git-commit/)

## 🎯 Prochaines Étapes

### À venir
- [ ] Automatiser la création de PRs
- [ ] Intégrer avec CI/CD
- [ ] Ajouter des templates de PR
- [ ] Créer des workflows de review
