---
type: knowledge
tags: [ipcrae, zettelkasten, consolidation, automatisation, llm]
domain: devops
status: draft
sources:
  - path: Inbox/demandes-brutes/traites/audit-passe-finale-amelioration-2026-02-22.md
created: 2026-02-24
updated: 2026-02-24
---

# Consolidation Automatique Zettelkasten (Optimisation E)

## Problème

Les notes dans `Zettelkasten/_inbox/` s'accumulent. La curation manuelle (_inbox/ → permanents/) prend du temps et est irrégulière.

## Solution : Agent LLM de Consolidation

Pipeline automatique déclenché par `ipcrae close` ou planifié :

1. **Analyse** : lire toutes les notes `_inbox/` (sémantique + liens existants)
2. **Détection** : identifier duplications, liens manquants, notes "matures"
3. **Critères de maturité** : note ≥ 3 liens + contenu > 100 mots + âge > 7j
4. **Proposition** : liste de candidats à promouvoir vers `permanents/`
5. **Validation humaine** : l'IA propose, l'humain valide (pas d'auto-move sans confirmation)

## Commande cible

```bash
ipcrae zettel consolidate [--dry-run]
# Liste les candidats à promouvoir + les duplications détectées
```

## Impact attendu

- Notes consolidées/mois : 5 → 20
- Densité graphe de connaissances : +40%

## Liens

- [[howto/zettelkasten-workflow]] — workflow manuel de référence
- [[howto/ressources-vs-zettelkasten]] — distinction Ressources vs Zettel
