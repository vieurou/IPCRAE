#!/usr/bin/env bash

set -euo pipefail
# IPCRAE - Initialisation de la structure de Conception Agile par IA (AIDD/CDE)
# Ce script crée un squelette documentaire optimisé pour la lecture par un agent IA.

IPCRAE_ROOT="${IPCRAE_ROOT:-$HOME/IPCRAE}"
CONCEPTION_DIR="docs/conception"
CONCEPTS_DIR="$CONCEPTION_DIR/concepts"
LOCAL_IPCRAE_DIR=".ipcrae-project"
LOCAL_NOTES_DIR="$LOCAL_IPCRAE_DIR/local-notes"

echo "🚀 Initialisation de l'arborescence Conception Agile Pilotée par l'IA..."

# Création des dossiers
mkdir -p "$CONCEPTS_DIR"
# Méthodo centralisée: pas de duplication complète IPCRAE dans chaque repo projet.
mkdir -p "$LOCAL_NOTES_DIR"
mkdir -p "$LOCAL_IPCRAE_DIR/memory" # Mémoire spécifique au projet

# Méta-données du projet
PROJECT_NAME="$(basename "$PWD")"
DATE_CREATION="$(date +%Y-%m-%d)"

# Création du .gitignore pour éviter de commiter les notes et liens mémoire
cat << EOF > "$LOCAL_IPCRAE_DIR/.gitignore"
# IPCRAE local notes and global memory links
local-notes/
memory/
memory-global
archives-global
journal-global
project.md
EOF
echo "✅ Créé : $LOCAL_IPCRAE_DIR/.gitignore"

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
cat << 'EOF' > "$CONCEPTION_DIR/03_IPCRAE_BRIDGE.md"
# IPCRAE Bridge — Contrat CDE explicite

## Ce que l'IA lit/écrit dans `.ipcrae-memory/`
- Lire: `.ipcrae/context.md`, `.ipcrae/instructions.md`, `memory/<domaine>.md`, `Projets/<projet>/`.
- Écrire: uniquement les apprentissages réutilisables et stables (multi-projets), jamais les brouillons/debug.

## Ce que l'IA écrit dans `.ipcrae-project/local-notes/`
- Notes volatiles: todo techniques, logs de debug, hypothèses temporaires.
- Ce contenu n'est pas une source de vérité durable.

## Ce qui est exporté vers `~/IPCRAE/Projets/<projet>/`
- `index.md`: état global, liens, contexte de pilotage.
- `tracking.md`: next actions et milestones.
- `memory.md`: synthèse projet consolidée.

## Ce qui est transformé en `Knowledge/` (stable)
- How-to/runbook/pattern réutilisable, taggé avec frontmatter YAML.
- Minimum attendu:

