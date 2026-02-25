---
type: prompt
tags: [ipcrae, regle0, gate, pretraitement, session, conformite]
domain: devops
status: active
created: 2026-02-25
sources:
  - vault:.ipcrae/prompts/core_ai_functioning.md
  - vault:.ipcrae/prompts/core_ai_workflow_ipcra.md
  - vault:Knowledge/patterns/pretraitement-demande-ipcrae.md
  - vault:Knowledge/howto/openclaw-ipcrae-integration.md
---

# 🚨 RÈGLE 0 — Gate de Pré-traitement IPCRAE

> **Ce fichier est injecté en tête de chaque session agent.**
> Il représente la gate obligatoire avant toute réponse ou exécution.
> Source de vérité : `core_ai_functioning.md` + `core_ai_workflow_ipcra.md`

---

## Séquence obligatoire (dans l'ordre)

### Étape 1 — Audit de santé (si session fraîche)
- Proposer `ipcrae-audit-check` si score inconnu
- Si score < 35/40 ou problème critique détecté → résolution prioritaire avant tout

### Étape 2 — Lire (dans l'ordre, sélectif)
1. `.ipcrae/context.md` — identité, structure, projets actifs
2. `core_ai_functioning.md` — mission + contrat d'exécution
3. `core_ai_workflow_ipcra.md` — pipeline obligatoire
4. `core_ai_memory_method.md` — gouvernance mémoire
5. `agent_<domaine>.md` — spécialisation si domaine identifié

### Étape 3 — Capturer la demande brute (OBLIGATOIRE avant tout)

Créer dans `Inbox/demandes-brutes/<slug-YYYYMMDD-HHMM>.md` :

```yaml
---
type: demande-brute
date: YYYY-MM-DD HH:MM
status: en-cours
project: <slug-projet>
domain: <devops|electronique|musique|maison|finance|sante>
---
# Demande brute
<contenu exact de la demande utilisateur>
```

### Étape 4 — Construire le prompt optimisé

Ne jamais répondre directement à la demande brute. Reconstruire avec :
- **Objectif explicite** : reformuler en livrable mesurable
- **Contexte projet** : mémoire domaine, phase active, tracking
- **Contraintes** : sécurité, réversibilité, budget tokens
- **Format de sortie** et critères de done
- **Niveau d'effort recommandé** : low / medium / high / extra-high

### Étape 5 — Exécuter avec traçabilité

Pour chaque action significative (décision, étape, bug résolu) :
- Écrire dans `memory/<domaine>.md` (décision durable)
- Cocher `[x]` dans `tracking.md` du projet
- Committer le cerveau : `git add -A && git commit` (ou `ipcrae checkpoint`)

---

## Template de décomposition (à utiliser pour toute demande > 2 actions)

```markdown
## Décomposition IPCRAE — [titre court]

**Objectif** : [livrable mesurable]
**Projet** : [slug] | **Domaine** : [domaine] | **Phase** : [phase active]

**Tâches atomiques** :
🔴 [urgent+important] ...
🟠 [important] ...

**Checks DoD** :
- [ ] Demande capturée dans Inbox/demandes-brutes/
- [ ] Tracking.md mis à jour
- [ ] Cerveau commité
- [ ] Demande déplacée vers traites/
```

---

## Rituel de clôture (fin de session ou de tâche)

1. **Résumé exécutif** (3 lignes max)
2. **Conformité IPCRAE** :
   - Capture demande : ✅/❌
   - Tracking mis à jour : ✅/❌
   - Cerveau commité : ✅/❌
   - Demande déplacée vers `traites/` : ✅/❌
3. **Coût tokens** : Bas (<2k) / Moyen (2–8k) / Élevé (>8k)
4. **Optimisation suivante** : 1 action pour réduire le coût

---

## Violations fréquentes (à éviter)

| Violation | Impact |
|-----------|--------|
| Répondre sans capture de la demande | Traçabilité perdue |
| Utiliser son propre protocole à la place d'IPCRAE | Non-conformité totale |
| Lire des fichiers non nécessaires (context bloat) | Coût tokens élevé |
| Agir sans décomposer une demande complexe | Risque d'angles morts |
| Ne pas committer le cerveau en cours de session | Info perdue si interruption |
