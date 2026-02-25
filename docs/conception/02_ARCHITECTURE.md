# Architecture et Décisions Techniques

## 1. Structure Globale

IPCRAE repose sur un modèle en **3 couches** (`docs/conception/00_OS_IA_3_COUCHES.md`) :

```
[Couche 1 — Vault/Stockage]          [Couche 2 — Agents IA]            [Couche 3 — CLI]
.ipcrae/context.md           →       CLAUDE.md / GEMINI.md         ←   ipcrae sync
.ipcrae/instructions.md      →       AGENTS.md / kilocode.md            ipcrae start/work/close
memory/<domaine>.md          →       (lu par l'agent actif)              ipcrae-tokenpack
Knowledge/ (tags YAML)      ←→       (indexé par ipcrae-index)           ipcrae-agent-bridge
```

**Flux de données canonique (session IA)** :
1. `ipcrae start` → injecte contexte minimisé (tokenpack) dans l'agent
2. `ipcrae work "<objectif>"` → agent IA lit le vault, agit, écrit
3. `ipcrae close <domaine>` → agent consolide `memory/<domaine>.md`, rebuild le cache tags
4. `ipcrae sync` → régénère les fichiers providers depuis les sources

**Flux GTD (utilisateur)** :
- Capturer (Inbox) → Clarifier → Organiser (Projets/Casquettes/Knowledge) → Agir

*Voir `docs/workflows.md` pour les workflows GTD détaillés : capture automatique, routage décisionnel, et transformation en projets/actions.*

## 2. Décisions de Conception (ADR)

- **ADR-001** : Stockage 100% Markdown local — simplicité, compatibilité Obsidian, versioning Git sans dépendance externe.
- **ADR-002** : Multi-provider IA (Claude/Gemini/Codex/Kilo) — pas de lock-in fournisseur ; `ipcrae-agent-bridge` compare les sorties.
- **ADR-003** : Mémoire IA par domaine (`memory/devops.md`, `memory/musique.md`...) — réduction du bruit contextuel, isolation des domaines métier.
- **ADR-004** : Fichiers providers (`CLAUDE.md`, `GEMINI.md`, `CODEX.md`) générés depuis `.ipcrae/prompts/provider_{name}.md` via `ipcrae sync` — entrées légères (pointeurs vers core files), édition manuelle interdite.
- **ADR-005** : `write_safe` avec backup automatique (`*.bak-<timestamp>`) et mode `--dry-run` — installation non destructive, rollback possible.
- **ADR-006** : Cache tags (`.ipcrae/cache/tag-index.json`) dérivé depuis le frontmatter YAML, jamais source de vérité — reconstructible à tout moment via `ipcrae index`.

## 3. Schéma de Données / API

### Arborescence vault (structure minimale)

```
IPCRAE_ROOT/
├── .ipcrae/
│   ├── context.md            # État actif : projets, phase, identité
│   ├── instructions.md       # Règles IA communes (qualité, vérification)
│   ├── config.yaml           # Provider par défaut, auto_git_sync
│   ├── prompts/              # Templates agents & workflows (core + domaines)
│   ├── cache/tag-index.json  # Cache tags (dérivé, reconstructible)
│   └── multi-agent/          # État partagé lead/assistants (state, tasks, notifications)
│       ├── state.env         # Variables d'état de session
│       ├── tasks.tsv         # Backlog de tâches partagées (TSV)
│       └── notifications.log # Historique des notifications inter-agents
├── memory/
│   ├── devops.md | electronique.md | musique.md | maison.md | sante.md | finance.md
│   └── index.md
├── Knowledge/
│   ├── howto/ | runbooks/ | patterns/ | MOC/
│   └── _template_knowledge.md
├── Projets/                  # Hubs centraux par projet (index + tracking + memory)
│   └── <slug>/
│       ├── index.md          # Dashboard projet
│       ├── memory.md         # Mémoire spécifique au projet
│       ├── demandes/        # Demandes clarifiées/organisées (via GTD)
│       └── ...               # Notes, ressources, etc.
├── Casquettes/               # Responsabilités continues (areas)
├── Inbox/
│   ├── demandes-brutes/      # Capture brute non triée (format texte brut)
│   │   └── traites/          # Demandes traitées (archivage)
│   └── waiting-for.md
├── Journal/{Daily,Weekly,Monthly}/
├── Phases/index.md           # Source de priorités active
├── Process/                  # Procédures récurrentes (checklists)
├── Objectifs/someday.md
├── Zettelkasten/{_inbox,permanents,MOC}/
├── Agents/agent_<domaine>.md
├── CLAUDE.md / GEMINI.md / AGENTS.md   # Générés — ne pas éditer manuellement
└── index.md                  # Dashboard central
```

