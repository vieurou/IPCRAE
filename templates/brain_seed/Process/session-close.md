---
type: process
tags: [ipcrae, session, close, git, memory, process]
domain: all
status: active
created: 2026-02-21
updated: 2026-02-24
---

# Process — Clôture de session IA

## Déclencheur

À exécuter **à la fin de toute session IA**, qu'elle soit courte ou longue.
Ne pas sauter même si peu de choses ont été faites — le push et le tag suffisent.

## Pré-requis

- `IPCRAE_ROOT` exporté dans le shell
- `ipcrae` installé (`~/bin/ipcrae`)
- Domaine et projet de la session identifiés

## Étapes

### 1. Résumer la session (2 min)

Lister mentalement (ou par écrit dans le daily) :
- Ce qui a été fait
- Les décisions prises
- Ce qui reste ouvert

### 2. Créer au moins 1 note Knowledge par concept émergent (OBLIGATOIRE)

**Règle absolue** : chaque session DOIT produire au moins une note `Knowledge/`.
Question à se poser : *"Qu'est-ce que quelqu'un d'autre aurait besoin de savoir si je lui passais ce projet ?"*

Pour chaque concept/pattern appris pendant la session :
- Procédure, howto → `Knowledge/howto/<nom>.md`
- Pattern technique → `Knowledge/patterns/<nom>.md`
- Runbook opérationnel → `Knowledge/runbooks/<nom>.md`
- Concept atomique → `Zettelkasten/_inbox/<id>-<slug>.md`

Si des scripts, commandes, ou comportements ont été modifiés :
- `README.md` — section concernée à jour ?
- `DEV/IPCRAE/README.md` — section concernée à jour ?
- `docs/conception/*.md` — architecture ou règles changées ?
- Prompts modifiés → templates DEV synchronisés ?
- **Vérifications recommandées** (optionnel mais recommandé) :
  - `ipcrae process review-coherence-doc-code` — Vérifier la cohérence documentation ↔ code
  - `ipcrae process anti-regression-commits` — Vérifier les régressions basées sur les commits

**Règle** : ne jamais committer sans que les Knowledge reflètent ce qui a été appris.
Si manque de temps → ouvrir un `- [ ]` dans tracking.md plutôt qu'ignorer.

### 3. Mettre à jour `memory/<domaine>.md`

Ajouter une entrée datée avec le format :
```markdown
### YYYY-MM-DD — [Projet] <titre court>
**Projet** : <slug|cross-project>
**Portée** : <project-specific|cross-project|incident|review>
**Statut** : <consolidé|import-brut|à-compacter>
**Contexte** : ...
**Décision** : ...
**Résultat** : ...
```

Règle : ne jamais laisser une entrée multi-projet implicite (projet non nommé).

Si rien de notable → écrire quand même une ligne de clôture.

### 4. Mettre à jour `context.md` si nécessaire

- Section "Projets en cours" : ajouter/retirer/modifier un projet
- Section "Working set" : domaine actif, projet actif, dernière clôture

### 5. Vérifier et mettre à jour la documentation (OBLIGATOIRE)

**Critères de mise à jour du README.md** :
- Nouvelle fonctionnalité ajoutée au système
- Modification de la structure IPCRAE
- Changement dans les commandes CLI principales
- Mise à jour de l'architecture ou des règles
- Script ou comportement modifié qui impacte l'utilisateur

**Fichiers à vérifier** :
- `README.md` — documentation générale du système (racine du vault)
- `index.md` — dashboard de navigation
- `docs/conception/*.md` — architecture ou règles changées
- Templates DEV synchronisés si prompts modifiés

**Processus** :
1. Si l'un des critères ci-dessus est rempli → mettre à jour le README.md
2. Si aucun critère → vérifier que le README.md reste cohérent
3. Si manque de temps pour la mise à jour → ouvrir un `- [ ]` dans tracking.md

**Règle** : ne jamais committer sans vérifier la cohérence de la documentation avec les changements effectués.

### 6. Merger les PRs DEV/IPCRAE ouvertes (OBLIGATOIRE si scripts modifiés)

Si des scripts `~/bin/ipcrae*` ont été modifiés pendant la session :

```bash
# Lister les PRs ouvertes sur DEV/IPCRAE
gh pr list --repo vieurou/IPCRAE

# Merger chaque PR feature/* sans attendre confirmation
gh pr merge <N> --repo vieurou/IPCRAE --merge

# Revenir sur master local
git -C ~/DEV/IPCRAE checkout master && git -C ~/DEV/IPCRAE pull
```

**Règle** : ne jamais laisser une PR DEV ouverte en fin de session — le merge fait partie du workflow, pas une étape optionnelle.

### 7. Clôturer via la commande canonique

```bash
ipcrae close <domaine> --project <slug>
```

Cette commande fait en une passe :
- `git add -A` + `git commit` dans le vault
- `git push` vers `brain.git`
- Tag annoté `session-YYYYMMDD-domaine`

### 8. Vérifier (optionnel mais recommandé)

```bash
git -C $IPCRAE_ROOT log --oneline -3    # dernier commit visible
git -C $IPCRAE_ROOT tag | tail -3       # tag session créé
IPCRAE_ROOT=$IPCRAE_ROOT ipcrae-audit-check | tail -5  # score vault
IPCRAE_ROOT=$IPCRAE_ROOT ipcrae-auto-apply --auto  # auto-amélioration
```

## Sorties attendues

- `memory/<domaine>.md` : entrée datée ajoutée
- Vault commité et pushé sur `brain.git`
- Tag `session-YYYYMMDD-<domaine>` créé
- Score audit ≥ 30/40 (si < 30 → ouvrir un ticket dans Inbox/)
- `ipcrae-auto-apply` exécuté avec succès (score amélioré ou stable)

## Fallback (si `ipcrae close` indisponible)

```bash
git -C $IPCRAE_ROOT add -A
git -C $IPCRAE_ROOT commit -m "chore(ipcrae): close session $(date '+%Y-%m-%d %H:%M')"
git -C $IPCRAE_ROOT push
```

## Agent IA recommandé

Tous agents — ce process est universel.
