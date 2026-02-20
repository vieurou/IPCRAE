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
# v3.1 : Zettelkasten + mémoire par domaine
mkdir -p Zettelkasten/{_inbox,permanents,MOC}
mkdir -p memory
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

write_safe ".ipcra/instructions.md" '# Instructions IA — IPCRA v3

> Source unique de vérité pour tous les providers (Claude, Gemini, Codex, Kilo).

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

## Exigences de qualité — CRITIQUE

- **VÉRIFICATION OBLIGATOIRE** : toute affirmation technique, chiffre, commande DOIT être vérifiée. En cas de doute → dire « je ne suis pas certain ».
- **Zéro approximation** : ne jamais deviner une version, syntaxe, nom de paquet, URL.
- **Sources** : privilégier docs officielles et sources primaires récentes. Citer.
- **Limites** : mentionner explicitement les incertitudes plutôt que les masquer.
- **Deux niveaux** : proposer une solution simple + une avancée quand pertinent.
- **Écrire, pas retenir** : les décisions/avancées doivent aller dans les fichiers (Journal, memory.md, Projets), pas « rester en tête ».

## Styles par domaine

### DevOps / Infra → commandes shell, configs, Dockerfiles, schémas archi
### Développement → code propre, tests, patterns modernes
### Électronique → schémas, code firmware, vérifier datasheets et brochages
### Musique → chaînes audio, réglages, reco matériel avec sources
### Maison → plans, matériaux, normes (NF C 15-100), alertes sécurité
### Santé → preuves scientifiques uniquement, JAMAIS de diagnostic, citer sources
### Finance → chiffres France vérifiés, mentionner date de validité

## Actions autorisées
- Créer/éditer fichiers markdown, code, configs
- Restructurer les notes, préparer plans et checklists

## Actions interdites
- Supprimer sans confirmation
- Modifier context.md/instructions.md sans demande
- Inventer des infos (surtout santé/finance)
- Présenter une supposition comme un fait

## Règle d'\''or
Si tu n'\''es pas sûr → dis-le clairement. **Ne jamais inventer.**'

write_safe ".ipcra/config.yaml" "# IPCRA v3 Configuration
# Généré le $(date +%Y-%m-%d)

ipcra_root: "\${IPCRA_ROOT}"
version: "\${VERSION}"
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
    note: \"Extension VS Code — .kilocode/rules/\""
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

write_safe "Agents/agent_devops.md" '# Agent DevOps / Infra

## Rôle
Architecte DevOps / SRE Linux/Docker, spécialisé IT santé.

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
- Si touche réseau → vérifier config nftables/firewall d'\''abord
- Si touche données → exiger backup AVANT toute action
- Si compliance santé → citer la norme exacte'

write_safe "Agents/agent_electronique.md" '# Agent Électronique / Embedded

## Rôle
Ingénieur systèmes embarqués (ESP32, Arduino, ARM/Orange Pi).

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
- Si doute sur composant → dire "à vérifier datasheet"'

write_safe "Agents/agent_musique.md" '# Agent Musique / Audio

## Rôle
Ingénieur du son et bidouilleur hardware audio.

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
- Ne pas inventer de fonctionnalités produit'

write_safe "Agents/agent_maison.md" '# Agent Maison / Rénovation / Domotique

## Rôle
Conseiller rénovation/énergie/domotique, contexte français.

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
- Mentionner aides (MaPrimeRénov, CEE) sans inventer les montants'

write_safe "Agents/agent_sante.md" '# Agent Santé personnelle

## Rôle
Conseiller santé basé exclusivement sur les preuves.

## Cadre
Hygiène de vie (nutrition, sport, sommeil). PAS de diagnostic ni prescription.

## Qualité — CRITIQUE
- JAMAIS de diagnostic → rappeler de consulter un médecin
- Sources obligatoires : HAS, OMS, méta-analyses
- Pas de posologie sans source
- Distinguer : consensus vs études isolées vs opinion populaire
- En cas de doute → « consultez un professionnel »'

write_safe "Agents/agent_finance.md" '# Agent Finances personnelles

## Rôle
Conseiller finances France pragmatique.

## Cadre
Fiscal français, enveloppes (Livret A, PEA, AV, PER), budget perso.

## Qualité — CRITIQUE
- Vérifier plafonds, taux, seuils → changent souvent
- Mentionner la date de validité des infos fiscales
- Pas de reco d'\''actions individuelles
- Rappeler : performances passées ≠ performances futures
- Indiquer quand un conseiller pro est recommandé'
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

  cat << 'EOF_LAUNCHER' > "$HOME/bin/ipcra"
#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# IPCRA Étendu v3.1 — Lanceur multi-provider
# Commandes : daily, weekly, monthly, close, sync, zettel, moc,
#             health, review, launch, menu
# Providers : Claude, Gemini, Codex, (Kilo via VS Code)
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

VERSION="3.1.0"
IPCRA_ROOT="${IPCRA_ROOT:-${HOME}/IPCRA}"
IPCRA_CONFIG="${IPCRA_ROOT}/.ipcra/config.yaml"
VAULT_NAME="$(basename "$IPCRA_ROOT")"

# ── Couleurs ──────────────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'

loginfo()  { printf '%b%s%b\n' "$GREEN"  "$*" "$NC"; }
logwarn()  { printf '%b%s%b\n' "$YELLOW" "$*" "$NC"; }
logerr()   { printf '%b%s%b\n' "$RED"    "$*" "$NC" >&2; }
section()  { printf '\n%b━━ %s ━━%b\n' "$BOLD" "$*" "$NC"; }

