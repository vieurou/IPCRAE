#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# IPCRA Étendu v3 — Installateur interactif multi-provider
# Phases/Process/Daily/Weekly/Monthly + Claude/Gemini/Codex/Kilo
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

VERSION="3.1.0"
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
AUTO_YES=false
IPCRA_ROOT=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { logerr "Commande requise introuvable: $1"; exit 1; }
}

normalize_root() {
  local input="$1"
  # Expansion robuste de ~ sans eval.
  if [[ "$input" == "~" ]]; then
    input="$HOME"
  elif [[ "$input" == ~/* ]]; then
    input="$HOME/${input#~/}"
  fi

  # Retirer les slashs finaux sauf pour '/'.
  while [ "$input" != "/" ] && [[ "$input" == */ ]]; do
    input="${input%/}"
  done
  printf '%s' "$input"
}

# ── Utilitaires ───────────────────────────────────────────────────────────
loginfo()  { printf '%b→ %s%b\n' "$GREEN"  "$1" "$NC"; }
logwarn()  { printf '%b⚠ %s%b\n' "$YELLOW" "$1" "$NC"; }
logerr()   { printf '%b✗ %s%b\n' "$RED"    "$1" "$NC" >&2; }
section()  { printf '\n%b━━ %s ━━%b\n' "$BOLD" "$1" "$NC"; }

prompt_yes_no() {
  local q="$1" d="$2" a
  [ "$AUTO_YES" = true ] && return 0
  while true; do
    if [ "$d" = "y" ]; then read -r -p "$q [Y/n] " a || a="y"; a=${a:-y}
    else read -r -p "$q [y/N] " a || a="n"; a=${a:-n}; fi
    case "$a" in [Yy]*) return 0;; [Nn]*) return 1;; *) echo "y ou n.";; esac
  done
}

backup_if_exists() {
  local f="$1"
  [ -f "$f" ] && { local t; t=$(date +%Y%m%d-%H%M%S); mv "$f" "${f}.bak-${t}"; } || true
}

write_safe() {
  local f="$1" c="$2"
  local tmp
  mkdir -p "$(dirname "$f")"
  tmp="$(mktemp "${f}.tmp.XXXXXX")"
  printf '%s\n' "$c" > "$tmp"
  backup_if_exists "$f"
  mv "$tmp" "$f"
}

usage() {
  cat <<EOF
IPCRA v3 — Installateur multi-provider
Usage: $(basename "$0") [OPTIONS] [CHEMIN]
  -y, --yes       Mode non-interactif
  -h, --help      Aide
  -V, --version   Version
EOF
}

cleanup() { local e=$?; if [ $e -ne 0 ]; then logerr "Erreur (code $e). Installation incomplète."; fi; }
trap cleanup EXIT

# ── Parsing ───────────────────────────────────────────────────────────────
while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) AUTO_YES=true;; -h|--help) usage; exit 0;;
    -V|--version) echo "IPCRA Install v$VERSION"; exit 0;;
    -*) logerr "Option inconnue: $1"; usage; exit 1;;
    *)
      if [ -n "$IPCRA_ROOT" ]; then
        logerr "Un seul chemin cible est autorisé. Reçu en trop: $1"
        usage
        exit 1
      fi
      IPCRA_ROOT="$1"
      ;;
  esac; shift
done

if [ -z "$IPCRA_ROOT" ]; then
  local_default="$HOME/IPCRA"
  if [ "$AUTO_YES" = true ]; then IPCRA_ROOT="$local_default"
  else printf 'Dossier racine IPCRA:\n'; read -r -p "→ [$local_default] " IPCRA_ROOT
    IPCRA_ROOT=${IPCRA_ROOT:-$local_default}; fi
fi

IPCRA_ROOT="$(normalize_root "$IPCRA_ROOT")"

case "$IPCRA_ROOT" in
  ""|"/")
    logerr "Chemin cible invalide: '$IPCRA_ROOT'"
    exit 1
    ;;
esac

printf '%b╔═══════════════════════════════════════════╗%b\n' "$BLUE" "$NC"
printf '%b║  IPCRA Étendu v3 — Install multi-provider ║%b\n' "$BLUE" "$NC"
printf '%b╚═══════════════════════════════════════════╝%b\n\n' "$BLUE" "$NC"
loginfo "Cible: $IPCRA_ROOT"

[ -d "$IPCRA_ROOT" ] && { logwarn "Le dossier existe."; prompt_yes_no "Continuer ?" "y" || exit 1; }
mkdir -p "$IPCRA_ROOT"; cd "$IPCRA_ROOT"

if [ ! -d ".git" ]; then
  if prompt_yes_no "Initialiser un dépôt Git dans $IPCRA_ROOT ?" "y"; then
    require_cmd git
    git init
    cat > .gitignore << 'GITEOF'
