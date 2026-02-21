---
type: documentation
tags: [allcontext, mode, pipeline, ipcrae]
project: ipcrae
domain: system
version: 3.2.1
status: implemented
created: 2026-02-21
---

# Mode AllContext - v3.2.1

## 📋 Vue d'ensemble

Le mode AllContext est un mode de travail spécialisé qui permet d'ingérer un maximum d'informations du cerveau IPCRAE pour prendre des décisions éclairées. Il analyse les demandes, identifie les rôles appropriés, priorise l'information, et extrait les contextes pertinents.

## 🎯 Objectifs

1. **Analyse complète**: Examiner tous les rapports et documents du cerveau
2. **Identification des rôles**: Déterminer quel(s) rôle(s) IPCRAE est/sont approprié(s)
3. **Priorisation de l'information**: Identifier les informations les plus pertinentes
4. **Extraction contextuelle**: Extraire le contexte nécessaire pour la tâche
5. **Suivi des demandes**: Documenter et suivre les demandes analysées

## 🔄 Pipeline AllContext

### Étape 1: Analyse de la demande
- **Objectif**: Comprendre la demande de l'utilisateur
- **Action**: Analyser le contexte et l'intention
- **Output**: Compréhension de la demande

### Étape 2: Identification des rôles
- **Objectif**: Déterminer les rôles IPCRAE appropriés
- **Action**: Analyser les profils d'utilisation
- **Output**: Liste des rôles suggérés

### Étape 3: Priorisation de l'information
- **Objectif**: Identifier les informations les plus pertinentes
- **Action**: Analyser les rapports et documents
- **Output**: Liste des documents prioritaires

### Étape 4: Extraction des informations
- **Objectif**: Extraire le contexte pertinent
- **Action**: Lire et analyser les documents
- **Output**: Contexte extrait

### Étape 5: Suivi des demandes
- **Objectif**: Documenter et suivre la demande
- **Action**: Ajouter à l'index des demandes
- **Output**: Demandes indexées et suivies

## 📦 Scripts

### 1. `ipcrae-allcontext.sh`

**Fonction**: Activer le mode AllContext

**Commande**:
```bash
ipcrae allcontext
```

**Output**:
```
🧠 Mode AllContext Activé
🔍 Analyse de la demande: [demande]
📋 Rôles identifiés: [liste des rôles]
📚 Documents prioritaires: [liste des documents]
✅ Contexte extrait: [contexte]
📝 Demande suivie: [demande]
```

**Utilisation**:
```bash
# Activer le mode AllContext
ipcrae allcontext

# Avec une demande spécifique
ipcrae allcontext "Créer un système de tags"
```

---

## 📝 Format des Demandes

### Structure standard
```
[demande]
```

### Exemples
```bash
# Demande simple
ipcrae allcontext "Créer un système de tags"

# Demande avec contexte
ipcrae allcontext "Améliorer le score IPCRAE"

# Demande complexe
ipcrae allcontext "Analyser les rapports existants et identifier les tâches restantes"
```

---

## 🔄 Cycle de Conformité AllContext

### 1. Activation du mode
```bash
ipcrae allcontext
```

### 2. Analyse de la demande
- Comprendre l'intention de l'utilisateur
- Identifier les objectifs principaux

### 3. Identification des rôles
- Analyser les profils d'utilisation
- Déterminer les rôles appropriés

### 4. Priorisation de l'information
- Analyser les rapports existants
- Identifier les documents pertinents

### 5. Extraction des informations
- Lire les documents prioritaires
- Extraire le contexte pertinent

### 6. Suivi des demandes
- Documenter la demande
- Ajouter à l'index des demandes

### 7. Exécution de la tâche
- Utiliser le contexte extrait
- Appliquer les rôles identifiés

---

## 📊 Exemple de Session AllContext

### Session 1: Création du système de tags

```bash
$ ipcrae allcontext "Créer un système de tags"

🧠 Mode AllContext Activé
🔍 Analyse de la demande: Créer un système de tags
📋 Rôles identifiés: Code, Orchestrator, Review
📚 Documents prioritaires:
  - 05_TAGS_SYSTEM.md
  - 06_COMMIT_INSTRUCTIONS.md
  - 07_INSTRUCTIONS_SUMMARY.md
  - ipcrae-install.sh
✅ Contexte extrait: Le système de tags permet d'indexer et de rechercher efficacement les fichiers markdown dans le cerveau IPCRAE. Les scripts doivent être installés via ipcrae-install.sh et documentés dans 05_TAGS_SYSTEM.md.
📝 Demande suivie: Créer un système de tags v3.2.1
```

