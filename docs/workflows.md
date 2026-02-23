# Workflows IPCRAE

Ce document détaille les workflows avancés pour gérer le cycle de vie des idées et des projets au sein de la méthode IPCRAE.

## 1. Workflow : Capturer et Traiter une Nouvelle Idée Automatiquement

L'objectif est de ne jamais perdre une idée et de laisser le système (via les agents IA et les rituels) s'occuper du tri. Ce processus s'appuie sur la synergie entre la méthode GTD (Hub of Action) et le Zettelkasten (Spoke of Insight).

### Étape 1 : Capture Sans Friction
Dès qu'une idée survient, utilisez la commande de capture de raccourci. Ne vous souciez pas de la structure à ce stade.
```bash
ipcrae capture "Mon idée d'application pour gérer la domotique..."
```
*Action : Cela crée un fichier `Inbox/capture-<timestamp>.md`.*

### Étape 2 : Enrichissement Automatisé (Frontmatter)
Lorsqu'un agent IA (via `ipcrae sprint` ou `ipcrae daily`) ou vous-même traitez l'Inbox, le fichier est qualifié avec des métadonnées YAML essentielles pour le routage automatique :
```yaml
---
type: fleeting
status: inbox
tags: [domotique, idee]
---
```

### Étape 3 : Routage Décisionnel (La logique de Tri)
L'idée est ensuite évaluée selon la logique suivante :
- **Actionnable + Objectif défini ?** → Élévation en **Projet** (déplacé/lié vers `Projets/<nom-du-projet>`).
- **Actionnable court terme ?** → Transformation en **Next Action** (ajouté au `tracking.md` du hub de domaine).
- **Ressource / Référence ?** → Déplacé vers `Ressources/` (Literature Note).
- **Concept / Connaissance pure ?** → Transformé en **Note Permanente** (`Zettelkasten/permanents/`) et lié au reste du système. `ipcrae zettel` peut être utilisé pour formaliser cette note atomique.


---

## 2. Workflow : Créer un Nouveau Projet avec IPCRAE

Ce workflow applique la méthode CDE (Context Driven Engineering) dès le premier jour d'un projet, garantissant une conception pilotée par l'IA de manière optimale.

### Étape 1 : Initialisation de l'espace de travail
Créez le dossier de votre nouveau code ou de votre nouveau projet, hors du Cerveau IPCRAE (ex: dans `~/DEV`).
```bash
mkdir -p ~/DEV/MonNouveauProjet
cd ~/DEV/MonNouveauProjet
git init
```

### Étape 2 : Injection de la structure IPCRAE (CDE)
Utilisez le script d'initialisation de projet IPCRAE.
```bash
ipcrae-addProject
```
*Action : Cette commande va :*
1. Créer le dossier `docs/conception/` avec les templates (`00_VISION.md`, `01_AI_RULES.md`, `02_ARCHITECTURE.md`).
2. Créer le hub central dans le cerveau `~/IPCRAE/Projets/MonNouveauProjet/`.
3. Générer le fichier `.ai-instructions.md` pour guider l'agent localement.
4. Créer un lien symbolique `.ipcrae-memory` pointant vers le Cerveau Global.

### Étape 3 : Définition de la Vision
Remplissez le fichier `docs/conception/00_VISION.md` avec le résumé de ce que vous souhaitez accomplir.

### Étape 4 : Lancement
Lancez l'agent pour commencer à travailler ou débutez votre sprint de code :
```bash
ipcrae sprint --project MonNouveauProjet
```

---

## 3. Workflow : Intégrer un Projet Existant à IPCRAE

Si vous avez déjà un projet en cours, la force d'IPCRAE est de pouvoir s'y greffer sans rien casser (Non-Destructif).

### Étape 1 : Se placer dans le projet
```bash
cd ~/DEV/ProjetDejaExistant
```

### Étape 2 : Lancer le Bridge IPCRAE
```bash
ipcrae-addProject
```
*Le script détecte le contexte et ajoute la surcouche documentaire IPCRAE sans modifier vos fichiers sources.*

### Étape 3 : Auto-Ingestion et Rétro-documentation (Crucial)
À la fin de l'exécution du script `ipcrae-addProject`, le système vous demandera si vous souhaitez lancer l'agent IA pour une **analyse initiale (Auto-ingestion)**.
- **Répondez OUI (`o`)**.
- L'agent IA va :
  1. Scanner votre code source existant.
  2. Rétro-documenter l'architecture dans `docs/conception/02_ARCHITECTURE.md`.
  3. Déduire les règles de code dans `01_AI_RULES.md`.
  4. Mettre à jour le statut du hub dans `~/IPCRAE`.

