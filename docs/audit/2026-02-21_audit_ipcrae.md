# Audit complet IPCRAE (méthode + scripts)

_Date : 2026-02-21_

## 1) Périmètre
- Documentation méthode: `README.md`, `docs/conception/*`, `docs/workflows.md`.
- Implémentation opérationnelle: `ipcrae-install.sh`, `templates/ipcrae-launcher.sh`, scripts `templates/scripts/*`.
- Robustesse minimale: `tests/test_write_safe.bats`.

## 2) Résultat exécutif
- **Méthode solide et cohérente** sur les principes (source de vérité locale, séparation brut/digéré, boucle start→work→close).
- **Niveau de maturité élevé côté structure** (vault, prompts factorisés, mémoire par domaine, migration safe).
- **Écart principal détecté** : `ipcrae daily --prep` était annoncé dans la doc mais non implémenté dans le launcher.
- **Correction appliquée** : `--prep` crée désormais une daily préremplie avec contexte automatique (hier/semaine/en attente/phase), au lieu d'échouer.

## 3) Vérification de la méthode IPCRAE (IPCRAE)

### I — Inbox
✅ Présente, avec capture timestampée et `waiting-for.md`.

### P — Projets
✅ Projet traité comme unité finie avec hub et tracking.

### C — Casquettes
✅ Responsabilités continues explicites (areas), alignées GTD/PARA.

### R — Ressources
✅ Couche “brut” bien séparée du digéré.

### A — Archives
✅ Présente dans l'arborescence canonique.

### E — Extensions
✅ Journal/Phases/Process/Objectifs/Zettelkasten/Knowledge/memory/Agents bien définis.

## 4) Écarts et risques

### 4.1 Écart corrigé
- **Daily `--prep`** : comportement non conforme à la promesse documentaire, désormais corrigé.

### 4.2 Risques restants (priorisés)
1. **Couverture tests faible sur launcher**  
   Les tests actuels ciblent surtout `write_safe`; très peu de garde-fous sur les commandes métier (`daily`, `close`, `doctor`, `sync-git`).

2. **Parsing YAML fragile**  
   Plusieurs lectures de config utilisent `grep/awk`, robuste pour cas simples, fragile pour YAML multi-lignes/commentaires complexes.

3. **Divergence potentielle doc/implémentation**  
   La méthode évolue rapidement; sans check automatique, les écarts peuvent réapparaître.

## 5) Améliorations recommandées

## Lot A (court terme, impact fort)
1. **Conformance checks doc↔CLI**
   - Ajouter un test de non-régression qui vérifie que les commandes “promises” dans README existent dans `ipcrae-launcher.sh`.
2. **Tests smoke Bats sur launcher**
   - Cas minimaux: `daily`, `daily --prep`, `weekly`, `monthly`, `doctor` en mode dégradé.
3. **Journalisation d'erreurs standardisée**
   - Ajouter des codes d'erreur constants et messages actionnables.

## Lot B (moyen terme)
4. **Parser YAML dédié (`yq` optionnel)**
   - Utiliser `yq` si disponible, fallback `grep/awk` sinon.
5. **Commande `ipcrae validate`**
   - Vérifie la santé structurelle du vault + cohérence prompts/config.
6. **Version contractuelle enrichie**
   - Afficher un rapport combiné `method_version`, `script_version`, date de sync.

## Lot C (gouvernance)
7. **Checklist release**
   - “Doc claim vs implémentation” avant tag.
8. **Policy de compatibilité**
   - Clarifier ce qui est stable vs expérimental dans README.

## 6) Correctif implémenté dans ce commit
- `templates/ipcrae-launcher.sh` : implémentation de `ipcrae daily --prep`.
- Comportement:
  - Crée la daily si absente.
  - Préremplit le contexte automatique:
    - lien vers la veille (si calculable),
    - weekly courante,
    - `Inbox/waiting-for.md`,
    - `Phases/index.md`.
  - Ajoute sections utiles: Top 3, next actions, décisions, journal.

## 7) Conclusion
La méthode IPCRAE est **globalement robuste, bien pensée et prête pour un usage sérieux**. Le principal écart fonctionnel identifié a été corrigé. La prochaine marche de qualité est de **renforcer la non-régression** (tests launcher + validation doc/CLI automatisée).