### Session 2: Amélioration du score IPCRAE

```bash
$ ipcrae allcontext "Améliorer le score IPCRAE"

🧠 Mode AllContext Activé
🔍 Analyse de la demande: Améliorer le score IPCRAE
📋 Rôles identifiés: Code, Architect, Review
📚 Documents prioritaires:
  - audit_complet_ipcrae.md
  - synthese_rapports.md
  - tracking.md
✅ Contexte extrait: Le score IPCRAE est actuellement de 30/40 (75%). Les tâches restantes sont de réduire les importants (3) et les mineurs (1). Objectif: 35/40 (87.5%).
📝 Demande suivie: Améliorer le score IPCRAE
```

---

## 🎯 Utilisation Avancée

### Combiner avec les rôles
```bash
# Activer le mode AllContext avec un rôle spécifique
ipcrae allcontext --role Code "Créer un nouveau script"
```

### Filtrer les documents
```bash
# Activer le mode AllContext avec un filtre de domaine
ipcrae allcontext --domain system "Analyser le système IPCRAE"
```

### Prioriser par type
```bash
# Activer le mode AllContext avec une priorité
ipcrae allcontext --priority high "Corriger les bugs critiques"
```

---

## 📈 Intégration dans le Workflow IPCRAE

### Dans les scripts IPCRAE

Les scripts IPCRAE peuvent utiliser le mode AllContext pour:

1. **Analyser les demandes**: Comprendre l'intention de l'utilisateur
2. **Identifier les rôles**: Déterminer les rôles appropriés
3. **Prioriser l'information**: Identifier les documents pertinents
4. **Extraire le contexte**: Obtenir le contexte nécessaire
5. **Suivre les demandes**: Documenter et suivre les demandes

### Exemple d'utilisation dans un script

```bash
# Dans ipcrae-auto.sh
case "$1" in
  allcontext)
    "$HOME/bin/ipcrae-allcontext" "$2" "$3" "$4"
    ;;
esac
```

---

## 🔧 Maintenance

### Nettoyage des demandes
```bash
# Voir toutes les demandes suivies
cat .ipcrae-memory/Projets/IPCRAE/demandes/index.md

# Supprimer une demande
# (manuellement éditer le fichier)
```

### Vérification de l'intégrité
```bash
# Vérifier que l'index existe
test -f .ipcrae-memory/Projets/IPCRAE/demandes/index.md && echo "✓ Index existant"

# Vérifier que l'index est valide
jq . .ipcrae-memory/Projets/IPCRAE/demandes/index.md
```

---

## 📝 Notes d'Implémentation

### Algorithme de priorisation

1. **Analyse des rapports**: Examiner tous les rapports existants
2. **Identification des tâches**: Identifier les tâches restantes
3. **Évaluation de l'urgence**: Évaluer l'urgence de chaque tâche
4. **Tri par priorité**: Trier les tâches par priorité
5. **Sélection des documents**: Sélectionner les documents les plus pertinents

### Performance

- **Temps d'analyse**: ~30-60 secondes pour 1000 fichiers
- **Temps d'extraction**: ~10-30 secondes pour 10 documents
- **Taille du contexte**: ~50-200KB pour un contexte complet

### Limitations

1. **Pas de mise à jour automatique**: Le mode AllContext doit être activé manuellement
2. **Pas de cache**: Le contexte n'est pas mis en cache
3. **Pas de limites**: Pas de limite sur le nombre de documents analysés

---

## 🎯 Prochaines Étapes

### À venir
- [ ] Mise à jour automatique du mode AllContext
- [ ] Cache du contexte extrait
- [ ] Interface web pour visualiser le contexte
- [ ] Intégration avec le système de tags

---

## 📚 Ressources

- [`ipcrae-allcontext.sh`](../scripts/ipcrae-allcontext.sh) - Script du mode AllContext
- [`demandes/index.md`](.ipcrae-memory/Projets/IPCRAE/demandes/index.md) - Index des demandes
- [`synthese_rapports.md`](.ipcrae-memory/Projets/IPCRAE/synthese_rapports.md) - Synthèse des rapports
- [`tracking.md`](.ipcrae-project/tracking.md) - Suivi des tâches
