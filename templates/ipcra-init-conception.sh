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

# Création des dossiers
mkdir -p "$CONCEPTS_DIR"
# Méthodo centralisée: pas de duplication complète IPCRA dans chaque repo projet.
mkdir -p "$LOCAL_NOTES_DIR"

# 1. 00_VISION.md
cat << 'EOF' > "$CONCEPTION_DIR/00_VISION.md"
# Vision et Objectifs du Projet

**Dernière mise à jour** : YYYY-MM-DD
**Statut global** : 🟡 En Spec | 🔵 En Developpement | 🟢 En Production

## 1. Pitch du Projet
[Insérer ici une description en 2-3 phrases de ce que fait le projet et à qui il s'adresse.]

## 2. Objectifs Business / Métier
- **Objectif 1** : [Ex: Réduire le temps de traitement de 50%]
- **Objectif 2** : [Ex: Fournir une interface sans friction et mobile-first]
- **Objectif 3** : ...

## 3. Personas / Utilisateurs cibles
- **[Nom du persona]** : [Courte description de son besoin et contexte d'usage]

## 4. Ce que le projet N'EST PAS (Anti-objectifs)
- [Ex: Ce n'est pas un système multi-tenant Saas complexe, c'est pour un usage solo]

EOF
echo "✅ Créé : $CONCEPTION_DIR/00_VISION.md"

# 2. 01_AI_RULES.md (Règles spécifiques projet)
cat << 'EOF' > "$CONCEPTION_DIR/01_AI_RULES.md"
# Règles de l'IA pour ce Projet

## 1. Stack Technique & Conventions
- **Langages** : [Ex: TypeScript]
- **Frameworks** : [Ex: React, SvelteKit]
- **Tests** : [Ex: Vitest, Playwright]
- **Style** : [Ex: Pas de semicolon, 2 espaces]

## 2. Librairies Interdites / Autorisées
- **Interdit** : [Ex: axios (utiliser fetch), lodash (utiliser méthodes ES6 native)]
- **Autorisé** : [Ex: zod pour la validation]

## 3. Workflow de Validation
Tout code produit doit être validé via `npm test` avant d'être considéré comme terminé ou suggéré.

EOF
echo "✅ Créé : $CONCEPTION_DIR/01_AI_RULES.md"

# 3. 02_ARCHITECTURE.md
cat << 'EOF' > "$CONCEPTION_DIR/02_ARCHITECTURE.md"
# Architecture et Décisions Techniques

## 1. Structure Globale
[Décrire brièvement l'organisation des dossiers et le flux de données]

## 2. Décisions de Conception (ADR)
- **ADR-001** : Utilisation de SQLite pour le stockage local (simplicité vs PostgreSQL).
- **ADR-002** : ...

## 3. Schéma de Données / API
[Insérer ici un schéma Mermaid ou une description des endpoints clés]

EOF
echo "✅ Créé : $CONCEPTION_DIR/02_ARCHITECTURE.md"

# 4. _TEMPLATE_CONCEPT.md
cat << 'EOF' > "$CONCEPTS_DIR/_TEMPLATE_CONCEPT.md"
# [Nom du Concept / Fonctionnalité]

**Dernière mise à jour** : YYYY-MM-DD
**Statut** : 🔴 À définir | 🟡 En cours | 🟢 Validé | 📦 Implémenté

## 1. Problème et Contexte
[Pourquoi avons-nous besoin de cela ? Quel problème résolvons-nous ?]

## 2. Solution et Parcours Utilisateur
- **Étape 1** : ...
- **Étape 2** : ...

> **Note IA** :
> L'agent IA ne doit coder QUE la section `V1 (Requis)`. Les sections `V2+` et `Réflexions` sont pour archivage et prévision.

## 3. Moyens Techniques et Logique Métier
- **Choix technique spécifique** : [Ex: Utilisation de JsonWebToken, validité 24h]
- **Base de données impactée** : [Ex: Table Users (id, email, password_hash)]
- **Algorithme / Logique** :
  1. Le user soumet le form.
  2. L'API vérifie le hash (argon2).
  3. Retourne token dans une res HTTPOnly Cookie.

## 4. Spécifications du Code (Prompt IA)
*Directives directes que l'IA exécutante doit accomplir pour terminer ce concept.*
- **Fichiers impactés** :
  - `src/api/auth.js` -> Implémenter POST /login
  - `src/ui/login.html` -> Créer le formulaire
- **Interfaces / Mockups** :
  ```javascript
  // L'interface attendue :
  interface AuthResponse {
     token: string;
     user: { id: number, email: string }
  }
  ```

EOF
echo "✅ Créé : $CONCEPTS_DIR/_TEMPLATE_CONCEPT.md"

# 5. Guide de lecture pour l'IA (priorité local + global)
cat << 'EOF' > "$CONCEPTION_DIR/03_IPCRA_CONTEXT_LINKS.md"
# IPCRA Context Links (Local + Global)

## Priorité de lecture recommandée
1. Contexte local projet : `docs/conception/00_VISION.md`, `01_AI_RULES.md`, `02_ARCHITECTURE.md`
2. Notes projet locales : `.ipcra-project/local-notes/` (contexte temporaire de ce repo)
3. Mémoire globale : `.ipcra-memory/memory/` (source de vérité durable)
4. Historique global : `.ipcra-memory/Archives/` et `.ipcra-memory/Journal/`

## Règle d'or
- Le global (`.ipcra-memory/*`) reste la source de vérité durable.
- Le local (`.ipcra-project/local-notes/`) sert au contexte court terme du projet.
- Après consolidation, remonter les décisions durables vers la mémoire globale.

## Cadence recommandée
- Fin de session: trier `local-notes/`.
- Fin de feature: promouvoir les décisions durables vers `.ipcra-memory/memory/`.
- Revue hebdo: archiver le bruit, conserver les apprentissages réutilisables.
EOF

echo "✅ Créé : $CONCEPTION_DIR/03_IPCRA_CONTEXT_LINKS.md"

# 6. Création des fichiers de règles universels pour les agents IA
# On utilise les noms de fichiers spécifiques aux agents utilisés par l'utilisateur.
# Antigravity lit .antigravity ou .ai-instructions.md
# Claude regarde .claude.md ou .clinerules
RULES_CONTENT=$(cat << EOF
# Project-Specific AI Instructions

## Ordre de lecture obligatoire pour l'agent
1) docs/conception/00_VISION.md
2) docs/conception/01_AI_RULES.md
3) docs/conception/02_ARCHITECTURE.md
4) .ipcra-project/local-notes/ (notes locales projet)
5) .ipcra-memory/memory/ (mémoire globale, source de vérité)
6) .ipcra-memory/Archives/ + .ipcra-memory/Journal/ (historique global)

