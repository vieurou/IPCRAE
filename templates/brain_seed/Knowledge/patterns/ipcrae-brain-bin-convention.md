---
type: knowledge
tags: [ipcrae, cli, installation, path, convention, devops]
project: IPCRAE
domain: devops
status: stable
sources:
  - path: templates/ipcrae-launcher.sh
  - path: templates/ipcrae-addProject.sh
  - path: ipcrae-install.sh
created: 2026-02-25
updated: 2026-02-25
---

# Convention installation CLI IPCRAE (cerveau + .bin)

## Décision
- Cerveau global par défaut : `~/brain`
- Variable dédiée au cerveau : `IPCRAE_brain`
- Alias compatibilité : `IPCRAE_ROOT`
- Scripts CLI installés dans : `$IPCRAE_brain/.bin`

## Règles de résolution
Priorité de résolution du cerveau dans les scripts :
1. `IPCRAE_brain`
2. `IPCRAE_BRAIN`
3. `IPCRAE_ROOT` (legacy)
4. `~/brain`

## Motivation
- Évite la confusion entre repo source IPCRAE (ex: `~/DEVs/IPCRAE`) et cerveau global.
- Évite la pollution de `~/bin` à la racine utilisateur.
- Rend l'installation plus portable et cohérente avec la structure du cerveau.
