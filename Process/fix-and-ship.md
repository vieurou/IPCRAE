---
type: process
domain: devops
status: active
created: 2026-02-23
updated: 2026-02-23
---

# Process — Fix & Ship (IPCRAE Dev)

## Règle absolue
Tout correctif identifié doit être appliqué, commité ET poussé dans la même session.
Ne jamais laisser un fix en local sans push. Ne jamais pousser sans avoir appliqué
le fix aux artefacts existants affectés.

## Étapes obligatoires

### 1. Identifier le périmètre du fix
- Quels fichiers sources sont concernés ? (`ipcrae-install.sh`, `templates/ipcrae-addProject.sh`, `templates/prompts/`, `scripts/`, `templates/scripts/`)
- Est-ce que des cerveaux/projets existants sont déjà affectés par le bug ?

### 2. Corriger dans les sources
- Modifier le(s) fichier(s) source(s) du projet de dev.
- Tester si applicable : `DRY_RUN=true AUTO_YES=true bash ipcrae-install.sh`

### 3. Propager aux artefacts existants affectés
Si le bug a déjà produit des effets dans un cerveau ou un projet tracké :
- Corriger directement dans le projet affecté (ex : remplir un fichier vierge, supprimer un fichier parasite).
- Commiter dans le repo du projet affecté.
- Pousser dans le repo du projet affecté.

### 4. Commiter dans le projet de dev
```bash
git add <fichiers modifiés>
git commit -m "fix(<scope>): <description courte>

<détail du problème et de la correction>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

### 5. Pousser immédiatement
```bash
git push origin master
```

## Règles de bon sens (apprises en session)

| Interdit | Pourquoi |
|----------|----------|
| Ajouter des noms de dossiers génériques dans `.gitignore` | Peut masquer des dossiers légitimes de n'importe quel projet |
| Commiter sans pousser | Le travail n'existe pas tant qu'il n'est pas sur le remote |
| Corriger les sources sans propager aux projets affectés | Laisse des données corrompues/perdues en production |
| Écraser avec `>` des fichiers contenant des données utilisateur | Perte de données irréversible — toujours utiliser `[ ! -f ]` |

## Checklist rapide

- [ ] Fix appliqué dans les sources
- [ ] Testé (dry-run ou vérification manuelle)
- [ ] Propagé aux projets/cerveaux existants affectés
- [ ] Commité avec message clair
- [ ] Poussé (`git push origin master`)
