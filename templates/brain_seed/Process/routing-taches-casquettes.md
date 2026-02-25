---
type: process
tags: [ipcrae, routing, taches, casquettes, gtd]
domain: devops
status: active
created: 2026-02-22
---

# Process : Routing des Tâches vers les Casquettes

## Déclencheur
- Une nouvelle tâche est identifiée, typiquement lors du scan de l'inbox (`Process/inbox-scan.md`).
- Une tâche est créée manuellement.

## Objectif
Assurer que chaque tâche actionnable soit assignée à la bonne "Casquette" (responsabilité) pour un traitement efficace.

## Étapes

### 1. Analyse de la Tâche
- Lire la description de la tâche.
- Identifier les mots-clés et les concepts principaux.
- Associer ces concepts à des `tags` (ex: `hardware`, `kicad`, `script`, `ipcrae`, `prompt`).

### 2. Consultation des Casquettes
- Lister les "Casquettes" existantes dans le répertoire `Casquettes/`.
- Lire les responsabilités de chaque casquette pour comprendre leur périmètre.

### 3. Logique de Routing (mapping tags → casquette)

Utiliser le mapping suivant pour déterminer la destination :

| Si la tâche contient les tags... | Alors router vers la Casquette... | Fichier Destination |
|----------------------------------|-----------------------------------|---------------------|
| `hardware`, `pcb`, `kicad`, `mcu`, `firmware`, `esp32` | **Architecte Hardware** | `Casquettes/Architecte_Hardware.md` |
| `ipcrae`, `script`, `bash`, `prompt`, `devops`, `toolchain`, `agent`, `ia` | **IPCRAE Toolchain** | `Casquettes/ipcrae-toolchain.md` |
| `dev`, `feature`, `bug` (non lié à IPCRAE) | **Lead Developer** | `Casquettes/Lead_Developer.md` |
| *Aucun match* | *Casquette par défaut* | `Casquettes/Lead_Developer.md` |

### 4. Assignation de la Tâche
- Ouvrir le fichier `.md` de la casquette de destination.
- Ajouter la tâche à la fin du fichier, sous une section `## Tâches Entrantes` ou `## Backlog`.
- Utiliser le format `- [ ] Description de la tâche (Source: <lien vers la demande brute si applicable>)`.

### 5. Mise à jour de la Source
- Si la tâche provient d'un item de l'inbox, archiver l'item en ajoutant un commentaire de traitement.
- Exemple: `<!-- traité: 2026-02-22 → Tâche routée vers [[Casquettes/ipcrae-toolchain]] -->`

## Definition of Done
- La tâche est ajoutée au fichier de la casquette appropriée.
- La source de la tâche (si elle existe) est archivée ou mise à jour.

## Liens
- [[Process/inbox-scan]]
- [[Casquettes/]]
