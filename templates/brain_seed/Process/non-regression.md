# Process — Vérification des Non-Régressions

## Déclencheur (quand lancer ce process ?)
- Après chaque modification significative du système IPCRAE
- Avant de déployer une nouvelle version
- Après une session d'auto-amélioration
- Avant de merger une branche de fonctionnalité
- À la demande (manuel) via `ipcrae process non-regression`

## Entrées (inputs nécessaires)
- Répertoire IPCRAE_ROOT (par défaut : `$HOME/IPCRAE`)
- Script d'audit : `scripts/audit_non_regression.sh` (si disponible)
- Accès git pour vérifier les commits

## Checklist

### Phase 1: Préparation
- [ ] Se positionner dans le répertoire IPCRAE_ROOT
- [ ] Vérifier que le dépôt git est propre (pas de modifications non commitées)
- [ ] Sauvegarder l'état actuel si nécessaire

### Phase 2: Exécution de l'audit
- [ ] Lancer le script d'audit de non-régression : `bash scripts/audit_non_regression.sh`
- [ ] Vérifier que toutes les sections de l'audit passent
- [ ] Noter les avertissements et les échecs

### Phase 3: Analyse des résultats
- [ ] Vérifier l'intégrité des fichiers (Markdown, Shell, Tests)
- [ ] Vérifier l'intégrité des mémoires
- [ ] Vérifier l'intégrité des scripts
- [ ] Vérifier l'intégrité des templates
- [ ] Vérifier les commits git
- [ ] Vérifier la cohérence des tags
- [ ] Vérifier les liens entre fichiers
- [ ] Vérifier les références

### Phase 4: Correction des problèmes
- [ ] Corriger les échecs critiques (bloquants)
- [ ] Évaluer les avertissements (non bloquants)
- [ ] Documenter les décisions de ne pas corriger

### Phase 5: Validation
- [ ] Relancer l'audit pour confirmer les corrections
- [ ] Vérifier que le score d'audit est acceptable
- [ ] Documenter les résultats dans le journal de session

## Sorties (outputs attendus)
- Rapport d'audit de non-régression (console)
- Score d'audit (nombre de checks passés / total)
- Liste des problèmes détectés (échecs et avertissements)
- Entrée dans le journal de session avec les résultats

## Definition of Done
- L'audit de non-régression est exécuté avec succès
- Tous les échecs critiques sont corrigés
- Les avertissements sont évalués et documentés
- Le score d'audit est ≥ 80%
- Les résultats sont documentés dans le journal de session
- Aucune régression n'est détectée

## Agent IA recommandé
- agent_devops (pour les aspects techniques et infrastructure)
- Kilo Code (mode Code pour les corrections automatiques)

## Commandes associées
- `bash scripts/audit_non_regression.sh` — Exécuter l'audit de non-régression
- `ipcrae process non-regression` — Lancer ce process via le launcher

## Notes
- Ce process doit être exécuté régulièrement pour garantir la stabilité du système
- Les échecs critiques doivent être corrigés avant de continuer
- Les avertissements peuvent être différés mais doivent être documentés
- Le score d'audit doit être maintenu ≥ 80% pour considérer le système stable

## Références
- Script d'audit : `../DEV/IPCRAE/scripts/audit_non_regression.sh`
- Process d'auto-amélioration : `Process/auto-amelioration.md`
- Documentation IPCRAE : `Knowledge/howto/ipcrae-analyse-complete-cerveau-v3.3.md`
