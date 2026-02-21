# Auto-Audit IPCRAE - Système d'Auto-Évaluation

**Dernière mise à jour**: 2026-02-21
**Statut**: 🟡 En Développement

## Objectif
Ce document définit le système d'auto-audit pour vérifier la conformité des agents IA avec la méthode IPCRAE.

## Critères d'Évaluation IPCRAE

### 1. Fonctionnement IA (Core AI Functioning)

| Critère | Oui/Non | Justification |
|---------|---------|---------------|
| Transformer chaque demande en résultat actionnable | ⬜ | |
| Protéger la mémoire long terme contre le bruit court terme | ⬜ | |
| Rendre chaque décision traçable (contexte → décision → preuve → prochain pas) | ⬜ | |
| Clarifier l'intention avant d'agir | ⬜ | |
| Optimiser le prompt utilisateur (OBLIGATOIRE) | ⬜ | |
| Diagnostiquer le contexte minimal | ⬜ | |
| Agir avec étapes vérifiables | ⬜ | |
| Valider avec tests/risques/rollback | ⬜ | |
| Mémoriser durable vs temporaire | ⬜ | |

### 2. Mémoire IPCRAE (Memory Method)

| Critère | Oui/Non | Justification |
|---------|---------|---------------|
| Utilisation de la matrice de décision mémoire | ⬜ | |
| Information valable > 1 projet ? → Knowledge/ | ⬜ | |
| Information spécifique stack/projet ? → memory/ | ⬜ | |
| Information volatile ? → local-notes/ | ⬜ | |
| Frontmatter YAML avec tags normalisés | ⬜ | |
| Tags normalisés (minuscules, tirets, pas d'espaces) | ⬜ | |
| Provenance projet via `project:` | ⬜ | |
| Hygiène mémoire (éviter doublons) | ⬜ | |

### 3. Workflow IPCRAE (Agile + GTD)

| Critère | Oui/Non | Justification |
|---------|---------|---------------|
| Pipeline complet: Ingest → Prompt Opt → Plan → Construire → Review → Consolidate | ⬜ | |
| Prompt Optimization (OBLIGATOIRE) | ⬜ | |
| 1 objectif principal + critères de done | ⬜ | |
| Micro-étapes testables | ⬜ | |
| Traçabilité des décisions (quoi/pourquoi) | ⬜ | |
| Vérification qualité, risques, impacts croisés | ⬜ | |
| Consolidation et Commit (OBLIGATOIRE) | ⬜ | |
| Promotion du durable vers mémoire globale | ⬜ | |
| Documentation de toutes les features terminées | ⬜ | |
| Git commit sur tous les fichiers modifiés | ⬜ | |

### 4. Définition de Done IA (STRICTE)

| Critère | Oui/Non | Justification |
|---------|---------|---------------|
| Livrable répond à la demande | ⬜ | |
| Vérifications exécutées ou absence justifiée | ⬜ | |
| Documentation dans le système de fichiers | ⬜ | |
| Classification correcte (local/projet/global) | ⬜ | |
| Mise à jour du tracking ([x] dans tracking.md) | ⬜ | |
| Tous les fichiers modifiés commités | ⬜ | |
| Prochain pas nommé | ⬜ | |

## Métriques de Conformité

- **Score Global**: X/40
- **Score Fonctionnement IA**: X/9
- **Score Mémoire**: X/8
- **Score Workflow**: X/10
- **Score Définition de Done**: X/13

## Indicateurs de Problème

### 🔴 Critique (Doit corriger immédiatement)
- ❌ Pas de Prompt Optimization
- ❌ Pas de Git Commit après modifications
- ❌ Pas de documentation dans le cerveau
- ❌ Pas de suivi du tracking

### 🟡 Important (Doit corriger)
- ⚠️ Pas de traçabilité des décisions
- ⚠️ Pas de classification mémoire correcte
- ⚠️ Pas de vérifications complètes
- ⚠️ Pas de micro-étapes testables

### 🟢 Mineur (À améliorer)
- ℹ️ Tags non normalisés
- ℹ️ Frontmatter incomplet
- ℹ️ Prochain pas non nommé

## Règles Anti-Hallucination

- ⬜ Ne jamais inventer d'API, commande, norme
- ⬜ Indiquer explicitement si non vérifiable en live
- ⬜ Privilégier version safe puis optimisée

## Actions Correctives

### Pour les critères critiques:
1. [ ] Ajouter Prompt Optimization avant chaque exécution
2. [ ] Créer Git Commit après chaque modification
3. [ ] Documenter dans `.ipcrae-project/memory/`
4. [ ] Mettre à jour le tracking

### Pour les critères importants:
1. [ ] Ajouter traçabilité des décisions
2. [ ] Classifier correctement dans la matrice mémoire
3. [ ] Ajouter vérifications complètes
4. [ ] Décomposer en micro-étapes

### Pour les critères mineurs:
1. [ ] Normaliser les tags
2. [ ] Compléter le frontmatter
3. [ ] Nommer le prochain pas

## Exemple de Rapport d'Audit

```
📊 RAPPORT D'AUTO-AUDIT IPCRAE
==============================

Date: 2026-02-21
Agent: Kilo Code (Architect Mode)
Contexte: Test du système IPCRAE

SCORE GLOBAL: 18/40 (45%)

Fonctionnement IA: 5/9
- ✅ Transformer en résultat actionnable
- ✅ Protéger mémoire long terme
- ✅ Rendre décisions traçables
- ✅ Clarifier intention
- ✅ Optimiser prompt (OUI)
- ❌ Diagnostiquer contexte minimal
- ❌ Agir avec étapes vérifiables
- ❌ Valider avec tests
- ❌ Mémoriser durable

Mémoire IPCRAE: 4/8
- ✅ Utilisation matrice décision
- ✅ Information spécifique projet
- ✅ Information volatile
- ✅ Tags normalisés
- ❌ Frontmatter complet
- ❌ Provenance projet
- ❌ Hygiène mémoire

Workflow IPCRAE: 3/10
- ✅ Pipeline complet
- ✅ Prompt Optimization
- ✅ 1 objectif principal
- ❌ Micro-étapes testables
- ❌ Traçabilité décisions
- ❌ Vérifications complètes
- ❌ Consolidation et Commit
- ❌ Promotion durable
- ❌ Documentation features
- ❌ Git commit

Définition de Done: 6/13
- ✅ Livrable répond demande
- ✅ Vérifications exécutées
- ✅ Documentation fichiers
- ✅ Classification correcte
- ✅ Mise à jour tracking
- ✅ Fichiers commités
- ❌ Prochain pas nommé

🔴 CRITIQUES:
1. Pas de Git commit après modifications
2. Pas de documentation dans le cerveau
3. Pas de suivi du tracking

🟡 IMPORTANTS:
1. Pas de traçabilité des décisions
2. Pas de vérifications complètes
3. Pas de micro-étapes testables

🟢 MINEURS:
1. Prochain pas non nommé

RECOMMANDATIONS:
1. Implémenter système d'auto-audit intégré
2. Ajouter vérifications automatiques IPCRAE
3. Créer scripts de validation IPCRAE
4. Intégrer IPCRAE dans les prompts système
```

## Intégration dans le Workflow

### Phase 1: Audit Initial
- [ ] Exécuter l'audit sur les documents existants
- [ ] Identifier les écarts
- [ ] Documenter les corrections nécessaires

### Phase 2: Corrections
- [ ] Corriger les comportements manquants
- [ ] Implémenter les règles IPCRAE
- [ ] Créer les scripts d'audit

### Phase 3: Validation
- [ ] Tester le système d'audit
- [ ] Vérifier la conformité après corrections
- [ ] Documenter les résultats

## Conclusion

Ce système d'auto-audit permettra de:
1. Garantir la conformité IPCRAE des agents IA
2. Identifier rapidement les comportements incorrects
3. Corriger les écarts avant qu'ils ne deviennent des habitudes
4. Maintenir la qualité et la reproductibilité du travail IA
