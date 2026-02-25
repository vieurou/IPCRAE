---
type: knowledge
tags: [ipcrae, installation, bash, runbook, onboarding]
project: IPCRAE
domain: devops
status: stable
sources:
  - project:IPCRAE/ipcrae-install.sh
  - project:IPCRAE/README.md
created: 2026-02-21
updated: 2026-02-21
---

# Runbook : Installation IPCRAE (vault + CLI + projet local)

## Prérequis
- bash, git, curl
- `~/bin` dans le PATH (`echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc`)

## 1. Installer le vault central

```bash
git clone https://github.com/vieurou/IPCRAE.git ~/DEV/IPCRAE
cd ~/DEV/IPCRAE
bash ipcrae-install.sh -y "$HOME/IPCRAE"
```

**Options utiles :**
- `-y` : non-interactif (toutes réponses par défaut)
- `-d` / `--dry-run` : simulation, aucun fichier écrit
- `-V` : affiche la version

**Ce que l'installateur crée :**
- Arborescence complète du vault (Inbox, Projets, Casquettes, Journal, memory/, Knowledge/, Zettelkasten/, etc.)
- `.ipcrae/context.md` + `instructions.md` + `config.yaml`
- Prompts agents dans `.ipcrae/prompts/`
- Scripts CLI dans `~/bin/` : `ipcrae`, `ipcrae-addProject`, `ipcrae-tokenpack`, `ipcrae-agent-bridge`, `ipcrae-prompt-optimize`, `ipcrae-index`, `ipcrae-tag`

## 2. Vérifier l'installation

```bash
ipcrae doctor
```

Invariants vérifiés :
- `.ipcrae/context.md` et `instructions.md` existent
- Providers générés (CLAUDE.md, GEMINI.md, AGENTS.md)
- `.ipcrae/cache/tag-index.json` présent

## 3. Initialiser un projet local (mode CDE)

```bash
cd /chemin/vers/mon-projet
IPCRAE_ROOT="$HOME/IPCRAE" ipcrae-addProject
```

Crée dans le repo local :
- `docs/conception/` (00_VISION.md, 01_AI_RULES.md, 02_ARCHITECTURE.md, 03_IPCRAE_BRIDGE.md)
- `.ipcrae-project/local-notes/`
- `.ipcrae-memory` → symlink vers `~/IPCRAE`
- `.ai-instructions.md`
- Hub dans `~/IPCRAE/Projets/<slug>/` (index.md, tracking.md, memory.md)

## 4. Migration depuis une version existante

```bash
ipcrae migrate-safe
```

Algorithme :
1. Backup tar.gz complet du vault
2. Merge non-destructif des prompts (`.ipcrae/prompts/`) : absent → généré, différent → gardé en `.new-<timestamp>`
3. Mise à jour scripts CLI avec backup
4. Rapport de migration dans `.ipcrae/backups/`

## Troubleshooting

| Problème | Solution |
|----------|----------|
| `ipcrae` introuvable | `export PATH=$HOME/bin:$PATH` + ajouter dans `.bashrc` |
| Symlink `.ipcrae-memory` cassé | Relancer `ipcrae-addProject` localement |
| Contexte IA incomplet | `ipcrae sync` puis `ipcrae doctor` |
| Fichiers `.ipcrae/*` absents | Vérifier `$IPCRAE_ROOT` |

## Vérification QA rapide

```bash
bash -n ipcrae-install.sh        # lint syntaxe bash
TMP_HOME=$(mktemp -d)
HOME="$TMP_HOME" bash ipcrae-install.sh -y "$(mktemp -d)/vault"
```