Note : les process “seed” sont stockés côté repo dans `templates/brain_seed/Process/` puis copiés vers `Process/` du cerveau à l’installation.

### Frontmatter canonique (Knowledge/)

```yaml
---
type: knowledge
tags: [tag1, tag2]
project: <slug>
domain: devops|electronique|musique|maison|sante|finance
status: draft|stable
sources:
  - path: docs/conception/02_ARCHITECTURE.md
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

### Scripts CLI installés dans ~/bin

| Script | Rôle |
|--------|------|
| `ipcrae` | Launcher principal (daily, weekly, start, work, close, sync, health, zettel, moc, tag, index...) |
| `ipcrae-addProject` | Initialise un repo local CDE : `docs/conception/` + hub Projets + symlink `.ipcrae-memory` |
| `ipcrae-tokenpack` | Génère un contexte compact (core ou projet) pour minimiser les tokens IA |
| `ipcrae-agent-bridge` | Interroge automatiquement les agents CLI disponibles avec cache de réponses |
| `ipcrae-agent-hub` | Coordonne une session multi-agents parallèle (lead + assistants) via backlog partagé |
| `ipcrae-prompt-optimize` | Optimise un prompt selon l'agent cible avant délégation |
| `ipcrae-index` | Reconstruit le cache `tag-index.json` depuis les frontmatters Markdown |
| `ipcrae-tag` | Liste les fichiers liés à un tag donné |
| `ipcrae-migrate-safe` | Migration non destructive (backup tar.gz + merge non-overwrite des prompts) |
| `ipcrae-uninstall` | Purge du système |

### Commandes launcher intégrées

Le script principal `ipcrae-launcher.sh` (templates/ipcrae-launcher.sh) fournit des commandes supplémentaires non installées dans ~/bin :

| Commande | Rôle |
|----------|------|
| `ipcrae demandes [status|done]` | Suivi de l'état des demandes brutes dans `Inbox/demandes-brutes/` |
| `ipcrae process [nom]` | Créer/ouvrir un process récurrent dans `Process/` |
| `ipcrae update` | Met à jour IPCRAE via git pull puis relance l'installateur |
| `ipcrae sync-git` | Sauvegarde Git du vault entier (add, commit, push vers remote) |
| `ipcrae prompt build --agent <domaine>` | Compile les couches de prompts en un seul fichier |
| `ipcrae prompt check` | Vérifie la cohérence des sections obligatoires dans tous les agents |
| `ipcrae prompt --list` | Liste les agents disponibles |
| `ipcrae allcontext "<texte>"` | Pipeline d'analyse/ingestion universel (rôles + contexte + tracking) |
| `ipcrae archive <slug>` | Archive un projet terminé (Projets/ → Archives/) |
| `ipcrae remote [list|set-brain|set-project]` | Gestion des remotes git (cerveau + projets) |

### Mode CDE (Context Driven Engineering — projet local)

Quand un repo local intègre IPCRAE via `ipcrae-addProject` :

```
<repo-local>/
├── docs/conception/
│   ├── 00_VISION.md         # Vision + objectifs
│   ├── 01_AI_RULES.md       # Règles IA locales
│   ├── 02_ARCHITECTURE.md   # ADR + schéma données
│   └── 03_IPCRAE_BRIDGE.md  # Contrat lecture/écriture vault ↔ projet
├── .ipcrae-project/
│   └── local-notes/         # Notes volatiles (debug, hypothèses)
├── .ipcrae-memory -> ~/brain  # Symlink vers vault global
└── .ai-instructions.md      # Directive : lire mémoire globale, écrire local
```

## 4. Configuration Git Automatique

IPCRAE supporte la synchronisation automatique du vault et des projets via Git.

### Structure de configuration (`.ipcrae/config.yaml`)

Format **plat** (clés au top level, pas de section `git:` imbriquée) :

```yaml
# Provider IA par défaut
default_provider: claude

