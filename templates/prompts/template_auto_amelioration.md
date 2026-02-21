---
type: template
tags: [ipcrae, auto-amelioration, template, rapport]
project: ipcrae
domain: system
status: active
created: 2026-02-21
updated: 2026-02-21
---

# Template de Rapport d'Auto-Amélioration IPCRAE

**Ce template définit le format standard pour les rapports d'auto-amélioration des agents IPCRAE.**

---

## 📊 Rapport d'Auto-Amélioration - [Agent]

**Date**: [YYYY-MM-DD]
**Mode**: [Activé/Désactivé]
**Fréquence**: [Quotidien/Hebdomadaire/Mensuel]

---

## 📈 Évolution du Score

### Score Initial
- **Score**: [X/40] ([X%])
- **Critiques**: [X/3]
- **Importants**: [X/3]
- **Mineurs**: [X/1]

### Score Final
- **Score**: [X/40] ([X%])
- **Critiques**: [X/3]
- **Importants**: [X/3]
- **Mineurs**: [X/1]

### Amélioration
- **Points**: [+X points] ([+X%])
- **Critiques résolus**: [X/3] ([X%])
- **Vitesse d'amélioration**: [X points/audit]

---

## 🔴 Critiques (Doit être 0)

### [ ] Git commit après modifications
- **État**: [✅ Corrigé / ❌ Non corrigé]
- **Action**: [Description de l'action appliquée]

### [ ] Documentation dans le cerveau
- **État**: [✅ Corrigé / ❌ Non corrigé]
- **Action**: [Description de l'action appliquée]

### [ ] Suivi du tracking
- **État**: [✅ Corrigé / ❌ Non corrigé]
- **Action**: [Description de l'action appliquée]

---

## 🟡 Importants (Doit être 0)

### [ ] Traçabilité des décisions
- **État**: [✅ Corrigé / ❌ Non corrigé]
- **Action**: [Description de l'action appliquée]

### [ ] Vérifications complètes
- **État**: [✅ Corrigé / ❌ Non corrigé]
- **Action**: [Description de l'action appliquée]

### [ ] Micro-étapes testables
- **État**: [✅ Corrigé / ❌ Non corrigé]
- **Action**: [Description de l'action appliquée]

---

## 🟢 Mineurs (Doit être 0)

### [ ] Prochain pas nommé
- **État**: [✅ Corrigé / ❌ Non corrigé]
- **Action**: [Description de l'action appliquée]

---

## 📋 Actions Appliquées

### Corrections Critiques
1. ✅ [Description de la correction critique appliquée]
2. ✅ [Description de la correction critique appliquée]
3. ✅ [Description de la correction critique appliquée]

### Corrections Importantes
1. [ ] [Description de la correction importante planifiée]
2. [ ] [Description de la correction importante planifiée]
3. [ ] [Description de la correction importante planifiée]

### Corrections Mineures
1. [ ] [Description de la correction mineure planifiée]

---

## 🎯 Objectifs IPCRAE

### Fonctionnement IA
- [ ] Transformer chaque demande en résultat actionnable
- [ ] Protéger la mémoire long terme contre le bruit court terme
- [ ] Rendre chaque décision traçable (contexte → décision → preuve → prochain pas)
- [ ] Clarifier l'intention avant d'agir
- [ ] Optimiser le prompt utilisateur (OBLIGATOIRE)
- [ ] Diagnostiquer le contexte minimal
- [ ] Agir avec étapes vérifiables
- [ ] Valider avec tests/risques/rollback
- [ ] Mémoriser durable vs temporaire

### Mémoire IPCRAE
- [ ] Utilisation de la matrice de décision mémoire
- [ ] Information valable > 1 projet ? → Knowledge/
- [ ] Information spécifique stack/projet ? → memory/
- [ ] Information volatile ? → local-notes/
- [ ] Frontmatter YAML avec tags
- [ ] Tags normalisés (minuscules, tirets, pas d'espaces)
- [ ] Provenance projet via project:
- [ ] Hygiène mémoire (éviter doublons)

### Workflow IPCRAE
- [ ] Pipeline complet: Ingest → Prompt Opt → Plan → Construire → Review → Consolidate
- [ ] Prompt Optimization (OBLIGATOIRE)
- [ ] 1 objectif principal + critères de done
- [ ] Micro-étapes testables
- [ ] Traçabilité des décisions (quoi/pourquoi)
- [ ] Vérification qualité, risques, impacts croisés
- [ ] Consolidation et Commit (OBLIGATOIRE)
- [ ] Promotion du durable vers mémoire globale
- [ ] Documentation de toutes les features terminées
- [ ] Git commit sur tous les fichiers modifiés

### Définition de Done IA (STRICTE)
- [ ] Livrable répond à la demande
- [ ] Vérifications exécutées ou absence justifiée
- [ ] Documentation dans le système de fichiers
- [ ] Classification correcte (local/projet/global)
- [ ] Mise à jour du tracking ([x] dans tracking.md)
- [ ] Tous les fichiers modifiés commités
- [ ] Prochain pas nommé

---

## 🔄 Prochaines Étapes

### Court Terme (1 semaine)
- **Objectif**: Score de 35/40 (87.5%)
- **Actions**:
  - [ ] [Action spécifique]
  - [ ] [Action spécifique]
  - [ ] [Action spécifique]

### Moyen Terme (1 mois)
- **Objectif**: Score de 38/40 (95%)
- **Actions**:
  - [ ] [Action spécifique]
  - [ ] [Action spécifique]
  - [ ] [Action spécifique]

### Long Terme (3 mois)
- **Objectif**: Score de 39/40 (97.5%)
- **Actions**:
  - [ ] [Action spécifique]
  - [ ] [Action spécifique]
  - [ ] [Action spécifique]

---

## 📊 Indicateurs de Performance

### Score IPCRAE
- **Score Total**: [X/40] ([X%])
- **Fonctionnement IA**: [X/9] ([X%])
- **Mémoire IPCRAE**: [X/8] ([X%])
- **Workflow IPCRAE**: [X/10] ([X%])
- **Définition de Done IA**: [X/13] ([X%])

### Indicateurs de Conformité
- **Critiques**: [X/3] ([X%])
- **Importants**: [X/3] ([X%])
- **Mineurs**: [X/1] ([X%])

### Indicateurs d'Amélioration
- **Vitesse d'amélioration**: [X points/audit]
- **Stabilité**: [X/3 audits avec score stable]
- **Consistance**: [X/3 critiques résolus]
- **Tendances**: [En hausse / Stable / En baisse]

---

## 🎓 Règles d'Utilisation

### Règle 1: Activation Explicite
- Le mode ne peut être activé que par demande explicite de l'utilisateur
- L'agent doit confirmer l'activation
- L'utilisateur doit être informé des implications

### Règle 2: Fréquence Définie
- Par défaut: Quotidien
- Optionnel: Hebdomadaire, Mensuel
- L'utilisateur peut définir sa propre fréquence

### Règle 3: Consentement
- L'utilisateur doit consentir à l'auto-amélioration
- L'utilisateur peut à tout moment désactiver le mode
- L'utilisateur peut voir l'historique des audits

### Règle 4: Confidentialité
- Les rapports sont stockés localement
- Les données ne sont pas partagées
- L'utilisateur contrôle l'accès

### Règle 5: Transparence
- L'agent doit expliquer chaque audit
- L'agent doit expliquer chaque correction
- L'agent doit expliquer chaque amélioration

---

## 📁 Fichiers Générés

### Fichiers de Configuration
- `.ipcrae-project/memory/agent_auto_amelioration.md` - Documentation principale
- `.ipcrae-project/memory/agent_auto_amelioration_config.md` - Configuration détaillée
- `.ipcrae-project/memory/agent_auto_amelioration_history.md` - Historique des audits

### Fichiers de Tracking
- `.ipcrae-project/memory/last_audit_[agent].txt` - Dernier audit
- `.ipcrae-project/memory/last_audit_[agent].score` - Dernier score

### Scripts
- `scripts/auto_audit.sh` - Script principal d'audit
- `scripts/ipcrae-auto.sh` - Commande IPCRAE pour le mode auto-amélioration

### Templates
- `templates/prompts/template_auto_amelioration.md` - Ce template

---

## 🎯 Conclusion

Ce rapport d'auto-amélioration permet de mesurer la progression de l'agent vers la conformité IPCRAE. L'agent s'améliore continuellement en s'auto-évaluant et en appliquant les corrections identifiées.

**Score actuel**: [X/40] ([X%])
**Objectif**: 39/40 (97.5%)
**Prochain audit**: [YYYY-MM-DD]

---

## 🔄 Cycle d'Auto-Amélioration

1. **Activation**: Par demande explicite de l'utilisateur
2. **Audit Initial**: Score calculé, écarts identifiés
3. **Application des Corrections**: Corrections critiques appliquées immédiatement
4. **Nouvel Audit**: Comparaison avec l'audit initial
5. **Itération**: Répéter jusqu'à l'objectif
6. **Maintenance**: Réduire la fréquence
7. **Désactivation**: Par demande explicite de l'utilisateur

---

**Note**: Ce rapport est généré automatiquement par le mode d'auto-amélioration IPCRAE.
