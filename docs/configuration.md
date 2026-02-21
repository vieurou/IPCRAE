# Configuration IPCRAE — `config.yaml`

Fichier généré à l'installation dans `$IPCRAE_ROOT/.ipcrae/config.yaml`.
Tracké en Git (ne contient pas de secrets).

---

## Format complet annoté

```yaml
# IPCRAE v3 Configuration

# Chemin absolu du vault (cerveau)
# Défaut : $HOME/IPCRAE — override via $IPCRAE_ROOT dans le shell
ipcrae_root: "/home/<user>/IPCRAE"

# Version du script CLI installé (ipcrae-install.sh injecte cette valeur)
script_version: "3.3.0"

# Version documentaire de la méthode (README, conventions, contrat CDE)
method_version: "3.3"

# Agent IA par défaut utilisé par ipcrae work / ipcrae ingest
# Valeurs valides : claude | gemini | codex | kilo
default_provider: "claude"

# Commit automatique du vault après chaque close/daily/capture
# true (défaut) = commit auto en arrière-plan
# false = pas de commit auto (commit manuel requis)
auto_git_sync: true

# Push automatique vers brain_remote après auto_git_sync
# false (défaut) = push manuel via ipcrae close ou git push
# true = push immédiat (activer explicitement ou export IPCRAE_AUTO_GIT_PUSH=true)
auto_git_push: false

# Remote Git du vault (cerveau)
# Utilisé par ipcrae close pour le push brain.git
brain_remote: "https://github.com/<user>/brain.git"

# Remotes des repos DEV liés (facultatif, utilisé pour les tags croisés)
project_remotes:
  <slug>: "https://github.com/<user>/<repo>.git"

# Configuration des providers IA
providers:
  claude:
    enabled: true
    command: claude          # binaire dans $PATH
  gemini:
    enabled: true
    command: gemini
  codex:
    enabled: false           # désactiver si non installé
    command: codex
  kilo:
    enabled: true
    note: "Extension VS Code — inject via .kilocode/rules/ipcrae.md"
```

---

## Variables d'environnement (override config.yaml)

| Variable | Effet | Défaut |
|----------|-------|--------|
| `IPCRAE_ROOT` | Override `ipcrae_root` | `$HOME/IPCRAE` |
| `IPCRAE_AUTO_GIT_PUSH` | Override `auto_git_push` | `false` |
| `IPCRAE_AUTO_GIT` | Désactive entièrement auto_git_sync si `false` | `true` |
| `IPCRAE_DEFAULT_PROVIDER` | Override `default_provider` | valeur config |

---

## Champs obligatoires

Ces champs doivent être présents et non vides pour que `ipcrae doctor` passe :

- `ipcrae_root`
- `default_provider`

`ipcrae doctor` vérifie aussi que `ipcrae_root` est un répertoire existant.

---

## Modifier la config

```bash
# Édition directe
$EDITOR $IPCRAE_ROOT/.ipcrae/config.yaml

# Vérifier après modification
ipcrae doctor
```

Ne pas modifier manuellement `script_version` ou `method_version` — ces champs
sont mis à jour par `ipcrae-install.sh` lors des mises à jour.