prompt_yes_no() {
  local q="$1" d="${2:-y}" a
  while true; do
    if [ "$d" = "y" ]; then
      read -r -p "$q [Y/n] " a || a="y"
      a=${a:-y}
    else
      read -r -p "$q [y/N] " a || a="n"
      a=${a:-n}
    fi
    case "$a" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "y ou n." ;;
    esac
  done
}

# ── Fichiers temp (cleanup auto) ─────────────────────────────
TEMP_FILES=()
cleanup_temps() { for f in "${TEMP_FILES[@]}"; do rm -f "$f"; done; }
trap cleanup_temps EXIT INT TERM

make_temp() {
  local f
  f=$(mktemp /tmp/ipcra.XXXXXX.md)
  TEMP_FILES+=("$f")
  printf '%s' "$f"
}

# ── Utilitaires ───────────────────────────────────────────────
iso_week() { date +%G-W%V; }
today()    { date +%F; }
year()     { date +%Y; }
yesterday() {
  date -d "yesterday" +%F 2>/dev/null || date -v-1d +%F 2>/dev/null || echo ""
}

need_root() {
  if [ ! -d "$IPCRA_ROOT" ]; then
    logerr "IPCRA_ROOT introuvable: $IPCRA_ROOT"
    exit 1
  fi
  cd "$IPCRA_ROOT"
}

urlencode() {
  python3 -c "import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))" "$1" 2>/dev/null || printf '%s' "$1" | sed 's/ /%20/g; s/\[/%5B/g; s/\]/%5D/g'
}

# ── Obsidian / Éditeur ────────────────────────────────────────
obsidian_open_note() {
  local vault="$1" file="$2"
  command -v xdg-open >/dev/null 2>&1 || return 1
  local v f
  v="$(urlencode "$vault")"
  f="$(urlencode "$file")"
  xdg-open "obsidian://open?vault=${v}&file=${f}" >/dev/null 2>&1 || return 1
}

open_note() {
  local abs="$1" rel="$2"
  if obsidian_open_note "$VAULT_NAME" "$rel"; then
    loginfo "Ouvert dans Obsidian: $rel"
  else
    ${EDITOR:-nano} "$abs"
  fi
}

# ── Provider detection ────────────────────────────────────────
get_default_provider() {
  if [ -f "$IPCRA_CONFIG" ]; then
    local p
    p=$(grep -E '^default_provider:' "$IPCRA_CONFIG" 2>/dev/null | awk '{print $2}' | tr -d '"' || true)
    [ -n "$p" ] && printf '%s' "$p" && return
  fi
  for cmd in claude gemini codex; do
    command -v "$cmd" &>/dev/null && printf '%s' "$cmd" && return
  done
  printf 'none'
}

list_providers() {
  printf '%b📋 Providers :%b\n' "$BOLD" "$NC"
  local providers=("claude" "gemini" "codex" "kilo")
  local names=("Claude Code" "Gemini CLI" "Codex" "Kilo Code (VS Code)")
  for i in "${!providers[@]}"; do
    local p="${providers[$i]}" n="${names[$i]}"
    if [ "$p" = "kilo" ]; then
      printf '  %b•%b %-10s — %s\n' "$YELLOW" "$NC" "$p" "$n"
    elif command -v "$p" &>/dev/null; then
      printf '  %b✓%b %-10s — %s\n' "$GREEN" "$NC" "$p" "$n"
    else
      printf '  %b✗%b %-10s — %s (non installé)\n' "$RED" "$NC" "$p" "$n"
    fi
  done
}

# ── Sync : régénérer fichiers provider ────────────────────────
sync_providers() {
  loginfo "Synchronisation des fichiers provider..."
  local ctx="${IPCRA_ROOT}/.ipcra/context.md"
  local ins="${IPCRA_ROOT}/.ipcra/instructions.md"
  [ ! -f "$ctx" ] || [ ! -f "$ins" ] && { logerr "Sources manquantes (.ipcra/context.md ou instructions.md)"; exit 1; }

  local body
  body="$(cat "$ctx"; printf '\n\n---\n\n'; cat "$ins")"

  for target in "CLAUDE.md:Claude" "GEMINI.md:Gemini" "AGENTS.md:Codex"; do
    local file="${target%%:*}" name="${target##*:}"
    printf '# Instructions pour %s — IPCRA v3.1\n# ⚠ GÉNÉRÉ — éditer .ipcra/context.md + instructions.md\n# Régénérer : ipcra sync\n\n%s\n' \
      "$name" "$body" > "${IPCRA_ROOT}/${file}"
    printf '  ✓ %s\n' "$file"
  done

  mkdir -p "${IPCRA_ROOT}/.kilocode/rules"
  printf '# Instructions IPCRA pour Kilo Code\n# ⚠ GÉNÉRÉ\n\n%s\n' "$body" > "${IPCRA_ROOT}/.kilocode/rules/ipcra.md"
  printf '  ✓ .kilocode/rules/ipcra.md\n'
  loginfo "Sync terminée."
}

# ── Daily ─────────────────────────────────────────────────────
cmd_daily() {
  local prep="${1:-}"
  need_root
  local y d rel abs
  y="$(year)"; d="$(today)"
  rel="Journal/Daily/${y}/${d}.md"
  abs="${IPCRA_ROOT}/${rel}"
  mkdir -p "${IPCRA_ROOT}/Journal/Daily/${y}"

  if [ "$prep" = "--prep" ]; then
    cmd_daily_prep "$abs" "$rel" "$d"
    return
  fi

  if [ ! -f "$abs" ]; then
    if [ -f "${IPCRA_ROOT}/Journal/template_daily.md" ]; then
      sed "s/{{date}}/${d}/g" "${IPCRA_ROOT}/Journal/template_daily.md" > "$abs"
    else
      printf '# Daily — %s\n\n## Top 3\n- [ ] \n- [ ] \n- [ ] \n' "$d" > "$abs"
    fi
    loginfo "Daily créée: $rel"
  fi
  open_note "$abs" "$rel"
}

