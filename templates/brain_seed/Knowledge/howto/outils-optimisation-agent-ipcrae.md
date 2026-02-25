---
type: knowledge
tags: [outils, git, optimisation, agent, ipcrae, terminal, performance]
domain: devops
status: active
sources:
  - project:IPCRAE/AGENTS.md
  - project:IPCRAE/.ipcrae/prompts/core_ai_functioning.md
created: 2026-02-23
updated: 2026-02-23
---

# How-to : Outils d'optimisation pour l'agent IPCRAE

## Pourquoi
L'agent IPCRAE doit travailler efficacement et rapidement en utilisant les outils les plus adaptés à chaque tâche. L'utilisation d'outils optimisés réduit le temps de traitement, améliore la précision et minimise la consommation de ressources.

## Outils Git optimisés

### git diff
**Utilisation** : Comparer les modifications au lieu de lire manuellement les fichiers.

```bash
# Comparer les modifications non commitées
git diff

# Comparer un fichier spécifique
git diff chemin/vers/fichier.md

# Comparer deux commits
git diff <commit1> <commit2>

# Comparer avec une branche
git diff main
```

**Avantages** :
- Affiche uniquement les lignes modifiées
- Contexte clair des changements
- Plus rapide que la lecture manuelle

### git log --oneline
**Utilisation** : Identifier rapidement les commits pertinents.

```bash
# Historique compact
git log --oneline

# Historique avec limite
git log --oneline -10

# Historique filtré par fichier
git log --oneline -- chemin/vers/fichier.md

# Historique avec recherche
git log --oneline --grep="mot clé"
```

**Avantages** :
- Affichage condensé (hash + message)
- Identification rapide des commits
- Facilite la navigation dans l'historique

### git show
**Utilisation** : Examiner le contenu d'un commit sans checkout.

```bash
# Voir le détail d'un commit
git show <commit-hash>

# Voir seulement le fichier modifié
git show <commit-hash>:chemin/vers/fichier.md

# Voir les statistiques du commit
git show --stat <commit-hash>
```

**Avantages** :
- Pas besoin de changer de branche
- Accès rapide au contenu historique
- Visualisation des modifications dans le contexte

### git grep
**Utilisation** : Rechercher dans l'historique des versions.

```bash
# Rechercher dans le code actuel
git grep "terme"

# Rechercher dans un commit spécifique
git grep "terme" <commit-hash>

# Rechercher dans toutes les branches
git grep --all "terme"

# Rechercher avec contexte
git grep -C 3 "terme"
```

**Avantages** :
- Recherche dans tout l'historique
- Plus rapide que grep + git log
- Contexte des résultats

## Outils système optimisés

### tree
**Utilisation** : Visualiser la structure d'un répertoire.

```bash
# Afficher l'arborescence complète
tree

# Afficher avec profondeur limitée
tree -L 2

# Afficher seulement les dossiers
tree -d

# Afficher avec tailles
tree -h
```

**Avantages** :
- Vue d'ensemble claire
- Plus lisible que plusieurs `ls`
- Structure hiérarchique immédiate

### ripgrep (rg)
**Utilisation** : Recherche rapide de contenu dans les fichiers.

```bash
# Rechercher un terme
rg "terme"

# Recherche insensible à la casse
rg -i "terme"

# Recherche avec contexte
rg -C 3 "terme"

# Recherche dans des fichiers spécifiques
rg -t md "terme"

# Recherche avec expressions régulières
rg "pattern.*regex"
```

**Avantages** :
- Beaucoup plus rapide que `grep`
- Supporte les expressions régulières
- Coloration syntaxique des résultats
- Ignorance automatique des fichiers .gitignore

### fd
**Utilisation** : Recherche rapide de fichiers.

```bash
# Rechercher un fichier par nom
rg nom_fichier

# Recherche par extension
fd -e md

# Recherche dans un répertoire spécifique
fd "terme" chemin/vers/dossier

# Recherche avec exclusion
fd -E node_modules "terme"
```

**Avantages** :
- Plus rapide que `find`
- Syntaxe plus intuitive
- Respecte .gitignore par défaut
- Coloration des résultats

## Bonnes pratiques

### Priorité des outils
1. **Pour les comparaisons** : `git diff` > lecture manuelle
2. **Pour l'historique** : `git log --oneline` > `git log` complet
3. **Pour l'examen de commit** : `git show` > checkout + lecture
4. **Pour la recherche historique** : `git grep` > grep + log
5. **Pour la structure** : `tree` > plusieurs `ls`
6. **Pour la recherche contenu** : `ripgrep` > `grep`
7. **Pour la recherche fichiers** : `fd` > `find`

### Combinaisons efficaces
```bash
# Rechercher un terme dans l'historique
git log --oneline --all | grep "terme"

# Voir les modifications d'un commit spécifique
git show <commit-hash> --stat

# Rechercher un fichier et voir son historique
fd nom_fichier && git log --oneline -- nom_fichier

# Comparer avec la branche principale
git diff main -- chemin/vers/fichier.md
```

### Quand utiliser les outils standards
- `grep` : quand ripgrep n'est pas disponible
- `find` : quand fd n'est pas disponible
- `ls` : pour des listes simples d'un seul niveau

## Intégration avec IPCRAE

Ces outils doivent être utilisés systématiquement par l'agent IPCRAE pour :
- Réduire le temps de traitement des demandes
- Améliorer la précision des opérations Git
- Faciliter la navigation dans les projets
- Optimiser la recherche de connaissances

## Liens
- [[Knowledge/howto/capture-demande-brute]] — Capture des demandes brutes
- [[Knowledge/patterns/git-workflow-ipcrae]] — Workflow Git dans IPCRAE
- [[Knowledge/patterns/pretraitement-demande-ipcrae]] — Pré-traitement des demandes
