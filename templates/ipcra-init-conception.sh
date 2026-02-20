#!/usr/bin/env bash

set -euo pipefail
# IPCRA - Initialisation de la structure de Conception Agile par IA (AIDD/CDE)
# Ce script crée un squelette documentaire optimisé pour la lecture par un agent IA.

IPCRA_ROOT="${IPCRA_ROOT:-$HOME/IPCRA}"
CONCEPTION_DIR="docs/conception"
CONCEPTS_DIR="$CONCEPTION_DIR/concepts"
LOCAL_IPCRA_DIR=".ipcra-project"
LOCAL_NOTES_DIR="$LOCAL_IPCRA_DIR/local-notes"

echo "🚀 Initialisation de l'arborescence Conception Agile Pilotée par l'IA..."

# Chemin des templates
PROMPTS_DIR="$IPCRA_ROOT/.ipcra/prompts"
if [ ! -d "$PROMPTS_DIR" ]; then
  echo "⚠️ Dossier des templates $PROMPTS_DIR introuvable. Installation IPCRA incomplète ?"
  PROMPTS_DIR="$HOME/.ipcra/prompts"
fi

# Création des dossiers
mkdir -p "$CONCEPTS_DIR"
# Méthodo centralisée: pas de duplication complète IPCRA dans chaque repo projet.
mkdir -p "$LOCAL_NOTES_DIR"

# 1. 00_VISION.md
if [ -f "$PROMPTS_DIR/init_00_VISION.md" ]; then
  cp "$PROMPTS_DIR/init_00_VISION.md" "$CONCEPTION_DIR/00_VISION.md"
else
  echo "# Vision et Objectifs du Projet" > "$CONCEPTION_DIR/00_VISION.md"
fi
echo "✅ Créé : $CONCEPTION_DIR/00_VISION.md"

# 2. 01_AI_RULES.md
if [ -f "$PROMPTS_DIR/init_01_AI_RULES.md" ]; then
  cp "$PROMPTS_DIR/init_01_AI_RULES.md" "$CONCEPTION_DIR/01_AI_RULES.md"
else
  echo "# Règles et Contraintes pour l'IA" > "$CONCEPTION_DIR/01_AI_RULES.md"
fi
echo "✅ Créé : $CONCEPTION_DIR/01_AI_RULES.md"

# 3. 02_ARCHITECTURE.md
if [ -f "$PROMPTS_DIR/init_02_ARCHITECTURE.md" ]; then
  cp "$PROMPTS_DIR/init_02_ARCHITECTURE.md" "$CONCEPTION_DIR/02_ARCHITECTURE.md"
else
  echo "# Architecture Technique et Stack" > "$CONCEPTION_DIR/02_ARCHITECTURE.md"
fi
echo "✅ Créé : $CONCEPTION_DIR/02_ARCHITECTURE.md"

# 4. _TEMPLATE_CONCEPT.md
if [ -f "$PROMPTS_DIR/init_TEMPLATE_CONCEPT.md" ]; then
  cp "$PROMPTS_DIR/init_TEMPLATE_CONCEPT.md" "$CONCEPTS_DIR/_TEMPLATE_CONCEPT.md"
else
  echo "# Concept :" > "$CONCEPTS_DIR/_TEMPLATE_CONCEPT.md"
fi
echo "✅ Créé : $CONCEPTS_DIR/_TEMPLATE_CONCEPT.md"

# 5. Liens vers le Cerveau Global + raccourcis ciblés
# On crée un lien symbolique vers l'IPCRA global pour que l'IA puisse lire la mémoire,
# les archives et l'historique même en travaillant dans un repo local.
if [ -d "$IPCRA_ROOT" ]; then
    ln -sfn "$IPCRA_ROOT" ".ipcra-memory"
    echo "✅ Créé : Lien symbolique .ipcra-memory -> \$IPCRA_ROOT"

    [ -d "$IPCRA_ROOT/memory" ] && ln -sfn "../.ipcra-memory/memory" "$LOCAL_IPCRA_DIR/memory-global"
    [ -d "$IPCRA_ROOT/Archives" ] && ln -sfn "../.ipcra-memory/Archives" "$LOCAL_IPCRA_DIR/archives-global"
    [ -d "$IPCRA_ROOT/Journal" ] && ln -sfn "../.ipcra-memory/Journal" "$LOCAL_IPCRA_DIR/journal-global"