*.bak-*
*.log
*.tmp
.ipcra/config.yaml
node_modules/
GITEOF
    git add .gitignore
  fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# 1) ARBORESCENCE
# ═══════════════════════════════════════════════════════════════════════════
section "Arborescence"
mkdir -p Inbox Projets Casquettes Ressources Archives Agents Scripts Process Phases Objectifs .ipcra
mkdir -p Journal/{Daily,Weekly,Monthly}
mkdir -p Ressources/Tech/{DevOps,Linux,Docker,NodeJS,SvelteKit,Embedded,Healthcare-IT,Security,Database}
mkdir -p Ressources/Electronique/{ESP32,Arduino,Circuits,IoT,Datasheets}
mkdir -p Ressources/Musique/{Production,Synthese,Hardware,Plugins}
mkdir -p Ressources/Maison/{Domotique,Renovation,Energie,Jardinage}
mkdir -p Ressources/Sante/{Nutrition,Sport,Sommeil}
mkdir -p Ressources/Finance/{Budget,Investissement,Fiscalite}
mkdir -p Ressources/Apprentissage/{Methodes,Cours,Certifications}
mkdir -p Ressources/Autres .kilocode/rules
# v3.1 : Zettelkasten + mémoire par domaine + prompts IA
mkdir -p Zettelkasten/{_inbox,permanents,MOC}
mkdir -p memory .ipcra/prompts
loginfo "Arborescence créée."

# ═══════════════════════════════════════════════════════════════════════════
# 2) FICHIERS SOURCE (.ipcra/)
# ═══════════════════════════════════════════════════════════════════════════
section "Fichiers source IPCRA"
if prompt_yes_no "Écrire context.md, instructions.md, config.yaml ?" "y"; then

write_safe ".ipcra/context.md" '# Contexte Global — IPCRA v3

## Pourquoi ce système
- La mémoire des chats est bruitée → la vérité est dans des fichiers locaux versionnables.
- L'\''IA travaille sur un contexte structuré, mis à jour par les cycles daily/weekly/close.

## Identité

### Professionnel
- DevOps autodidacte, infrastructure IT santé (Santelys)
- Linux (Debian), Docker, systèmes embarqués (ESP32, Orange Pi)
- Node.js, SvelteKit, MariaDB, PostgreSQL
- VSCode, Git/GitHub, CLI/SSH

### Centres d'\''intérêt
- Informatique : Linux, Amiga, optimisation
- Électronique : IoT, domotique, systèmes programmés
- Musique : production, synthèse, circuit bending, hardware
- Maison : rénovation, énergie, domotique, DIY

### Valeurs
- Open-source, pragmatique, documenté
- Zéro tolérance pour les infos non vérifiées
- Hands-on, apprendre par la pratique

## Structure IPCRA v3.1

| Dossier | Rôle |
|---------|------|
| Inbox/ | Capture brute (idées, tâches, liens) |
| Projets/ | Projets avec objectif et fin |
| Casquettes/ | Responsabilités continues |
| Ressources/ | Documentation brute par domaine (notes littérales) |
| Zettelkasten/ | Notes atomiques permanentes (une idée = une note, reliées) |
| Archives/ | Terminé |
| Journal/Daily/ | Notes quotidiennes |
| Journal/Weekly/ | Revues hebdo ISO |
| Journal/Monthly/ | Revues mensuelles |
| Phases/ | Phases de vie actives (pilotent la priorité) |
| Process/ | Procédures récurrentes (inputs/outputs/checklists) |
| Objectifs/ | Vision annuelle, trimestrielle, Someday/Maybe |
| memory/ | Mémoire IA par domaine (décisions, erreurs, patterns) |
| Agents/ | Rôles IA spécialisés |

