---
type: process
tags: [ipcrae, ia, llm, reasoning-effort, pretraitement, process]
domain: all
status: active
created: 2026-02-23
updated: 2026-02-23
---

# Process — Calibrage de l'Effort de Raisonnement

## 1) Fréquence + déclencheur
- **Temporalité** : on-trigger (au début de chaque demande non triviale)
- **Déclencheur précis** : toute demande impliquant >1 étape, incertitude, risque de perte, production, rebase/merge, architecture, diagnostic complexe
- **Temps actuel (baseline)** : 15-45 secondes de pré-traitement

## 2) Inputs
### Inputs dynamiques (variables à chaque exécution)
- Demande utilisateur
- Complexité estimée (`simple|standard|complexe|critique`)
- Risque (perte de données, prod, sécurité)
- Réversibilité de l'action
- Réglage visible ou non dans l'interface / wrapper

### Inputs statiques (références, règles, templates)
- `Knowledge/patterns/calibrage-effort-raisonnement-agent.md`
- `Knowledge/patterns/pretraitement-demande-ipcrae.md`
- `Process/decomposition-demande.md`
- `Process/session-close.md`

## 3) Étapes (checklist exécutable)
- [ ] Classer la demande (`simple`, `standard`, `complexe`, `critique`)
- [ ] Évaluer les modulateurs de risque (perte de données, irréversibilité, prod, sécurité)
- [ ] Déduire le niveau d'effort recommandé (`low|medium|high|extra high`)
- [ ] Vérifier si l'agent peut modifier le réglage
- [ ] Si non modifiable : annoncer le niveau recommandé + compenser via méthode (plan, vérifs, anti-perte)
- [ ] Tracer la décision dans la réponse (au moins 1 ligne)
- [ ] Si la politique évolue : mettre à jour `Knowledge/` et/ou ce process

## 4) Output attendu
- **Format attendu** : mini-bloc “Calibrage effort de raisonnement”
- **Destination du fichier** : réponse utilisateur + éventuellement `memory/system.md` si apprentissage méthode

### Exemple “bon output”
```markdown
Calibrage effort (recommandé): high
- Complexité: complexe (debug multi-fichiers)
- Risque: moyen (pas de suppression)
- Action: je ne peux pas changer le réglage UI, je compense avec plan + vérifications
```

### Exemple “mauvais output”
```markdown
Je vais réfléchir.
```

## 5) Méthode (obligatoire)
- **Critères de qualité** :
  - Niveau recommandé cohérent avec complexité + risque
  - Limite de contrôle (UI non modifiable) explicitée si applicable
  - Vérifications renforcées sur tâches critiques
- **Ce qu'il faut toujours faire** :
  - Préférer `high` ou `extra high` si doute sur risque de perte
  - Rappeler la règle “ne jamais perdre de données”
- **Ce qu'il faut éviter** :
  - Utiliser `low` sur une tâche de migration/rebase/incident
  - Supposer que le paramètre est modifiable sans preuve
- **Style attendu** : factuel, court, orienté action

## 6) Décision d’exécution (arbre agent vs automatisation)
- **Mode** : agent-supervisé (avec future automatisation possible)
- **Niveau de supervision** : faible sur tâches simples, élevé sur critiques
- **Validation humaine obligatoire ?** oui, si changement de réglage UI manuel est requis

## 7) Paramètres d’exécution (agent spec)
- **Agent** : tous (focus devops/system)
- **Context tags** : [project:ipcrae, process, ia]
- **Output path** : `memory/system.md` (si apprentissage durable) + `Knowledge/` pour la politique
- **Collector script (optionnel)** : futur `ipcrae-effort-policy` (helper recommandation)

## 8) Dernière exécution
- **Date** : 2026-02-23
- **Résumé** : Création du process + intégration dans la méthode suite à demande utilisateur
- **Fichier produit** : `Knowledge/patterns/calibrage-effort-raisonnement-agent.md`

