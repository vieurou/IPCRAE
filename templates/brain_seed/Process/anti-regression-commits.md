---
type: process
tags: [anti-regression, commits, verification, qualite, git]
domain: all
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Process — Vérification Anti-Régression Basée sur les Commits

## Déclencheur
- Avant de merger une PR significative
- Après une session d'auto-amélioration
- À la demande (manuel) via `ipcrae process anti-regression-commits`
- Mensuellement lors de la revue monthly
- Quand une fonctionnalité critique a été modifiée

## Concept
Analyser l'historique des commits pour détecter les régressions potentielles : fonctions disparues, comportements modifiés, violations de la méthode IPCRAE. Comparer l'état actuel avec l'état précédent pour identifier ce qui a changé et vérifier que les changements sont cohérents avec la méthode.

## Checklist

### Étape 1 : Préparation
- [ ] Se positionner dans le répertoire IPCRAE_ROOT
- [ ] Vérifier que le dépôt git est propre (pas de modifications non commitées)
- [ ] Identifier le commit de référence (ex: dernier tag `session-*` ou `v*`)
- [ ] Sauvegarder l'état actuel si nécessaire

### Étape 2 : Analyse des changements

#### A. Identifier les fichiers modifiés
- [ ] Lister les fichiers modifiés depuis le commit de référence :
  ```bash
  git diff --name-only <commit_ref> HEAD
  ```
- [ ] Catégoriser les fichiers modifiés :
  - Scripts CLI (`scripts/ipcrae-*.sh`)
  - Scripts utilitaires (`scripts/*.sh`)
  - Processus (`Process/*.md`)
  - Prompts (`.ipcrae/prompts/agent_*.md`)
  - Documentation (`README.md`, `Knowledge/*.md`, `docs/*.md`)
  - Configuration (`.ipcrae/config.yaml`, `.gitignore`)
  - Autres

#### B. Analyser les modifications par catégorie

##### Scripts CLI
Pour chaque script CLI modifié (`scripts/ipcrae-*.sh`) :
- [ ] Vérifier que la fonctionnalité principale n'a pas été supprimée
- [ ] Vérifier que les arguments et options n'ont pas été modifiés sans mise à jour de la documentation
- [ ] Vérifier que le comportement par défaut n'a pas été modifié sans justification
- [ ] Vérifier que les dépendances externes n'ont pas été ajoutées/supprimées sans documentation
- [ ] Vérifier que le script respecte toujours les principes IPCRAE (bash pur, erreurs gérées, logging)

##### Scripts utilitaires
Pour chaque script utilitaire modifié (`scripts/*.sh`) :
- [ ] Vérifier que la fonctionnalité n'a pas été supprimée
- [ ] Vérifier que les scripts qui dépendent de ce script ne sont pas cassés
- [ ] Vérifier que le script est toujours référencé dans des processus ou prompts

##### Processus
Pour chaque processus modifié (`Process/*.md`) :
- [ ] Vérifier que le processus n'a pas été supprimé sans être remplacé
- [ ] Vérifier que les liens wikilinks `[[process]]` sont toujours valides
- [ ] Vérifier que le processus est toujours référencé dans `Process/index.md`
- [ ] Vérifier que le processus est toujours cohérent avec la méthode IPCRAE v3.3

##### Prompts
Pour chaque prompt modifié (`.ipcrae/prompts/agent_*.md`) :
- [ ] Vérifier que les instructions clés n'ont pas été supprimées
- [ ] Vérifier que les règles IPCRAE sont toujours respectées
- [ ] Vérifier que le prompt compilé `.ipcrae/compiled/prompt_<domaine>.md` est à jour
- [ ] Vérifier que le prompt est toujours cohérent avec la méthode IPCRAE v3.3

##### Documentation
Pour chaque fichier de documentation modifié :
- [ ] Vérifier que les informations clés n'ont pas été supprimées
- [ ] Vérifier que les liens wikilinks `[[note]]` sont toujours valides
- [ ] Vérifier que les tags frontmatter sont toujours cohérents
- [ ] Vérifier que la version IPCRAE est cohérente

### Étape 3 : Détection des régressions

