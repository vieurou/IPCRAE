#!/bin/bash

# IPCRA - Initialisation de la structure de Conception Agile par IA (AIDD/CDE)
# Ce script crée un squelette documentaire optimisé pour la lecture par un agent IA.

CONCEPTION_DIR="docs/conception"
CONCEPTS_DIR="$CONCEPTION_DIR/concepts"

echo "🚀 Initialisation de l'arborescence Conception Agile Pilotée par l'IA..."

# Création des dossiers
mkdir -p "$CONCEPTS_DIR"

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

# 2. 01_AI_RULES.md
cat << 'EOF' > "$CONCEPTION_DIR/01_AI_RULES.md"
# Règles et Contraintes pour l'IA (AI Rules)

!!! ATTENTION AGENT IA !!!
Ce document contient des directives absolues. Vous devez les respecter sans exception pour ne pas diverger des attentes architecturales.

## 1. Règles de Codage & Langage
- **Langage / Version** : [Ex: Python 3.12, ou TypeScript 5.0]
- **Style guide** : [Ex: PEP8, ESLint Standard, ou "Pas de commentaires superflus si le code est explicite"]
- **Gestion des erreurs** : [Ex: Ne jamais ignorer les exceptions silencieusement, toujours utiliser notre logger interne]

## 2. Exclusions (Ce qu'il ne faut JAMAIS utiliser)
- ❌ **Bibliothèques interdites** : [Ex: Lodash (préférer vanilla JS), ou Tailwind CSS (préférer Vanilla CSS)]
- ❌ **Patterns à proscrire** : [Ex: Variables globales, classes massives]

## 3. Processus de Validation
- Avant de proposer un nouveau fichier, vérifiez qu'il respecte l'arborescence définie dans `02_ARCHITECTURE.md`.
- Assurez-vous d'écrire ou mettre à jour un test unitaire pour chaque nouvelle fonction de logique métier.

EOF
echo "✅ Créé : $CONCEPTION_DIR/01_AI_RULES.md"

# 3. 02_ARCHITECTURE.md
cat << 'EOF' > "$CONCEPTION_DIR/02_ARCHITECTURE.md"
# Architecture Technique et Stack

## 1. Stack Technique Retenue
- **Frontend** : [Ex: Vanilla HTML/JS/CSS, React, Vue...]
- **Backend** : [Ex: Node.js, FastAPI...]
- **Base de Données** : [Ex: SQLite pour la simplicité, ou PostgreSQL]
- **Outils de Build / DevOps** : [Ex: Vite, Docker, GitHub Actions]

## 2. Arborescence Cible (A respecter par l'IA)
```text
/src/
  /components/     # UI
  /services/       # Logique métier et appels API
  /assets/
```

## 3. Décisions Architecturales Majeures (ADR)
| Date | Décision | Justification |
|------|----------|---------------|
| YYYY-MM-DD | Choix de SQLite | Pas besoin de scalabilité horizontale pour l'instant, simplifie le déploiement |

EOF
echo "✅ Créé : $CONCEPTION_DIR/02_ARCHITECTURE.md"

# 4. _TEMPLATE_CONCEPT.md
cat << 'EOF' > "$CONCEPTS_DIR/_TEMPLATE_CONCEPT.md"
# Concept : [Nom du Concept - Ex: Authentication]

**Statut** : 🟡 En Réflexion | 🔵 Prêt pour Dev | 🟢 Terminé
**Date** : YYYY-MM-DD
**Dépend de** : [Liens éventuels, ex: 00_base_de_donnees.md]

## 1. User Story et Intentions
*En tant que [rôle], je veux [action] afin de [bénéfice/but].*
- **Description** : [Explication claire du besoin sans technique]

## 2. Périmètre (V1 vs Future)
L'agent IA ne doit coder QUE la section `V1 (Requis)`. Les sections `V2+` et `Rejeté` sont listées pour éviter à l'IA de faire de mauvaises suggestions futures.

- [x] **V1 (Requis)** : [Ex: Connexion par email/mot de passe]
- [ ] **Prochaine Version (V2+)** : [Ex: Social Login Google/Github]
- [x] **Rejeté** : [Ex: 2FA par SMS, trop complexe et couteux, écarté définitivement]

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

# 5. Création des fichiers de règles universels pour les agents IA
# On utilise les noms de fichiers spécifiques aux agents utilisés par l'utilisateur.
# Antigravity lit .antigravity ou .ai-instructions.md
# Claude regarde .claude.md ou .clinerules
RULES_CONTENT=$(cat << 'EOF'
# Project-Specific AI Instructions (AIDD Protocol)

You are working on a project using the Context Driven Engineering (CDE) framework. 
Before writing any code or proposing architecture, you MUST read:
1. docs/conception/01_AI_RULES.md (Technical absolute constraints)
2. docs/conception/00_VISION.md (Project goals and personas)
3. docs/conception/02_ARCHITECTURE.md (Standard stack and folder structure)

When implementing a feature, refer to the specific concept in docs/conception/concepts/*.md:
- Code ONLY the elements marked as 'V1 (Requis)'.
- DO NOT implement 'V2+' or 'Rejeté' elements.
- Ensure your code aligns with the global vision and technical imperatives.
EOF
)

echo "$RULES_CONTENT" > ".ai-instructions.md" && echo "✅ Créé : .ai-instructions.md"
echo "$RULES_CONTENT" > ".antigravity" && echo "✅ Créé : .antigravity"
echo "$RULES_CONTENT" > ".claude.md" && echo "✅ Créé : .claude.md"
echo "$RULES_CONTENT" > ".openai" && echo "✅ Créé : .openai"
echo "$RULES_CONTENT" > ".kilocode.md" && echo "✅ Créé : .kilocode.md"
echo "$RULES_CONTENT" > ".clinerules" && echo "✅ Créé : .clinerules"

# 6. Création du lien vers le Cerveau Global (Bouton d'or)
# On crée un lien symbolique vers ~/IPCRA pour que l'IA puisse "voir" la mémoire globale 
# même si elle est limitée au dossier du projet.
if [ -d "/home/eric/IPCRA" ]; then
    ln -sfn "/home/eric/IPCRA" ".ipcra-memory"
    echo "✅ Créé : Lien symbolique .ipcra-memory -> ~/IPCRA"
fi

echo "🎉 Squelette documentaire, instructions IA et lien mémoire générés avec succès !"
