---
type: process
tags: [architecte, methode, verification, evolution, coherence, qualite]
domain: all
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Process — Mode Architecte Méthode

## Déclencheur
- À la demande (manuel) via `ipcrae process architecte-methode`
- Mensuellement lors de la revue monthly
- Après une session d'auto-amélioration significative
- Quand une évolution majeure de la méthode est planifiée

## Concept
Le mode Architecte Méthode est un rôle spécialisé qui vérifie la cohérence de la méthode IPCRAE v3.3, son évolution et son bon respect dans tous les composants du système : méthode, scripts, prompts, processus et documentation. Ce mode identifie les incohérences, les violations de la méthode et les opportunités d'amélioration.

## Rôle de l'Architecte Méthode

L'Architecte Méthode est responsable de :
1. **Vérifier la cohérence de la méthode** : S'assurer que la méthode IPCRAE v3.3 est cohérente dans tous ses aspects
2. **Analyser l'évolution de la méthode** : Identifier les évolutions récentes et s'assurer qu'elles sont cohérentes
3. **Vérifier le respect de la méthode** : S'assurer que tous les composants du système respectent la méthode
4. **Identifier les opportunités d'amélioration** : Proposer des améliorations de la méthode basées sur l'expérience

## Checklist

### Étape 1 : Inventaire des composants de la méthode
- [ ] Lister tous les documents de la méthode :
  - `Knowledge/howto/ipcrae-analyse-complete-cerveau-v3.3.md`
  - `Knowledge/howto/session-protocol-ipcrae.md`
  - `Knowledge/howto/gtd-adapte-ipcrae.md`
  - `Knowledge/howto/zettelkasten-workflow.md`
  - `Knowledge/howto/moc-generation-automatique.md`
  - `Knowledge/patterns/*.md`
- [ ] Lister tous les scripts qui implémentent la méthode
- [ ] Lister tous les processus qui définissent la méthode
- [ ] Lister tous les prompts qui intègrent la méthode
- [ ] Lister tous les fichiers de configuration qui définissent la méthode

### Étape 2 : Vérification de la cohérence de la méthode

#### A. Cohérence des principes
- [ ] Vérifier que les principes IPCRAE sont cohérents dans tous les documents :
  - Tag-first navigation
  - Markdown versionné (Git)
  - Scripts shell d'automatisation
  - Protocole de mémoire IA par domaine
  - GTD adapté
- [ ] Vérifier que les principes ne se contredisent pas entre eux
- [ ] Vérifier que les principes sont appliqués de manière cohérente

#### B. Cohérence des workflows
- [ ] Vérifier que les workflows sont cohérents entre eux :
  - Workflow session (start → work → close)
  - Workflow auto-amélioration (8 étapes)
  - Workflow GTD (capture → clarifier → organiser → réfléchir → agir)
  - Workflow Zettelkasten (Inbox → _inbox → permanents)
- [ ] Vérifier que les workflows se connectent correctement entre eux
- [ ] Vérifier que les workflows sont documentés de manière cohérente

#### C. Cohérence des structures
- [ ] Vérifier que les structures de fichiers sont cohérentes :
  - Structure du vault (Inbox/, Projets/, Casquettes/, etc.)
  - Structure des projets (index.md, tracking.md, memory.md)
  - Structure des processus (frontmatter, checklist, DoD)
  - Structure des notes (frontmatter, tags, wikilinks)
- [ ] Vérifier que les structures sont documentées de manière cohérente
- [ ] Vérifier que les structures sont respectées dans tous les fichiers

### Étape 3 : Analyse de l'évolution de la méthode

#### A. Identification des évolutions récentes
- [ ] Identifier les évolutions récentes de la méthode (via git log ou tags)
- [ ] Analyser les changements dans les documents de la méthode
- [ ] Identifier les nouveaux principes, workflows ou structures introduits
- [ ] Identifier les principes, workflows ou structures supprimés

#### B. Analyse de la cohérence des évolutions
- [ ] Vérifier que les évolutions sont cohérentes avec les principes existants
- [ ] Vérifier que les évolutions ne se contredisent pas
- [ ] Vérifier que les évolutions sont bien intégrées dans la méthode

#### C. Analyse de l'impact des évolutions
- [ ] Vérifier que les évolutions sont bien documentées
- [ ] Vérifier que les évolutions sont bien communiquées
- [ ] Vérifier que les évolutions sont bien adoptées par les composants du système

### Étape 4 : Vérification du respect de la méthode

#### A. Respect dans les scripts
Pour chaque script qui implémente la méthode :
- [ ] Vérifier que le script respecte les principes IPCRAE
- [ ] Vérifier que le script suit les workflows définis
- [ ] Vérifier que le script utilise les structures définies
- [ ] Vérifier que le script est cohérent avec les autres scripts

