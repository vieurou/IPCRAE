# Référence des Commandes IPCRAE

Ce document fournit une référence complète de toutes les commandes IPCRAE avec exemples d'usage et mapping vers les scripts implémentation.

## Sommaire

- [1. Commandes Principales (launcher `ipcrae`)](#1-commandes-principales-launcher-ipcrae)
- [2. Scripts CLI installés dans ~/bin](#2-scripts-cli-installés-dans-bin)
- [3. Scripts utilitaires (templates/)](#3-scripts-utilitaires-templates)
- [4. Scripts d'automatisation (scripts/)](#4-scripts-dautomatisation-scripts)

---

## 1. Commandes Principales (launcher `ipcrae`)

Le script principal `templates/ipcrae-launcher.sh` est le point d'entrée unique pour IPCRAE.

### Workflow quotidien

| Commande | Description | Exemple | Script implémentation |
|----------|-------------|---------|----------------------|
| `ipcrae daily` | Journal quotidien + objectifs du jour | `ipcrae daily` | `templates/ipcrae-launcher.sh` |
| `ipcrae weekly` | Synthèse hebdomadaire + planification | `ipcrae weekly` | `templates/ipcrae-launcher.sh` |
| `ipcrae monthly` | Revue mensuelle complète | `ipcrae monthly` | `templates/ipcrae-launcher.sh` |

### Session IA

| Commande | Description | Exemple | Script implémentation |
|----------|-------------|---------|----------------------|
| `ipcrae start <provider>` | Démarrer session IA avec contexte | `ipcrae start claude` | `templates/ipcrae-launcher.sh` |
| `ipcrae work "<objectif>"` | Travailler sur un objectif avec l'IA | `ipcrae work "Implémenter API REST"` | `templates/ipcrae-launcher.sh` |
| `ipcrae close <domaine>` | Fermer session + consolidation mémoire | `ipcrae close devops` | `templates/ipcrae-launcher.sh` |
| `ipcrae health` | Vérifier l'état du système | `ipcrae health` | `templates/ipcrae-launcher.sh` |

### Gestion du Vault

| Commande | Description | Exemple | Script implémentation |
|----------|-------------|---------|----------------------|
| `ipcrae sync` | Régénérer fichiers providers depuis sources | `ipcrae sync` | `templates/ipcrae-launcher.sh` |
| `ipcrae index` | Reconstruire cache tags | `ipcrae index` | `templates/scripts/ipcrae-index.sh` |
| `ipcrae tag <tag>` | Lister fichiers liés à un tag | `ipcrae tag docker` | `templates/scripts/ipcrae-tag.sh` |
| `ipcrae moc <domaine>` | Générer MOC pour un domaine | `ipcrae moc devops` | `templates/ipcrae-launcher.sh` |
| `ipcrae zettel` | Créer une nouvelle note Zettelkasten | `ipcrae zettel` | `templates/ipcrae-launcher.sh` |

### Gestion des projets

| Commande | Description | Exemple | Script implémentation |
|----------|-------------|---------|----------------------|
| `ipcrae addProject <slug> <url>` | Créer nouveau projet + initialiser IPCRAE | `ipcrae addProject mon-api https://github.com/user/mon-api.git` | `templates/ipcrae-addProject.sh` |
| `ipcrae archive <slug>` | Archiver un projet terminé | `ipcrae archive mon-api` | `templates/ipcrae-launcher.sh` |
| `ipcrae project <slug>` | Ouvrir le dashboard d'un projet | `ipcrae project mon-api` | `templates/ipcrae-launcher.sh` |

### Gestion GTD

| Commande | Description | Exemple | Script implémentation |
|----------|-------------|---------|----------------------|
| `ipcrae demandes [status\|done]` | Suivi des demandes brutes | `ipcrae demandes status` | `templates/ipcrae-launcher.sh` |
| `ipcrae process [nom]` | Créer/ouvrir process récurrent | `ipcrae process "Review Hebdo"` | `templates/ipcrae-launcher.sh` |
| `ipcrae capture "<texte>"` | Capturer rapide dans Inbox | `ipcrae capture "Idée: script de backup auto"` | `templates/ipcrae-launcher.sh` |

### Synchronisation Git

| Commande | Description | Exemple | Script implémentation |
|----------|-------------|---------|----------------------|
| `ipcrae sync-git` | Sauvegarde Git complète (add, commit, push) | `ipcrae sync-git` | `templates/ipcrae-launcher.sh` |
| `ipcrae remote list` | Lister tous les remotes configurés | `ipcrae remote list` | `templates/ipcrae-launcher.sh` |
| `ipcrae remote set-brain <url>` | Configurer remote du cerveau | `ipcrae remote set-brain https://github.com/user/IPCRAE.git` | `templates/ipcrae-launcher.sh` |
| `ipcrae remote set-project <slug> <url>` | Configurer remote d'un projet | `ipcrae remote set-project mon-api https://github.com/user/mon-api.git` | `templates/ipcrae-launcher.sh` |

### Gestion des Prompts

| Commande | Description | Exemple | Script implémentation |
|----------|-------------|---------|----------------------|
| `ipcrae prompt build --agent <domaine>` | Compiler les couches de prompts | `ipcrae prompt build --agent devops` | `templates/ipcrae-launcher.sh` |
| `ipcrae prompt check` | Vérifier cohérence des sections | `ipcrae prompt check` | `templates/ipcrae-launcher.sh` |
| `ipcrae prompt --list` | Lister les agents disponibles | `ipcrae prompt --list` | `templates/ipcrae-launcher.sh` |
| `ipcrae prompt optimize --agent <domaine> "<prompt>"` | Optimiser un prompt pour un agent | `ipcrae prompt optimize --agent devops "Créer un Dockerfile..."` | `templates/scripts/ipcrae-prompt-optimize.sh` |

### Multi-Agent

| Commande | Description | Exemple | Script implémentation |
|----------|-------------|---------|----------------------|
| `ipcrae allcontext "<texte>"` | Pipeline d'analyse universel | `ipcrae allcontext "Analyser architecture microservices..."` | `scripts/ipcrae-allcontext.sh` |
| `ipcrae agent bridge "<commande>"` | Interroger agents disponibles | `ipcrae agent bridge "docker build --help"` | `templates/scripts/ipcrae-agent-bridge.sh` |
| `ipcrae agent hub <lead> <assistants>` | Lancer session multi-agents | `ipcrae agent hub claude "gemini,codex"` | `templates/scripts/ipcrae-agent-hub.sh` |

### Utilitaires

| Commande | Description | Exemple | Script implémentation |
|----------|-------------|---------|----------------------|
| `ipcrae tokenpack [core\|projet <slug>]` | Générer contexte compact | `ipcrae tokenpack core` | `templates/scripts/ipcrae-tokenpack.sh` |
| `ipcrae update` | Mettre à jour IPCRAE | `ipcrae update` | `templates/ipcrae-launcher.sh` |
| `ipcrae migrate-safe` | Migration non destructive | `ipcrae migrate-safe` | `templates/ipcrae-migrate-safe.sh` |
| `ipcrae uninstall` | Purger le système | `ipcrae uninstall` | `templates/scripts/ipcrae-uninstall.sh` |

---

## 2. Scripts CLI installés dans ~/bin

Ces scripts sont directement accessibles depuis n'importe où dans le terminal.

| Script | Description | Commande principale équivalente | Chemin source |
|--------|-------------|----------------------------------|---------------|
| `ipcrae` | Launcher principal | `ipcrae <commande>` | `templates/ipcrae-launcher.sh` |
| `ipcrae-addProject` | Initialiser repo local CDE | `ipcrae addProject` | `templates/ipcrae-addProject.sh` |
| `ipcrae-tokenpack` | Générer contexte compact | `ipcrae tokenpack` | `templates/scripts/ipcrae-tokenpack.sh` |
| `ipcrae-agent-bridge` | Interroger agents CLI | `ipcrae agent bridge` | `templates/scripts/ipcrae-agent-bridge.sh` |
| `ipcrae-agent-hub` | Coordonner multi-agents | `ipcrae agent hub` | `templates/scripts/ipcrae-agent-hub.sh` |
| `ipcrae-prompt-optimize` | Optimiser prompts | `ipcrae prompt optimize` | `templates/scripts/ipcrae-prompt-optimize.sh` |
| `ipcrae-index` | Reconstruire cache tags | `ipcrae index` | `templates/scripts/ipcrae-index.sh` |
| `ipcrae-tag` | Lister fichiers par tag | `ipcrae tag` | `templates/scripts/ipcrae-tag.sh` |
| `ipcrae-migrate-safe` | Migration non destructive | `ipcrae migrate-safe` | `templates/ipcrae-migrate-safe.sh` |
| `ipcrae-uninstall` | Purge du système | `ipcrae uninstall` | `templates/scripts/ipcrae-uninstall.sh` |

---

## 3. Scripts utilitaires (templates/)

Scripts internes utilisés par le launcher mais pas installés directement.

| Script | Rôle | Utilisé par |
|--------|------|-------------|
| `templates/ipcrae-launcher.sh` | Launcher principal (parse arguments, dispatch) | `ipcrae` |
| `templates/ipcrae-addProject.sh` | Initialisation projet local | `ipcrae addProject` |
| `templates/scripts/ipcrae-index.sh` | Indexation tags depuis frontmatter | `ipcrae index` |
| `templates/scripts/ipcrae-tag.sh` | Recherche par tag | `ipcrae tag` |
| `templates/scripts/ipcrae-tokenpack.sh` | Génération contexte compact | `ipcrae tokenpack` |
| `templates/scripts/ipcrae-agent-bridge.sh` | Pont vers agents CLI externes | `ipcrae agent bridge` |
| `templates/scripts/ipcrae-agent-hub.sh` | Orchestration multi-agents | `ipcrae agent hub` |
| `templates/scripts/ipcrae-prompt-optimize.sh` | Optimisation prompts | `ipcrae prompt optimize` |
| `templates/ipcrae-migrate-safe.sh` | Migration avec backup | `ipcrae migrate-safe` |
| `templates/scripts/ipcrae-uninstall.sh` | Désinstallation complète | `ipcrae uninstall` |

---

## 4. Scripts d'automatisation (scripts/)

Scripts avancés pour automatisation et intégrations externes.

| Script | Rôle | Utilisation typique |
|--------|------|---------------------|
| `scripts/ipcrae-task.sh` | Gestion des tâches (création, suivi) | `bash scripts/ipcrae-task.sh new "Description"` |
| `scripts/ipcrae-allcontext.sh` | Pipeline d'analyse universel | `bash scripts/ipcrae-allcontext.sh "Analyser..."` |
| `scripts/ipcrae-inbox-scan.sh` | Scan automatique Inbox/demandes-brutes | Cron job quotidien |
| `scripts/ipcrae-capture-request.sh` | Capture de requêtes externes | Webhook handler |
| `scripts/ipcrae-agent-bootstrap.sh` | Bootstrapping agent autonome | `bash scripts/ipcrae-agent-bootstrap.sh` |
| `scripts/ipcrae-moc-auto.sh` | Génération automatique MOC | Cron job hebdomadaire |
| `scripts/ipcrae-audit-check.sh` | Vérifications post-audit | Après modifications majeures |
| `scripts/auto_audit.sh` | Audit automatique du système | `bash scripts/auto_audit.sh` |
| `scripts/audit_ipcrae.sh` | Audit complet manuel | `bash scripts/audit_ipcrae.sh` |
| `scripts/audit_non_regression.sh` | Tests de non-régression | `bash scripts/audit_non_regression.sh` |
| `scripts/apply_ipcrae_corrections.sh` | Application corrections audit | Après audit auto |
| `scripts/ipcrae-methodology-e2e.sh` | Test E2E reproductible de la méthode (install → bootstrap → cerveau → auto-audit → rapport) | `bash scripts/ipcrae-methodology-e2e.sh --vault /tmp/IPCRAE_CERVEAU_E2E --agent codex` |

---

## 5. Flux de commandes typiques

### Session de développement

```bash
# 1. Démarrage journal
ipcrae daily

# 2. Ouverture projet
cd ~/dev/mon-api
ipcrae project mon-api

# 3. Démarrage session IA
ipcrae start claude

# 4. Travail avec l'IA
ipcrae work "Implémenter endpoint POST /users"

# 5. Génération contexte si besoin
ipcrae tokenpack projet mon-api

# 6. Fermeture session
ipcrae close devops

# 7. Synchronisation
ipcrae sync-git
```

### Multi-Agent parallèle

```bash
# 1. Initialisation session multi-agent
ipcrae allcontext "Analyser architecture microservices pour app e-commerce"

# 2. Lancement hub multi-agents
ipcrae agent hub claude "gemini,codex"

# 3. Les agents travaillent en parallèle via .ipcrae/multi-agent/tasks.tsv

# 4. Consolidation automatique dans memory/
```

### GTD quotidien

```bash
# 1. Capture rapide
ipcrae capture "Bug fix: login timeout after 30s"

# 2. Suivi demandes brutes
ipcrae demandes status

# 3. Organisation
ipcrae process "Review Hebdo GTD"

# 4. Synthèse journalière
ipcrae daily
```

---

## 6. Variables d'environnement

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `IPCRAE_ROOT` | Racine du vault | `~/IPCRAE` |
| `IPCRAE_AUTO_GIT` | Activer synchro Git auto | `false` |
| `IPCRAE_DEFAULT_PROVIDER` | Provider IA par défaut | `claude` |
| `IPCRAE_DEBUG` | Mode debug (verbose) | `false` |
| `EDITOR` | Éditeur par défaut | `vim` |

Exemple:
```bash
export IPCRAE_ROOT="$HOME/IPCRAE"
export IPCRAE_AUTO_GIT="true"
export IPCRAE_DEFAULT_PROVIDER="claude"
```

---

## 7. Configuration

Le fichier `.ipcrae/config.yaml` configure le comportement global:

```yaml
# Provider IA par défaut
default_provider: claude

# Synchronisation Git automatique
git:
  auto_sync: false
  brain_remote: origin
  brain_url: https://github.com/vieurou/IPCRAE.git
  project_remotes:
    mon-projet: git@github.com:vieurou/mon-projet.git

# Comportement des agents
agents:
  max_concurrent: 3
  timeout: 300  # secondes

# Prompts
prompts:
  core_path: .ipcrae/prompts/core/
  domains_path: .ipcrae/prompts/domains/
```

---

## 8. Intégration avec Obsidian

### Commandes Obsidian (via plugins)

Les commandes CLI peuvent être invoquées depuis Obsidian via:
- **Command Palette** → Custom scripts
- **Hotkeys** → Mapped to shell commands
- **URI scheme** → `obsidian://ipcrae?command=daily`

Exemple de configuration `obsidian-commands`:

```json
{
  "IPCRAE: Daily": {
    "command": "ipcrae daily",
    "hotkey": "Alt+D"
  },
  "IPCRAE: Sync": {
    "command": "ipcrae sync-git",
    "hotkey": "Alt+S"
  }
}
```

---

## 9. Mapping complet commande → script

| Commande | Script principal | Scripts secondaires |
|----------|------------------|---------------------|
| `ipcrae daily` | `templates/ipcrae-launcher.sh` | - |
| `ipcrae start` | `templates/ipcrae-launcher.sh` | `templates/scripts/ipcrae-tokenpack.sh` |
| `ipcrae work` | `templates/ipcrae-launcher.sh` | - |
| `ipcrae close` | `templates/ipcrae-launcher.sh` | `templates/scripts/ipcrae-index.sh` |
| `ipcrae sync` | `templates/ipcrae-launcher.sh` | - |
| `ipcrae index` | `templates/scripts/ipcrae-index.sh` | - |
| `ipcrae tag` | `templates/scripts/ipcrae-tag.sh` | - |
| `ipcrae addProject` | `templates/ipcrae-addProject.sh` | - |
| `ipcrae tokenpack` | `templates/scripts/ipcrae-tokenpack.sh` | - |
| `ipcrae agent bridge` | `templates/scripts/ipcrae-agent-bridge.sh` | - |
| `ipcrae agent hub` | `templates/scripts/ipcrae-agent-hub.sh` | `templates/scripts/ipcrae-agent-bridge.sh` |
| `ipcrae prompt optimize` | `templates/scripts/ipcrae-prompt-optimize.sh` | - |
| `ipcrae allcontext` | `scripts/ipcrae-allcontext.sh` | `templates/scripts/ipcrae-tokenpack.sh` |
| `ipcrae sync-git` | `templates/ipcrae-launcher.sh` | `git` |
| `ipcrae update` | `templates/ipcrae-launcher.sh` | `git`, `bash ipcrae-install.sh` |
| `ipcrae migrate-safe` | `templates/ipcrae-migrate-safe.sh` | `tar`, `git` |
| `ipcrae uninstall` | `templates/scripts/ipcrae-uninstall.sh` | `rm`, `git` |

---

## 10. Aide et Debug

### Obtenir de l'aide

```bash
# Aide générale
ipcrae --help

# Aide sur une commande spécifique
ipcrae start --help

# Mode verbose
IPCRAE_DEBUG=true ipcrae start claude
```

### Debug

```bash
# Vérifier l'état du système
ipcrae health

# Vérifier la config
cat ~/.ipcrae/config.yaml

# Vérifier les logs
tail -f ~/.ipcrae/multi-agent/notifications.log

# Vérifier l'état des tâches
cat ~/.ipcrae/multi-agent/tasks.tsv
```

---

## 11. Notes de version

### Version actuelle: 1.0.0

**Nouvelles commandes récentes**:
- `ipcrae allcontext` (v0.9.0) - Pipeline d'analyse universel
- `ipcrae agent hub` (v0.8.0) - Orchestration multi-agents
- `ipcrae demandes` (v0.7.0) - Suivi GTD demandes brutes
- `ipcrae remote` (v0.6.0) - Gestion remotes Git

**Dépréciées**:
- `ipcrae new-note` → Utiliser `ipcrae zettel` ou `ipcrae capture`
- `ipcrae list-projects` → Utiliser `ipcrae project --list`

---

**Voir aussi**:
- `docs/conception/02_ARCHITECTURE.md` - Architecture technique
- `docs/workflows.md` - Workflows détaillés
- `templates/ipcrae-launcher.sh` - Implémentation du launcher
