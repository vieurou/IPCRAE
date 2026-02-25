---
type: knowledge
tags: [dev, workflow, process, bash, test, review, ipcrae, bonnes-pratiques, deploiement]
domain: devops
status: active
sources:
  - project:IPCRAE/Process/dev-concept-solution.md
  - project:IPCRAE/Process/dev-bash-specialist.md
  - project:IPCRAE/Process/dev-test.md
  - project:IPCRAE/Process/dev-review.md
  - project:IPCRAE/Process/dev-veille-domaine.md
  - project:IPCRAE/Process/review-coherence-doc-code.md
  - project:IPCRAE/Process/non-regression.md
created: 2026-02-22
updated: 2026-02-24
---

# Pattern : Workflow de développement IPCRAE (5 process + déploiement)

## IMPÉRATIF ABSOLU

> Tout travail sur IPCRAE se fait DANS LE PROJET DE DEV `/home/eric/IPCRAE`,
> puis on redéploie, puis on teste.
> JAMAIS modifier `~/bin/ipcrae` ou `~/brain/.ipcrae/` directement.

## Chaîne complète (dev → cerveau)

```
1. dev-concept-solution   → Clarifier + choisir l'approche AVANT de coder
2. dev-bash-specialist    → Écrire le script selon les bonnes pratiques bash
3. dev-test               → Valider : bats + intégration + non-régression
4. dev-review             → Vérifier : shellcheck + cohérence IPCRAE + sécurité
5. dev-veille-domaine     → Mettre à jour la Knowledge si gap détecté
     ↓
6. COMMIT + PUSH (projet dev /home/eric/IPCRAE)
7. REDÉPLOYER → cp templates/ipcrae-launcher.sh ~/bin/ipcrae
              → ipcrae-install.sh si scripts ou structure modifiés
8. TESTER sur ~/brain
9. VÉRIFIER doc + cerveau (voir checklist post-déploiement)
```

## Checklist post-déploiement (étape 9 — OBLIGATOIRE)

### Cohérence documentation
- [ ] `ipcrae sync` — régénère CLAUDE.md, GEMINI.md, CODEX.md, AGENTS.md
- [ ] `ipcrae index` — reconstruit le cache tags + liens
- [ ] `ipcrae health` — diagnostic cerveau (inbox stale, waiting-for expirés, projets)
- [ ] `ipcrae-audit-check` — score vault (objectif ≥ 80%)
- [ ] Vérifier README.md du projet dev à jour (nouvelles commandes ?)
- [ ] Vérifier `.ipcrae/context.md` du cerveau à jour

### Cohérence cerveau
- [ ] La mémoire domaine concernée (`memory/<domaine>.md`) est mise à jour
- [ ] Si nouveau pattern : créer note dans `Knowledge/patterns/` ou `Knowledge/howto/`
- [ ] Si nouveaux prompts : vérifier `Agents/agent_<domaine>.md`
- [ ] `Process/review-coherence-doc-code.md` si changement significatif

### Non-régression
- [ ] Les commandes existantes fonctionnent encore
- [ ] `bash scripts/audit_non_regression.sh` si disponible

## Règles non-négociables

### Avant de coder
- Formuler en 1 phrase : "Ce composant fait X pour que Y puisse Z"
- Documenter la décision dans `memory/<domaine>.md` AVANT d'implémenter
- Ajouter les tâches dans `tracking.md` AVANT d'exécuter

### En codant (bash)
- `set -euo pipefail` TOUJOURS en tête
- `IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"` JAMAIS hardcodé
- `--dry-run` pour tout script qui modifie des fichiers
- Variables entre guillemets : `"$var"` (jamais non cité)

### Avant de merger
- `shellcheck` passe sans erreur E/W
- Score vault ≥ score avant modification (`ipcrae-audit-check`)

### Après avoir mergé
- Mettre à jour `ipcrae-install.sh` si nouveau script
- Créer note `Knowledge/` si pattern réutilisable
- `ipcrae sync` si prompts modifiés
- Mettre à jour les fichiers liés (docs/seeds/process) + `ipcrae index` si tags modifiés

## Feature branch workflow
```
git checkout master && git pull
git checkout -b feature/<nom-court>
# ... développement dans /home/eric/IPCRAE ...
git commit + push
gh pr create --base master
# review + tests
merge → redéployer (~/bin/) → tester sur ~/brain → vérifier doc + cerveau
```

## Séparation dev / cerveau

| Quoi | Où |
|------|----|
| Code source (templates, scripts, launcher) | `/home/eric/IPCRAE/` (projet dev git) |
| Launcher installé | `~/bin/ipcrae` (déployé depuis templates/) |
| Scripts installés | `~/bin/ipcrae-*` (déployés depuis scripts/) |
| Cerveau (notes, mémoire, Knowledge) | `~/brain/` (IPCRAE_ROOT) |
| Provider files cerveau | `~/brain/CLAUDE.md`, `~/brain/CODEX.md`, etc. |

## Liens
- [[Process/dev-concept-solution]] — Process 1 : Conception
- [[Process/dev-bash-specialist]] — Process 2 : Bash
- [[Process/dev-test]] — Process 3 : Tests
- [[Process/dev-review]] — Process 4 : Review
- [[Process/dev-veille-domaine]] — Process 5 : Veille
- [[Process/review-coherence-doc-code]] — Vérification cohérence doc ↔ code
- [[Process/non-regression]] — Vérification non-régression
- [[git-workflow-ipcrae]] — Convention Git IPCRAE
