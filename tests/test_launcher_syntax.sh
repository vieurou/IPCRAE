#!/usr/bin/env bash
set -euo pipefail

bash -n templates/ipcrae-launcher.sh
bash -n ipcrae-install.sh

# Vérifie aussi les scripts principaux livrés
for script in scripts/*.sh; do
  bash -n "$script"
done

echo "OK: syntaxe bash valide"