#### A. Fonctions disparues
- [ ] Vérifier que toutes les commandes documentées dans `README.md` existent encore
- [ ] Vérifier que tous les scripts documentés dans `README.md` existent encore
- [ ] Vérifier que tous les processus documentés dans `Process/index.md` existent encore
- [ ] Vérifier que tous les agents documentés dans `Agents/` existent encore

#### B. Comportements modifiés
- [ ] Vérifier que les arguments et options des commandes n'ont pas été modifiés sans mise à jour de la documentation
- [ ] Vérifier que le comportement par défaut des scripts n'a pas été modifié sans justification
- [ ] Vérifier que les processus n'ont pas été modifiés sans mise à jour de la documentation

#### C. Violations de la méthode
- [ ] Vérifier que les scripts respectent toujours les principes IPCRAE (bash pur, erreurs gérées, logging)
- [ ] Vérifier que les processus respectent toujours les principes IPCRAE (checklist, DoD, documentation)
- [ ] Vérifier que les prompts respectent toujours les principes IPCRAE (contexte, mémoire, tracking)

### Étape 4 : Analyse des dépendances
- [ ] Vérifier que les scripts qui dépendent d'autres scripts ne sont pas cassés
- [ ] Vérifier que les processus qui dépendent d'autres processus ne sont pas cassés
- [ ] Vérifier que les prompts qui dépendent d'autres prompts ne sont pas cassés
- [ ] Vérifier que la documentation qui dépend d'autres fichiers n'est pas cassée

### Étape 5 : Correction des régressions
Pour chaque régression détectée :
- [ ] Corriger le code pour restaurer la fonctionnalité disparue
- [ ] OU mettre à jour la documentation pour refléter le nouveau comportement
- [ ] Documenter la décision de ne pas corriger (si applicable)
- [ ] Vérifier que les dépendances sont toujours valides

### Étape 6 : Validation
- [ ] Relancer `ipcrae-audit-check` → score après corrections
- [ ] Vérifier que le score d'audit est ≥ 80%
- [ ] Exécuter les tests de non-régression (si disponibles)
- [ ] Documenter les résultats dans le journal de session

## Sorties attendues
- Rapport d'analyse des commits (console)
- Liste des fichiers modifiés par catégorie
- Liste des régressions détectées (fonctions disparues, comportements modifiés, violations de la méthode)
- Liste des dépendances cassées
- Score de régression (nombre de checks passés / total)
- Entrée dans le journal de session avec les résultats

## Definition of Done
- Tous les fichiers modifiés ont été analysés
- Aucune fonctionnalité n'a disparu sans justification
- Aucun comportement n'a été modifié sans mise à jour de la documentation
- Aucune violation de la méthode n'a été détectée
- Toutes les dépendances sont valides
- Le score d'audit est ≥ 80%
- Les résultats sont documentés dans le journal de session

## Agent IA recommandé
- agent_devops (pour les aspects techniques et infrastructure)
- Kilo Code (mode Code pour les corrections automatiques)

## Commandes associées
- `git diff --name-only <commit_ref> HEAD` — Lister les fichiers modifiés
- `git diff <commit_ref> HEAD -- <fichier>` — Voir les modifications d'un fichier
- `bash scripts/audit_non_regression.sh` — Audit de non-régression
- `bash scripts/ipcrae-audit-check.sh` — Audit vault complet
- `ipcrae process anti-regression-commits` — Lancer ce process via le launcher

## Notes
- Ce process doit être exécuté régulièrement pour garantir qu'aucune régression n'est introduite
- Les régressions doivent être corrigées avant de continuer
- Les décisions de ne pas corriger doivent être documentées
- Le score de régression doit être maintenu ≥ 80% pour considérer le système stable
- Ce process est complémentaire au process de non-régression (`Process/non-regression.md`)

## Références
- Process de non-régression : `Process/non-regression.md`
- Process de review de cohérence : `Process/review-coherence-doc-code.md`
- Documentation IPCRAE : `Knowledge/howto/ipcrae-analyse-complete-cerveau-v3.3.md`
- Git documentation : `https://git-scm.com/docs`
