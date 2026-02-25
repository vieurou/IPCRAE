---
type: process
tags: [ipcrae, demande, verification, satisfaction, decomposition, traçabilité, process]
domain: all
status: active
created: 2026-02-23
updated: 2026-02-23
---

# Process — Réexamen de Fin de Traitement d'une Demande

## Déclencheur

- **Avant la réponse finale** pour toute demande non triviale (décomposée en plusieurs actions)
- Après exécution d'un plan ou d'une décomposition (`Process/decomposition-demande`)
- Quand l'utilisateur demande explicitement "tout est fait ?" / "as-tu bien répondu à tout ?"

## Objectif

Vérifier en **boucle fermée** que la demande brute a été satisfaite **entièrement** après décomposition, en reliant :
- la demande verbatim,
- les sous-actions exécutées,
- les artefacts produits,
- la mémoire/journal/tracking mis à jour,
- les points éventuellement non couverts.

## Inputs

- Demande brute capturée (`Tasks/to_ai/task-*.md` ou `Inbox/demandes-brutes/*.md`)
- Décomposition/plan publié
- Diff Git / fichiers modifiés
- Réponse en cours de préparation
- Artefacts IPCRAE produits (`Knowledge/`, `Process/`, `memory/`, `Journal/`, `Projets/`)

## Checklist exécutable

### 1. Recharger la demande brute (source de vérité de l'intention)
- [ ] Relire le texte verbatim de la demande
- [ ] Identifier les attentes implicites (ex: "et aussi", "au passage", "n'oublie pas")
- [ ] Identifier les critères de satisfaction explicites et implicites

### 2. Rejouer la décomposition
- [ ] Relister les actions atomiques prévues
- [ ] Vérifier que chaque action planifiée a été traitée (`[x]` / preuve)
- [ ] Identifier les actions réellement faites mais non prévues (drift d'exécution)

### 3. Vérifier la satisfaction complète (pas seulement technique)
Pour chaque sous-demande :
- [ ] Résultat produit ?
- [ ] Réponse utilisateur explicite fournie ?
- [ ] Limites/risques expliqués si non couvert à 100% ?
- [ ] Next step proposé si pertinent ?

### 4. Vérifier la traçabilité IPCRAE (relations)
- [ ] Demande brute reliée aux fichiers produits (références)
- [ ] Knowledge créée si concept réutilisable
- [ ] Process créé/mis à jour si workflow récurrent
- [ ] Mémoire domaine/système mise à jour si décision durable
- [ ] Journal/tracking mis à jour si la demande le justifie
- [ ] Section `## Références croisées automatiques` complétée (libellés stables)
- [ ] **Imports bruts** (si présents) référencés et reliés aux tâches/artefacts/journal

### 5. Statut final de la demande
- [ ] `satisfaite` (100%) OU
- [ ] `partiellement satisfaite` (avec liste explicite des manques) OU
- [ ] `bloquée` (avec blocage, preuve, action suivante)

### 6. Boucle d'amélioration méthode (si écart)
Si la demande a révélé un manque de méthode :
- [ ] créer/mettre à jour `Process/` ou `Knowledge/`
- [ ] noter l'amélioration dans `memory/system.md`
- [ ] ajouter une idée d'évolution actionnable (tracking / task)

## Output attendu (mini-bloc dans la réponse)

```markdown
Réexamen fin de traitement : OK (satisfaite)
- Demande brute relue
- 6/6 sous-actions satisfaites
- Artefacts: 1 Process, 1 Knowledge, 1 note mémoire
- Manques: aucun
```

## Sortie complémentaire (dans la demande brute)

Compléter la section :
- `## Références croisées automatiques (libellés stables)`

Cette section est la base de post-analyse et d'optimisation automatique.

## Cas "partiel" (obligatoire)

Si tout n'est pas fait, **ne pas masquer** :
- lister les points restants,
- expliquer pourquoi,
- créer une tâche explicite (`Tasks/to_ai/` ou tracking projet),
- répondre honnêtement à l'utilisateur.

## Liens

- [[Process/decomposition-demande]]
- [[Process/verification-travail]]
- [[capture-demande-brute]]
