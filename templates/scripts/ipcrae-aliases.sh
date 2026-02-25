#!/bin/bash

# IPCRAE Aliases - Amélioration pour les agents IA
# Pour utiliser : source ce fichier dans votre .bashrc ou .zshrc
# Exemple : echo "source $IPCRAE_ROOT/scripts/ipcrae-aliases.sh" >> ~/.bashrc

# Alias de base
alias ipc='ipcrae'
alias ipcs='ipcrae start'
alias ipcc='ipcrae close'
alias ipca='ipcrae-audit-check'
alias ipct='ipcrae tag'
alias ipci='ipcrae index'
alias ipcsr='ipcrae search'

# Alias avancés (à venir)
# alias ipcb='ipcrae prompt build'
# alias ipcd='ipcrae doctor'

echo "✅ Alias IPCRAE chargés. Utilisez 'ipc' au lieu de 'ipcrae' etc."