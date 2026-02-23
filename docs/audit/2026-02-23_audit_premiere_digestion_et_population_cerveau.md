# Audit IPCRAE — première digestion & population complète du cerveau

Date: 2026-02-23
Contexte: correction post-retour utilisateur sur une ingestion initiale jugée trop légère.

## 1) Pourquoi trop peu de fichiers sont créés à la première digestion

### Cause racine A — Prompt d'ingestion trop interprété en mode "synthèse"
Le flux initial favorisait l'analyse architecture/projet local, mais n'imposait pas explicitement la création d'artefacts dans chaque dossier du cerveau global.

### Cause racine B — Absence de "quota minimum" par concept IPCRAE
Sans seuils explicites, un agent peut considérer la tâche comme terminée après quelques fichiers (ex: `docs/conception` + `Projets/<slug>/index.md`).

### Cause racine C — Pas de gate bloquante de couverture inter-dossiers
Le Done ne bloquait pas clairement la clôture si `Casquettes`, `Journal`, `Inbox`, `Ressources`, `Tasks` ou `Zettelkasten` restaient vides.

### Cause racine D — Flou entre périmètre projet local vs cerveau global
Lors du bootstrap d'un projet, l'effort se concentre naturellement sur les fichiers du repo en cours si le prompt n'impose pas le pont vers `IPCRAE_ROOT`.

## 2) Correctifs appliqués dans le projet IPCRAE

### 2.1 Renforcement de l'auto-ingestion lancée par `ipcrae-addProject`
Le prompt injecté automatiquement demande désormais une **auto-ingestion complète** avec population explicite de tous les concepts IPCRAE (Casquettes, Journal, Inbox, Knowledge, memory, Objectifs, Phases, Process, Ressources, Tasks, Zettelkasten), suivi d'un auto-audit avec score avant/après.

### 2.2 Renforcement du template canonique d'ingestion
`templates/prompts/prompt_ingest.md` contient maintenant:
- un diagnostic des causes de sous-population,
- une matrice de population minimale obligatoire par dossier,
- un gate anti-sous-population avec tableau de couverture (preuve fichier),
- une interdiction de clôture tant qu'un concept applicable est vide.

### 2.3 Renforcement documentaire du README
Le README précise explicitement que la première ingestion doit peupler l'ensemble des dossiers IPCRAE et référence le prompt d'ingestion comme protocole opératoire.

## 3) Audit de mon "cerveau" (méta-analyse du repo IPCRAE)

### 3.1 Éléments déjà bien couverts
- `Projets/` et tracking de session: structure présente et utilisée.
- `docs/conception/`: corpus méthodologique riche.
- `Knowledge/` et `memory/` dans les templates d'installation: présents par design.

### 3.2 Éléments historiquement sous-forcés au bootstrap
- Création systématique d'artefacts `Inbox/` contextualisés dès la première ingestion.
- Création d'entrées `Tasks/to_ai` et `Tasks/to_human` directement issues de l'analyse.
- Création de notes `Zettelkasten/_inbox` minimales avec liens croisés.
- Liaison explicite à `Casquettes`, `Objectifs`, `Phases`, `Process`, `Ressources` au moment zéro.

### 3.3 Effet attendu après ces correctifs
Sur une nouvelle installation + auto-ingestion, l'agent devrait produire un cerveau beaucoup plus dense dès la première passe, avec couverture transversale des concepts IPCRAE et meilleure continuité pour les sessions suivantes.

## 4) Informations "ultra précises" intégrées pour les prochaines installations

Les précisions suivantes sont maintenant embarquées dans les templates/protocoles de base:
1. Liste explicite des dossiers à peupler dès la première digestion.
2. Seuils minimaux concrets (ex: 2 notes zettel, 1 knowledge, 1 entrée memory, 1 journal daily, etc.).
3. Gate de validation par preuves de fichiers.
4. Auto-audit obligatoire pour mesurer la complétude (score et gaps).

## 5) Plan d'amélioration continue (mode auto-amélioration conservé)

- À chaque retour utilisateur sur "ingestion incomplète", mettre à jour `prompt_ingest.md` avant toute autre optimisation.
- Garder un audit daté dans `docs/audit/` pour tracer la progression de la méthode.
- Prioriser les améliorations qui augmentent la population durable du cerveau, pas seulement la qualité narrative des résumés.
