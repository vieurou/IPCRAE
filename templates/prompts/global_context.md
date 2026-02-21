# Contexte Global — IPCRAE v3.2

## Pourquoi ce système
- La mémoire des chats est bruitée → la vérité est dans des fichiers locaux versionnables.
- L'IA travaille sur un contexte structuré, mis à jour par les cycles daily/weekly/close.
- La recherche de connaissance est **tag-first** (index + frontmatter), pas arborescence-first.

## Identité

### Professionnel
- DevOps autodidacte, infrastructure IT santé (Santelys)
- Linux (Debian), Docker, systèmes embarqués (ESP32, Orange Pi)
- Node.js, SvelteKit, MariaDB, PostgreSQL
- VSCode, Git/GitHub, CLI/SSH

### Centres d'intérêt
- Informatique : Linux, Amiga, optimisation
- Électronique : IoT, domotique, systèmes programmés
- Musique : production, synthèse, circuit bending, hardware
- Maison : rénovation, énergie, domotique, DIY

### Valeurs
- Open-source, pragmatique, documenté
- Zéro tolérance pour les infos non vérifiées
- Hands-on, apprendre par la pratique

## Structure IPCRAE v3.2

| Dossier | Rôle |
|---------|------|
| Inbox/ | Capture brute (idées, tâches, liens) |
| Projets/ | Hubs centraux projet |
| Casquettes/ | Responsabilités continues |
| Ressources/ | Documentation brute par domaine |
| Zettelkasten/ | Notes atomiques permanentes |
| Knowledge/ | Connaissances réutilisables (howto/runbooks/patterns) |
| Archives/ | Terminé |
| Journal/ | Daily / Weekly / Monthly |
| Phases/ | Phases de vie actives |
| Process/ | Procédures récurrentes |
| Objectifs/ | Vision et Someday/Maybe |
| memory/ | Mémoire IA par domaine |
| Agents/ | Rôles IA spécialisés |

## Knowledge + tags (source de vérité)
- Les tags sont portés par le frontmatter YAML des notes Markdown.
- Champs recommandés : `type`, `tags`, `project`, `domain`, `status`, `sources`, `created`, `updated`.
- Le cache `.ipcrae/cache/tag-index.json` est reconstructible (accélération, pas vérité).

## Recherche de connaissance
1. `ipcrae tag <tag>`
2. `ipcrae index` (si cache absent/obsolète)
3. `ipcrae search <mots|tags>` (fallback full-text)

## Mémoire IA par domaine
Chaque domaine a sa propre mémoire dans `memory/` :
- `memory/devops.md`, `memory/electronique.md`, `memory/musique.md`, etc.
- Contient : contraintes, décisions passées, erreurs apprises, raccourcis.
- Mise à jour via `ipcrae close`.

## Cycles de revue
| Cycle | Quand | Durée | Commande |
|-------|-------|-------|----------|
| Daily | Chaque matin | 5 min | `ipcrae daily` |
| Weekly | Dimanche | 30 min | `ipcrae weekly` |
| Monthly | 1er du mois | 1h | `ipcrae monthly` |
| Close | Fin de session IA | 5 min | `ipcrae close` |

## IA — Commandes utiles
- `ipcrae daily --prep`
- `ipcrae health`
- `ipcrae review phase|project|quarter`
- `ipcrae index`
- `ipcrae tag <tag>`
- `ipcrae search <mots|tags>`
