---
type: knowledge
tags: [ipcrae, ia, llm, reasoning-effort, parametres, auto-amelioration, process]
project: IPCRAE
domain: system
status: active
sources:
  - project:IPCRAE/Process/calibrage-effort-raisonnement.md
  - vault:memory/system.md
created: 2026-02-23
updated: 2026-02-23
---

# Pattern : Calibrage de l'effort de raisonnement (LLM) par complexité

## Problème

Le paramètre `reasoning effort` (ou équivalent) a un impact réel sur :
- la profondeur d'analyse,
- la latence,
- le coût,
- la robustesse sur les tâches complexes / ambiguës.

Sans politique explicite, on obtient souvent :
- surcoût sur les tâches simples,
- sous-réflexion sur les tâches critiques,
- comportement incohérent selon l'agent ou l'humeur de session.

## Contraintes importantes

- L'agent **ne peut pas modifier lui-même** un réglage UI de chat configuré par l'utilisateur.
- L'agent peut :
  - recommander un niveau,
  - adapter sa méthode (plus ou moins de planification / vérification),
  - appliquer automatiquement le paramètre **si** le wrapper/API expose ce réglage.

## Politique recommandée (pragmatique)

### 1) Classification de tâche

- `simple` : une action, faible risque, résultat facilement réversible
- `standard` : 2-5 actions, quelques fichiers, validation simple
- `complexe` : multi-fichiers / architecture / root cause incertaine
- `critique` : risque élevé (prod, données, migration, sécurité, rebase complexe)

### 2) Mapping effort conseillé

- `simple` → `low`
- `standard` → `medium`
- `complexe` → `high`
- `critique` → `extra high`

### 3) Modulateurs (surclasser d'un niveau si présent)

- Données difficiles à récupérer / risque de perte
- Forte incertitude (causes multiples plausibles)
- Domaine à forte contrainte (prod, sécurité, santé, finance, juridique)
- Besoin de décision irréversible (migration, suppression, rebase)

## Fallback si aucun réglage n'est fourni

Si le paramètre n'est pas visible / non réglable pendant la session :
- l'agent **déclare explicitement** le niveau recommandé,
- applique une méthode équivalente :
  - plus de pré-traitement,
  - plan plus détaillé,
  - plus de vérifications,
  - validation anti-perte avant actions risquées.

## Ce qu'il faut stocker (IPCRAE)

### Question brute utilisateur (volatile)
- `Tasks/to_ai/task-<timestamp>.md` ou `Inbox/demandes-brutes/`

### Réponse durable réutilisable
- `Knowledge/patterns/` (ce fichier)

### Procédure récurrente
- `Process/calibrage-effort-raisonnement.md`

### Trace de session / décisions de méthode
- `memory/system.md` (résumé daté)

## Heuristique "idéale" (base de travail)

- Par défaut : `medium`
- Dev/debug non trivial : `high`
- Incident prod / rebase / compaction mémoire / migration : `extra high`
- Édits répétitifs / renommages / formatting : `low`

## Liens

- [[Process/calibrage-effort-raisonnement]]
- [[auto-amelioration-ipcrae]]
- [[pretraitement-demande-ipcrae]]