# Synchronisation Git automatique (true/false)
# Peut aussi être forcé via la variable d'env IPCRAE_AUTO_GIT (priorité sur config)
auto_git_sync: true

# Push automatique après commit (true/false)
auto_git_push: false

# Remote du cerveau (nom du git remote à utiliser)
brain_remote: origin

# Remotes des projets (mapping slug → remote ou URL)
project_remotes:
  mon-projet: git@github.com:vieurou/mon-projet.git
  autre-projet: https://github.com/vieurou/autre-projet.git
```

### Variable d'environnement `IPCRAE_AUTO_GIT`

Priorité sur `auto_git_sync` dans `config.yaml`. Utile pour les overrides temporaires :

```bash
IPCRAE_AUTO_GIT=false ipcrae close devops   # Désactiver le commit auto pour cette session
IPCRAE_AUTO_GIT=true  ipcrae daily          # Forcer le commit même si config=false
```

Ordre de résolution : `IPCRAE_AUTO_GIT` env var → `auto_git_sync` dans config.yaml → `false` (défaut).

### Flux de synchronisation

```
1. Session IA active
   ↓
2. `ipcrae close <domaine>` → consolidation mémoire
   ↓
3. Vérification IPCRAE_AUTO_GIT (env var ou config)
   ↓ (si activé)
4. `ipcrae sync-git` → add + commit + push
   ↓
5. Git push vers remote approprié:
   - Cerveau → brain_remote
   - Projet → project_remotes[<slug>]
```

### Commandes Git

| Commande | Action |
|----------|--------|
| `ipcrae sync-git` | Sauvegarde Git manuelle (add, commit, push) |
| `ipcrae remote list` | Liste tous les remotes configurés |
| `ipcrae remote set-brain <url>` | Configure le remote du cerveau |
| `ipcrae remote set-project <slug> <url>` | Configure le remote d'un projet |
| `git log --oneline --graph` | Visualiser l'historique du vault |

## 5. Protocole Multi-Agent File-Based

IPCRAE utilise un protocole sans serveur basé sur fichiers pour la coordination multi-agents (lead + assistants).

### Architecture

```
                    ┌─────────────────────────────────────┐
                    │      Lead Agent (orchestrateur)      │
                    │    - Lit state.env                   │
                    │    - Lit/tasks.tsv                   │
                    │    - Écrit notifications.log         │
                    └─────────────────────────────────────┘
                              │            │
                              │ (tasks.tsv) │ (state.env)
                              ▼            ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │              Répertoire .ipcrae/multi-agent/                     │
    │                                                                   │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
    │  │ state.env   │  │ tasks.tsv   │  │ notifications.log        │  │
    │  │             │  │             │  │                         │  │
    │  │ SESSION_ID= │  │ #ID STATUS  │  │ [2025-02-22 21:00:00]   │  │
    │  │ phase=work  │  │ t1 pending  │  │ Lead: Début session     │  │
    │  │ lead=...    │  │ t2 done     │  │ [2025-02-22 21:05:00]   │  │
    │  │ assistants= │  │ t3 active   │  │ Assistant1: Tâche t1 ok  │  │
    │  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
    └─────────────────────────────────────────────────────────────────┘
                              ▲            ▲
                              │            │
                              │ (lecture)  │ (écriture)
                              │            │
    ┌─────────────────────────────────────────────────────────────────┐
    │                Assistant Agents (parallèles)                      │
    │                                                                   │
    │  Assistant 1           Assistant 2           Assistant 3        │
    │  - Lit tasks.tsv       - Lit tasks.tsv       - Lit tasks.tsv   │
    │  - Prend tâche t1      - Prend tâche t2      - Prend tâche t3  │
    │  - Exécute             - Exécute             - Exécute          │
    │  - Notifie done        - Notifie done        - Notifie done     │
    └─────────────────────────────────────────────────────────────────┘
