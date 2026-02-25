---
type: process
tags: [dev, review, bonnes-pratiques, qualite, process]
domain: devops
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Process — Review Code et Bonnes Pratiques

## Déclencheur
- Avant tout merge de PR dans DEV/IPCRAE
- Après une session d'implémentation (auto-revue)
- En mode auto-amélioration (revue du code existant)

## Checklist de Review

### Code Bash
- [ ] `shellcheck <script>` passe sans erreur E/W
- [ ] `set -euo pipefail` présent en tête
- [ ] Pas de `IPCRAE_ROOT` hardcodé
- [ ] Variables entre guillemets : `"$var"`
- [ ] Pas de commandes dangereuses sans `--dry-run` / confirmation
- [ ] Fonctions courtes (< 30 lignes si possible)
- [ ] Nommage cohérent (snake_case fonctions, CAPS_SNAKE globals)

### Structure fichiers vault
- [ ] Frontmatter YAML complet (type, tags, domain, status, created, updated)
- [ ] Tags cohérents avec l'index (`ipcrae index`)
- [ ] Liens `[[wikilink]]` vers les notes liées
- [ ] Format mémoire respecté (`### YYYY-MM-DD — Titre`)

### Cohérence IPCRAE
- [ ] La modification est documentée dans `memory/<domaine>.md`
- [ ] Tracking.md mis à jour (tâche cochée `[x]`)
- [ ] Si nouveau process → entrée dans `Process/index.md`
- [ ] Si nouvelle commande → aide dans le launcher + doc
- [ ] `ipcrae sync` relancé si prompts/context modifiés

### Sécurité
- [ ] Pas de secrets/tokens dans les fichiers vaultés
- [ ] Pas de chemins absolus spécifiques à la machine (sauf $HOME/$IPCRAE_ROOT)
- [ ] Pas d'écriture sans backup/rollback possible
- [ ] Inputs utilisateur validés/sanitisés

### Performance
- [ ] Pas de boucles inutiles sur de grands corpus
- [ ] Préférer `find -print0 | while read -r -d ''` à `for f in *`
- [ ] Pas de `cat file | grep` (utiliser `grep file` directement)

## Bonnes pratiques à vérifier (veille)
→ Voir `Knowledge/howto/bash-best-practices.md` (à créer si absent)
→ Voir `Knowledge/runbooks/ipcrae-dev-workflow.md`

## Sorties
- Liste des points à corriger (si review KO)
- PR approuvée (si review OK)
- Entrée Knowledge si pattern nouveau identifié

## Definition of Done
- [ ] `shellcheck` propre
- [ ] Frontmatter complet sur tous les fichiers vault modifiés
- [ ] Cohérence IPCRAE vérifiée
- [ ] Aucun secret ou chemin hardcodé
- [ ] PR approuvée ou points listés

## Agent IA recommandé
Claude Code (général) — utilise `agent_devops` pour les aspects infrastructure

## Process suivant recommandé
`dev-veille-domaine` (si bonnes pratiques à mettre à jour) | merge PR
