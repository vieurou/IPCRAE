---
type: process
tags: [review, coherence, documentation, code, verification, qualite]
domain: all
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Process — Review de la Cohérence Documentation ↔ Code

## Déclencheur
- Avant de merger une PR significative
- Après une session d'auto-amélioration
- À la demande (manuel) via `ipcrae process review-coherence-doc-code`
- Mensuellement lors de la revue monthly

## Concept
Vérifier que la documentation est à jour et cohérente avec le code, les scripts, les processus et les prompts. Détecter les incohérences, les obsolescences et les manques.

## Checklist

### Étape 1 : Inventaire des éléments à vérifier
- [ ] Lister tous les scripts CLI dans `scripts/ipcrae-*.sh`
- [ ] Lister tous les scripts utilitaires dans `scripts/*.sh`
- [ ] Lister tous les processus dans `Process/*.md`
- [ ] Lister tous les prompts dans `.ipcrae/prompts/agent_*.md`
- [ ] Lister toutes les commandes documentées dans `README.md`

### Étape 2 : Vérification de la cohérence Documentation ↔ Code

#### A. Scripts CLI
Pour chaque script `scripts/ipcrae-*.sh` :
- [ ] La commande est documentée dans `README.md` (section "Commandes CLI Principales") ?
- [ ] La commande est documentée dans `.ipcrae/context.md` ?
- [ ] La commande est documentée dans `Knowledge/howto/` (si applicable) ?
- [ ] La commande est intégrée dans le launcher principal (si applicable) ?
- [ ] Le script a une description dans la première ligne (commentaire `#`) ?

#### B. Scripts utilitaires
Pour chaque script `scripts/*.sh` (hors `ipcrae-*.sh`) :
- [ ] Le script est documenté dans `README.md` (section "Scripts Disponibles") ?
- [ ] Le script a une description dans la première ligne (commentaire `#`) ?
- [ ] Le script est référencé dans un processus ou une note Knowledge ?

#### C. Processus
Pour chaque processus `Process/*.md` :
- [ ] Le processus est référencé dans `Process/index.md` ?
- [ ] Le processus est lié à d'autres processus via wikilinks `[[process]]` ?
- [ ] Le processus est documenté dans `Knowledge/howto/` (si applicable) ?
- [ ] Le processus est intégré dans le cycle de vie IPCRAE (session-close, auto-amélioration, etc.) ?

#### D. Prompts
Pour chaque prompt `.ipcrae/prompts/agent_*.md` :
- [ ] Le prompt est documenté dans `Agents/agent_<domaine>.md` ?
- [ ] Le prompt est compilé dans `.ipcrae/compiled/prompt_<domaine>.md` ?
- [ ] Le prompt est référencé dans `.ipcrae/context.md` ?
- [ ] Le prompt est cohérent avec la méthode IPCRAE (v3.3) ?

#### E. Schémas YAML
Pour chaque schéma `.ipcrae/schema/*.yaml` :
- [ ] Le schéma est documenté dans `README.md` (section "Schémas YAML IPCRAE v4.0") ?
- [ ] Le schéma est documenté dans `.ipcrae/schema/README.md` ?
- [ ] Le schéma est utilisé dans des templates ou des processus ?

### Étape 3 : Vérification de l'obsolescence

#### A. Commandes obsolètes
- [ ] Vérifier que toutes les commandes documentées dans `README.md` existent encore
- [ ] Vérifier que toutes les commandes documentées dans `.ipcrae/context.md` existent encore
- [ ] Supprimer ou marquer comme obsolètes les commandes qui n'existent plus

#### B. Scripts obsolètes
- [ ] Vérifier que tous les scripts documentés existent encore
- [ ] Vérifier que tous les scripts sont encore utilisés (référencés dans des processus ou prompts)
- [ ] Archiver ou supprimer les scripts obsolètes

#### C. Processus obsolètes
- [ ] Vérifier que tous les processus sont encore pertinents
- [ ] Vérifier que tous les processus sont encore utilisés (référencés dans d'autres processus ou prompts)
- [ ] Archiver ou supprimer les processus obsolètes

### Étape 4 : Vérification de la cohérence interne

#### A. Cohérence des versions
- [ ] Vérifier que la version IPCRAE est cohérente dans tous les fichiers :
  - `README.md` (ligne224)
  - `.ipcrae/config.yaml` (script_version)
  - `index.md` (si applicable)
- [ ] Vérifier que la version de la méthode est cohérente dans tous les fichiers :
  - `.ipcrae/config.yaml` (method_version)
  - `README.md` (si documentée)
  - `Knowledge/howto/ipcrae-analyse-complete-cerveau-v3.3.md`

#### B. Cohérence des chemins
- [ ] Vérifier que tous les chemins relatifs sont cohérents
- [ ] Vérifier qu'il n'y a pas de chemins absolus hardcodés
- [ ] Vérifier que les chemins sont cohérents entre la documentation et le code

#### C. Cohérence des tags
- [ ] Vérifier que les tags sont en minuscules dans tous les fichiers
- [ ] Vérifier que les tags sont cohérents entre les fichiers connexes

### Étape 5 : Correction des incohérences
Pour chaque incohérence détectée :
- [ ] Corriger la documentation pour refléter le code
- [ ] OU corriger le code pour refléter la documentation
- [ ] Documenter la décision de ne pas corriger (si applicable)

### Étape 6 : Validation
- [ ] Relancer `ipcrae-audit-check` → score après corrections
- [ ] Vérifier que le score d'audit est ≥ 80%
- [ ] Documenter les résultats dans le journal de session

## Sorties attendues
- Rapport de review de cohérence (console)
- Liste des incohérences détectées
- Liste des éléments obsolètes identifiés
- Score de cohérence (nombre de checks passés / total)
- Entrée dans le journal de session avec les résultats

## Definition of Done
- Tous les scripts CLI sont documentés dans `README.md` et `.ipcrae/context.md`
- Tous les scripts utilitaires sont documentés dans `README.md`
- Tous les processus sont référencés dans `Process/index.md`
- Tous les prompts sont documentés dans `Agents/agent_<domaine>.md`
- Tous les schémas YAML sont documentés dans `README.md`
- Aucun élément obsolète n'est documenté
- La version IPCRAE est cohérente dans tous les fichiers
- Le score d'audit est ≥ 80%
- Les résultats sont documentés dans le journal de session

## Agent IA recommandé
- agent_devops (pour les aspects techniques et infrastructure)
- Kilo Code (mode Code pour les corrections automatiques)

## Commandes associées
- `bash scripts/ipcrae-audit-check.sh` — Audit vault complet
- `ipcrae process review-coherence-doc-code` — Lancer ce process via le launcher

## Notes
- Ce process doit être exécuté régulièrement pour garantir la cohérence entre la documentation et le code
- Les incohérences doivent être corrigées avant de continuer
- Les éléments obsolètes doivent être supprimés ou archivés
- Le score de cohérence doit être maintenu ≥ 80% pour considérer le système cohérent

## Références
- Process de non-régression : `Process/non-regression.md`
- Process de vérification du travail : `Process/verification-travail.md`
- Documentation IPCRAE : `Knowledge/howto/ipcrae-analyse-complete-cerveau-v3.3.md`
