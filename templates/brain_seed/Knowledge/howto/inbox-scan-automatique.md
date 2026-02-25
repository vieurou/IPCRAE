---
type: knowledge
tags: [inbox, scan, automatisation, bash, boot, ipcrae]
domain: devops
status: active
sources:
  - project:IPCRAE/scripts/ipcrae-inbox-scan.sh
  - project:IPCRAE/Process/inbox-scan.md
  - project:IPCRAE/Process/session-boot.md
created: 2026-02-22
updated: 2026-02-22
---

# How-to : Scan automatique de l'Inbox (bash pur)

## Concept
L'Inbox IPCRAE doit être scannée automatiquement à chaque démarrage de session — **sans IA** (bash pur, < 1 seconde). Si des fichiers sont détectés, un flag est posé pour que le prochain agent les traite.

## Architecture (2 couches)

```
COUCHE 1 — Bash pur (zéro IA)
  ipcrae-inbox-scan
    → Scanne Inbox/*/
    → Ignore README.md et traites/
    → Génère .ipcrae/auto/inbox-pending.md
    → Crée flag .ipcrae/auto/inbox-needs-processing
    → Exit 0 (rien) | 1 (items détectés)

COUCHE 2 — Agent IA (si flag présent)
  → Lit inbox-pending.md
  → Traite selon Process/inbox-scan.md
  → Archive dans traites/
  → Supprime le flag
```

## Usage

```bash
# Scan manuel
ipcrae-inbox-scan [--verbose] [--dry-run] [$IPCRAE_ROOT]

# Automatique à chaque ipcrae start
ipcrae start --project <slug>

# Voir le rapport
cat $IPCRAE_ROOT/.ipcrae/auto/inbox-pending.md
```

## Préférences d'agent
Stockées dans `.ipcrae/auto/inbox-agent-prefs.yaml` (créé au premier scan) :
```yaml
default_agent: claude
folder_agents:
  "infos à traiter": claude
  idees: claude
  taches: claude
  liens: claude
  projets-entrants: claude
  media: claude
  snippets: claude
  demandes-brutes: claude
```

## Sous-dossiers Inbox

| Dossier | Type de capture | Traitement |
|---------|----------------|-----------|
| `infos à traiter/` | Texte brut, discussions | Analyse → Knowledge/Process/Ressources |
| `idees/` | Brainstorm | → Zettelkasten/_inbox/ |
| `taches/` | Actions | → Casquette/Projet tracking |
| `liens/` | URLs | → Ressources/<domaine>/ |
| `projets-entrants/` | Idées projet | → process-ingest-projet |
| `media/` | Captures visuelles | → Ressources/ |
| `snippets/` | Code fragments | → Knowledge/howto/ |
| `demandes-brutes/` | Requests utilisateur | → Vérification traitement |

## Liens
- [[session-boot-2-couches]] — Architecture du boot
- [[Process/inbox-scan]] — Process de traitement
- [[Process/session-boot]] — Process de boot complet
