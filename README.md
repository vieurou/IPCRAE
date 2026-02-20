# 🧠 IPCRAE Étendu (v3.2)

> **I**nbox · **P**rojets · **C**asquettes · **R**essources · **A**rchives
> Un système de gestion de vie complet, piloté par l'IA, 100% local, versionnable et CLI-friendly.

---

## Pourquoi IPCRAE ?

Les assistants IA oublient tout entre les sessions. Les outils cloud centralisent vos données chez un tiers. Les méthodes classiques (GTD, PARA, Zettelkasten) sont puissantes mais rarement intégrées entre elles.

**IPCRAE résout ces problèmes à la fois :**

- La vérité est dans des **fichiers Markdown locaux**, versionnés sous Git.
- L'IA reçoit un **contexte structuré et à jour** à chaque session.
- La méthode combine **GTD + PARA + Zettelkasten + journaling** dans un seul système.
- Compatible avec **Claude Code, Gemini CLI, Codex, Kilo Code** (VS Code).

Ce dépôt suit une stratégie **centralisée** :
- `~/IPCRAE` (ou `$IPCRAE_ROOT`) est la **source de vérité** pour la mémoire durable.
- Un projet local ne doit pas dupliquer toute la hiérarchie IPCRAE. Le local sert de **contexte court terme** et pointe vers le global via des liens.

---

## Architecture

Le Cerveau IPCRAE (`~/IPCRAE`) maintient une structure rigoureuse :

```text
~/IPCRAE/
├── .ipcrae/                ← Configuration et prompts
├── Inbox/                  ← Capture brute (idées, tâches)
├── Projets/                ← Projets avec objectif et fin (Central Hubs)
├── Casquettes/             ← Responsabilités continues (Areas de PARA)
├── Ressources/             ← Documentation brute par domaine
├── Zettelkasten/           ← Notes atomiques permanentes (pensée digérée)
├── Archives/               ← Projets/ressources terminés
├── Journal/                ← Notes quotidiennes, hebdos, mensuelles
├── Phases/                 ← Phases de vie actives (pilotent les priorités)
├── Process/                ← Procédures récurrentes (checklists)
├── Objectifs/              ← Vision long-terme
├── memory/                 ← Mémoire IA par domaine (devops, musique, etc.)
├── Agents/                 ← Rôles IA spécialisés
├── CLAUDE.md / GEMINI.md   ← Contexte généré pour les providers
└── index.md                ← Dashboard central
```

---

## Installation & Mise à jour

### Installation rapide

Un seul script suffit pour déployer l'arborescence, les templates documentaires, les profils d'agents spécialisés et installer la CLI.

```bash
git clone https://github.com/vieurou/IPCRAE.git
cd IPCRAE
bash ipcrae-install.sh -y
```

Vérifiez que `~/bin` est dans votre `PATH`.

### Mise à jour IPCRAE en production (sans perte de données)

Pour un cerveau existant déjà en prod, utiliser la migration safe :

```bash
ipcrae migrate-safe
```

Algorithme appliqué :
1. Backup complet du vault (archive `tar.gz`) avant toute modification.
2. Merge non destructif des prompts (`.ipcrae/prompts/`) : fichier absent généré, fichier différent gardé en `.new-<timestamp>`.
3. Mise à jour des scripts CLI avec backup local.
4. Enrichissement de configuration sans overwrite (`default_provider`, `auto_git_sync`).
5. Rapport de migration écrit dans `.ipcrae/backups/`.

---

## Utilisation

### Commandes CLI principales

| Commande | Description |
|----------|-------------|
| `ipcrae` | Menu interactif |
| `ipcrae daily --prep` | L'IA génère un brouillon de daily en lisant votre contexte |
| `ipcrae close [domaine]` | Clôture session : l'IA résume dans `memory/` |
| `ipcrae capture "texte"` | Capture rapide dans `Inbox/` |
| `ipcrae zettel "titre"` | Créer une note atomique Zettelkasten |
| `ipcrae sync` | Régénère le contexte `CLAUDE.md`, `GEMINI.md`, etc. |
| `ipcrae sync-git` | Sauvegarde Git du vault entier (add, commit, push) |
| `ipcrae health` | Diagnostic du système |
| `ipcrae-addProject` | Scaffold documentaire local dans un dépôt de code (CDE) |

---

## Conception & Développement (CDE)

Le script `ipcrae-addProject` permet de lier la puissance documentaire d'IPCRAE à vos environnements de développement locaux :

```bash
# Dans votre dépôt de code (ex: ~/DEV/mon-projet)
ipcrae-addProject
```

Ce script génère :
1. **L'architecture projet locale** (`docs/conception/` pour Vision, Architecture, AI Rules).
2. **Le dossier de notes volatiles** (`.ipcrae-project/local-notes/`) pour des mémos locaux.
3. **Les liens symboliques** (`.ipcrae-memory`) pointant vers la mémoire globale.
4. **Le manifeste `.ai-instructions.md`** fusionnant vos directives spécifiques au projet avec les règles du cerveau global.
5. **Le Hub Central** du projet généré dans la branche `Projets/` de `~/IPCRAE`.