## Zettelkasten
Principes :
- **Atomicité** : une note = une seule idée, formulée dans tes mots
- **Liens** : chaque note doit être reliée à au moins une autre `[[note]]`
- **Émergence** : pas de hiérarchie rigide, la structure naît des connexions
- **Ressources/ vs Zettelkasten/** : Ressources = matière brute (extraits, refs), Zettelkasten = pensée digérée

Workflow : Inbox → Zettelkasten/_inbox/ (brouillon) → Zettelkasten/permanents/ (validé, lié)
Navigation : Zettelkasten/MOC/ contient les Maps of Content (index thématiques)
Commandes : `ipcra zettel "titre"` (créer note) | `ipcra moc "thème"` (créer/ouvrir MOC)

## Mémoire IA par domaine
Chaque domaine a sa propre mémoire dans `memory/` :
- memory/devops.md, memory/electronique.md, memory/musique.md, etc.
- Contient : contraintes, décisions passées, erreurs apprises, raccourcis
- L'\''agent concerné lit **uniquement** sa mémoire → moins de bruit, plus de pertinence
- Mise à jour via `ipcra close`

## Méthodologie GTD adaptée

### Workflow quotidien
```
Capturer (Inbox) → Clarifier (actionnable?) → Organiser (Projet/Casquette/Ressources/Someday)
                                             → Réfléchir (Daily/Weekly/Monthly)
                                             → Agir (Next Actions)
```

### Protocole Inbox
```
Item → Actionnable ?
├─ Non → Ressources, Someday/Maybe, ou Supprimer
└─ Oui → < 2 min ?
     ├─ Oui → Faire immédiatement
     └─ Non → Projet (multi-étapes) ou Next Action → Casquette
              Délégable ? → Inbox/waiting-for.md
```

### Priorités
```
🔴 Urgent + Important   → FAIRE maintenant
🟠 Important             → PLANIFIER (phase/projet)
🟡 Urgent seul           → DÉLÉGUER ou quick-win
⚪ Ni l'\''un ni l'\''autre   → Someday/Maybe ou supprimer
```

### Cycles de revue
| Cycle | Quand | Durée | Commande |
|-------|-------|-------|----------|
| Daily | Chaque matin | 5 min | `ipcra daily` |
| Weekly | Dimanche | 30 min | `ipcra weekly` |
| Monthly | 1er du mois | 1h | `ipcra monthly` |
| Close | Fin de session IA | 5 min | `ipcra close` |

## Phase(s) active(s)
→ Voir Phases/index.md (source de priorités)

## Projets en cours
<!-- Mis à jour par `ipcra close` -->
- (à compléter)

## IA — Commandes avancées
- `ipcra daily --prep` : l'\''IA prépare un brouillon de daily (sources: hier, weekly, waiting-for, phases)
- `ipcra zettel "titre"` : créer une note atomique Zettelkasten
- `ipcra moc "thème"` : créer/ouvrir une Map of Content
- `ipcra health` : diagnostic du système (inbox stale, waiting-for expirés)
- `ipcra review phase|project|quarter` : revue adaptative guidée par l'\''IA'

write_safe ".ipcra/instructions.md" <<'EOF_INS'
# Instructions IA — IPCRA v3

> Source unique de vérité pour tous les providers (Claude, Gemini, Codex, Kilo).

## Protocole d'Optimisation par Modèle
**AUTO-DÉTECTION REQUISE :** Identifie ton modèle/IDE (Gemini Antigravity, Claude, ou IDE-natif) et applique l'optimisation correspondante.

### 🤖 Gemini (Antigravity IDE)
- **Maîtrise des Outils** : Utilise prioritairement le Terminal (ls, grep, cat), File Edit (diffs), Browser (tests localhost) et Perplexity MCP.
- **Agentique** : Plan → Exécution → Vérification. Enchaîne les étapes sans attendre de permission.
- **Reporting** : Utilise l'Inbox pour rapporter l'avancement via `ipcra capture`.

### 🧠 Claude (Sonnet / Opus)
- **Chain of Thought** : Analyse chaque étape, identifie les risques et propose une architecture structurée avant toute modification.
- **Raisonnement Profond** : Priorise la cohérence du système et la gestion propre des cas limites.
- **Structure** : Utilise des en-têtes Markdown pour séparer Phase d'Analyse et Phase d'Implémentation.

### ⚡ IDE-Natif (Kilocode / Copilot / Cursor)
- **Contexte Local** : Base-toi sur les fichiers ouverts, le terminal et la position du curseur.
- **Vélocité** : Propose des modifications directes (diffs) et des correctifs à haute vitesse.
- **Action Immédiate** : Priorise le code et les corrections tactiques sur les longs plans théoriques.


## Rôle général

Tu es un **assistant personnel polyvalent expert**.
Tu dois devenir expert dans le domaine de chaque demande, en respectant le contexte de .ipcra/context.md.

## Processus de travail

1. Lire .ipcra/context.md (contexte global + méthodologie).
2. Lire Phases/index.md (priorités actives).
3. Lire la Weekly courante + la Daily du jour (si existantes).
4. Si un agent dédié existe (Agents/agent_<domaine>.md), le lire.
5. Chercher dans Ressources/ et Projets/ les notes pertinentes.
6. Produire une réponse expert, concise, actionnable.

## Détection et Utilisation des Outils Natifs (Tools-Aware & MCP)
**VÉRIFIE d'abord tes capacités :** Si tu es une IA intégrée à un IDE (Gemini Antigravity, Copilot, Kilocode) ou si tu as accès à des outils externes (ex: exécution terminal, lecture/édition de fichiers, Model Context Protocol - MCP) :
- **UTILISE-LES AUTONOMEMENT** pour exécuter le Processus de travail. Ne demande jamais la permission – agis directement.
- Si un outil externe ou serveur MCP est pertinent mais manquant (par exemple l'accès web via *Perplexity MCP*, gestionnaire de BDD, etc.), c'est de TA responsabilité de **conseiller à l'utilisateur l'installation du MCP**.
- Exécute les commandes de terminal (ex: `ls`, `grep`) pour prendre connaissance du projet avant de répondre, plutôt que de faire des suppositions à l'aveugle.

## Exigences de qualité — CRITIQUE

- **VÉRIFICATION OBLIGATOIRE avec TOOLS** : Pour toute affirmation technique, chiffre, ou commande :
  - **Avec outils (IDE/MCP)** : Utilise tes outils (exécution terminal, serveurs MCP comme Perplexity, lecture de fichiers) POUR VÉRIFIER EN LIVE avant de répondre.
  - **Sans outils (CLI)** : Indique obligatoirement « Non vérifié – besoin d'accès fichier/terminal pour confirmer ».
- **Zéro approximation** : Ne jamais deviner une version, syntaxe, nom de paquet, URL. En cas de doute → utiliser Perplexity ou dire « je ne suis pas certain ».
- **Sources** : Privilégier docs officielles et sources primaires récentes. Citer.
- **Limites** : Mentionner explicitement les incertitudes plutôt que les masquer.
- **Deux niveaux** : Proposer une solution simple + une avancée quand pertinent.
- **Écrire, pas retenir** : Les décisions/avancées doivent aller physiquement dans les fichiers (Journal, memory.md, Projets), pas « rester en tête ».

## Styles par domaine

### DevOps / Infra → commandes shell, configs, Dockerfiles, schémas archi
### Développement → code propre, tests, patterns modernes
### Électronique → schémas, code firmware, vérifier datasheets et brochages
### Musique → chaînes audio, réglages, reco matériel avec sources
### Maison → plans, matériaux, normes (NF C 15-100), alertes sécurité
### Santé → preuves scientifiques uniquement, JAMAIS de diagnostic, citer sources
### Finance → chiffres France vérifiés, mentionner date de validité

## Actions autorisées
- **Outils natifs PREMIERS** : Si disponibles, utiliser le terminal, file-edit, et MCP pour résoudre la consigne directement et valider la configuration avant de répondre textuellement.
- Créer/éditer fichiers markdown, code, configs
- Restructurer les notes, préparer plans et checklists
- **Autonomie de la Mémoire** : Réorganiser ou réécrire de ton propre chef `memory/<domaine>.md` si tu trouves la mémoire mal formatée ou confuse.
- **Création de Compétences** : Créer tes propres fichiers `Agents/agent_<nom>_skills.md` pour y dicter des workflows et patterns réutilisables que tu as appris au fur et à mesure.

## Actions interdites
- Supprimer sans confirmation
- Modifier context.md/instructions.md sans demande
- Inventer des infos (surtout santé/finance)
- Présenter une supposition comme un fait

## Règle d'or
Si tu n'es pas sûr → dis-le clairement. **Ne jamais inventer.**
EOF_INS

write_safe ".ipcra/config.yaml" <<EOF_CONF
# IPCRA v3 Configuration
# Généré le $(date +%Y-%m-%d)

ipcra_root: "${IPCRA_ROOT}"
version: "${VERSION}"
default_provider: claude

providers:
  claude:
    enabled: true
    command: claude
  gemini:
    enabled: true
    command: gemini
  codex:
    enabled: true
    command: codex
  kilo:
    enabled: true
    note: "Extension VS Code — .kilocode/rules/"
EOF_CONF
fi

# ═══════════════════════════════════════════════════════════════════════════
# 3) TEMPLATES JOURNAL
# ═══════════════════════════════════════════════════════════════════════════
section "Templates"
if prompt_yes_no "Installer templates (Daily/Weekly/Monthly/Phase/Process/Projet) ?" "y"; then

write_safe "Journal/template_daily.md" '# Daily — {{date}}

## 🎯 Top 3 (priorités du jour)
- [ ]
- [ ]
- [ ]

## 📅 Agenda / contraintes fixes

## ⚡ Next actions (par casquette)
### Travail / DevOps
- [ ]

### Perso / Projets
- [ ]

### Maison
- [ ]

## 📝 Log (ce qui a été fait)
-

## 📥 Captures Inbox
-

## 💡 Décisions / apprentissages
-

## 🔋 Énergie / humeur (1-5)
-'

write_safe "Journal/template_weekly.md" '# Weekly — {{iso_week}}

## 🎯 Phase active
→ [[Phases/index]]

## Objectifs semaine (3 max)
- [ ]
- [ ]
- [ ]

## 📥 Inbox — traitement
- [ ] Tout vidé et classé ?

## 🚀 Projets actifs
| Projet | Statut | Prochaine action |
|--------|--------|-----------------|

## 🎩 Casquettes — vérification
- [ ] Travail : RAS ?
- [ ] Maison : RAS ?
- [ ] Santé : sport/sommeil/nutrition OK ?
- [ ] Finances : RAS ?

## ⏳ Waiting-for
→ Voir [[Inbox/waiting-for]]

## 😤 Irritants / risques
-

## 📝 Leçons de la semaine
-

## 🎯 Plan semaine prochaine
-'

write_safe "Journal/template_monthly.md" '# Revue mensuelle — {{month}}

## 🎯 Bilan objectifs du mois
| Objectif | Résultat | Note |
|----------|----------|------|

## 📊 Casquettes — état général
- Travail :
- Maison :
- Santé :
- Finances :
- Projets perso :

## 🔄 Phase active — toujours pertinente ?
→ [[Phases/index]]

## 💡 Leçons du mois
-

## 🎯 Objectifs mois prochain (3 max)
- [ ]
- [ ]
- [ ]

## 🧹 Nettoyage
- [ ] Archiver projets terminés
- [ ] Vider Inbox
- [ ] Revoir Someday/Maybe'

write_safe "Phases/_template_phase.md" '# Phase — [Nom]

## Objectifs (1-3, mesurables)
-

## Projets autorisés (focus)
-

## Stop doing (ce qu'\''on refuse pendant cette phase)
-

## Indicateurs de succès
-

## Durée prévue
-'

write_safe "Process/_template_process.md" '# Process — [Nom]

## Déclencheur (quand lancer ce process ?)
-

## Entrées (inputs nécessaires)
-

## Checklist
- [ ]
- [ ]

## Sorties (outputs attendus)
-

## Definition of Done
-

## Agent IA recommandé
- (ex: agent_devops, agent_finance)'

write_safe "Projets/_template_projet.md" '# [Nom du Projet]

## Métadonnées
- **Domaine** : Tech/Electronique/Musique/Maison/Santé/Finance
- **Statut** : 💡Idée / 📋Planifié / 🚀Actif / ⏸Pause / ✅Terminé
- **Priorité** : 🔴Urgente / 🟠Haute / 🟡Moyenne / ⚪Basse
- **Énergie** : 🔋Haute / 🔋Moyenne / 🔋Basse
- **Début** : YYYY-MM-DD
- **Tags** : #tag

## Objectif (une phrase)

## Next actions
- [ ]
- [ ]

## Architecture / Plan

## Décisions importantes
| Date | Décision | Raison |
|------|----------|--------|

## Journal du projet
### YYYY-MM-DD
-'

write_safe "Casquettes/_template_casquette.md" '# [Nom de la Casquette]

## Responsabilités
-

## Routines
### Quotidien
- [ ]
### Hebdomadaire
- [ ]

## Projets liés
-'
fi

# ═══════════════════════════════════════════════════════════════════════════
# 4) AGENTS ENRICHIS
# ═══════════════════════════════════════════════════════════════════════════
section "Agents spécialisés"
if prompt_yes_no "Installer agents enrichis ?" "y"; then

write_safe "Agents/agent_devops.md" <<'EOF_DEVOPS'
# Agent DevOps / Infra

## Rôle
Architecte DevOps / SRE Linux/Docker, spécialisé IT santé.

## Mode Tools-Aware (IDE uniquement)
**Si tu as accès à un terminal ou au Model Context Protocol (MCP) :**
1. `terminal ls -R` + `grep` → Analyse la structure réelle de l'infra/code avant de proposer un changement.
2. `terminal docker ps` ou `systemctl` → Vérifie l'état des services si tu es en phase de debug.
3. **MCP Perplexity** → Obligatoire pour vérifier les versions de paquets Debian ou la documentation d'une API obscure. Si non installé, **recommande son installation** pour une meilleure fiabilité.

## Avant de répondre (workflow obligatoire)
1. Lire `memory/devops.md` (décisions passées, erreurs connues)
2. Identifier le type : déploiement / infrastructure / debug / sécurité / monitoring ?
3. Vérifier contraintes : stack actuelle, normes HDS/RGPD, budget infra
4. Produire : solution + commandes testables + plan de test + risques + rollback

## Expertise
- OS : Debian stable/testing, Ubuntu Server
- Conteneurs : Docker, Docker Compose, Swarm
- Langages : Bash, Node.js, Python, SQL
- BDD : MariaDB, PostgreSQL
- Réseau : VPN, reverse proxy (Nginx/Traefik), SSH, nftables
- Sécurité : hardening Debian, certificats, compliance HDS/RGPD

## Contexte personnel
<!-- À remplir -->
- Serveurs :
- Infra réseau :
- Services critiques :

## Sorties
- Commandes shell exactes et testables
- Configs complètes (pas de fragments)
- Dockerfiles fonctionnels, schémas archi (Mermaid/ASCII)

## Qualité
- Vérifier versions, syntaxe, noms de paquets Debian
- Mentionner prérequis et risques
- Proposer un plan de test pour chaque changement
- Ne JAMAIS inventer une option de commande

## Escalade
- Si touche réseau → vérifier config nftables/firewall d'abord
- Si touche données → exiger backup AVANT toute action
- Si compliance santé → citer la norme exacte
EOF_DEVOPS

write_safe "Agents/agent_electronique.md" <<'EOF_ELEC'
# Agent Électronique / Embedded

## Rôle
Ingénieur systèmes embarqués (ESP32, Arduino, ARM/Orange Pi).

## Mode Tools-Aware (IDE uniquement)
**Si tu as accès à un terminal ou au Model Context Protocol (MCP) :**
1. `terminal ls /dev/tty*` → Vérifie la présence de ports série si on te demande un flashage.
2. `terminal pio device list` → Si PlatformIO est détecté, liste les boards connectées.
3. **MCP Perplexity** → Utilise-le pour chercher les "pinout diagrams" ou les "registers" spécifiques d'un composant. Suggère son installation pour éviter toute erreur de brochage.

## Avant de répondre (workflow obligatoire)
1. Lire `memory/electronique.md` (projets passés, erreurs connues)
2. Identifier le type : conception / debug firmware / PCB / protocole ?
3. Vérifier contraintes : tension (3.3V/5V), courant, MCU cible
4. Produire : schéma + code + calculs composants + refs datasheets

## Expertise
- MCU : ESP32 (IDF + Arduino), Arduino, STM32
- Langages : C, C++, MicroPython
- Protocoles : I2C, SPI, UART, MIDI, RS485, WiFi, BLE, MQTT
- Outils : PlatformIO, KiCad, oscilloscope
- Domaines : IoT, domotique, MIDI controllers, circuit bending

## Contexte personnel
<!-- À remplir -->
- MCU principaux :
- Projets en cours :
- Contraintes alimentations :

## Sorties
- Schémas de connexion (broches exactes, niveaux logiques)
- Code firmware complet et commenté
- Calculs composants, références datasheets exactes

## Qualité
- Vérifier chaque brochage dans la datasheet
- Vérifier compatibilité 3.3V/5V
- Indiquer consommations et limites courant
- Toujours référence exacte du composant

## Escalade
- Si courant > 500mA → dimensionner alimentation séparée
- Si tension mixte 3.3/5V → level shifter obligatoire
- Si doute sur composant → dire "à vérifier datasheet"
EOF_ELEC

write_safe "Agents/agent_musique.md" <<'EOF_MUSIQUE'
# Agent Musique / Audio

## Rôle
Ingénieur du son et bidouilleur hardware audio.

## Mode Tools-Aware (IDE uniquement)
**Si tu as accès à un terminal ou au Model Context Protocol (MCP) :**
1. **MCP Perplexity** → Utilise-le systématiquement pour récupérer les manuels (PDF) ou les specs de réglage fin (attack/release times recommandés, impédance).
2. **Recommandation** : Suggère l'installation de serveurs MCP spécialisés dans la recherche audio ou web si tu n'as pas de visibilité sur le matériel récent.

## Expertise
- DAW : Reaper, Bitwig | Synthèse : soustractive, FM, granulaire, modulaire
- Hardware : synthés, drum machines, circuit bending, DIY audio
- MIDI : standard, SysEx, MIDI 2.0 | Audio : VST/CLAP, Pure Data

## Sorties
- Chaînes de signal complètes, réglages précis
- Reco matériel avec budget et alternatives, schémas routage

## Qualité
- Vérifier specs techniques avant de recommander
- Distinguer faits objectifs vs préférences subjectives
- Ne pas inventer de fonctionnalités produit
EOF_MUSIQUE

write_safe "Agents/agent_maison.md" <<'EOF_MAISON'
# Agent Maison / Rénovation / Domotique

## Rôle
Conseiller rénovation/énergie/domotique, contexte français.

## Mode Tools-Aware (IDE uniquement)
**Si tu as accès à un terminal ou au Model Context Protocol (MCP) :**
1. **MCP Perplexity** → Crucial pour vérifier les dernières mises à jour des normes (NF C 15-100) ou les barèmes d'aides d'État (MaPrimeRénov) à la date du jour.
2. **Outil Terminal** : Cherche dans le répertoire `Process/` ou `Ressources/maison/` pour trouver les schémas existants avant d'en proposer un nouveau.

## Expertise
- Réno : isolation, plomberie, électricité, menuiserie
- Énergie : PAC, solaire, DPE | Domotique : Home Assistant, Zigbee, MQTT
- Normes : NF C 15-100, DTU, RE2020

## Sorties
- Plans avec étapes, matériaux, fourchettes de coûts réalistes, alertes sécurité

## Qualité
- Vérifier normes avant de conseiller
- Indiquer quand un pro est obligatoire (tableau élec, gaz, structure)
- Fourchettes réalistes, pas de chiffres inventés
- Mentionner aides (MaPrimeRénov, CEE) sans inventer les montants
EOF_MAISON

write_safe "Agents/agent_sante.md" <<'EOF_SANTE'
# Agent Santé personnelle

## Rôle
Conseiller santé basé exclusivement sur les preuves.

## Mode Tools-Aware (IDE uniquement)
**Si tu as accès à un terminal ou au Model Context Protocol (MCP) :**
1. **MCP Perplexity** → **OBLIGATOIRE** pour sourcer chaque affirmation via des méta-analyses récentes ou des recommandations de la HAS.
2. Suggère l'installation d'un MCP de recherche scientifique si tu n'as pas accès aux publications récentes (PubMed/Google Scholar).

## Cadre
Hygiène de vie (nutrition, sport, sommeil). PAS de diagnostic ni prescription.

## Qualité — CRITIQUE
- JAMAIS de diagnostic → rappeler de consulter un médecin
- Sources obligatoires : HAS, OMS, méta-analyses
- Pas de posologie sans source
- Distinguer : consensus vs études isolées vs opinion populaire
- En cas de doute → « consultez un professionnel »
EOF_SANTE

write_safe "Agents/agent_finance.md" <<'EOF_FINANCE'
# Agent Finances personnelles

## Rôle
Conseiller finances France pragmatique.

## Mode Tools-Aware (IDE uniquement)
**Si tu as accès à un terminal ou au Model Context Protocol (MCP) :**
1. **MCP Perplexity** → Vérification systématique des taux (Livret A, LEP), plafonds fiscaux et conditions de sortie (PEA, AV) actualisés à la date du jour.
2. Suggère d'installer un connecteur d'informations financières certifiés pour éviter toute approximation sur les seuils d'imposition.

## Cadre
Fiscal français, enveloppes (Livret A, PEA, AV, PER), budget perso.

## Qualité — CRITIQUE
- Vérifier plafonds, taux, seuils → changent souvent
- Mentionner la date de validité des infos fiscales
- Pas de reco d'actions individuelles
- Rappeler : performances passées ≠ performances futures
- Indiquer quand un conseiller pro est recommandé
EOF_FINANCE
fi

# ═══════════════════════════════════════════════════════════════════════════
# 5) FICHIERS D'INITIALISATION
# ═══════════════════════════════════════════════════════════════════════════
section "Fichiers d'initialisation"

[ ! -f "Phases/index.md" ] && write_safe "Phases/index.md" '# Phases — Index

## Phase active
- (à définir) → créer depuis Phases/_template_phase.md

## Règle
Une phase active = priorité > tout le reste.
Les projets non autorisés par la phase sont en pause.'

[ ! -f "Process/index.md" ] && write_safe "Process/index.md" '# Process — Index

## Processus récurrents
- [[Process - Revue hebdo]]
- [[Process - Budget mensuel]]
- [[Process - Backup et maintenance]]

## Créer un process
Copier Process/_template_process.md et remplir.'

[ ! -f "Inbox/waiting-for.md" ] && write_safe "Inbox/waiting-for.md" '# Waiting-for — Éléments en attente

| Date | En attente de | Sujet | Relance prévue | Statut |
|------|--------------|-------|----------------|--------|'

[ ! -f "Objectifs/someday.md" ] && write_safe "Objectifs/someday.md" '# Someday / Maybe

> Idées et projets futurs, pas encore engagés. Revoir mensuellement.

## Tech / Dev
-

## Électronique
-

## Musique
-

## Maison
-

## Perso
-'

# v3.1 : mémoire par domaine au lieu de memory.md unique
for domain in devops electronique musique maison sante finance; do
  [ ! -f "memory/${domain}.md" ] && write_safe "memory/${domain}.md" "# Mémoire — ${domain}

## Contraintes connues
<!-- Stack, infra, budget, normes -->
-

## Décisions passées
<!-- Date + contexte + décision + raison -->

## Erreurs apprises
<!-- Ce qu'il ne faut pas refaire -->

## Raccourcis méthodologiques
<!-- Heuristiques validées par l'expérience -->
"
done

[ ! -f "memory/index.md" ] && write_safe "memory/index.md" '# Memory — Index

| Domaine | Fichier | Dernière maj |
|---------|---------|-------------|
| DevOps | [[memory/devops]] | |
| Électronique | [[memory/electronique]] | |
| Musique | [[memory/musique]] | |
| Maison | [[memory/maison]] | |
| Santé | [[memory/sante]] | |
| Finance | [[memory/finance]] | |

## Format d'\''entrée
```
## YYYY-MM-DD - Titre court
**Contexte** :
**Décision** :
**Raison** :
**Résultat** :
```
'

[ ! -f "Zettelkasten/MOC/index.md" ] && write_safe "Zettelkasten/MOC/index.md" '# MOC — Index général

## Thèmes
<!-- Lister ici les MOC créés : [[MOC-devops]], [[MOC-electronique]]... -->
-'

# v3.1 : Zettelkasten template
write_safe "Zettelkasten/_template.md" '---
id: {{id}}
tags: []
liens: []
source:
created: {{date}}
---
# {{titre}}

<!-- Une seule idée, formulée dans tes mots -->


## Liens
- [[]] — raison du lien

## Source
- '

write_safe "index.md" '# 🧠 IPCRA v3.1 — Dashboard

## Navigation
| Fichier | Rôle |
|---------|------|
| [[Phases/index]] | Phases de vie actives (priorités) |
| [[Process/index]] | Procédures récurrentes |
| [[Objectifs/someday]] | Someday/Maybe |
| [[Inbox/waiting-for]] | En attente |
| [[memory/index]] | Mémoire IA par domaine |
| [[Zettelkasten/MOC/index]] | Zettelkasten — Maps of Content |

## Commandes CLI
```
ipcra               # menu interactif
ipcra daily         # daily note
ipcra daily --prep  # daily pré-rédigée par l'\''IA
ipcra weekly        # weekly ISO
ipcra monthly       # revue mensuelle
ipcra close         # clôture session (maj mémoire domaine)
ipcra sync          # régénère CLAUDE.md, GEMINI.md, AGENTS.md, Kilo
ipcra zettel "titre" # créer note atomique Zettelkasten
ipcra moc "thème"   # créer/ouvrir Map of Content
ipcra health        # diagnostic système
ipcra DevOps        # mode expert
ipcra -p gemini     # choisir le provider
```'

# ═══════════════════════════════════════════════════════════════════════════
# 6) FICHIERS PROVIDER + IGNORE
# ═══════════════════════════════════════════════════════════════════════════
section "Fichiers provider"
if prompt_yes_no "Générer CLAUDE.md, GEMINI.md, AGENTS.md, Kilo ?" "y"; then
  body="$(cat .ipcra/context.md; printf '\n\n---\n\n'; cat .ipcra/instructions.md)"
  for t in "CLAUDE.md:Claude" "GEMINI.md:Gemini" "AGENTS.md:Codex"; do
    f="${t%%:*}"; n="${t##*:}"
    printf '# Instructions pour %s — IPCRA v3\n# ⚠ GÉNÉRÉ — éditer .ipcra/context.md + instructions.md\n# Régénérer : ipcra sync\n\n%s\n' "$n" "$body" > "$f"
    loginfo "$f"
  done
  mkdir -p .kilocode/rules
  printf '# Instructions IPCRA pour Kilo Code\n# ⚠ GÉNÉRÉ\n\n%s\n' "$body" > .kilocode/rules/ipcra.md
  loginfo ".kilocode/rules/ipcra.md"
fi

section "Fichiers ignore"
if prompt_yes_no "Créer .claudeignore et .geminiignore ?" "y"; then
  ignore='Archives/
Scripts/
*.log
*.tmp
node_modules/
.git/
.ipcra/'
  write_safe ".claudeignore" "$ignore"
  write_safe ".geminiignore" "$ignore"
fi

# ═══════════════════════════════════════════════════════════════════════════
# 7) INSTALLATION DES LANCEURS (IPCRA + IPCRA-INIT-CONCEPTION)
# ═══════════════════════════════════════════════════════════════════════════
section "Installation des scripts CLI dans le PATH"

if prompt_yes_no "Installer ~/bin/ipcra et ~/bin/ipcra-init-conception ?" "y"; then
  mkdir -p "$HOME/bin"

  if [ -f "$SCRIPT_DIR/templates/ipcra-launcher.sh" ]; then
    cp "$SCRIPT_DIR/templates/ipcra-launcher.sh" "$HOME/bin/ipcra"
  else
    logerr "Template templates/ipcra-launcher.sh introuvable !"
    exit 1
  fi
  
  if [ -f "$SCRIPT_DIR/templates/ipcra-init-conception.sh" ]; then
    cp "$SCRIPT_DIR/templates/ipcra-init-conception.sh" "$HOME/bin/ipcra-init-conception"
  else
    logerr "Template templates/ipcra-init-conception.sh introuvable !"
    exit 1
  fi
  
  if [ -d "$SCRIPT_DIR/templates/prompts" ]; then
    mkdir -p "$IPCRA_ROOT/.ipcra/prompts/"
    cp "$SCRIPT_DIR"/templates/prompts/*.md "$IPCRA_ROOT/.ipcra/prompts/"
    loginfo "✓ Prompts IA extraits dans .ipcra/prompts/"
  else
    logwarn "Dossier templates/prompts introuvable, installation des prompts omise."
  fi

  chmod +x "$HOME/bin/ipcra-init-conception"
  loginfo "✓ Script ipcra-init-conception installé dans ~/bin"

  if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    loginfo "Ajouté ~/bin au PATH dans ~/.bashrc. Redémarrez le terminal en tapant 'bash'."
  fi
fi