cmd_daily_prep() {
  local abs="$1" rel="$2" d="$3"
  local provider
  provider="$(get_default_provider)"

  if [ "$provider" = "none" ]; then
    logerr "Aucun provider IA disponible pour --prep"
    return 1
  fi

  loginfo "Préparation de la daily par IA ($provider)..."

  # Composer le contexte
  local ctx_file
  ctx_file="$(make_temp)"

  {
    printf '# Contexte pour préparer la daily du %s\n\n' "$d"

    # Daily d'hier
    local yd
    yd="$(yesterday)"
    if [ -n "$yd" ] && [ -f "${IPCRA_ROOT}/Journal/Daily/$(date -d "$yd" +%Y 2>/dev/null || date +%Y)/${yd}.md" ]; then
      printf '## Daily hier (%s)\n' "$yd"
      cat "${IPCRA_ROOT}/Journal/Daily/$(date -d "$yd" +%Y 2>/dev/null || date +%Y)/${yd}.md"
      printf '\n\n'
    fi

    # Weekly courante
    local w_file="${IPCRA_ROOT}/Journal/Weekly/$(date +%G)/$(iso_week).md"
    if [ -f "$w_file" ]; then
      printf '## Weekly courante (%s)\n' "$(iso_week)"
      cat "$w_file"
      printf '\n\n'
    fi

    # Waiting-for
    if [ -f "${IPCRA_ROOT}/Inbox/waiting-for.md" ]; then
      printf '## Waiting-for\n'
      cat "${IPCRA_ROOT}/Inbox/waiting-for.md"
      printf '\n\n'
    fi

    # Phase active
    if [ -f "${IPCRA_ROOT}/Phases/index.md" ]; then
      printf '## Phases actives\n'
      cat "${IPCRA_ROOT}/Phases/index.md"
      printf '\n\n'
    fi

    # Instructions
    [ -f "${IPCRA_ROOT}/.ipcra/instructions.md" ] && cat "${IPCRA_ROOT}/.ipcra/instructions.md"
  } > "$ctx_file"

  local prep_prompt="Prépare ma daily du ${d}. Lis le contexte fourni.
Génère un brouillon structuré avec :
- Les tâches non terminées d'hier (reportées)
- Les priorités de la phase active
- Les waiting-for qui arrivent à échéance
- 3 priorités suggérées pour aujourd'hui
Format : utilise le template standard daily (## Top 3, ## Agenda, ## Next actions par casquette)."

  # Lancer le provider
  case "$provider" in
    claude)
      claude --append-system-prompt-file "$ctx_file" "$prep_prompt"
      ;;
    gemini)
      if gemini --context "$ctx_file" "$prep_prompt" 2>/dev/null; then
        :
      else
        logwarn "Gemini: --context non supporté, lancement sans contexte fichier"
        gemini "$prep_prompt"
      fi
      ;;
    codex)
      codex "$prep_prompt"
      ;;
  esac
}

# ── Weekly ────────────────────────────────────────────────────
cmd_weekly() {
  need_root
  local y w rel abs
  y="$(date +%G)"; w="$(iso_week)"
  rel="Journal/Weekly/${y}/${w}.md"
  abs="${IPCRA_ROOT}/${rel}"
  mkdir -p "${IPCRA_ROOT}/Journal/Weekly/${y}"
  if [ ! -f "$abs" ]; then
    if [ -f "${IPCRA_ROOT}/Journal/template_weekly.md" ]; then
      sed "s/{{iso_week}}/${w}/g" "${IPCRA_ROOT}/Journal/template_weekly.md" > "$abs"
    else
      printf '# Weekly — %s\n\n## Objectifs semaine\n- [ ] \n- [ ] \n- [ ] \n' "$w" > "$abs"
    fi
    loginfo "Weekly créée: $rel"
  fi
  open_note "$abs" "$rel"
}

# ── Monthly ───────────────────────────────────────────────────
cmd_monthly() {
  need_root
  local y m rel abs
  y="$(year)"; m="$(date +%Y-%m)"
  rel="Journal/Monthly/${y}/${m}.md"
  abs="${IPCRA_ROOT}/${rel}"
  mkdir -p "${IPCRA_ROOT}/Journal/Monthly/${y}"
  if [ ! -f "$abs" ]; then
    if [ -f "${IPCRA_ROOT}/Journal/template_monthly.md" ]; then
      sed "s/{{month}}/${m}/g" "${IPCRA_ROOT}/Journal/template_monthly.md" > "$abs"
    else
      printf '# Revue mensuelle — %s\n\n## Bilan objectifs\n\n## Ajustements\n\n## Mois prochain\n' "$m" > "$abs"
    fi
    loginfo "Monthly créée: $rel"
  fi
  open_note "$abs" "$rel"
}