Une fois terminé, votre ancien projet est entièrement pilotable via IPCRAE.

---

## 4. Workflow : Collaboration Multi-Agents en parallèle

Objectif : exploiter plusieurs abonnements/providers en même temps avec un protocole commun lisible par tous les agents.

### Étape 1 : Un agent devient orchestrateur (lead)
```bash
ipcrae-agent-hub start claude-main
ipcrae-agent-hub task-add "Extraction principes vidéos" claude-main
ipcrae-agent-hub task-add "Comparer avec méthode IPCRAE" claude-main
```

### Étape 2 : Les autres agents basculent en mode assistant
Chaque agent lit l'état partagé :
```bash
ipcrae-agent-hub status
ipcrae-agent-hub task-pick 1 gemini-research
```

### Étape 3 : Handoff asynchrone
```bash
ipcrae-agent-hub notify gemini-research claude-main "Tâche #1 terminée, résultats dans docs/audit/"
ipcrae-agent-hub task-done 1 gemini-research
```

### Étape 4 : Consolidation finale par le lead
```bash
ipcrae-agent-hub status
ipcrae-agent-hub stop claude-main
```

Résultat : coordination légère, explicite et traçable dans `.ipcrae/multi-agent/`.

---

## 5. Workflow : Clôture de tâche automatisée (self-audit + contexte allégé)

Objectif : réduire l'effort manuel en fin de tâche et garder les sessions IA courtes en tokens.

### Étape 1 : Démarrer avec contexte limité
`ipcrae start` génère un `session-context.md` tronqué automatiquement (mémoire/projet/phases) pour éviter de charger tout le vault.

Vous pouvez ajuster les limites dans `.ipcrae/config.yaml` :
```yaml
session_context_memory_max_lines: 140
session_context_project_max_lines: 120
session_context_phase_max_lines: 40
```

### Étape 2 : Travailler normalement
Exécuter les actions habituelles (`ipcrae work`, scripts, commits, tests).

### Étape 3 : Clôturer et auto-auditer
```bash
ipcrae close <domaine> --project <slug> --note "résumé"
```

Cette commande produit désormais automatiquement :
1. consolidation mémoire;
2. synchronisation index/tags;
3. **self-audit de session** dans `.ipcrae/auto/self-audits/`;
4. badge de gratification session (`Or`, `Argent`, `Bronze`) selon coût tokens estimé.

### Étape 4 : Exploiter le self-audit
Lire le fichier généré pour décider l'amélioration suivante:
- réduire davantage le contexte;
- découper en deux passes (analyse puis patch);
- limiter les relectures globales.

---

## 6. Workflow : Mode strict (discipline automatique)

Objectif : appliquer la discipline IPCRAE sans effort manuel.

### Activer le mode strict
Dans `.ipcrae/config.yaml` :
```yaml
strict_mode: true
```

### Vérifier à la demande
```bash
ipcrae strict-check
ipcrae strict-report 10
```

Le check valide notamment :
- présence d'une capture utilisateur (`Tasks/to_ai`),
- journal actif (`Tasks/active_session.md`),
- contexte de session borné (`.ipcrae/session-context.md`),
- existence d'un self-audit (`.ipcrae/auto/self-audits/`).

### Exécution automatique en clôture
Quand `strict_mode: true`, `ipcrae close` lance automatiquement le strict-check après le self-audit.


### Journalisation + analyse de comportement
`ipcrae strict-check` écrit désormais un historique dans `.ipcrae/auto/strict-check-history.md` (score, warnings/failures, recommandation).
Cela permet d'analyser l'évolution de ta discipline session après session.
`ipcrae strict-report` synthétise la tendance (moyenne, delta, recommandation courante).

### Fun / motivation
Le self-audit attribue un badge (`Or`, `Argent`, `Bronze`) selon la charge estimée de la session.


## 7. Workflow : Test méthodologique E2E reproductible

Objectif : valider rapidement la chaîne complète IPCRAE sur un vault jetable, avec un rapport comparable entre runs.

```bash
bash scripts/ipcrae-methodology-e2e.sh \
  --vault /tmp/IPCRAE_CERVEAU_E2E \
  --agent codex \
  --project ipcrae-methodologie-e2e \
  --domain devops \
  --frequency quotidien
```

Le script enchaîne automatiquement :
- installation propre du vault,
- bootstrap agent,
- création d'une note de cerveau opératoire,
- activation du mode auto-amélioration,
- baseline audit, cycle auto-audit forcé, ré-audit,
- génération d'un rapport dans `docs/audit/`.