#### B. Respect dans les processus
Pour chaque processus qui définit la méthode :
- [ ] Vérifier que le processus respecte les principes IPCRAE
- [ ] Vérifier que le processus suit les workflows définis
- [ ] Vérifier que le processus utilise les structures définies
- [ ] Vérifier que le processus est cohérent avec les autres processus

#### C. Respect dans les prompts
Pour chaque prompt qui intègre la méthode :
- [ ] Vérifier que le prompt respecte les principes IPCRAE
- [ ] Vérifier que le prompt suit les workflows définis
- [ ] Vérifier que le prompt utilise les structures définies
- [ ] Vérifier que le prompt est cohérent avec les autres prompts

#### D. Respect dans la documentation
Pour chaque document de la méthode :
- [ ] Vérifier que le document respecte les principes IPCRAE
- [ ] Vérifier que le document suit les workflows définis
- [ ] Vérifier que le document utilise les structures définies
- [ ] Vérifier que le document est cohérent avec les autres documents

### Étape 5 : Identification des incohérences et violations

#### A. Incohérences internes
- [ ] Identifier les incohérences entre les documents de la méthode
- [ ] Identifier les incohérences entre les scripts
- [ ] Identifier les incohérences entre les processus
- [ ] Identifier les incohérences entre les prompts

#### B. Violations de la méthode
- [ ] Identifier les scripts qui violent les principes IPCRAE
- [ ] Identifier les processus qui violent les principes IPCRAE
- [ ] Identifier les prompts qui violent les principes IPCRAE
- [ ] Identifier la documentation qui viole les principes IPCRAE

#### C. Opportunités d'amélioration
- [ ] Identifier les opportunités d'amélioration des principes IPCRAE
- [ ] Identifier les opportunités d'amélioration des workflows
- [ ] Identifier les opportunités d'amélioration des structures
- [ ] Identifier les opportunités d'amélioration de la documentation

### Étape 6 : Correction des incohérences et violations
Pour chaque incohérence ou violation détectée :
- [ ] Corriger le composant pour respecter la méthode
- [ ] OU mettre à jour la méthode pour refléter la nouvelle réalité
- [ ] Documenter la décision de ne pas corriger (si applicable)

### Étape 7 : Documentation des améliorations
Pour chaque opportunité d'amélioration identifiée :
- [ ] Documenter l'amélioration proposée
- [ ] Évaluer l'impact de l'amélioration
- [ ] Prioriser l'amélioration
- [ ] Ajouter l'amélioration au backlog si applicable

### Étape 8 : Validation
- [ ] Relancer `ipcrae-audit-check` → score après corrections
- [ ] Vérifier que le score d'audit est ≥ 80%
- [ ] Documenter les résultats dans le journal de session
- [ ] Proposer une évolution de la méthode si nécessaire

## Sorties attendues
- Rapport d'analyse de la méthode (console)
- Liste des incohérences détectées
- Liste des violations de la méthode détectées
- Liste des opportunités d'amélioration identifiées
- Score de cohérence de la méthode (nombre de checks passés / total)
- Propositions d'évolution de la méthode
- Entrée dans le journal de session avec les résultats

## Definition of Done
- Tous les composants de la méthode ont été analysés
- Toutes les incohérences ont été identifiées et corrigées
- Toutes les violations de la méthode ont été identifiées et corrigées
- Toutes les opportunités d'amélioration ont été identifiées et documentées
- Le score de cohérence de la méthode est ≥ 80%
- Les résultats sont documentés dans le journal de session
- Les propositions d'évolution de la méthode sont documentées

## Agent IA recommandé
- agent_devops (pour les aspects techniques et infrastructure)
- Claude (Anthropic) — Mode Architect (pour l'analyse de la méthode)

## Commandes associées
- `bash scripts/ipcrae-audit-check.sh` — Audit vault complet
- `bash scripts/audit_non_regression.sh` — Audit de non-régression
- `ipcrae process architecte-methode` — Lancer ce process via le launcher

## Notes
- Ce process doit être exécuté régulièrement pour garantir la cohérence de la méthode IPCRAE
- Les incohérences et violations doivent être corrigées avant de continuer
- Les décisions de ne pas corriger doivent être documentées
- Le score de cohérence de la méthode doit être maintenu ≥ 80% pour considérer le système cohérent
- Ce mode est complémentaire aux autres modes de vérification (non-régression, review de cohérence, etc.)

## Références
- Documentation IPCRAE : `Knowledge/howto/ipcrae-analyse-complete-cerveau-v3.3.md`
- Process de non-régression : `Process/non-regression.md`
- Process de review de cohérence : `Process/review-coherence-doc-code.md`
- Process d'auto-amélioration : `Process/auto-amelioration.md`
- Patterns IPCRAE : `Knowledge/patterns/*.md`
