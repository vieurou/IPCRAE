---
type: process
tags: [ipcrae, daily, journal, inbox, gtd, process]
domain: all
status: active
created: 2026-02-21
updated: 2026-02-21
---

# Process — Cycle Daily

## Déclencheur

Chaque matin, en début de journée.
Commande : `ipcrae daily` (ou `ipcrae daily --prep` pour générer un brouillon IA).

## Pré-requis

- `IPCRAE_ROOT` exporté dans le shell
- Daily d'hier présente dans `Journal/Daily/<YYYY>/` (ou pas, c'est ok)

---

## Étapes

### 1. Créer le fichier daily du jour

```bash
ipcrae daily
```

Crée `Journal/Daily/<YYYY>/<YYYY-MM-DD>.md` depuis le template standard.
Si le fichier existe déjà → l'ouvrir directement.

### 2. Reporter les tâches non terminées d'hier

Lire le daily de la veille (`Journal/Daily/<YYYY>/<date-hier>.md`).
Pour chaque `- [ ]` non coché → décider :
- **Reporter** → copier dans le daily du jour
- **Abandonner** → supprimer ou déplacer dans Someday/Maybe
- **Déléguer** → ajouter à `Inbox/waiting-for.md`

### 3. Clarifier l'Inbox

```bash
ls $IPCRAE_ROOT/Inbox/
```

Pour chaque item non traité — appliquer le protocole GTD :
```
Actionnable ?
├─ Non  → Ressources/ | Someday/Maybe | Supprimer
└─ Oui  → < 2 min ? → Faire maintenant
           > 2 min ? → Projet/tracking.md ou Next Action
           Délégable ? → waiting-for.md
```

### 4. Vérifier les Waiting For en retard

```bash
cat $IPCRAE_ROOT/Inbox/waiting-for.md
```

Tout item dont la date d'échéance est dépassée → relancer ou fermer.

### 5. Aligner avec les priorités de la phase

```bash
cat $IPCRAE_ROOT/Phases/index.md
```

La phase active définit les priorités. Les tâches du jour doivent y être cohérentes.

### 6. Définir le Top 3 du jour

Dans le daily, remplir la section `## Top 3` :
- 3 actions concrètes, faisables aujourd'hui, alignées avec la phase
- Format : `- [ ] Verbe + quoi + pour atteindre quoi`

### 7. Clôturer si session IA impliquée

Si la daily a été préparée par un agent IA → suivre `Process/session-close.md`.

---

## Sorties attendues

- `Journal/Daily/<YYYY>/<YYYY-MM-DD>.md` créé et rempli
- Inbox clarifiée (zéro item non traité de > 2j)
- Top 3 du jour défini
- Waiting For nettoyé

## Definition of Done

- [ ] Fichier daily du jour créé
- [ ] Tâches d'hier reportées ou abandonnées
- [ ] Inbox parcourue (aucun item non traité > 48h)
- [ ] Waiting For vérifié (aucun dépassement silencieux)
- [ ] Top 3 défini et cohérent avec la phase active

## Fréquence

Quotidienne, matin de préférence.
Si une journée est sautée → reporter brièvement dans la daily suivante.

## Agent IA recommandé

Tous agents — utiliser `prompt_daily_prep.md` pour générer le brouillon.
