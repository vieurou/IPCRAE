---
type: process
tags: [ipcrae, session, start, contexte, planning, process]
domain: all
status: active
created: 2026-02-21
updated: 2026-02-21
---

# Process — Démarrage de session IA

## Déclencheur

À exécuter **au début de toute session IA**, avant toute action.
Objectif : charger le contexte minimal, définir l'objectif et planifier les tâches.

## Pré-requis

- `IPCRAE_ROOT` exporté dans le shell
- `ipcrae` installé (`~/bin/ipcrae`)
- Projet et domaine de la session identifiés

---

## Étapes

### 1. Lancer le démarrage

```bash
ipcrae start --project <slug>
```

Cette commande charge le contexte projet et affiche le working set.

### 2. Lire le contexte dans cet ordre (3 fichiers obligatoires)

```
.ipcrae/context.md          → projets en cours, phase active, working set
memory/<domaine>.md         → décisions passées, contraintes, erreurs connues
Projets/<slug>/tracking.md  → tâches en cours, backlog, done récent
```

**Règle** : ne pas commencer à travailler avant d'avoir lu ces 3 fichiers.

### 3. Vérifier l'inbox

```bash
ls $IPCRAE_ROOT/Inbox/         # items non clarifiés ?
cat $IPCRAE_ROOT/Inbox/waiting-for.md  # délais dépassés ?
```

Si un item urgent est présent → le traiter ou le planifier avant de commencer.

### 4. Définir l'objectif de session

Formuler explicitement :
- **Objectif** : que doit-on avoir accompli en fin de session ?
- **Critères de done** : comment saura-t-on que c'est terminé ?
- **Domaine** : devops | electronique | musique | maison | sante | finance

### 5. Planifier les tâches dans tracking.md

Créer ou identifier les tâches `- [ ]` dans `Projets/<slug>/tracking.md` **avant** d'exécuter.
Cocher `[x]` au fil de l'eau (pas en bloc à la fin).

---

## Sorties attendues

- Objectif de session formulé et partagé avec l'utilisateur
- Tâches listées dans tracking.md
- Contexte chargé (domaine, projet, phase, contraintes connues)

## Definition of Done

- [ ] Les 3 fichiers de contexte ont été lus
- [ ] L'inbox a été vérifiée
- [ ] L'objectif de session est défini et validé
- [ ] Les tâches sont dans tracking.md avant tout travail

## Fallback (si `ipcrae start` indisponible)

```bash
cat $IPCRAE_ROOT/.ipcrae/context.md
cat $IPCRAE_ROOT/memory/<domaine>.md
cat $IPCRAE_ROOT/Projets/<slug>/tracking.md
```

## Agent IA recommandé

Tous agents — ce process est universel.