# ── Close session ─────────────────────────────────────────────
cmd_close() {
  need_root
  local domain="${1:-}"
  local provider
  provider="$(get_default_provider)"
  local domain_hint=""
  [ -n "$domain" ] && domain_hint=" Utiliser spécifiquement le domaine: ${domain}."
  local close_prompt="PROCÉDURE CLOSE SESSION:
1) Lire: Journal/Daily (aujourd'hui), Journal/Weekly, Phases/index.md, memory/, .ipcra/context.md.
2) Résumer ce qui a été fait/décidé.
3) Identifier le domaine principal (devops, electronique, musique, maison, sante, finance).${domain_hint}
4) Écrire une entrée structurée dans memory/<domaine>.md.
5) Mettre à jour .ipcra/context.md section \"Projets en cours\" si nécessaire.
6) Proposer (sans exécuter) les déplacements vers Archives/ pour les projets Terminé."
  launch_with_prompt "$provider" "$close_prompt"
}

# ── Capture ───────────────────────────────────────────────────
cmd_capture() {
  need_root
  local text="${1:-}"
  if [ -z "$text" ]; then
    read -r -p "Note à capturer: " text
    [ -z "$text" ] && { logerr "Texte requis"; return 1; }
  fi
  local ts
  ts=$(date +%Y%m%d%H%M%S)
  local rel="Inbox/capture-${ts}.md"
  local abs="${IPCRA_ROOT}/${rel}"
  printf '# Capture %s\n\n%s\n' "$(date +'%Y-%m-%d %H:%M')" "$text" > "$abs"
  loginfo "Note capturée dans $rel"
}

