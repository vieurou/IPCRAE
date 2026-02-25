#!/bin/bash
# scripts/ipcrae-update-readme.sh
# Script de mise à jour automatique du README.md

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction d'aide
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Affiche cette aide"
    echo "  -d, --dry-run  Simulation sans modification"
    echo "  -v, --verbose  Mode verbeux"
    echo ""
    echo "Description:"
    echo "  Met à jour le README.md avec la liste des scripts disponibles"
    echo "  et la documentation du système IPCRAE."
    exit 0
}

# Fonction de logging
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        INFO)
            echo -e "${GREEN}[INFO]${NC} $timestamp - $message"
            ;;
        WARN)
            echo -e "${YELLOW}[WARN]${NC} $timestamp - $message"
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} $timestamp - $message"
            ;;
        *)
            echo "[$level] $timestamp - $message"
            ;;
    esac
}

# Variables
DRY_RUN=false
VERBOSE=false

# Parsing des arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            log ERROR "Option inconnue: $1"
            usage
            ;;
    esac
done

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "README.md" ]; then
    log ERROR "README.md non trouvé dans le répertoire courant"
    exit 1
fi

# Vérifier le répertoire scripts
if [ ! -d "scripts" ]; then
    log ERROR "Répertoire scripts/ non trouvé"
    exit 1
fi

# Récupérer la version IPCRAE
VERSION=$(grep "script_version:" .ipcrae/config.yaml | cut -d'"' -f2)
if [ -z "$VERSION" ]; then
    VERSION="3.3.0"
fi

log INFO "Version IPCRAE: $VERSION"
log INFO "Mise à jour du README.md..."

# Si dry-run, afficher ce qui serait fait
if [ "$DRY_RUN" = true ]; then
    log INFO "Mode simulation (dry-run)"
    log INFO "Les modifications suivantes seraient appliquées :"
    log INFO "  - Mise à jour de la version à $VERSION"
    log INFO "  - Mise à jour de la liste des scripts CLI"
    log INFO "  - Mise à jour de la liste des scripts utilitaires"
    log INFO "  - Mise à jour de la section Schémas YAML"
    exit 0
fi

# Créer une sauvegarde
BACKUP_FILE="README.md.backup.$(date +%Y%m%d_%H%M%S)"
cp README.md "$BACKUP_FILE"
log INFO "Sauvegarde créée: $BACKUP_FILE"

# Extraire la liste des scripts CLI
CLI_SCRIPTS=$(find scripts -name "ipcrae-*.sh" -type f -executable | sort)
CLI_SCRIPTS_COUNT=$(echo "$CLI_SCRIPTS" | wc -l | tr -d ' \t')

# Extraire la liste des scripts utilitaires
UTIL_SCRIPTS=$(find scripts -name "*.sh" -type f -executable | grep -v "ipcrae-" | sort)
UTIL_SCRIPTS_COUNT=$(echo "$UTIL_SCRIPTS" | wc -l | tr -d ' \t')

# Extraire la liste des schémas YAML
SCHEMA_FILES=$(find .ipcrae/schema -name "*.yaml" -type f | sort)
SCHEMA_FILES_COUNT=$(echo "$SCHEMA_FILES" | wc -l | tr -d ' \t')

log VERBOSE "Scripts CLI trouvés: $CLI_SCRIPTS_COUNT"
log VERBOSE "Scripts utilitaires trouvés: $UTIL_SCRIPTS_COUNT"
log VERBOSE "Schémas YAML trouvés: $SCHEMA_FILES_COUNT"

# Créer le contenu README.md
cat > README.md << 'EOF'
# 🧠 IPCRAE v3.3 — Système de Gestion de Vie et de Travail

> **IPCRAE** = **I**ntelligent **P**ersonal **C**ontext **R**ecovery **A**nd **E**nvironment
> 
> Système de gestion de vie et de travail 100% local, CLI-first, multi-agent IA (Claude/Gemini/Codex/Kilo). Vault Markdown versionné (Git) + scripts shell d'automatisation + protocole de mémoire IA par domaine. Objectif : éliminer le bruit des sessions IA et rendre le contexte de travail reproductible sans dépendance à la mémoire interne des chats.

## 🎯 Objectif Principal

La mémoire des chats est bruitée → la vérité est dans des fichiers locaux versionnables. L'IA travaille sur un contexte structuré, mis à jour par les cycles daily/weekly/close. La recherche de connaissance est **tag-first** (index + frontmatter), pas arborescence-first.

## 🏗️ Structure IPCRAE v3.3

