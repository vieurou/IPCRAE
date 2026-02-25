---
type: process
tags: [dev, test, bats, validation, process]
domain: devops
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Process — Tests et Validation

## Déclencheur
- Avant tout merge de PR dans DEV/IPCRAE
- Après modification d'un script bash existant
- Après modification du launcher `ipcrae`
- En mode auto-amélioration (vérification régression)

## Types de tests IPCRAE

| Type | Outil | Portée | Quand |
|------|-------|--------|-------|
| Tests unitaires scripts | `bats-core` | Fonctions isolées | Avant commit |
| Tests intégration | `bats-core` | Script complet + vault | Avant PR |
| Test non-régression | `audit_non_regression.sh` | Score vault avant/après | Avant merge |
| Smoke test install | `ipcrae doctor` | Launcher + deps | Après install |

## Checklist

### Étape 1 : Tests bats (unitaires)
- [ ] Fichier test dans `DEV/IPCRAE/tests/test_<nom>.bats`
- [ ] `@test "description claire" { ... }` pour chaque comportement
- [ ] Cas nominal testé
- [ ] Cas limites testés (fichier absent, vide, permissions)
- [ ] Idempotence testée (run 2 fois → même résultat)
- [ ] Dry-run testé si applicable

### Étape 2 : Tests intégration vault
- [ ] Créer un vault de test temporaire (`mktemp -d`)
- [ ] Initialiser avec `ipcrae-install.sh --dry-run` ou structure minimale
- [ ] Exécuter le script sur le vault de test
- [ ] Vérifier les fichiers produits (format, frontmatter, contenu)
- [ ] Nettoyer le vault de test après

### Étape 3 : Test de non-régression
- [ ] `ipcrae-audit-check` avant modification → score initial
- [ ] Appliquer la modification
- [ ] `ipcrae-audit-check` après → score final ≥ score initial
- [ ] Si score baisse → identifier le gap et corriger

### Étape 4 : Smoke test
- [ ] `ipcrae doctor` passe après install/modification
- [ ] `ipcrae start --project test` fonctionne
- [ ] `ipcrae close devops --dry-run` fonctionne

## Anti-patterns
- Tests qui ne nettoient pas après eux (pollution des autres tests)
- Tests dépendant d'un état global du vault réel
- `sleep` dans les tests (utiliser des mocks ou des fichiers fixtures)
- Ignorer les warnings `shellcheck`

## Sorties
- Rapport tests : X/Y passants
- Score audit avant/après
- PR prête à merger si tous les tests passent

## Definition of Done
- [ ] Tous les tests bats passent (0 failure)
- [ ] Score vault ≥ score avant modification
- [ ] `ipcrae doctor` sans erreur
- [ ] Couverture : nominal + au moins 2 cas limites

## Agent IA recommandé
Claude Code + `agent_devops`

## Process suivant recommandé
`dev-review` → merge PR
