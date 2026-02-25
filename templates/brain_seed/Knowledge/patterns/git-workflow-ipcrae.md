---
type: knowledge
tags: [git, workflow, feature-branch, vault, ipcrae, versionning]
project: IPCRAE
domain: devops
status: stable
sources:
  - project:IPCRAE/templates/ipcrae-launcher.sh
  - project:IPCRAE/ipcrae-install.sh
created: 2026-02-21
updated: 2026-02-21
---

# Pattern : Workflow Git IPCRAE (deux repos, deux stratégies)

## Contexte
IPCRAE implique deux types de repos Git avec des besoins distincts :
- Le **repo code** (`~/DEV/IPCRAE`) : installateur, templates, scripts — évolue par features
- Le **vault/cerveau** (`~/IPCRAE`) : notes, mémoire, journal — évolue en continu

## Stratégie DEV/IPCRAE (repo code)

**Feature branch par changement logique** — convention déjà en place sur le repo.

Nommage des branches :
```
feature/<description-kebab-case>         # changements fonctionnels
fix/<description-kebab-case>             # corrections de bugs
docs/<description-kebab-case>            # documentation seule
refactor/<description-kebab-case>        # refactoring sans nouvelle fonctionnalité
```

Workflow IA :
1. `git checkout -b feature/<nom>` avant tout changement
2. Commits atomiques avec message structuré (feat/fix/chore/docs + corps explicatif)
3. `git push origin feature/<nom>` pour revue
4. PR → merge master

**Pourquoi des branches** : permet la revue, le revert ciblé, la traçabilité par fonctionnalité. Le repo a déjà cette convention (`codex/*` branches dans les remotes).

## Stratégie ~/IPCRAE (vault/cerveau)

**Commits directs sur `main` via `auto_git_sync`** — pas de feature branches.

Le vault est un cerveau vivant : chaque `ipcrae close` déclenche `auto_git_sync_event` qui :
```bash
git add -A
git commit -m "chore(ipcrae): ${reason} ($(date))"
git push  # si remote configuré
```

**Pourquoi pas de branches** : le vault est continu et cumulatif. Brancher un journal ou une note mémoire n'a pas de sens — ce n'est pas du code, c'est un historique de vie/travail.

**Remote vault** : recommandé (git push vers un repo privé) pour backup multi-machine.

## Convention commits

Format : `<type>: <sujet court>\n\n<corps optionnel>`

Types :
- `feat` : nouvelle fonctionnalité ou workflow
- `fix` : correction de bug
- `chore` : maintenance (sync, rebuild cache, install)
- `docs` : documentation uniquement
- `refactor` : restructuration sans changement fonctionnel

## Convention sources: dans les notes vault

Dans le frontmatter YAML des notes Knowledge et Zettelkasten :

```yaml
# ✅ Correct — chemin relatif au projet
sources:
  - project:IPCRAE/templates/scripts/ipcrae-agent-bridge.sh

# ✅ Correct — fichier dans le vault
sources:
  - vault:memory/devops.md

# ❌ Interdit — chemin absolu machine-spécifique
sources:
  - path: /home/eric/DEV/IPCRAE/templates/scripts/ipcrae-agent-bridge.sh
```

## Anti-patterns à éviter
- Hardcoder `/home/<user>/` dans tout fichier versionné
- Committer sur master directement dans DEV/IPCRAE sans branch pour des changements significatifs
- Oublier de push le vault vers un remote (risque de perte si disque mort)
