---
type: knowledge
tags: [mémoire, domaine, agent, ipcrae, bruit-contextuel, session]
domain: devops
status: active
sources:
  - project:IPCRAE/.ipcrae/context.md
  - project:IPCRAE/memory/devops.md
  - project:IPCRAE/Process/session-close.md
created: 2026-02-22
updated: 2026-02-23
---

# Pattern : Mémoire IA par domaine (isolation du bruit contextuel)

## Problème
La mémoire de chat IA est éphémère et bruitée. Si on stocke tout dans un seul fichier, le contexte devient trop lourd pour être utile.

## Solution : Segmentation par domaine

Chaque domaine a sa propre mémoire dans `memory/<domaine>.md` :

| Domaine | Fichier | Contenu |
|---------|---------|---------|
| devops | `memory/devops.md` | Docker, scripts, infra, CI/CD |
| electronique | `memory/electronique.md` | ESP32, tensions, PCB, firmware |
| musique | `memory/musique.md` | Synth, audio, MIDI, signal chain |
| maison | `memory/maison.md` | Domotique, énergie, rénovation |
| sante | `memory/sante.md` | Santé personnelle, wellbeing |
| finance | `memory/finance.md` | Budget, épargne, investissements |

## Format canonique d'une entrée mémoire (v2 — agent-friendly)

```markdown
### YYYY-MM-DD — Titre court décision

**Projet** : <slug-projet | cross-project>
**Portée** : <project-specific | cross-project | incident | review>
**Statut** : <consolidé | import-brut | à-compacter>
**Contexte** : [Situation précise qui a provoqué cette décision]
**Décision** : [Choix technique ou méthodologique]
**Raison** : [Pourquoi ce choix vs les alternatives]
**Résultat** : [Outcome mesurable, liens vers fichiers produits]
**Réutilisable** : [oui/non + pointer vers Knowledge/* si oui]
```

## Règles d'hygiène

- **Une entrée par session** minimum (même "rien de notable ce jour")
- **Format daté** (permet TTL et GC)
- **TTL recommandé** : 180 jours → archiver dans `Archives/memory/`
- **Jamais de secrets** dans les fichiers mémoire
- **Mise à jour via** `ipcrae close <domaine> --project <slug>`
- **Compaction régulière** : weekly/monthly, convertir les blocs "en vrac" en entrées v2

## Règles de lisibilité multi-agents (obligatoire)

- **Nommer explicitement le projet** dans chaque entrée (ne pas supposer "c'est évident").
- **Pas de multi-projet implicite** : si une entrée touche plusieurs projets, indiquer `Projet: cross-project` et lister les projets dans le contexte.
- **Séparer brut vs consolidé** :
  - `Statut: import-brut` pour import de merge/rebase/copier-coller
  - `Statut: consolidé` après normalisation
- **Préfixer les titres ambigus** avec le projet si nécessaire (ex: `[IPCRAE]`, `[velotrack]`).
- **Une entrée = une décision principale** (scinder si plusieurs décisions indépendantes).
- **Connaissance réutilisable** : la synthétiser aussi dans `Knowledge/` puis la référencer depuis `memory/<domaine>.md`.
- **Conserver sans perdre** : en cas de conflit Git, préserver les deux versions puis marquer `import-brut` avant compaction.

## Lecture prioritaire par l'agent
L'agent spécialisé lit **prioritairement** sa mémoire domaine au démarrage :
```
Process/session-start.md → Step 2 : lire memory/<domaine>.md
```
Cela réduit le bruit : un agent musique ne charge pas les décisions devops.

## Mémoire IA persistante (MEMORY.md)
Séparée de la mémoire vault :
- `~/.claude/projects/-home-eric-IPCRAE/memory/MEMORY.md` = mémoire Claude Code
- Contient : conventions stables, préférences workflow, solutions récurrentes
- Organisée par thème (pas chronologiquement)

## Liens
- [[202602210003-memoire-ia-par-domaine]] — Note Zettelkasten sur ce pattern
- [[Process/session-close]] — Mise à jour mémoire en fin de session
- [[Process/session-start]] — Lecture mémoire en début de session