fi

# 6. Guide de lecture pour l'IA (priorité local + global)
if [ -f "$PROMPTS_DIR/init_03_CONTEXT_LINKS.md" ]; then
  cp "$PROMPTS_DIR/init_03_CONTEXT_LINKS.md" "$CONCEPTION_DIR/03_IPCRA_CONTEXT_LINKS.md"
else
  echo "# IPCRA Context Links (Local + Global)" > "$CONCEPTION_DIR/03_IPCRA_CONTEXT_LINKS.md"
fi

echo "✅ Créé : $CONCEPTION_DIR/03_IPCRA_CONTEXT_LINKS.md"

if [ -f "$PROMPTS_DIR/init_LOCAL_NOTES_README.md" ]; then
  cp "$PROMPTS_DIR/init_LOCAL_NOTES_README.md" "$LOCAL_NOTES_DIR/README.md"
else
  echo "# Local Notes (Projet)" > "$LOCAL_NOTES_DIR/README.md"
fi

if [ -f "$PROMPTS_DIR/init_STATE.md" ]; then
  cp "$PROMPTS_DIR/init_STATE.md" "$LOCAL_NOTES_DIR/STATE.md"
else
  echo "# Etat du developpement" > "$LOCAL_NOTES_DIR/STATE.md"
fi

echo "✅ Créé : $LOCAL_NOTES_DIR/README.md"

# 7. Création des fichiers de règles universels pour les agents IA
# On utilise les noms de fichiers spécifiques aux agents utilisés par l'utilisateur.
# Antigravity lit .antigravity ou .ai-instructions.md
# Claude regarde .claude.md ou .clinerules
if [ -f "$PROMPTS_DIR/init_AI_INSTRUCTIONS.md" ]; then
  RULES_CONTENT=$(cat "$PROMPTS_DIR/init_AI_INSTRUCTIONS.md")
else
  RULES_CONTENT="# Project-Specific AI Instructions"
fi

CTX="$(cat "$IPCRA_ROOT/.ipcra/context.md" 2>/dev/null || echo "Contexte introuvable.")"
INS="$(cat "$IPCRA_ROOT/.ipcra/instructions.md" 2>/dev/null || echo "Instructions introuvables.")"
RUL="$(cat "$CONCEPTION_DIR/01_AI_RULES.md" 2>/dev/null || echo "Règles introuvables.")"
LNK="$(cat "$CONCEPTION_DIR/03_IPCRA_CONTEXT_LINKS.md" 2>/dev/null || echo "Liens de contexte introuvables.")"

RULES_CONTENT="${RULES_CONTENT//\{\{context\}\}/$CTX}"
RULES_CONTENT="${RULES_CONTENT//\{\{instructions\}\}/$INS}"
RULES_CONTENT="${RULES_CONTENT//\{\{rules\}\}/$RUL}"
RULES_CONTENT="${RULES_CONTENT//\{\{links\}\}/$LNK}"

echo "$RULES_CONTENT" > ".ai-instructions.md" && echo "✅ Créé : .ai-instructions.md"
echo "$RULES_CONTENT" > ".antigravity" && echo "✅ Créé : .antigravity"
echo "$RULES_CONTENT" > ".claude.md" && echo "✅ Créé : .claude.md"
echo "$RULES_CONTENT" > ".openai" && echo "✅ Créé : .openai"
echo "$RULES_CONTENT" > ".clinerules" && echo "✅ Créé : .clinerules"
echo "$RULES_CONTENT" > ".cursorrules" && echo "✅ Créé : .cursorrules"
echo "$RULES_CONTENT" > ".kilocode.md" && echo "✅ Créé : .kilocode.md"

echo "🎉 Squelette documentaire, instructions IA et liens mémoire générés avec succès !"