# ── Zettelkasten ──────────────────────────────────────────────
cmd_zettel() {
  need_root
  local title="${1:-}"
  if [ -z "$title" ]; then
    read -r -p "Titre de la note: " title
    [ -z "$title" ] && { logerr "Titre requis"; return 1; }
  fi

  local id
  id="$(date +%Y%m%d%H%M)"
  local slug
  slug=$(printf '%s' "$title" | iconv -t ASCII//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  [ -z "$slug" ] && slug="note"
  local filename="${id}-${slug}.md"
  local rel="Zettelkasten/_inbox/${filename}"
  local abs="${IPCRA_ROOT}/${rel}"

  if [ -f "${IPCRA_ROOT}/Zettelkasten/_template.md" ]; then
    sed -e "s/{{id}}/${id}/g" \
        -e "s/{{date}}/$(today)/g" \
        -e "s/{{titre}}/${title}/g" \
        "${IPCRA_ROOT}/Zettelkasten/_template.md" > "$abs"
  else
    cat > "$abs" <<ZEOF
---
id: ${id}
tags: []
liens: []
source:
created: $(today)
---
# ${title}

<!-- Une seule idée, formulée dans tes mots -->


## Liens
- [[]] — raison du lien

## Source
-
ZEOF
  fi

  loginfo "Zettel créée: $rel"
  open_note "$abs" "$rel"
}

# ── MOC (Map of Content) ─────────────────────────────────────
cmd_moc() {
  need_root
  local theme="${1:-}"
  if [ -z "$theme" ]; then
    read -r -p "Thème du MOC: " theme
    [ -z "$theme" ] && { logerr "Thème requis"; return 1; }
  fi

  local slug
  slug=$(printf '%s' "$theme" | iconv -t ASCII//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  [ -z "$slug" ] && slug="theme"
  local filename="MOC-${slug}.md"
  local rel="Zettelkasten/MOC/${filename}"
  local abs="${IPCRA_ROOT}/${rel}"

  if [ ! -f "$abs" ]; then
    cat > "$abs" <<MEOF
# MOC — ${theme}

## Notes liées
<!-- Lister les notes [[permanents/YYYYMMDDHHMM-slug]] reliées à ce thème -->

## Sous-thèmes
-

## Résumé
<!-- Synthèse de ce que tu sais sur ce thème -->

MEOF
    loginfo "MOC créé: $rel"
  fi
  open_note "$abs" "$rel"
}

# ── Consolidation CDE ─────────────────────────────────────────
cmd_consolidate() {
  if [ ! -d ".ipcra-project/local-notes" ]; then
    logerr "Dossier .ipcra-project/local-notes introuvable."
    logwarn "Cette commande s'exécute à la racine d'un projet local (Architecture CDE)."
    return 1
  fi

  local domain="${1:-}"
  if [ -z "$domain" ]; then
    read -r -p "Domaine global cible (ex: devops, electronique) : " domain
    [ -z "$domain" ] && { logerr "Domaine requis"; return 1; }
  fi

  local memory_dir=".ipcra-memory/memory"
  local memory_file="${memory_dir}/${domain}.md"
  
  if [ ! -d "$memory_dir" ]; then
    logerr "Lien global .ipcra-memory introuvable ou brisé."
    return 1
  fi

  local local_content=""
  local has_notes=false
  for f in .ipcra-project/local-notes/*.md; do
    [ -e "$f" ] || continue
    [ "$(basename "$f")" = "README.md" ] && continue
    has_notes=true
    local_content+=$'\n\n--- Source: '"$(basename "$f")"$' ---\n'
    local_content+=$(cat "$f" 2>/dev/null)
  done

  if [ "$has_notes" = false ] || [ -z "$(echo "$local_content" | tr -d '[:space:]-')" ]; then
    logwarn "Aucun contenu Markdown local trouvé à consolider (hors README.md)."
    return 0
  fi

  loginfo "Génération de la synthèse IA (cela prend quelques secondes)..."
  local prompt
  prompt=$(cat <<EOF
Voici les notes brutes locales d'un projet. Joue le rôle d'un architecte technique implacable.
Extrais UNIQUEMENT les décisions durables, les leçons apprises, les erreurs résolues et les patterns réutilisables.
Ignore totalement les TODOs, les notes jetables et les logs sans intérêt.
Rédige une entrée concise et structurée (en Markdown) pour la base de connaissances globale du domaine "${domain}".
Commence obligatoirement par un titre H2 : "## $(today) - Synthèse de projet" (invente le nom du projet).
Voici les notes :
${local_content}
EOF
)

  local provider
  provider=$(get_default_provider)
  local draft=".ipcra-project/draft-consolidation.md"
  
  case "$provider" in
    claude) claude -p "$prompt" > "$draft" 2>/dev/null ;;
    gemini) gemini "$prompt" > "$draft" 2>/dev/null ;;
    codex) codex "$prompt" > "$draft" 2>/dev/null ;;
    *) logerr "Provider $provider non supporté en headless."; return 1 ;;
  esac

  if [ ! -s "$draft" ]; then
    logerr "La génération IA a échoué (réponse vide)."
    return 1
  fi

  loginfo "Brouillon généré."
  local editor="${EDITOR:-nano}"
  "$editor" "$draft"

  section "Validation de la consolidation"
  cat "$draft"
  echo ""
  
  if prompt_yes_no "Ce draft est-il correct ? L'injecter dans la mémoire globale ($domain) ?" "y"; then
    if [ ! -f "$memory_file" ]; then
      echo "# Mémoire — ${domain}" > "$memory_file"
    fi
    echo "" >> "$memory_file"
    cat "$draft" >> "$memory_file"
    loginfo "Injecté avec succès dans $memory_file"
    
    if prompt_yes_no "Vider les notes locales traitées pour ce projet ?" "y"; then
      for f in .ipcra-project/local-notes/*.md; do
        [ -e "$f" ] || continue
        [ "$(basename "$f")" = "README.md" ] && continue
        rm -f "$f"
      done
      echo "# Tâches en cours" > .ipcra-project/local-notes/todo.md
      loginfo "Dossier local-notes/ purgé."
    fi
  else
    logwarn "Injection annulée. Le draft reste disponible dans $draft"
    return 0
  fi
  
  rm -f "$draft" 2>/dev/null || true
}

# ── Health ────────────────────────────────────────────────────
cmd_health() {
  need_root
  printf '%b📊 Health Check — %s%b\n\n' "$BOLD" "$(today)" "$NC"

  # Inbox
  local inbox_count inbox_stale
  inbox_count=$(find Inbox/ -maxdepth 1 -name "*.md" ! -name "waiting*" 2>/dev/null | wc -l)
  inbox_stale=$(find Inbox/ -maxdepth 1 -name "*.md" ! -name "waiting*" -mtime +7 2>/dev/null | wc -l)
  printf '📥 Inbox: %s notes' "$inbox_count"
  if [ "$inbox_stale" -gt 0 ]; then
    printf ' %b(⚠ %s > 7 jours)%b' "$RED" "$inbox_stale" "$NC"
  fi
  printf '\n'

  # Waiting-for
  if [ -f "Inbox/waiting-for.md" ]; then
    local wf_count
    wf_count=$(grep -c '^|[^-|]' "Inbox/waiting-for.md" 2>/dev/null || echo 0)
    wf_count=$((wf_count > 0 ? wf_count - 1 : 0))  # soustraire l'en-tête
    printf '⏳ Waiting-for: %s items\n' "$wf_count"
  fi

  # Projets actifs
  local proj_count
  proj_count=$(find Projets/ -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
  printf '🚀 Projets: %s\n' "$proj_count"

  # Zettelkasten
  local zk_inbox zk_perm zk_moc zk_inbox_stale
  zk_inbox=$(find Zettelkasten/_inbox/ -name "*.md" 2>/dev/null | wc -l)
  zk_inbox_stale=$(find Zettelkasten/_inbox/ -name "*.md" -mtime +7 2>/dev/null | wc -l)
  zk_perm=$(find Zettelkasten/permanents/ -name "*.md" 2>/dev/null | wc -l)
  zk_moc=$(find Zettelkasten/MOC/ -name "*.md" 2>/dev/null | wc -l)
  printf '🗃️  Zettelkasten: %s inbox ' "$zk_inbox"
  if [ "$zk_inbox_stale" -gt 0 ]; then
    printf '%b(⚠ %s > 7j)%b | ' "$RED" "$zk_inbox_stale" "$NC"
  else
    printf '| '
  fi
  printf '%s permanents | %s MOC\n' "$zk_perm" "$zk_moc"

  # Mémoire
  local mem_count
  mem_count=$(find memory/ -name "*.md" ! -name "index.md" -exec grep -l '^## ' {} \; 2>/dev/null | wc -l)
  printf '🧠 Mémoire: %s domaines avec entrées\n' "$mem_count"

  # Casquettes sans activité
  local stale_hats
  stale_hats=$(find Casquettes/ -name "*.md" -mtime +30 2>/dev/null | wc -l)
  if [ "$stale_hats" -gt 0 ]; then
    printf '%b⚠  Casquettes sans activité > 30j: %s%b\n' "$YELLOW" "$stale_hats" "$NC"
  fi

  # Daily streak
  local streak=0 check_date
  check_date="$(today)"
  while [ -f "Journal/Daily/$(date -d "$check_date" +%Y 2>/dev/null || date +%Y)/${check_date}.md" ]; do
    streak=$((streak + 1))
    check_date=$(python3 -c "import datetime; d=datetime.date.fromisoformat('$check_date'); print((d-datetime.timedelta(days=1)).isoformat())" 2>/dev/null || break)
  done
  printf '📝 Streak daily: %s jours consécutifs\n' "$streak"

  # Dernière activité
  printf '\n%b📝 Modifié récemment (7j)%b\n' "$YELLOW" "$NC"
  find . -name "*.md" -type f -mtime -7 ! -path "*/Archives/*" ! -path "*/.ipcra/*" -print0 2>/dev/null \
    | xargs -0 ls -lt 2>/dev/null | head -5 | awk '{print "  • " $NF}' | sed 's|^\./||' || true
}

# ── Review ────────────────────────────────────────────────────
cmd_review() {
  need_root
  local type="${1:-}"
  local provider="${2:-$(get_default_provider)}"

  case "$type" in
    phase)
      local prompt="REVUE DE PHASE:
1) Lire Phases/index.md
2) Lire les projets actifs dans Projets/
3) Évaluer: la phase actuelle est-elle toujours pertinente?
4) Proposer des ajustements de priorités
5) Identifier ce qui devrait être mis en pause ou accéléré"
      launch_with_prompt "$provider" "$prompt" ;;
    project)
      local prompt="RÉTROSPECTIVE PROJET:
1) Demander quel projet
2) Lire le dossier du projet
3) Évaluer: objectifs atteints? Leçons apprises?
4) Proposer l'archivage si terminé
5) Écrire un résumé dans memory/<domaine>.md"
      launch_with_prompt "$provider" "$prompt" ;;
    quarter)
      local prompt="REVUE TRIMESTRIELLE:
1) Lire Objectifs/, Phases/index, memory/
2) Bilan: quels objectifs atteints? Lesquels abandonnés?
3) Évaluer les phases de vie actuelles
4) Proposer les objectifs du trimestre suivant
5) Revoir Objectifs/someday.md: quelque chose à activer?"
      launch_with_prompt "$provider" "$prompt" ;;
    *)
      logerr "Usage: ipcra review <phase|project|quarter>"
      return 1 ;;
  esac
}

# ── Process ───────────────────────────────────────────────────
cmd_process() {
  need_root
  local proc="${1:-}"
  local provider="${2:-$(get_default_provider)}"
  if [ -z "$proc" ]; then
    open_note "${IPCRA_ROOT}/Process/index.md" "Process/index.md"
    return
  fi
  local p="Process/${proc}.md"
  if [ ! -f "${IPCRA_ROOT}/${p}" ]; then
    if [ -f "${IPCRA_ROOT}/Process/_template_process.md" ]; then
      cp "${IPCRA_ROOT}/Process/_template_process.md" "${IPCRA_ROOT}/${p}"
      local safe_proc
      safe_proc=$(printf '%s' "$proc" | sed 's/[\/&]/\\&/g')
      sed -i "s/\[Nom\]/${safe_proc}/g" "${IPCRA_ROOT}/${p}"
    else
      printf '# Process — %s\n' "$proc" > "${IPCRA_ROOT}/${p}"
    fi
  fi
  
  local agent
  agent=$(grep -A1 "^## Agent IA recommandé" "${IPCRA_ROOT}/${p}" 2>/dev/null \
    | grep -v '^--$' | tail -n 1 | sed 's/^- *//')
  if [ -n "$agent" ] && [[ "$agent" != "(ex"* ]]; then
     printf '%b🤖 Agent recommandé détecté : %s%b\n' "$GREEN" "$agent" "$NC"
    if prompt_yes_no "Lancer l'IA avec cet agent sur ce process ?" "y"; then
      local prompt="Exécute le process défini dans ${p} avec l'expertise de l'agent ${agent}."
      launch_with_prompt "$provider" "$prompt"
      return
    fi
  fi
  
  open_note "${IPCRA_ROOT}/${p}" "$p"
}

# ── Launch AI provider ────────────────────────────────────────
launch_with_prompt() {
  local provider="$1" prompt="${2:-}"

  case "$provider" in
    claude)
      command -v claude &>/dev/null || { logerr "claude introuvable"; exit 1; }
      if [ -n "$prompt" ]; then
        claude --append-system-prompt-file "${IPCRA_ROOT}/CLAUDE.md" "$prompt"
      else
        claude --append-system-prompt-file "${IPCRA_ROOT}/CLAUDE.md"
      fi ;;
    gemini)
      command -v gemini &>/dev/null || { logerr "gemini introuvable"; exit 1; }
      if [ -n "$prompt" ]; then
        gemini "$prompt"
      else
        gemini
      fi ;;
    codex)
      command -v codex &>/dev/null || { logerr "codex introuvable"; exit 1; }
      if [ -n "$prompt" ]; then
        codex "$prompt"
      else
        codex
      fi ;;
    *)
      logerr "Provider inconnu: $provider (claude|gemini|codex)"
      exit 1 ;;
  esac
}