---

## Méthodologie & Mémoire : Où écrire quoi ?

L'objectif est de ne jamais dupliquer l'information entre le global et le local.

| Emplacement | Rôle | Durée |
|---|---|---|
| `Inbox/*.md` | Idée rapide, capture brute. | Très Courte |
| `.ipcrae-project/local-notes/` | Brouillons de projet, contexte immédiat (CDE local). | Courte |
| `~/IPCRAE/Projets/[Nom]/` | Objectifs du projet, Hub GTD partagé. | Moyenne |
| `.ipcrae-memory/memory/[Domaine].md` | **Décisions techniques durables**, leçons apprises. L'IA doit lire ça. | Longue |
| `Zettelkasten/permanents/` | Concept isolé et digéré, réutilisable. | Longue |
| `Journal/` & `Archives/` | Traces et historique d'activité. | Éternelle |

### Workflow CDE recommandé

1. Capturer dans `.ipcrae-project/local-notes/` pendant le travail.
2. En fin de feature / session, utiliser l'IA (`ipcrae close` ou `ipcrae consolidate`) pour synthétiser l'essentiel vers `.ipcrae-memory/memory/` en purgeant les `local-notes`.
3. Garder l’historique des journées dans `Journal/`.

---

## Architecture des prompts IA (v3.2)

Le système de prompts est factorisé en couches dans `.ipcrae/prompts/` :

1. `core_ai_functioning.md` : fonctionnement IA commun.
2. `core_ai_workflow_ipcra.md` : workflow Agile/GTD IPCRAE.
3. `core_ai_memory_method.md` : gouvernance mémoire (local/projet/global).
4. `agent_<domaine>.md` : spécialisations métier.

*Le principe est de recharger le noyau commun puis la couche métier pour des résultats homogènes.*

---

## Providers IA & Compatibilités

Le lanceur gère **Claude Code** (`claude`), **Gemini CLI** (`gemini`), **Codex**, et **Kilo Code**.
Le système fallback selon vos préférences définies dans `.ipcrae/config.yaml`.

- Utiliser `ipcrae sync` pour régénérer la version statique des fichiers provider.
- Utiliser `ipcrae doctor` pour auditer le format si une IA vous semble désorientée.

---

## Git dans le workflow mémoire

Par défaut (`auto_git_sync: true` via `.ipcrae/config.yaml`), IPCRAE va **auto-commit** et **auto-push** vos nouvelles entrées mémoire (capture, zettel, création daily, close) *en arrière-plan*, si le vault est un dépôt Git et possède un remote `origin` configuré.

- Vous pouvez overrider pour la session : `export IPCRAE_AUTO_GIT=false`.
- Sauvegarde manuelle complète (ajout de nouveau remotes) : `ipcrae sync-git`.

---

## Workflows Avancés & Vérification

### Consolidation et Ingestion
IPCRAE inclut des scripts d'Audit et de Refactoring autonome :
- **`ipcrae consolidate [domaine]`** : Ferme la boucle d'un projet local, extrayant les insights techniques des dossiers de debug vers la mémoire serveur durable, supprimant les notes obsolètes.
- **`ipcrae ingest [domaine]`** : Scan IA profond d'un repo tiers inactif, afin de digérer automatiquement son readme, son architecture et de déposer cette trace dans `memory/` et le `Zettelkasten`.

### Méthode de vérification recommandée (QA)

Intuitif à tester en environnement sandbox isolé avant de toucher à votre vrai cerveau :

```bash
# 1) Sanity check syntaxe Bash
bash -n ipcrae-install.sh

# 2) Exécution non-interactive isolée
TMP_HOME=$(mktemp -d)
TMP_VAULT="$(mktemp -d)/vault"
HOME="$TMP_HOME" bash ipcrae-install.sh -y "$TMP_VAULT"

# 3) Contrôle minimal
[ -f "$TMP_VAULT/.ipcrae/context.md" ]
[ -f "$TMP_VAULT/.ipcrae/config.yaml" ]
```

### Troubleshooting
- **`ipcrae` introuvable** : l'installateur place le binaire dans `$HOME/bin`. Si votre shell ne l'a pas sourcé, faites `export PATH=$HOME/bin:$PATH`.
- **Lien symbolique `.ipcrae-memory` cassé** : vérifiez de n'avoir pas déplacé `<projet_local>` ou la variable `$IPCRAE_ROOT`. Relancez `ipcrae-addProject` localement.
- **Ecriture de script bloquée** : `write_safe` utilise le mode hermétique `set -u` et refoule les entrées vides.

---

## Licence & Contribution

MIT — Utilisation libre, personnelle et commerciale.

Les PR sont bienvenues. Avant toute soumission exécutez un Linter agressif :
`bash -n ipcrae-install.sh` + `shellcheck ipcrae-install.sh`.
