---
type: process
tags: [ipcrae, inbox, ingest, automation, knowledge]
domain: devops
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Process : Ingestion automatique Inbox/infos à traiter/

## Déclencheur

- Dépôt d'un fichier `.md` dans `Inbox/infos à traiter/` (temps réel via daemon)
- `ipcrae start` (fallback batch si daemon inactif)
- Manuel : `ipcrae-ingest-infos [fichier.md] [--dry-run] [--verbose]`

## Architecture

```
[inotifywait daemon]  →  ipcrae-ingest-infos  →  Vault
    (systemd)              (classification)        (files + git)
ipcrae-inbox-watch.service   heuristique + routing
```

## Classification heuristique

| Type | Critères | Action |
|------|----------|--------|
| **INFO** | `type: info/knowledge/ressource`, code blocks, mots-clés factuels | → Knowledge/howto/ + memory/<domain> |
| **DEMANDE** | `type: demande/task/action`, checkboxes `[ ]`, verbes d'action | → tracking.md + Casquette |
| **MIXTE** | Score INFO ≥ 6 ET DEMANDE ≥ 6 | Les deux protocoles |
| **REVIEW** | Ambigu (aucun seuil atteint) | Tâche REVIEW + copie demandes-brutes/ |

## Protocole INFO

1. Extraire titre (frontmatter `title:` ou H1 ou nom fichier)
2. Créer `Knowledge/howto/<slug>.md` avec frontmatter canonique
3. Appender dans `memory/<domain>.md` (section `### YYYY-MM-DD — Ingestion: <titre>`)
4. Rebuilder le tag cache : `ipcrae index`

## Protocole DEMANDE

1. Détecter le projet (frontmatter `project:` ou keywords)
2. Router vers la Casquette (voir `Process/routing-taches-casquettes.md`)
3. Ajouter dans `Projets/<slug>/tracking.md` section Backlog
4. Ajouter dans la Casquette cible
5. Traçabilité : `ipcrae-capture-request "<titre>"`

## Archivage (toujours)

```
Inbox/infos à traiter/<fichier>  →  Inbox/infos à traiter/traites/YYYY-MM-DD-<fichier>
```
En-tête de traçabilité ajouté : `<!-- traité: YYYY-MM-DD → <type> → <destination> -->`

## Installation du daemon temps réel

```bash
# Prérequis (une seule fois)
sudo apt install -y inotify-tools

# Démarrer le service
systemctl --user start ipcrae-inbox-watch.service

# Vérifier le statut
systemctl --user status ipcrae-inbox-watch.service
```

## Vérification

```bash
# Test INFO
cat > "$IPCRAE_ROOT/Inbox/infos à traiter/test-info.md" << 'EOF'
---
type: info
domain: devops
---
# Résumé : Comment fonctionne Traefik
Traefik est un reverse proxy automatique...
EOF

# Test DEMANDE
cat > "$IPCRAE_ROOT/Inbox/infos à traiter/test-demande.md" << 'EOF'
# À faire : Ajouter monitoring Prometheus
Il faut implémenter un dashboard Prometheus pour megadockerapi.
EOF

# Vérifier log
tail -20 "$IPCRAE_ROOT/.ipcrae/auto/inbox-watch.log"
```

## Logs

- Daemon : `$IPCRAE_ROOT/.ipcrae/auto/inbox-watch.log`
- Journal daily : entrée auto `#### Auto-ingest infos à traiter — HH:MM`

## Liens

- [[Knowledge/howto/ipcrae-ingest-infos]]
- [[Process/routing-taches-casquettes]]
- [[Process/inbox-scan]]