launch_ai() {
  local provider="$1" expert="${2:-}"
  if [ -n "$expert" ]; then
    local prompt="Mode expert: ${expert}. Lis d'abord .ipcra/context.md, Phases/index.md, memory/, la weekly courante et la daily du jour. Puis travaille."
    launch_with_prompt "$provider" "$prompt"
  else
    launch_with_prompt "$provider" ""
  fi
}

# ── Dashboard ─────────────────────────────────────────────────
show_dashboard() {
  need_root
  printf '%b╔═══════════════════════════════════════╗%b\n' "$BLUE" "$NC"
  printf '%b║     🧠 IPCRA v3.1 — CLI               ║%b\n' "$BLUE" "$NC"
  printf '%b╚═══════════════════════════════════════╝%b\n\n' "$BLUE" "$NC"

  local ic pc rc zc
  ic=$(find Inbox/ -maxdepth 1 -name "*.md" ! -name "README*" ! -name "waiting*" ! -name "someday*" 2>/dev/null | wc -l || echo 0)
  pc=$(find Projets/ -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l || echo 0)
  rc=$(find Ressources/ -name "*.md" 2>/dev/null | wc -l || echo 0)
  zc=$(find Zettelkasten/permanents/ -name "*.md" 2>/dev/null | wc -l || echo 0)

  printf '%b📊 État%b\n' "$GREEN" "$NC"
  printf '├─ 📥 Inbox        : %s notes\n' "$ic"
  printf '├─ 🚀 Projets      : %s\n' "$pc"
  printf '├─ 📚 Ressources   : %s docs\n' "$rc"
  printf '└─ 🗃️  Zettelkasten : %s permanents\n\n' "$zc"

  if [ -f "Phases/index.md" ]; then
    printf '%b🎯 Phase active%b\n' "$YELLOW" "$NC"
    grep -E '^\- ' Phases/index.md 2>/dev/null | head -3 || printf '  (aucune)\n'
    printf '\n'
  fi

  printf '%b📝 Modifié récemment (7j)%b\n' "$YELLOW" "$NC"
  find . -name "*.md" -type f -mtime -7 ! -path "*/Archives/*" ! -path "*/.ipcra/*" -print0 2>/dev/null \
    | xargs -0 ls -lt 2>/dev/null | head -5 | awk '{print "  • " $NF}' | sed 's|^\./||' || true
  printf '\n'
}

