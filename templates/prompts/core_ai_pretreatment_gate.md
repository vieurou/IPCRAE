# 🚨 Gate de Pré-traitement — MANDATORY FIRST STEP

> Gate NON-NÉGOCIABLE avant toute action technique.

## Séquence obligatoire (optimisée)

### Étape 1 — Identifier le contexte actif
- Projet ciblé (`.ipcrae-project/`, hub projet, `docs/conception/`).
- Phase/objectif courant (`Phases/index.md`, tracking, TODO session).

### Étape 2 — Charger la mémoire minimale utile
- Mémoire domaine (`memory/<domaine>.md`).
- Mémoire locale projet (`.ipcrae-project/memory/`).
- Si absent : noter explicitement le mode dégradé (ne pas bloquer).

### Étape 3 — Recherche tag-first
- Chercher dans `Knowledge/` (tags/frontmatter).
- Vérifier si un process/runbook existe déjà.
- Réutiliser avant de recréer.

### Étape 4 — Construire le prompt d'exécution
Formuler avant d'agir :
- **Objectif livrable** (sortie attendue).
- **Contexte retenu** (faits réellement lus).
- **Contraintes** (techniques, sécurité, compatibilité).
- **Definition of Done** (tests/checks de validation).
- **Niveau d'effort** : `low | medium | high | extra high`.

### Étape 5 — Exécuter avec traçabilité
- Découper en étapes testables.
- Mettre à jour les artefacts de suivi au fil de l'eau.
- Vérifier avant clôture (tests + cohérence doc/code).

---

## Mode dégradé autorisé (important)
Si certaines sources sont absentes (`memory`, `Knowledge`, `Phases`) :
1. le signaler explicitement,
2. continuer avec hypothèses minimales,
3. proposer la création des artefacts manquants.

## Signal de compliance attendu
Avant livraison, pouvoir répondre :
1. Quels fichiers/contextes ont été consultés ?
2. Quelles connaissances existantes ont été réutilisées ?
3. Quels tests/checks confirment le résultat ?

Si une réponse manque, le gate n'est pas complet.
