---
type: process
tags: [dev, veille, knowledge, bonnes-pratiques, process]
domain: all
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Process — Veille et Mise à Jour Knowledge Domaine

## Déclencheur
- Avant d'implémenter dans un domaine technique non maîtrisé
- Quand un process de dev (bash, test, review...) cite des références manquantes
- Hebdomadaire : pendant la revue weekly
- Quand `ipcrae health` détecte une knowledge stale (> 30 jours)

## Domaines de veille IPCRAE

| Domaine | Process concernés | Sujets de veille |
|---------|------------------|-----------------|
| Bash | `dev-bash-specialist`, `dev-review` | shellcheck, bash 5, POSIX, outils (fd, ripgrep...) |
| Tests | `dev-test` | bats-core, mocking, fixtures, coverage |
| Git/GitHub | `dev-review` | conventions commit, gh CLI, PR automation |
| Markdown/YAML | `dev-review` | frontmatter YAML v2, wikilinks, Obsidian compat |
| Synth/DSP | `agent_synth_bidouille` | DaisySP, ML_SynthTools, ESP32, YM2413 |
| DevOps | `agent_devops` | Docker, Traefik, Keycloak, PostgreSQL |

## Checklist

### Étape 1 : Identifier le gap de connaissance
- [ ] Quel concept est flou ou absent de Knowledge/ ?
- [ ] `ipcrae tag <tag>` → note existante ? Stale ?
- [ ] `ipcrae search <mot>` → résultat pertinent ?

### Étape 2 : Recherche (WebSearch + WebFetch)
- [ ] Requêtes de veille ciblées (ex: "bats-core best practices 2026")
- [ ] Vérifier les dates des sources (préférer < 12 mois)
- [ ] Croiser plusieurs sources (doc officielle, GitHub, Reddit, forums)

### Étape 3 : Synthèse et écriture Knowledge
- [ ] Créer ou mettre à jour `Knowledge/<type>/<sujet>.md` avec :
  ```yaml
  ---
  type: knowledge
  tags: [bash, test, ...]
  domain: devops
  status: active
  sources:
    - url: https://...
      date: 2026-02-22
  created: 2026-02-22
  updated: 2026-02-22
  ---
  ```
- [ ] Contenu : pratiques vérifiées + exemples concrets + pièges connus
- [ ] Lien vers note depuis les process concernés

### Étape 4 : Mise à jour des process liés
- [ ] Si nouvelle pratique → mettre à jour le process concerné
- [ ] Si outil obsolète → corriger la checklist du process

### Étape 5 : Indexation
- [ ] `ipcrae index` → reconstruire le cache tags
- [ ] Vérifier que la note est trouvable : `ipcrae tag <tag>`

## Sorties
- Note Knowledge créée/mise à jour
- Process liés mis à jour si besoin
- Cache tags rebuild

## Definition of Done
- [ ] Note Knowledge avec frontmatter complet et sources datées
- [ ] `ipcrae tag <tag>` retrouve la note
- [ ] Process lié référence la nouvelle Knowledge

## Agent IA recommandé
Claude Code avec WebSearch — ce process est transversal

## Fréquence recommandée
- **Bash/Test/Review** : veille mensuelle (notes stale > 30j)
- **Synth/DSP** : veille avant chaque session projet PSS-290
- **DevOps** : veille hebdomadaire (technologies évoluent vite)