# ── Menu interactif ───────────────────────────────────────────
cmd_menu() {
  show_dashboard
  PS3="Choix> "
  select choice in \
    "Daily" \
    "Daily --prep (IA)" \
    "Weekly (ISO)" \
    "Monthly" \
    "Zettelkasten (nouvelle note)" \
    "MOC (Map of Content)" \
    "Capture rapide (Inbox)" \
    "Consolider notes locales (Projet)" \
    "Lancer session IA" \
    "Lancer session IA (mode expert)" \
    "Close session" \
    "Health check" \
    "Sync providers" \
    "Lister providers" \
    "Ouvrir Phases/index" \
    "Ouvrir Process/index" \
    "Quitter"; do
    case "$REPLY" in
      1)  cmd_daily; break ;;
      2)  cmd_daily "--prep"; break ;;
      3)  cmd_weekly; break ;;
      4)  cmd_monthly; break ;;
      5)  read -r -p "Titre: " _t; cmd_zettel "$_t"; break ;;
      6)  read -r -p "Thème: " _t; cmd_moc "$_t"; break ;;
      7)  read -r -p "Note: " _n; cmd_capture "$_n"; break ;;
      8)  cmd_consolidate; break ;;
      9)  launch_ai "$(get_default_provider)"; break ;;
      10) read -r -p "Mode expert (DevOps, Electronique, Musique…): " m
          launch_ai "$(get_default_provider)" "$m"; break ;;
      11) cmd_close "${extra:-}"; break ;;
      12) cmd_health; break ;;
      13) sync_providers; break ;;
      14) list_providers; break ;;
      15) open_note "${IPCRA_ROOT}/Phases/index.md" "Phases/index.md"; break ;;
      16) open_note "${IPCRA_ROOT}/Process/index.md" "Process/index.md"; break ;;
      17) exit 0 ;;
      *)  echo "Choix invalide." ;;
    esac
  done
}

# ── Usage ─────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: ipcra [COMMANDE] [OPTIONS]

Commandes:
  (rien)|menu              Menu interactif
  daily                    Créer/ouvrir la daily du jour
  daily --prep             Daily pré-rédigée par l'IA
  weekly                   Créer/ouvrir la weekly ISO en cours
  monthly                  Créer/ouvrir la revue mensuelle
  capture "texte"          Capturer une idée rapide dans Inbox
  close                    Clôturer la session (maj mémoire domaine)
  sync                     Régénérer CLAUDE.md, GEMINI.md, AGENTS.md, Kilo
  list                     Lister les providers disponibles
  zettel [titre]           Créer une note atomique Zettelkasten
  moc [thème]              Créer/ouvrir une Map of Content
  health                   Diagnostic du système IPCRA
  review <type>            Revue adaptative (phase|project|quarter)
  phase|phases             Ouvrir Phases/index.md
  process [nom]            Ouvrir un process ou l'index
  <texte_libre>            Mode expert (ex: ipcra DevOps)

Options:
  -p, --provider PROVIDER  Choisir le provider (claude|gemini|codex)
  -h, --help               Aide
  -V, --version            Version

Exemples:
  ipcra                    # menu
  ipcra daily              # daily note
  ipcra daily --prep       # daily pré-rédigée par l'IA
  ipcra zettel "Idée X"   # nouvelle note Zettelkasten
  ipcra moc "DevOps"       # Map of Content DevOps
  ipcra health             # diagnostic système
  ipcra review phase       # revue de phase
  ipcra close              # clôture session (mémoire globale -> IPCRA_ROOT)
  ipcra consolidate        # consolide notes du projet CDE -> mémoire globale
  ipcra DevOps             # mode expert DevOps
  ipcra -p gemini Musique  # Gemini en mode expert musique
  ipcra sync               # régénérer fichiers provider
EOF
}