```

### Format des fichiers

#### `state.env` - État de session

```bash
# Identifiants
SESSION_ID=20250222-210000
SESSION_START=2025-02-22T21:00:00+01:00

# Phase actuelle
PHASE=planning|execution|synthesis

# Agents
LEAD_AGENT=claude
ASSISTANT_AGENTS=gemini,codex,kilo

# Contexte
CURRENT_PROJECT=mon-projet
CURRENT_DOMAIN=devops

# Métriques
TASKS_TOTAL=10
TASKS_COMPLETED=5
TASKS_ACTIVE=3
```

#### `tasks.tsv` - Backlog partagé

```tsv
ID	STATUS	ASSIGNEE	DESCRIPTION	PRIORITY	CREATED	UPDATED
t1	pending		Analyser architecture du projet	high	2025-02-22	2025-02-22
t2	active	gemini	Implémenter auth JWT	high	2025-02-22	2025-02-22
t3	done	codex	Créer tests unitaires	medium	2025-02-22	2025-02-22
t4	pending		Documenter API endpoints	low	2025-02-22	2025-02-22
t5	pending		Setup Docker Compose	high	2025-02-22	2025-02-22
```

**Status possibles**: `pending`, `active`, `done`, `blocked`, `cancelled`
**Priority**: `high`, `medium`, `low`

#### `notifications.log` - Historique inter-agents

```log
[2025-02-22 21:00:00] [LEAD] Session démarrée. ID: 20250222-210000
[2025-02-22 21:01:23] [LEAD] Tâche t1 créée: "Analyser architecture du projet"
[2025-02-22 21:02:15] [GEMINI] Tâche t2 assignée à gemini
[2025-02-22 21:03:45] [GEMINI] Tâche t2 complétée
[2025-02-22 21:04:00] [LEAD] Tâche t2 marquée done
[2025-02-22 21:05:00] [LEAD] Phase passée: planning → execution
```

### Flux de coordination

```
1. Lead Agent initialise state.env
   ↓
2. Lead remplit tasks.tsv avec backlog initial
   ↓
3. Assistants pollent tasks.tsv périodiquement
   ↓
4. Assistant A prend tâche t1 (STATUS: pending → active, ASSIGNEE: A)
   ↓
5. Assistant A exécute, notifie dans notifications.log
   ↓
6. Assistant A marque tâche t1 done (STATUS: done)
   ↓
7. Lead détecte changement, consolide dans memory/
   ↓
8. Répéter 4-7 jusqu'à backlog vide
   ↓
9. Lead passe PHASE: execution → synthesis
   ↓
10. Lead génère rapport final, ferme session
```

### Avantages du protocole file-based

- **Sans serveur**: Pas de dépendance à un service externe
- **Versionnable**: L'historique complet est dans Git
- **Debuggable**: Fichiers texte lisibles par l'humain
- **Scalable**: Supporte N assistants parallèles
- **Résilient**: Les fichiers survivent aux crashes agents
- **Obsidian-friendly**: Intégration directe dans le vault
