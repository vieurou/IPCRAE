# IPCRAE

Script d'installation et de bootstrap IPCRA (installateur + launcher + init conception).

## Position méthodologique (important)

Ce dépôt suit une stratégie **centralisée** :

- `~/IPCRA` (ou `$IPCRA_ROOT`) est la **source de vérité** pour la mémoire durable.
- Un projet local ne doit pas dupliquer toute la hiérarchie IPCRA.
- Le local sert de **contexte court terme** et pointe vers le global via des liens.

## `ipcra-init-conception` (résumé)

Le script généré :

- crée `docs/conception/` (vision, règles IA, architecture, liens contexte),
- crée `.ipcra-memory -> $IPCRA_ROOT`,
- crée `.ipcra-project/local-notes/` (minimal),
- crée des liens vers mémoire/historique globaux dans `.ipcra-project/`.

Cela permet à l'IA de lire à la fois le contexte projet et la mémoire globale **sans duplicer** l'arborescence IPCRA complète.

## Vérification rapide

```bash
bash -n ipcra-install.sh
HOME=$(mktemp -d) bash ipcra-install.sh -y "$(mktemp -d)/vault"
```