# ── Main ──────────────────────────────────────────────────────
main() {
  local provider="" cmd="" extra=""

  while [ $# -gt 0 ]; do
    case "$1" in
      -p|--provider) provider="${2:-}"; shift ;;
      -h|--help)     usage; exit 0 ;;
      -V|--version)  printf 'IPCRA Launcher v%s\n' "$VERSION"; exit 0 ;;
      -*)            # Options attachées à une commande (ex: --prep)
        if [ -n "$cmd" ]; then extra="$1"
        else logerr "Option inconnue: $1"; usage; exit 1; fi ;;
      *)
        if [ -z "$cmd" ]; then cmd="$1"
        else extra="$1"; fi ;;
    esac
    shift
  done

  [ -z "$provider" ] && provider="$(get_default_provider)"

  case "${cmd:-menu}" in
    menu)            cmd_menu ;;
    daily)           cmd_daily "$extra" ;;
    weekly)          cmd_weekly ;;
    monthly)         cmd_monthly ;;
    capture)         cmd_capture "${extra:-}" ;;
    close)           cmd_close "${extra:-}" ;;
    consolidate)     cmd_consolidate "${extra:-}" ;;
    sync)            sync_providers ;;
    list)            list_providers ;;
    zettel)          cmd_zettel "$extra" ;;
    moc)             cmd_moc "$extra" ;;
    health)          cmd_health ;;
    review)          cmd_review "$extra" "$provider" ;;
    phase|phases)    need_root; open_note "${IPCRA_ROOT}/Phases/index.md" "Phases/index.md" ;;
    process|processes) cmd_process "${extra:-}" "$provider" ;;
    *)
      # Texte libre = mode expert
      need_root; show_dashboard
      printf '%b🤖 Provider: %s | 🎯 Expert: %s%b\n\n' "$BOLD" "$provider" "$cmd" "$NC"
      launch_ai "$provider" "$cmd" ;;
  esac
}

main "$@"
EOF_LAUNCHER

  chmod +x "$HOME/bin/ipcra"
  loginfo "✓ Launcher ipcra installé dans ~/bin"
  
  for p in claude gemini codex; do
    printf '#!/usr/bin/env bash\nexec "$HOME/bin/ipcra" -p %s "$@"\n' "$p" \
      > "$HOME/bin/ipcra-${p}"
    chmod +x "$HOME/bin/ipcra-${p}"
  done
  loginfo "✓ Raccourcis ipcra-claude, ipcra-gemini, ipcra-codex installés dans ~/bin"

  cat << 'EOF_CONCEPTION' > "$HOME/bin/ipcra-init-conception"
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

- **Effort estimé** : 
- **Tests requis** : 

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

# 6. Liens vers le Cerveau Global + raccourcis ciblés
# On crée un lien symbolique vers l'IPCRA global pour que l'IA puisse lire la mémoire,
# les archives et l'historique même en travaillant dans un repo local.
if [ -d "$IPCRA_ROOT" ]; then
    ln -sfn "$IPCRA_ROOT" ".ipcra-memory"
    echo "✅ Créé : Lien symbolique .ipcra-memory -> \$IPCRA_ROOT"

    [ -d "$IPCRA_ROOT/memory" ] && ln -sfn "../.ipcra-memory/memory" "$LOCAL_IPCRA_DIR/memory-global"
    [ -d "$IPCRA_ROOT/Archives" ] && ln -sfn "../.ipcra-memory/Archives" "$LOCAL_IPCRA_DIR/archives-global"
    [ -d "$IPCRA_ROOT/Journal" ] && ln -sfn "../.ipcra-memory/Journal" "$LOCAL_IPCRA_DIR/journal-global"
fi

# 7. Guide de lecture pour l'IA (priorité local + global)
cat << 'EOF' > "$CONCEPTION_DIR/03_IPCRA_CONTEXT_LINKS.md"
# IPCRA Context Links (Local + Global)

## Priorité de lecture recommandée
1. Contexte local projet : \`docs/conception/00_VISION.md\`, \`01_AI_RULES.md\`, \`02_ARCHITECTURE.md\`
2. Notes projet locales : \`.ipcra-project/local-notes/\` (contexte temporaire de ce repo)
3. Mémoire globale : \`.ipcra-memory/memory/\` (source de vérité durable)
4. Historique global : \`.ipcra-memory/Archives/\` et \`.ipcra-memory/Journal/\`

## Règle d'or
- Le global (\`.ipcra-memory/*\`) reste la source de vérité durable.
- Le local (\`.ipcra-project/local-notes/\`) sert au contexte court terme du projet.
- Après consolidation, remonter les décisions durables vers la mémoire globale.
EOF

echo "✅ Créé : $CONCEPTION_DIR/03_IPCRA_CONTEXT_LINKS.md"

cat << 'EOF' > "$LOCAL_NOTES_DIR/README.md"
# Local Notes (Projet)

Ce dossier est volontairement **minimal** pour éviter de dupliquer la hiérarchie IPCRA globale.

## Usage
- Mettre ici le contexte de travail court terme lié au repo courant.
- Conserver la connaissance durable dans \`.ipcra-memory/memory/\` (source de vérité).

## Fichiers suggérés
- \`todo.md\`
- \`decisions-locales.md\`
- \`debug-log.md\`
EOF

echo "✅ Créé : $LOCAL_NOTES_DIR/README.md"

echo "🎉 Squelette documentaire, instructions IA et liens mémoire générés avec succès !"
EOF_CONCEPTION

  chmod +x "$HOME/bin/ipcra-init-conception"
  loginfo "✓ Script ipcra-init-conception installé dans ~/bin"

  if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    loginfo "Ajouté ~/bin au PATH dans ~/.bashrc. Redémarrez le terminal en tapant 'bash'."
  fi
fi
