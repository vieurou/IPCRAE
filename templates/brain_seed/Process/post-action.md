---
type: process
tags: [ipcrae, workflow, brain-first, checkpoint, post-action]
domain: all
status: active
created: 2026-02-24
updated: 2026-02-24
---

# Process — Après chaque action (close_action)

## Déclencheur

À exécuter **après chaque action significative** en cours de session.
Ne pas attendre la fin : une session peut être interrompue à tout moment.

## Étapes

### 1. Écrire dans le cerveau (immédiatement)

| Ce qui s'est passé | Où écrire |
|--------------------|-----------|
| Décision prise / erreur apprise | `memory/<domaine>.md` (entrée datée) |
| Procédure / howto découvert | `Knowledge/howto/<nom>.md` |
| Pattern réutilisable | `Knowledge/patterns/<nom>.md` |
| Concept atomique | `Zettelkasten/_inbox/<id>-<slug>.md` |
| État intermédiaire (WIP) | `Inbox/session-<date>-wip.md` |

### 2. Cocher le tracking

```markdown
- [x] Étape accomplie — description courte
- [ ] Prochaine étape → description
```

Dans `tracking.md` du projet ou `Phases/index.md`.

### 3. Committer (checkpoint)

```bash
ipcrae checkpoint "raison courte"
```

Ou manuellement :
```bash
cd $IPCRAE_ROOT && git add -A && git commit -m "chore(brain): <action>" && git push
```

## Règle fondamentale

> **Si ce n'est pas dans le cerveau, ça n'existe pas.**
> L'écriture dans le cerveau est l'action, pas son compte-rendu.

## Différence avec ipcrae close

| `close_action` (post-action) | `ipcrae close` (fin de session) |
|------------------------------|----------------------------------|
| Après chaque action | Une seule fois, en fin de session |
| Pas de mémoire domaine obligatoire | Mémoire domaine consolidée |
| `ipcrae checkpoint` suffit | `ipcrae close <domaine>` |
| 30 secondes | 2-5 minutes |

## Voir aussi

- [[Process/session-close]] — clôture complète de session
- [[patterns/brain-first-rendering-ipcrae]] — principe brain-first
