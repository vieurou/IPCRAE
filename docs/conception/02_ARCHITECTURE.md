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

## 2. Décisions de Conception (ADR)

- **ADR-001** : Stockage 100% Markdown local — simplicité, compatibilité Obsidian, versioning Git sans dépendance externe.
- **ADR-002** : Multi-provider IA (Claude/Gemini/Codex/Kilo) — pas de lock-in fournisseur ; `ipcrae-agent-bridge` compare les sorties.
- **ADR-003** : Mémoire IA par domaine (`memory/devops.md`, `memory/musique.md`...) — réduction du bruit contextuel, isolation des domaines métier.
- **ADR-004** : Fichiers providers (`CLAUDE.md`, `GEMINI.md`) générés depuis `context.md + instructions.md` via `ipcrae sync` — source unique de vérité, édition manuelle interdite.
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
│   └── cache/tag-index.json  # Cache tags (dérivé, reconstructible)
├── memory/
│   ├── devops.md | electronique.md | musique.md | maison.md | sante.md | finance.md
│   └── index.md
├── Knowledge/
│   ├── howto/ | runbooks/ | patterns/ | MOC/
│   └── _template_knowledge.md
├── Projets/                  # Hubs centraux par projet (index + tracking + memory)
├── Casquettes/               # Responsabilités continues (areas)
├── Inbox/waiting-for.md
├── Journal/{Daily,Weekly,Monthly}/
├── Phases/index.md           # Source de priorités active
├── Process/                  # Procédures récurrentes (checklists)
├── Objectifs/someday.md
├── Zettelkasten/{_inbox,permanents,MOC}/
├── Agents/agent_<domaine>.md
├── CLAUDE.md / GEMINI.md / AGENTS.md   # Générés — ne pas éditer manuellement
└── index.md                  # Dashboard central
```

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
| `ipcrae-prompt-optimize` | Optimise un prompt selon l'agent cible avant délégation |
| `ipcrae-index` | Reconstruit le cache `tag-index.json` depuis les frontmatters Markdown |
| `ipcrae-tag` | Liste les fichiers liés à un tag donné |
| `ipcrae-migrate-safe` | Migration non destructive (backup tar.gz + merge non-overwrite des prompts) |
| `ipcrae-uninstall` | Purge du système |

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
├── .ipcrae-memory -> ~/IPCRAE  # Symlink vers vault global
└── .ai-instructions.md      # Directive : lire mémoire globale, écrire local
```