| Dossier | Rôle |
|---------|------|
| `Inbox/` | Capture brute (idées, tâches, liens) |
| `Projets/` | Hubs centraux projet |
| `Casquettes/` | Responsabilités continues |
| `Ressources/` | Documentation brute par domaine |
| `Zettelkasten/` | Notes atomiques permanentes |
| `Knowledge/` | Connaissances réutilisables (howto/runbooks/patterns) |
| `Archives/` | Terminé |
| `Journal/` | Daily / Weekly / Monthly |
| `Phases/` | Phases de vie actives |
| `Process/` | Procédures récurrentes |
| `Objectifs/` | Vision et Someday/Maybe |
| `memory/` | Mémoire IA par domaine |
| `Agents/` | Rôles IA spécialisés |

## 🚀 Installation

\`\`\`bash
# Cloner le vault
git clone https://github.com/vieurou/brain.git ~/IPCRAE
cd ~/IPCRAE

# Exécuter l'installateur
bash ipcrae-install.sh

# Relancer le shell pour charger les variables d'environnement
source ~/.bashrc  # ou ~/.zshrc
\`\`\`

## 📋 Commandes CLI Principales

### Commandes quotidiennes
\`\`\`bash
ipcrae               # Menu interactif
ipcrae daily         # Daily note
ipcrae daily --prep  # Daily pré-rédigée par l'IA
ipcrae weekly        # Weekly ISO
ipcrae monthly       # Revue mensuelle
\`\`\`

### Commandes de session
\`\`\`bash
ipcrae start --project <slug> --phase <phase>  # Initialise le contexte
ipcrae work "objectif"                         # Lance agent avec contexte minimisé
ipcrae close <domaine> --project <slug>        # Consolidation dynamique
\`\`\`

### Commandes de gestion
\`\`\`bash
ipcrae sync          # Régénère CLAUDE.md, GEMINI.md, AGENTS.md, Kilo
ipcrae index         # Reconstruit le cache tags (.ipcrae/cache/tag-index.json)
ipcrae tag devops    # Liste les notes taggées
ipcrae health        # Diagnostic système
ipcrae DevOps        # Mode expert
ipcrae -p gemini     # Choisir le provider
\`\`\`

### Commandes Zettelkasten
\`\`\`bash
ipcrae zettel "titre"  # Créer note atomique Zettelkasten
ipcrae moc "thème"    # Créer/ouvrir Map of Content
\`\`\`

### Commandes avancées (nouvelles en v3.3)
\`\`\`bash
ipcrae allcontext "texte"  # Pipeline analyse/ingestion universal (Mode AllContext)
ipcrae inbox scan          # Scan automatique de l'Inbox (bash pur, < 1s)
\`\`\`

## 🔄 Cycles de Revue

| Cycle | Quand | Durée | Commande |
|-------|-------|-------|----------|
| Daily | Chaque matin | 5 min | \`ipcrae daily\` |
| Weekly | Dimanche | 30 min | \`ipcrae weekly\` |
| Monthly | 1er du mois | 1h | \`ipcrae monthly\` |
| Start | Début de session IA | 2 min | \`ipcrae start --project <slug> --phase <phase>\` |
| Work | Exécution focalisée | variable | \`ipcrae work "<objectif>"\` |
| Close | Fin de session IA | 5 min | \`ipcrae close <domaine> --project <slug>\` |

## 🧩 Méthodologie GTD Adaptée

### Workflow quotidien
\`\`\`
Capturer (Inbox) → Clarifier (actionnable?) → Organiser (Projet/Casquette/Ressources/Someday)
                                             → Réfléchir (Daily/Weekly/Monthly)
                                             → Agir (Next Actions)
\`\`\`

### Protocole Inbox
\`\`\`
Item → Actionnable ?
├─ Non → Ressources, Someday/Maybe, ou Supprimer
└─ Oui → < 2 min ?
     ├─ Oui → Faire immédiatement
     └─ Non → Projet (multi-étapes) ou Next Action → Casquette
              Délégable ? → Inbox/waiting-for.md
\`\`\`

### Priorités
\`\`\`
🔴 Urgent + Important   → FAIRE maintenant
🟠 Important             → PLANIFIER (phase/projet)
🟡 Urgent seul           → DÉLÉGUER ou quick-win
⚪ Ni l'un ni l'autre   → Someday/Maybe ou supprimer
\`\`\`

## 📊 Projets en Cours

- **IPCRAE** (\`/home/eric/DEV/IPCRAE\`) — outillage du système IPCRAE lui-même (scripts CLI, installateur, templates, prompts) | domaine: devops | hub: \`Projets/IPCRAE/\`
- **megadockerapi** (\`/home/eric/DEV/megadockerapi\`) — API SaaS santé Santelys (Node.js/Sequelize, PostgreSQL+PostGIS, Keycloak, Traefik, Docker) | domaine: devops | hub: \`Projets/megadockerapi/\`
- **EscapeCode** (\`/home/eric/DEV/EscapeCode\`) — Plateforme IoT SaaS multi-tenant (MQTT/Mosquitto, Node-RED, Redis, Docker) — POC validé | domaine: devops | hub: \`Projets/EscapeCode/\`
- **Ultimate Sound Workstation** (\`/home/eric/DEV/Ultimate Sound Workstation\`) — Synthétiseur modulaire (Teensy 4.1 master + modules ESP32/Pico, C++/PlatformIO, KiCad) | domaine: electronique | hub: \`Projets/Ultimate Sound Workstation/\`
- **PSS-290 MaxDaisyedMultiESP** — Hack Yamaha PSS-290 : Daisy Seed STM32H7 + ESP32 multi-slots, polyphonie 16 voix, FX stéréo, app web MIDI WiFi, circuit bending intégré (<100€) | domaine: electronique/musique | hub: \`Projets/PSS-290 MaxDaisyedMultiESP/\`

## 🎓 Documentation

- **Dashboard** : \`index.md\` — Navigation rapide
- **Processus** : \`Process/index.md\` — Procédures récurrentes
- **Objectifs** : \`Objectifs/vision.md\` — Vision à long terme
- **Knowledge** : \`Knowledge/MOC/index.md\` — Connaissances opérationnelles
- **Zettelkasten** : \`Zettelkasten/MOC/index.md\` — Notes atomiques

## 🔧 Scripts Disponibles

### Scripts CLI
EOF

# Ajouter les scripts CLI
for script in $CLI_SCRIPTS; do
    description=$(head -1 "$script" | sed 's/^# //')
    if [ -z "$description" ]; then
        description="Script sans description"
    fi
    echo "- \`$script\` — $description" >> README.md
done

cat >> README.md << 'EOF'

### Scripts utilitaires
EOF

# Ajouter les scripts utilitaires
for script in $UTIL_SCRIPTS; do
    description=$(head -1 "$script" | sed 's/^# //')
    if [ -z "$description" ]; then
        description="Script sans description"
    fi
    echo "- \`$script\` — $description" >> README.md
done

cat >> README.md << 'EOF'

## 📝 Schémas YAML IPCRAE v4.0

Le système utilise des schémas YAML standardisés pour tous les types de fichiers :

| Schéma | Type de fichier |
|--------|-----------------|
EOF

# Ajouter les schémas YAML
for schema in $SCHEMA_FILES; do
    schema_type=$(head -1 "$schema" | sed 's/^# //')
    if [ -z "$schema_type" ]; then
        schema_type="Schéma sans description"
    fi
    echo "| \`$schema\` | $schema_type |" >> README.md
done

cat >> README.md << EOF

Documentation complète : \`.ipcrae/schema/README.md\`

## 🤖 Multi-Agent IA

IPCRAE supporte 4 providers IA :

- **Claude** (Anthropic) — Mode par défaut
- **Gemini** (Google)
- **Codex** (OpenAI)
- **Kilo** (Extension VS Code)

Chaque agent a ses propres prompts spécialisés dans \`Agents/\` et \`.ipcrae/prompts/\`.

## 🔍 Recherche de Connaissance

1. \`ipcrae tag <tag>\` — Recherche par tags
2. \`ipcrae index\` — Si cache absent/obsolète
3. \`ipcrae search <mots|tags>\` — Fallback full-text

## 📦 Configuration

Configuration principale : \`.ipcrae/config.yaml\`

\`\`\`yaml
ipcrae_root: "/home/eric/IPCRAE"
script_version: "$VERSION"
method_version: "3.3"
default_provider: "claude"
auto_git_sync: true

brain_remote: "https://github.com/vieurou/brain.git"
\`\`\`

## 🚧 Développement

### Branches
- \`main\` — Branche principale (vault)
- \`master\` — Branche principale (projet IPCRAE)

### Tags
- \`session-YYYYMMDD-domaine\` — Jalons temporels vault
- \`vX.Y.Z\` — Versions de release

## 📄 Licence

Ce projet est open-source et utilise une licence permissive.

## 🤝 Contribution

Ce projet est personnel mais les idées et patterns sont documentés pour être réutilisables.

---

**Version** : IPCRAE v3.3
**Dernière mise à jour** : $(date '+%Y-%m-%d')
**Phase active** : phase-outillage-ipcrae
**Statut vault** : $(bash scripts/ipcrae-audit-check.sh 2>/dev/null | grep "score=" | cut -d'"' -f2)/25 ($(bash scripts/ipcrae-audit-check.sh 2>/dev/null | grep "pct=" | cut -d'"' -f2)%)
EOF

log INFO "README.md mis à jour avec succès"
log INFO "Sauvegarde disponible: $BACKUP_FILE"

exit 0
