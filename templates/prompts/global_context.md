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

## Zettelkasten
Principes :
- **Atomicité** : une note = une seule idée, formulée dans tes mots.
- **Liens** : chaque note doit être reliée à au moins une autre `[[note]]`.
- **Émergence** : pas de hiérarchie rigide, la structure naît des connexions.
- **Ressources/ vs Zettelkasten/** : Ressources = matière brute (extraits, refs), Zettelkasten = pensée digérée.

Workflow : Inbox → Zettelkasten/_inbox/ (brouillon) → Zettelkasten/permanents/ (validé, lié).
Navigation : Zettelkasten/MOC/ contient les Maps of Content (index thématiques).
Commandes : `ipcrae zettel "titre"` (créer note) | `ipcrae moc "thème"` (créer/ouvrir MOC).

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
- L'agent concerné lit prioritairement sa mémoire domaine pour réduire le bruit.
- Mise à jour via `ipcrae close`.

## Méthodologie GTD adaptée

### Workflow quotidien
```
Capturer (Inbox) → Clarifier (actionnable?) → Organiser (Projet/Casquette/Ressources/Someday)
                                             → Réfléchir (Daily/Weekly/Monthly)
                                             → Agir (Next Actions)
```

### Protocole Inbox
```
Item → Actionnable ?
├─ Non → Ressources, Someday/Maybe, ou Supprimer
└─ Oui → < 2 min ?
     ├─ Oui → Faire immédiatement
     └─ Non → Projet (multi-étapes) ou Next Action → Casquette
              Délégable ? → Inbox/waiting-for.md
```

### Priorités
```
🔴 Urgent + Important   → FAIRE maintenant
🟠 Important             → PLANIFIER (phase/projet)
🟡 Urgent seul           → DÉLÉGUER ou quick-win
⚪ Ni l'un ni l'autre   → Someday/Maybe ou supprimer
```

## Cycles de revue
| Cycle | Quand | Durée | Commande |
|-------|-------|-------|----------|
| Daily | Chaque matin | 5 min | `ipcrae daily` |
| Weekly | Dimanche | 30 min | `ipcrae weekly` |
| Monthly | 1er du mois | 1h | `ipcrae monthly` |
| Close | Fin de session IA | 5 min | `ipcrae close` |

## Phase(s) active(s)
→ Voir `Phases/index.md` (source de priorités).

## Projets en cours
<!-- Mis à jour par `ipcrae close` -->
- (à compléter)

## IA — Commandes avancées
- `ipcrae daily --prep` : l'IA prépare un brouillon de daily (sources : hier, weekly, waiting-for, phases).
- `ipcrae zettel "titre"` : créer une note atomique Zettelkasten.
- `ipcrae moc "thème"` : créer/ouvrir une Map of Content.
- `ipcrae health` : diagnostic du système (inbox stale, waiting-for expirés).
- `ipcrae review phase|project|quarter` : revue adaptative guidée par l'IA.
- `ipcrae index` : reconstruire le cache tags.
- `ipcrae tag <tag>` : retrouver les notes liées à un tag.
- `ipcrae search <mots|tags>` : recherche hybride tags + texte.
