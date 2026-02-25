---
type: process
tags: [vérification, demandes, traçabilité, ipcrae, qualité, audit]
domain: all
status: active
created: 2026-02-22
updated: 2026-02-23
---

# Process — Vérification du Travail Effectué

## Déclencheur
- En fin de session (après `ipcrae close`)
- Quand l'utilisateur demande "est-ce que tout a été fait ?"
- En mode auto-amélioration (vérification hebdomadaire)
- Quand le score vault < 36/40

## Concept
Scanner les demandes brutes stockées dans `Inbox/demandes-brutes/`, analyser chacune selon les principes IPCRAE, vérifier que tout a été traité et que la mémoire est à jour.

Ce process est la **vue macro** (balayage du backlog de demandes).
Pour la **vue micro** (une demande courante juste avant réponse finale), utiliser aussi :
- `Process/reexamen-fin-traitement-demande.md`

## Checklist

### Étape 1 : Inventaire des demandes brutes
- [ ] Lister tous les fichiers dans `Inbox/demandes-brutes/` (hors README, hors `traites/`)
- [ ] Pour chacun : lire le statut frontmatter (`en-cours` | `traite` | `en-attente`)
- [ ] Identifier les demandes dont le statut est `en-cours` ou `en-attente`

### Étape 2 : Analyse de chaque demande non traitée
Pour chaque fichier avec statut `en-cours` ou `en-attente` :

**A. Décomposer la demande en actions atomiques**
- [ ] Lister chaque action demandée (un point par ligne)
- [ ] Cocher `[x]` les actions visiblement effectuées
- [ ] Vérifier après coup la satisfaction complète via `Process/reexamen-fin-traitement-demande.md` (si demande courante)

**B. Vérifier les outputs IPCRAE attendus**
Pour chaque action :
- [ ] **Fichier créé** : est-il présent dans le vault ?
- [ ] **Knowledge** : si concept réutilisable → note dans `Knowledge/` ?
- [ ] **Process** : si procédure décrite → note dans `Process/` ?
- [ ] **Zettelkasten** : si idée atomique → note dans `Zettelkasten/_inbox/` ?
- [ ] **Ressources** : si référence/lien → dans `Ressources/<domaine>/` ?
- [ ] **Mémoire** : si décision technique → entrée dans `memory/<domaine>.md` ?
- [ ] **Tracking** : si tâche → cochée `[x]` dans `Projets/<slug>/tracking.md` ?
- [ ] **Journal** : entrée dans `Journal/Daily/<YYYY>/<YYYY-MM-DD>.md` ?
- [ ] **Références croisées** : section `Références croisées automatiques` complétée ?
- [ ] **Imports bruts** : sources brutes référencées + reliées aux tâches/artefacts/journal ?

**C. Vérifier les principes IPCRAE**
- [ ] Tags frontmatter présents sur les notes créées ?
- [ ] Sources citées (format `project:<slug>/chemin`) ?
- [ ] Liens wikilinks vers les notes liées ?
- [ ] Pas de chemin absolu hardcodé ?

### Étape 3 : Créer les éléments manquants
Pour chaque manque identifié :
- [ ] Créer la note Knowledge/Zettelkasten/Process/Ressource manquante
- [ ] Mettre à jour la mémoire domaine si décision non documentée
- [ ] Mettre à jour le tracking si tâche non cochée

### Étape 4 : Archiver les demandes traitées
Pour chaque demande dont toutes les actions sont cochées `[x]` :
- [ ] Changer le statut frontmatter : `status: traite`
- [ ] Déplacer vers `Inbox/demandes-brutes/traites/YYYY-MM-DD-<slug>.md`

### Étape 5 : Mesurer et rapporter
- [ ] Relancer `ipcrae-audit-check` → score après corrections
- [ ] Documenter le delta dans `memory/devops.md`
- [ ] Commit : `git -C $IPCRAE_ROOT add -A && ipcrae close devops --project IPCRAE`

## Sorties attendues
- Demandes non traitées identifiées et complétées
- Knowledge, Process, Zettelkasten créés pour chaque concept manquant
- Mémoire domaine à jour
- Demandes traitées archivées dans `traites/`
- Score vault ≥ 36/40

## Automatisation (évolution recommandée)
- Cible : `ipcrae demandes verify` (vue macro programmable)
- Entrées : `Inbox/demandes-brutes/` + frontmatter + `Références croisées automatiques`
- Sorties : statut par demande (`satisfaite|partielle|bloquée`), manques, artefacts absents, résumé global
- Le process présent reste la référence fonctionnelle (contrat métier) en attendant l'automatisation CLI.

## Definition of Done
- [ ] Zéro demande avec statut `en-cours` dans `Inbox/demandes-brutes/`
- [ ] Chaque action de chaque demande cochée `[x]`
- [ ] Score vault ≥ 36/40
- [ ] `ipcrae close` exécuté

## Fréquence recommandée
- **Post-session** : systématiquement (inclus dans `Process/session-close.md` step 6 optionnel)
- **Hebdomadaire** : pendant la revue weekly
- **Manuel** : quand l'utilisateur le demande

## Agent IA recommandé
Claude Code (général) — ce process est transversal

## Liens
- [[capture-demande-brute]] — Comment les demandes sont capturées
- [[Process/reexamen-fin-traitement-demande]] — Réexamen micro d'une demande courante
- [[auto-amelioration-ipcrae]] — Mode auto-amélioration
- [[Process/session-close]] — Clôture de session
- [[Process/auto-amelioration]] — Process d'audit complet