```yaml
---
type: knowledge
tags: [devops, exemple]
project: $(basename "$PWD")
domain: devops
status: stable
sources:
  - path: docs/conception/02_ARCHITECTURE.md
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

## Règle d'or
- Build/test ne dépendent jamais du cerveau global.
- IA/conception/doctor CDE: mode normal si cerveau présent, mode dégradé sinon.
EOF

echo "✅ Créé : $CONCEPTION_DIR/03_IPCRAE_BRIDGE.md"

# 6. Création des fichiers de règles universels pour les agents IA
# ⚠ Stratégie: ne PAS dupliquer le cerveau global dans chaque repo.
# On écrit un "prompt routeur" court qui pointe vers les sources de vérité.
# Option debug: si IPCRAE_EMBED_PROMPTS=true, on ajoute un snapshot inline.
RULES_CONTENT=$(cat << EOF
# Project-Specific AI Instructions

## Routage de contexte (source de vérité)
Lis les fichiers ci-dessous directement (ne pas supposer de copie locale à jour):
1) docs/conception/00_VISION.md
2) docs/conception/01_AI_RULES.md
3) docs/conception/02_ARCHITECTURE.md
4) docs/conception/03_IPCRAE_BRIDGE.md
5) .ipcrae-project/local-notes/ (contexte temporaire)
6) .ipcrae-project/memory/ (décisions propres au repo)
7) .ipcrae-memory/.ipcrae/context.md (méthodo globale)
8) .ipcrae-memory/.ipcrae/instructions.md (règles globales)
9) .ipcrae-memory/memory/ (connaissance durable multi-projets)

## Règles de mémoire
- Réutilisable multi-projets => écrire dans .ipcrae-memory/memory/
- Spécifique à CE repo => écrire dans .ipcrae-project/memory/
- Volatile (todo/debug) => écrire dans .ipcrae-project/local-notes/

## Anti-bloat
Ne pas relire tout le cerveau global à chaque requête.
Charger d'abord le contexte local/projet, puis ouvrir le global seulement si besoin structurant.
EOF
)

if [ "${IPCRAE_EMBED_PROMPTS:-false}" = "true" ]; then
  RULES_CONTENT+="\n\n---\n# Snapshot debug (peut devenir obsolète)\n"
  RULES_CONTENT+="$(cat "$IPCRAE_ROOT/.ipcrae/context.md" 2>/dev/null || echo "Contexte global introuvable.")"
  RULES_CONTENT+="\n---\n"
  RULES_CONTENT+="$(cat "$IPCRAE_ROOT/.ipcrae/instructions.md" 2>/dev/null || echo "Instructions globales introuvables.")"
fi

echo "$RULES_CONTENT" > ".ai-instructions.md" && echo "✅ Créé : .ai-instructions.md"

# 7. Liens vers le Cerveau Global + raccourcis ciblés
# On crée un lien symbolique vers l'IPCRAE global pour que l'IA puisse lire la mémoire,
# les archives et l'historique même en travaillant dans un repo local.
if [ -d "$IPCRAE_ROOT" ]; then
    ln -sfn "$IPCRAE_ROOT" ".ipcrae-memory"
    echo "✅ Créé : Lien symbolique .ipcrae-memory -> \$IPCRAE_ROOT"

    [ -d "$IPCRAE_ROOT/memory" ] && ln -sfn "../.ipcrae-memory/memory" "$LOCAL_IPCRAE_DIR/memory-global"
    [ -d "$IPCRAE_ROOT/Archives" ] && ln -sfn "../.ipcrae-memory/Archives" "$LOCAL_IPCRAE_DIR/archives-global"
    [ -d "$IPCRAE_ROOT/Journal" ] && ln -sfn "../.ipcrae-memory/Journal" "$LOCAL_IPCRAE_DIR/journal-global"
fi

cat << 'EOF' > "$LOCAL_NOTES_DIR/README.md"
# Local Notes (Projet)

Ce dossier est volontairement **minimal** pour éviter de dupliquer la hiérarchie IPCRAE globale.

## Usage
- Mettre ici le contexte de travail court terme lié au repo courant.
- Conserver la connaissance de domaine (réutilisable) dans `.ipcrae-memory/memory/`.
- Conserver la connaissance stricte au projet (stack, hardware, choix) dans `.ipcrae-project/memory/`.

## Fichiers suggérés
- `todo.md`
- `decisions-locales.md`
- `debug-log.md`
EOF

echo "✅ Créé : $LOCAL_NOTES_DIR/README.md"

# 8. Création du Manifeste Projet
cat << EOF > "$LOCAL_IPCRAE_DIR/project.md"
# Project Manifest: ${PROJECT_NAME}

- **Domaine** : [À Remplir]
- **Créé le** : ${DATE_CREATION}
- **Chemin** : ${PWD}
- **Mémoire Locale** : .ipcrae-project/memory/
EOF
echo "✅ Créé : $LOCAL_IPCRAE_DIR/project.md"

# 9. Création du Project Central Hub
HUB_DIR="$IPCRAE_ROOT/Projets/$PROJECT_NAME"
mkdir -p "$HUB_DIR"

if [ ! -f "$HUB_DIR/index.md" ]; then
    cat << EOF > "$HUB_DIR/index.md"
# ${PROJECT_NAME}
Status: Active | Next: [Définir la prochaine action GTD] | Phase: [Lier la phase actuelle]

## Overview
- **Domaine** : [À Remplir]
- **Chemin Local** : \`${PWD}\`
- **Mémoire Locale** : \`.ipcrae-project/memory/\`

## Liens
- [[Casquettes/]] (Rôles impliqués)
- [[Objectifs/]] (Objectifs liés)
EOF
    echo "✅ Créé : $HUB_DIR/index.md"
fi

if [ ! -f "$HUB_DIR/tracking.md" ]; then
    cat << EOF > "$HUB_DIR/tracking.md"
# GTD Tracking - ${PROJECT_NAME}

## Next Actions
- [ ] 

## Milestones
- [ ] 
EOF
    echo "✅ Créé : $HUB_DIR/tracking.md"
fi

if [ ! -f "$HUB_DIR/memory.md" ]; then
    cat << EOF > "$HUB_DIR/memory.md"
# Memory - ${PROJECT_NAME}

- Log des réunions, des décisions globales et de la synthèse IA.
- TODO: Injecter ici les spécifications hybrides lors de la consolidation.
EOF
    echo "✅ Créé : $HUB_DIR/memory.md"
fi

# 10. Enregistrement dans le Registre Global
REGISTRY_FILE="$IPCRAE_ROOT/Projets/index.md"
if [ ! -f "$REGISTRY_FILE" ]; then
    mkdir -p "$IPCRAE_ROOT/Projets"
    echo "# Registre des Projets IPCRAE" > "$REGISTRY_FILE"
    echo "" >> "$REGISTRY_FILE"
    echo "| Nom | Chemin | Créé le |" >> "$REGISTRY_FILE"
    echo "|---|---|---|" >> "$REGISTRY_FILE"
fi

if ! grep -q "$PWD" "$REGISTRY_FILE"; then
    echo "| **[[${PROJECT_NAME}]]** | \`${PWD}\` | ${DATE_CREATION} |" >> "$REGISTRY_FILE"
    echo "✅ Projet enregistré dans le Registre Global : $REGISTRY_FILE"
else
    echo "ℹ️  Le projet est déjà enregistré dans le Registre Global."
fi

echo "🎉 Projet intégré à IPCRAE avec succès !"

# 11. Analyse initiale par l'IA (Auto-ingestion)
echo ""
read -r -p "🤖 Veux-tu lancer l'agent IA maintenant pour analyser le code et auto-remplir les templates ? [O/n] " run_ai
run_ai=${run_ai:-o}

if [[ "$run_ai" =~ ^[Oo]$ ]]; then
    echo "Lancement de l'analyse initiale..."
    if command -v ipcrae &> /dev/null; then
        ipcrae work "Ceci est le premier scan d'ingestion de ce projet. 1. Analyse le code source présent dans ce répertoire pour comprendre son rôle et son architecture. 2. Édite les fichiers docs/conception/00_VISION.md et docs/conception/02_ARCHITECTURE.md pour remplacer les placeholders [À Remplir] par tes déductions. 3. Édite le fichier $HUB_DIR/index.md pour remplir le Domaine et la description. Fais un travail concis et termine en faisant un résumé."
    else
        echo "⚠️  Commande 'ipcrae' introuvable. Assure-toi qu'elle est dans le PATH."
    fi
fi
