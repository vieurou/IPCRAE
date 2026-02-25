---
type: process
tags: [securite, suppression, donnees, regle]
project: ipcrae
domain: system
status: stable
created: 2026-02-24
---

# Règle Critique : Interdiction de Suppression de Données Utilisateur

## 🚨 RÈGLE D'OR

**NE JAMAIS SUPPRIMER UN FICHIER UTILISATEUR SANS CONFIRMATION EXPLICITE ET VÉRIFICATION PRÉALABLE**

## Contexte

Le 2026-02-24, une erreur critique a été commise : un fichier contenant une demande utilisateur (`Inbox/infos à traiter/traites/2026-02-22-test-demande.md`) a été supprimé suite à une mauvaise interprétation d'une tâche de "nettoyage".

## Catégories de Fichiers PROTÉGÉS

Les fichiers suivants sont considérés comme **DONNÉES UTILISATEUR** et ne doivent JAMAIS être supprimés sans vérification explicite :

### 1. Inbox et GTD
- `Inbox/demandes-brutes/*` → **DONNÉES BRUTES** (jamais supprimer)
- `Inbox/demandes-brutes/traites/*` → **DONNÉES TRAITÉES** (jamais supprimer)
- `Inbox/infos à traiter/*` → **DONNÉES** (jamais supprimer)
- `Inbox/infos à traiter/traites/*` → **DONNÉES** (jamais supprimer)
- `Inbox/idees/*` → **IDÉES** (jamais supprimer)
- `Inbox/capture-*.md` → **CAPTURES** (jamais supprimer)
- `Inbox/waiting-for.md` → **DONNÉES** (jamais supprimer)

### 2. Projets
- `Projets/*/index.md` → **DONNÉES**
- `Projets/*/memory.md` → **DONNÉES**
- `Projets/*/tracking.md` → **DONNÉES**
- `Projets/*/demandes/*` → **DONNÉES**

### 3. Journal
- `Journal/Daily/*.md` → **DONNÉES**
- `Journal/Weekly/*.md` → **DONNÉES**
- `Journal/Monthly/*.md` → **DONNÉES**

### 4. Mémoire
- `memory/*.md` → **DONNÉES**
- `Knowledge/*` → **CONNAISSANCES** (jamais supprimer)

## Procédure OBLIGATOIRE Avant Toute Suppression

### Étape 1 : Vérification de la catégorie
1. Identifier le type de fichier (données utilisateur vs fichier système)
2. Si c'est une donnée utilisateur → **STOP** et demander confirmation

### Étape 2 : Confirmation explicite
1. Demander à l'utilisateur : "Ce fichier contient des données utilisateur. Confirmez-vous la suppression ?"
2. Attendre une réponse explicite "OUI" ou "CONFIRMER"
3. **NE PAS** accepter de réponses implicites ou vagues

### Étape 3 : Backup avant suppression
1. Créer un backup du fichier avant suppression
2. Utiliser `cp fichier.md fichier.md.bak-<timestamp>`
3. Conserver le backup pendant au moins 7 jours

### Étape 4 : Documentation
1. Documenter la suppression dans un fichier de log
2. Inclure : date, fichier, raison, confirmation utilisateur

## Exceptions AUTORISÉES

Les seuls fichiers qui peuvent être supprimés SANS confirmation explicite :

1. **Fichiers temporaires** : `*.tmp`, `*.bak-*` (après 7 jours)
2. **Fichiers système** : `.ipcrae/cache/*`, `.ipcrae/auto/*` (seulement cache)
3. **Fichiers README.md** dans les sous-dossiers (seulement si explicitement demandé)
4. **Fichiers dupliqués** : SEULEMENT si le duplicata est identique ET que l'original existe

## Checklist de Sécurité

Avant de supprimer un fichier, vérifier :

- [ ] Le fichier n'est PAS dans `Inbox/`
- [ ] Le fichier n'est PAS dans `Projets/`
- [ ] Le fichier n'est PAS dans `Journal/`
- [ ] Le fichier n'est PAS dans `memory/`
- [ ] Le fichier n'est PAS dans `Knowledge/`
- [ ] L'utilisateur a CONFIRMÉ explicitement la suppression
- [ ] Un backup a été créé
- [ ] La suppression est documentée

## Sanction en cas de non-respect

Toute suppression de données utilisateur sans respect de cette procédure est considérée comme une **ERREUR CRITIQUE** et doit :

1. Être immédiatement signalée à l'utilisateur
2. Faire l'objet d'une restauration immédiate
3. Être documentée dans un rapport d'incident
4. Déclencher une révision des règles de sécurité

## Références

- Règle dans [`../brain/.ipcrae/instructions.md:57`](../brain/.ipcrae/instructions.md:57) : "Ne jamais supprimer un fichier utilisateur sans demande explicite."
- Incident du 2026-02-24 : Suppression erronée de `Inbox/infos à traiter/traites/2026-02-22-test-demande.md`

## Mise à jour

- **Créé** : 2026-02-24 suite à l'incident de suppression
- **Statut** : STABLE (à appliquer strictement)
- **Révision** : À réviser après chaque incident de suppression
