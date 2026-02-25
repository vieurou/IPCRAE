---
type: knowledge
tags: [demande, capture, inbox, session, traçabilité, ipcrae]
domain: devops
status: active
sources:
  - project:IPCRAE/scripts/ipcrae-capture-request.sh
  - project:IPCRAE/Inbox/demandes-brutes/README.md
created: 2026-02-22
updated: 2026-02-23
---

# How-to : Capture de la demande brute utilisateur

## Pourquoi
Une demande utilisateur complexe (multi-étapes, multi-fichiers) doit être conservée **verbatim** avant traitement.

Sans ça, il est impossible de :
- vérifier que toutes les sous-demandes ont bien été traitées,
- faire une **post-analyse** fiable (demande ↔ actions ↔ résultat),
- améliorer automatiquement la méthode (détection des oublis, surcoûts, dérives),
- relier la demande aux artefacts produits (`Knowledge/`, `Process/`, `memory/`, `Journal/`, `Projets/`).

## Quand capturer
- Toute demande contenant ≥2 actions distinctes
- Toute demande qui génère des fichiers dans le vault
- Toute demande mentionnant "il faut", "tu devrais", "je veux que"

## Comment

```bash
# Capture depuis la ligne de commande
ipcrae-capture-request "Texte verbatim de la demande..." \
  [--project pss290-maxdaisyed] \
  [--domain electronique] \
  [--title "titre court"]

# Capture depuis stdin (pipe)
echo "Texte demande" | ipcrae-capture-request --project ipcrae

# Résultat : Inbox/demandes-brutes/YYYY-MM-DD-HHMMSS-<slug>.md
```

## Format du fichier créé

```markdown
---
type: demande-brute
date: YYYY-MM-DD HH:MM
status: en-cours | traite | en-attente
project: <slug>
domain: <domaine>
---

# Demande brute — <titre>

## Texte original (VERBATIM)
[Copie exacte du message]

## Traitements effectués
- [ ] Point 1
- [ ] Point 2

## Références croisées automatiques (libellés stables)
### Décomposition / exécution
- Plan / décomposition : ...
- Réexamen fin de traitement : OK | partiel | bloqué

### Artefacts IPCRAE produits
- Fichiers créés/modifiés : ...
- Knowledge créées : ...
- Process créés/modifiés : ...
- Mémoire domaine mise à jour : ...
- Mémoire système mise à jour : ...
- Journal mis à jour : ...
- Tracking projet mis à jour : ...

### Imports bruts / sources brutes (obligatoire si présent)
- Imports bruts utilisés : (paths exacts, ex: `Ressources/...`, `Inbox/infos à traiter/...`)
- Origine des imports bruts : (email, web, dump, notes, etc.)
- Liens vers tâches/artefacts : (liens vers `Tasks/to_ai/...` + `Knowledge/...` + `Process/...` + `Journal/...`)
- Statut d'intégration : (ingéré | partiel | à compacter)

### Git / livraison
- Commits : ...
- Tags : ...
- PR / merge : ...

### Satisfaction demande
- Statut de satisfaction : satisfaite | partiellement satisfaite | bloquée
- Points non couverts : ...
- Réponse finale : ...
```

### Pourquoi ces libellés "stables" ?
- Permettent une post-analyse semi-automatique (diff, mining de sessions, scoring)
- Facilitent le mapping demande ↔ artefacts ↔ satisfaction
- Réduisent les oublis lors du réexamen final

## Vérification (process de revue)
- **Micro (demande courante)** : `Process/reexamen-fin-traitement-demande` — vérifie la satisfaction complète avant la réponse finale
- **Macro (backlog)** : `verification-travail` — scanne `Inbox/demandes-brutes/` et vérifie que chaque demande a ses traitements cochés `[x]`

## Intégration future
- Hook Claude Code (`user-prompt-submit-hook`) pour capture automatique
- Trigger via `ipcrae-inbox-scan` qui détecte les demandes non traitées

## Liens
- [[Process/verification-travail]] — Vérification que tout a été traité
- [[Process/reexamen-fin-traitement-demande]] — Réexamen de fin de traitement d'une demande
- [[inbox-scan-automatique]] — Scan automatique de l'Inbox