$(cat "$IPCRA_ROOT/.ipcra/context.md" 2>/dev/null || echo "Contexte introuvable.")
---
$(cat "$IPCRA_ROOT/.ipcra/instructions.md" 2>/dev/null || echo "Instructions introuvables.")
---
$(cat "$CONCEPTION_DIR/01_AI_RULES.md" 2>/dev/null || echo "Règles introuvables.")
---
$(cat "$CONCEPTION_DIR/03_IPCRA_CONTEXT_LINKS.md" 2>/dev/null || echo "Liens de contexte introuvables.")
EOF
)

echo "$RULES_CONTENT" > ".ai-instructions.md" && echo "✅ Créé : .ai-instructions.md"
echo "$RULES_CONTENT" > ".antigravity" && echo "✅ Créé : .antigravity"
echo "$RULES_CONTENT" > ".claude.md" && echo "✅ Créé : .claude.md"
echo "$RULES_CONTENT" > ".openai" && echo "✅ Créé : .openai"
echo "$RULES_CONTENT" > ".kilocode.md" && echo "✅ Créé : .kilocode.md"
echo "$RULES_CONTENT" > ".clinerules" && echo "✅ Créé : .clinerules"

# 7. Liens vers le Cerveau Global + raccourcis ciblés
# On crée un lien symbolique vers l'IPCRA global pour que l'IA puisse lire la mémoire,
# les archives et l'historique même en travaillant dans un repo local.
if [ -d "$IPCRA_ROOT" ]; then
    ln -sfn "$IPCRA_ROOT" ".ipcra-memory"
    echo "✅ Créé : Lien symbolique .ipcra-memory -> \$IPCRA_ROOT"

    [ -d "$IPCRA_ROOT/memory" ] && ln -sfn "../.ipcra-memory/memory" "$LOCAL_IPCRA_DIR/memory-global"
    [ -d "$IPCRA_ROOT/Archives" ] && ln -sfn "../.ipcra-memory/Archives" "$LOCAL_IPCRA_DIR/archives-global"
    [ -d "$IPCRA_ROOT/Journal" ] && ln -sfn "../.ipcra-memory/Journal" "$LOCAL_IPCRA_DIR/journal-global"
fi

cat << 'EOF' > "$LOCAL_NOTES_DIR/README.md"
# Local Notes (Projet)

Ce dossier est volontairement **minimal** pour éviter de dupliquer la hiérarchie IPCRA globale.

## Usage
- Mettre ici le contexte de travail court terme lié au repo courant.
- Conserver la connaissance durable dans `.ipcra-memory/memory/` (source de vérité).

## Fichiers suggérés
- `todo.md`
- `decisions-locales.md`
- `debug-log.md`
EOF

echo "✅ Créé : $LOCAL_NOTES_DIR/README.md"

echo "🎉 Squelette documentaire, instructions IA et liens mémoire générés avec succès !"
