---
type: knowledge
title: IPCRAE — Pipeline ingest Inbox/infos à traiter
tags: [ipcrae, inbox, ingest, automation, knowledge, bash, systemd, inotify]
domain: devops
status: active
sources: [vault:Process/ingest-infos-a-traiter]
created: 2026-02-22
updated: 2026-02-22
---

# IPCRAE — Pipeline ingest Inbox/infos à traiter

## Résumé

Pipeline automatique pour traiter les fichiers déposés dans `Inbox/infos à traiter/`.
Classifie chaque fichier (INFO / DEMANDE / MIXTE / REVIEW), route vers le bon emplacement vault, archive, et commit.

## Composants

| Script | Rôle |
|--------|------|
| `~/bin/ipcrae-ingest-infos` | Classification + routing + archivage + commit |
| `~/bin/ipcrae-watch-inbox` | Daemon inotifywait → appel ingest |
| `~/.config/systemd/user/ipcrae-inbox-watch.service` | Service persistant |

## Usage courant

```bash
# Traiter tous les fichiers en attente
ipcrae-ingest-infos

# Traiter un fichier spécifique
ipcrae-ingest-infos mon-fichier.md

# Mode test (aucune écriture)
ipcrae-ingest-infos --dry-run --verbose

# Vérifier le daemon temps réel
systemctl --user status ipcrae-inbox-watch.service

# Voir les logs
tail -f ~/IPCRAE/.ipcrae/auto/inbox-watch.log
```

## Classification heuristique

Le script attribue des scores à chaque fichier :

- **INFO** (score ≥ 6) : frontmatter `type: info/knowledge`, blocs code, mots factuels
- **DEMANDE** (score ≥ 6) : frontmatter `type: demande/task`, checkboxes `[ ]`, verbes d'action
- **MIXTE** : les deux seuils atteints → applique les deux protocoles
- **REVIEW** : ambigu → tâche REVIEW + copie `Inbox/demandes-brutes/`

## Flux de données

```
Inbox/infos à traiter/<fichier>.md
    ↓ classify()
  INFO → Knowledge/howto/<slug>.md + memory/<domain>.md + ipcrae index
  DEMANDE → Projets/<slug>/tracking.md + Casquettes/<casquette>.md
  MIXTE → (INFO + DEMANDE)
  REVIEW → Projets/IPCRAE/tracking.md (tâche REVIEW) + Inbox/demandes-brutes/
    ↓ archive()
Inbox/infos à traiter/traites/YYYY-MM-DD-<fichier>.md
    ↓ git commit
"Auto: ingest infos-à-traiter — <fichier> → <type>"
```

## Prérequis installation daemon

```bash
# Installer inotify-tools (nécessite sudo)
sudo apt install -y inotify-tools

# Activer et démarrer le service
systemctl --user enable --now ipcrae-inbox-watch.service
```

## Routing casquettes

| Keywords détectés | Casquette |
|-------------------|-----------|
| `hardware`, `pcb`, `kicad`, `esp32`, `firmware` | `Architecte_Hardware.md` |
| `ipcrae`, `bash`, `script`, `devops`, `agent`, `ia` | `ipcrae-toolchain.md` |
| Autres | `Lead_Developer.md` |

## Patterns frontmatter recommandés

```yaml
# Pour guider la classification :
---
type: info          # → protocole INFO
domain: devops      # → memory/devops.md
tags: [tag1, tag2]
project: IPCRAE     # → Projets/IPCRAE/tracking.md
---
```

## Liens

- [[Process/ingest-infos-a-traiter]]
- [[Process/routing-taches-casquettes]]
- [[Knowledge/howto/ipcrae-inbox-scan]]
