#!/bin/bash

# ipcrae-task: Script pour gérer le cycle de vie des tâches dans le système IPCRAE v3.4
# Usage:
# ipcrae-task new "Description de la tâche"
# ipcrae-task list
# ipcrae-task done <task_id>

set -e
set -o pipefail

# Assurer que IPCRAE_ROOT est défini, sinon utiliser le répertoire parent du script
if [ -z "$IPCRAE_ROOT" ]; then
    # Heuristique simple: remonter jusqu'à trouver un dossier .git ou .ipcrae-project
    CURRENT_DIR=$(pwd)
    while [ "$CURRENT_DIR" != "/" ]; do
        if [ -d "$CURRENT_DIR/.git" ] || [ -d "$CURRENT_DIR/.ipcrae-project" ]; then
            IPCRAE_ROOT="$CURRENT_DIR"
            break
        fi
        CURRENT_DIR=$(dirname "$CURRENT_DIR")
    done
    if [ -z "$IPCRAE_ROOT" ]; then
        echo "Erreur: Impossible de déterminer IPCRAE_ROOT. Veuillez le définir." >&2
        exit 1
    fi
fi

TASKS_DIR="$IPCRAE_ROOT/Tasks"
TO_AI_DIR="$TASKS_DIR/to_ai"
TO_USER_DIR="$TASKS_DIR/to_user"
HISTORY_DIR="$TASKS_DIR/history"

# --- Fonctions ---

function task_new() {
    local description="$1"
    if [ -z "$description" ]; then
        echo "Usage: ipcrae-task new \"<description>\"" >&2
        return 1
    }

    local timestamp
    timestamp=$(date +%s)
    local task_id="task-${timestamp}"
    local task_file="$TO_AI_DIR/${task_id}.md"

    cat > "$task_file" << EOF
---
id: ${task_id}
from: user
to: agent
status: pending
created: $(date '+%Y-%m-%d')
---

# Tâche : ${task_id}

${description}
EOF

    echo "Tâche créée : ${task_file}"
}

function task_list() {
    echo "--- Tâches pour l'IA (to_ai) ---"
    if [ -z "$(ls -A "$TO_AI_DIR")" ]; then
        echo "(vide)"
    else
        grep -l "status: pending" "$TO_AI_DIR"/*.md | xargs -r basename -s .md
    fi

    echo ""
    echo "--- Tâches pour l'Utilisateur (to_user) ---"
    if [ -z "$(ls -A "$TO_USER_DIR")" ]; then
        echo "(vide)"
    else
        grep -l "status: pending" "$TO_USER_DIR"/*.md | xargs -r basename -s .md
    fi
}

function task_done() {
    local task_id="$1"
    if [ -z "$task_id" ]; then
        echo "Usage: ipcrae-task done <task_id>" >&2
        return 1
    }

    local task_file
    task_file=$(find "$TO_AI_DIR" "$TO_USER_DIR" -name "${task_id}.md" 2>/dev/null | head -n 1)

    if [ ! -f "$task_file" ]; then
        echo "Erreur: Tâche '${task_id}' introuvable." >&2
        return 1
    }

    # Mettre à jour le statut (utilise sed)
    sed -i 's/status: .*/status: done/' "$task_file"

    local year
    year=$(date '+%Y')
    local month
    month=$(date '+%m')
    local dest_dir="$HISTORY_DIR/$year/$month"
    mkdir -p "$dest_dir"

    mv "$task_file" "$dest_dir/"
    echo "Tâche archivée : ${dest_dir}/${task_id}.md"
}


# --- Main ---

SUBCOMMAND="$1"
shift || true

case "$SUBCOMMAND" in
    new)
        task_new "$@"
        ;;
    list)
        task_list
        ;;
    done)
        task_done "$@"
        ;;
    *)
        echo "Usage: ipcrae-task [new|list|done] [arguments...]" >&2
        exit 1
        ;;
esac
