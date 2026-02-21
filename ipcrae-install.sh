#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# IPCRAE Étendu v3 — Installateur interactif multi-provider
# Phases/Process/Daily/Weekly/Monthly + Claude/Gemini/Codex/Kilo
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_VERSION="3.3.0"
METHOD_VERSION="3.3"
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
AUTO_YES=false
DRY_RUN=false
IPCRAE_ROOT=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

execute() {
  if [ "$DRY_RUN" = true ]; then
    loginfo "[DRY-RUN] $*"
  else
    "$@"
  fi
}

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
  local f="$1"
  local c="${2-}"
  if [ "$DRY_RUN" = true ]; then
    loginfo "[DRY-RUN] write_safe $f"
    [ -t 0 ] || cat >/dev/null
    return 0
  fi
  local tmp
  mkdir -p "$(dirname "$f")"
  tmp="$(mktemp "${f}.tmp.XXXXXX")"
  if [ "$#" -ge 2 ]; then
    printf '%s\n' "$c" > "$tmp"
  elif [ -t 0 ]; then
    logerr "write_safe: contenu manquant pour '$f' (utiliser un 2e argument ou un heredoc)"
    rm -f "$tmp"
    return 1
  else
    cat > "$tmp"
  fi
  backup_if_exists "$f"
  mv "$tmp" "$f"
}

usage() {
  cat <<EOF
IPCRAE v3 — Installateur multi-provider
Usage: $(basename "$0") [OPTIONS] [CHEMIN]
  -y, --yes       Mode non-interactif
  -d, --dry-run   Simulation, afficher les actions sans modifier le système
  -h, --help      Aide
  -V, --version   Version
EOF
}

cleanup() { local e=$?; if [ $e -ne 0 ]; then logerr "Erreur (code $e). Installation incomplète."; fi; }
trap cleanup EXIT

# ── Parsing ───────────────────────────────────────────────────────────────
while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) AUTO_YES=true;;
    -d|--dry-run) DRY_RUN=true; AUTO_YES=true;;
    -h|--help) usage; exit 0;;
    -V|--version) echo "IPCRAE Install script v$SCRIPT_VERSION (method v$METHOD_VERSION)"; exit 0;;
    -*) logerr "Option inconnue: $1"; usage; exit 1;;
    *)
      if [ -n "$IPCRAE_ROOT" ]; then
        logerr "Un seul chemin cible est autorisé. Reçu en trop: $1"
        usage
        exit 1
      fi
      IPCRAE_ROOT="$1"
      ;;
  esac; shift
done

if [ -z "$IPCRAE_ROOT" ]; then
  local_default="$HOME/IPCRAE"
  if [ "$AUTO_YES" = true ]; then IPCRAE_ROOT="$local_default"
  else printf 'Dossier racine IPCRAE:\n'; read -r -p "→ [$local_default] " IPCRAE_ROOT
    IPCRAE_ROOT=${IPCRAE_ROOT:-$local_default}; fi
fi

IPCRAE_ROOT="$(normalize_root "$IPCRAE_ROOT")"

case "$IPCRAE_ROOT" in
  ""|"/")
    logerr "Chemin cible invalide: '$IPCRAE_ROOT'"
    exit 1
    ;;
esac

printf '%b╔═══════════════════════════════════════════╗%b\n' "$BLUE" "$NC"
printf '%b║  IPCRAE Étendu v3 — Install multi-provider ║%b\n' "$BLUE" "$NC"
printf '%b╚═══════════════════════════════════════════╝%b\n\n' "$BLUE" "$NC"
loginfo "Cible: $IPCRAE_ROOT"

[ -d "$IPCRAE_ROOT" ] && { logwarn "Le dossier existe."; prompt_yes_no "Continuer ?" "y" || exit 1; }
if [ "$DRY_RUN" = true ]; then
  loginfo "[DRY-RUN] mkdir -p $IPCRAE_ROOT && cd $IPCRAE_ROOT"
else
  mkdir -p "$IPCRAE_ROOT"
  cd "$IPCRAE_ROOT" || exit 1
fi

if [ "$DRY_RUN" = true ] || [ ! -d ".git" ]; then
  if prompt_yes_no "Initialiser un dépôt Git dans $IPCRAE_ROOT ?" "y"; then
    require_cmd git
    execute git init -b main
    write_safe ".gitignore" << 'GITEOF'
*.bak-*
*.log
*.tmp
.ipcrae/config.yaml
node_modules/
GITEOF
    git_remote=""
    if ! [ "$AUTO_YES" = true ]; then
      read -r -p "URL du remote Git (vide pour ignorer) : " git_remote
    fi

    if [ -n "$git_remote" ]; then
      execute git remote add origin "$git_remote"
      if prompt_yes_no "Pousser (push) la structure initiale vers $git_remote ?" "y"; then
        execute git add .
        execute git commit -m "chore: initial IPCRAE vault structure" || true
        execute git push -u origin main || logwarn "Échec du push initial."
      fi
    else
      execute git add .gitignore
    fi
  fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# 1) ARBORESCENCE
# ═══════════════════════════════════════════════════════════════════════════
section "Arborescence"
execute mkdir -p Inbox Projets Casquettes Ressources Archives Agents Scripts Process Phases Objectifs .ipcrae
execute mkdir -p Journal/{Daily,Weekly,Monthly}
execute mkdir -p Ressources/Tech/{DevOps,Linux,Docker,NodeJS,SvelteKit,Embedded,Healthcare-IT,Security,Database}
execute mkdir -p Ressources/Electronique/{ESP32,Arduino,Circuits,IoT,Datasheets}
execute mkdir -p Ressources/Musique/{Production,Synthese,Hardware,Plugins}
execute mkdir -p Ressources/Maison/{Domotique,Renovation,Energie,Jardinage}
execute mkdir -p Ressources/Sante/{Nutrition,Sport,Sommeil}
execute mkdir -p Ressources/Finance/{Budget,Investissement,Fiscalite}
execute mkdir -p Ressources/Apprentissage/{Methodes,Cours,Certifications}
execute mkdir -p Ressources/Autres .kilocode/rules
# v3.2 : Zettelkasten + memory par domaine + Knowledge + cache tags
execute mkdir -p Zettelkasten/{_inbox,permanents,MOC}
execute mkdir -p Knowledge/{howto,runbooks,patterns,MOC} memory .ipcrae/{prompts,cache}
loginfo "Arborescence créée."

# ═══════════════════════════════════════════════════════════════════════════
# 2) FICHIERS SOURCE (.ipcrae/)
# ═══════════════════════════════════════════════════════════════════════════
section "Fichiers source IPCRAE"
if prompt_yes_no "Écrire context.md, instructions.md, config.yaml ?" "y"; then

  execute cp "$SCRIPT_DIR/templates/prompts/global_context.md" ".ipcrae/context.md"
  execute cp "$SCRIPT_DIR/templates/prompts/global_instructions.md" ".ipcrae/instructions.md"
  loginfo "Context et instructions copiés."

write_safe ".ipcrae/config.yaml" <<EOF_CONF
# IPCRAE v3 Configuration
# Généré le $(date +%Y-%m-%d)

ipcrae_root: "${IPCRAE_ROOT}"
script_version: "${SCRIPT_VERSION}"
method_version: "${METHOD_VERSION}"
default_provider: claude
auto_git_sync: true

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

  execute cp "$SCRIPT_DIR/templates/prompts/template_daily.md" "Journal/"
  execute cp "$SCRIPT_DIR/templates/prompts/template_weekly.md" "Journal/"
  execute cp "$SCRIPT_DIR/templates/prompts/template_monthly.md" "Journal/"
  execute cp "$SCRIPT_DIR/templates/prompts/template_phase.md" "Phases/_template_phase.md"
  execute cp "$SCRIPT_DIR/templates/prompts/template_process.md" "Process/_template_process.md"
  execute cp "$SCRIPT_DIR/templates/prompts/template_projet.md" "Projets/_template_projet.md"
  execute cp "$SCRIPT_DIR/templates/prompts/template_casquette.md" "Casquettes/_template_casquette.md"
fi

# ═══════════════════════════════════════════════════════════════════════════
# 4) AGENTS ENRICHIS
# ═══════════════════════════════════════════════════════════════════════════
section "Agents spécialisés"
if prompt_yes_no "Installer agents enrichis ?" "y"; then

  for a in devops electronique musique maison sante finance; do
    execute cp "$SCRIPT_DIR/templates/prompts/agent_${a}.md" "Agents/agent_${a}.md"
  done
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

[ ! -f "Knowledge/MOC/index.md" ] && write_safe "Knowledge/MOC/index.md" '# Knowledge — MOC Index

## Convention tags (source de vérité)
- Les tags sont définis dans le frontmatter YAML des notes Markdown.
- Tags normalisés: minuscules, tirets, sans espaces.
- Provenance projet via `project:` (et optionnellement `project:<slug>` dans `tags`).

## Tags principaux
- `devops` → [[Knowledge/howto/]]
- `observability` → [[Knowledge/patterns/]]
- `project:*` → [[Projets/index]]

## Top notes par domaine
- DevOps: (à compléter)
- Produit: (à compléter)
'

[ ! -f "Knowledge/_template_knowledge.md" ] && write_safe "Knowledge/_template_knowledge.md" '---
type: knowledge
tags: [example-tag]
project: mon-projet
domain: devops
status: draft
sources:
  - path: docs/conception/02_ARCHITECTURE.md
created: 2026-02-21
updated: 2026-02-21
---

# Titre

## Contexte

## Procédure / Décision

## Vérification
'

[ ! -f ".ipcrae/cache/tag-index.json" ] && write_safe ".ipcrae/cache/tag-index.json" '{
  "generated_at": "",
  "version": "1",
  "tags": {}
}'

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

write_safe "index.md" '# 🧠 IPCRAE v3.2 — Dashboard

## Navigation
| Fichier | Rôle |
|---------|------|
| [[Phases/index]] | Phases de vie actives (priorités) |
| [[Process/index]] | Procédures récurrentes |
| [[Objectifs/someday]] | Someday/Maybe |
| [[Inbox/waiting-for]] | En attente |
| [[memory/index]] | Mémoire IA par domaine |
| [[Zettelkasten/MOC/index]] | Zettelkasten — Maps of Content |
| [[Knowledge/MOC/index]] | Connaissance opérationnelle réutilisable |

## Commandes CLI
```
ipcrae               # menu interactif
ipcrae daily         # daily note
ipcrae daily --prep  # daily pré-rédigée par l'\''IA
ipcrae weekly        # weekly ISO
ipcrae monthly       # revue mensuelle
ipcrae start --project <slug> --phase <phase> # initialise le contexte
ipcrae work "objectif" # lance agent avec contexte minimisé
ipcrae close <domaine> --project <slug> # consolidation dynamique
ipcrae sync          # régénère CLAUDE.md, GEMINI.md, AGENTS.md, Kilo
ipcrae zettel "titre" # créer note atomique Zettelkasten
ipcrae moc "thème"   # créer/ouvrir Map of Content
ipcrae index          # reconstruit le cache tags (.ipcrae/cache/tag-index.json)
ipcrae tag devops     # liste les notes taggées
ipcrae health        # diagnostic système
ipcrae DevOps        # mode expert
ipcrae -p gemini     # choisir le provider
```'

# ═══════════════════════════════════════════════════════════════════════════
# 6) FICHIERS PROVIDER + IGNORE
# ═══════════════════════════════════════════════════════════════════════════
section "Fichiers provider"
if prompt_yes_no "Générer CLAUDE.md, GEMINI.md, AGENTS.md, Kilo ?" "y"; then
  body="$(cat .ipcrae/context.md; printf '\n\n---\n\n'; cat .ipcrae/instructions.md)"
  for t in "CLAUDE.md:Claude" "GEMINI.md:Gemini" "AGENTS.md:Codex"; do
    f="${t%%:*}"; n="${t##*:}"
    printf '# Instructions pour %s — IPCRAE v%s\n# ⚠ GÉNÉRÉ — éditer .ipcrae/context.md + instructions.md\n# Régénérer : ipcrae sync\n\n%s\n' "$n" "$METHOD_VERSION" "$body" > "$f"
    loginfo "$f"
  done
  mkdir -p .kilocode/rules
  printf '# Instructions IPCRAE pour Kilo Code\n# ⚠ GÉNÉRÉ\n\n%s\n' "$body" > .kilocode/rules/ipcrae.md
  loginfo ".kilocode/rules/ipcrae.md"
fi

section "Fichiers ignore"
if prompt_yes_no "Créer .claudeignore et .geminiignore ?" "y"; then
  ignore='Archives/
Scripts/
*.log
*.tmp
node_modules/
.git/
.ipcrae/'
  write_safe ".claudeignore" "$ignore"
  write_safe ".geminiignore" "$ignore"
fi

# ═══════════════════════════════════════════════════════════════════════════
# 7) INSTALLATION DES LANCEURS (IPCRAE + IPCRAE-ADDPROJECT)
# ═══════════════════════════════════════════════════════════════════════════
section "Installation des scripts CLI dans le PATH"

if prompt_yes_no "Installer ~/bin/ipcrae et ~/bin/ipcrae-addProject ?" "y"; then
  mkdir -p "$HOME/bin"

  if [ -f "$SCRIPT_DIR/templates/ipcrae-launcher.sh" ]; then
    cp "$SCRIPT_DIR/templates/ipcrae-launcher.sh" "$HOME/bin/ipcrae"
    chmod +x "$HOME/bin/ipcrae"
    sed -i "s|IPCRAE_ROOT=\"\${IPCRAE_ROOT:-\${HOME}/IPCRAE}\"|IPCRAE_ROOT=\"${IPCRAE_ROOT}\"|" "$HOME/bin/ipcrae"
  else
    logerr "Template templates/ipcrae-launcher.sh introuvable !"
    exit 1
  fi
  
  if [ -f "$SCRIPT_DIR/templates/ipcrae-addProject.sh" ]; then
    cp "$SCRIPT_DIR/templates/ipcrae-addProject.sh" "$HOME/bin/ipcrae-addProject"
  else
    logerr "Template templates/ipcrae-addProject.sh introuvable !"
    exit 1
  fi

  if [ -f "$SCRIPT_DIR/templates/ipcrae-migrate-safe.sh" ]; then
    cp "$SCRIPT_DIR/templates/ipcrae-migrate-safe.sh" "$HOME/bin/ipcrae-migrate-safe"
    chmod +x "$HOME/bin/ipcrae-migrate-safe"
  else
    logwarn "Template templates/ipcrae-migrate-safe.sh introuvable (migration safe non installée)."
  fi
  
  if [ -d "$SCRIPT_DIR/templates/prompts" ]; then
    mkdir -p "$IPCRAE_ROOT/.ipcrae/prompts/"
    cp "$SCRIPT_DIR"/templates/prompts/*.md "$IPCRAE_ROOT/.ipcrae/prompts/"
    loginfo "✓ Prompts IA extraits dans .ipcrae/prompts/"
  else
    logwarn "Dossier templates/prompts introuvable, installation des prompts omise."
  fi

  if [ -d "$SCRIPT_DIR/templates/scripts" ]; then
    mkdir -p "$IPCRAE_ROOT/Scripts" "$HOME/bin"
    cp "$SCRIPT_DIR"/templates/scripts/*.sh "$IPCRAE_ROOT/Scripts/"
    chmod +x "$IPCRAE_ROOT"/Scripts/*.sh

    cp "$SCRIPT_DIR/templates/scripts/ipcrae-tokenpack.sh" "$HOME/bin/ipcrae-tokenpack"
    cp "$SCRIPT_DIR/templates/scripts/ipcrae-agent-bridge.sh" "$HOME/bin/ipcrae-agent-bridge"
    cp "$SCRIPT_DIR/templates/scripts/ipcrae-prompt-optimize.sh" "$HOME/bin/ipcrae-prompt-optimize"
    chmod +x "$HOME/bin/ipcrae-tokenpack" "$HOME/bin/ipcrae-agent-bridge" "$HOME/bin/ipcrae-prompt-optimize"
    loginfo "✓ Scripts token/multi-agent installés (ipcrae-tokenpack, ipcrae-agent-bridge, ipcrae-prompt-optimize)"

    if [ -f "$SCRIPT_DIR/templates/scripts/ipcrae-index.sh" ]; then
      cp "$SCRIPT_DIR/templates/scripts/ipcrae-index.sh" "$HOME/bin/ipcrae-index"
      chmod +x "$HOME/bin/ipcrae-index"
      loginfo "✓ Script optionnel installé: ipcrae-index"
    else
      logwarn "Optionnel non installé: ipcrae-index (template manquant)"
    fi

    if [ -f "$SCRIPT_DIR/templates/scripts/ipcrae-tag.sh" ]; then
      cp "$SCRIPT_DIR/templates/scripts/ipcrae-tag.sh" "$HOME/bin/ipcrae-tag"
      chmod +x "$HOME/bin/ipcrae-tag"
      loginfo "✓ Script optionnel installé: ipcrae-tag"
    else
      logwarn "Optionnel non installé: ipcrae-tag (template manquant)"
    fi

    if [ -f "$SCRIPT_DIR/templates/scripts/ipcrae-uninstall.sh" ]; then
      cp "$SCRIPT_DIR/templates/scripts/ipcrae-uninstall.sh" "$HOME/bin/ipcrae-uninstall"
      chmod +x "$HOME/bin/ipcrae-uninstall"
      loginfo "✓ Script de purge installé: ipcrae-uninstall"
    fi
  else
    logwarn "Dossier templates/scripts introuvable, installation des scripts avancés omise."
  fi

  chmod +x "$HOME/bin/ipcrae-addProject"
  loginfo "✓ Script ipcrae-addProject installé dans ~/bin"

  if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    loginfo "Ajouté ~/bin au PATH dans ~/.bashrc. Redémarrez le terminal en tapant 'bash'."
  fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# 8) CONFIGURATION DU PROVIDER PAR DÉFAUT
# ═══════════════════════════════════════════════════════════════════════════
section "Provider IA par défaut"
if ! [ "$AUTO_YES" = true ]; then
  echo "Quel provider CLI utiliser par défaut (daily, review, expert) ?"
  echo "1) claude (Claude Code - Recommandé pour l'architecture)"
  echo "2) gemini (Google Gemini - Recommandé pour le code/tools)"
  echo "3) codex  (OpenAI)"
  echo "4) kilo   (Kilometer / VS Code)"
  read -r -p "Choix [1-4] (défaut: 1): " prov_choice
  
  default_prov="claude"
  case "$prov_choice" in
    2) default_prov="gemini" ;;
    3) default_prov="codex" ;;
    4) default_prov="kilo" ;;
    *) default_prov="claude" ;;
  esac
else
  default_prov="claude"
fi

if [ "$DRY_RUN" = true ]; then
  loginfo "[DRY-RUN] Mise à jour de default_provider: $default_prov dans .ipcrae/config.yaml"
else
  if grep -q '^default_provider:' ".ipcrae/config.yaml" 2>/dev/null; then
    sed -i "s/^default_provider:.*/default_provider: \"$default_prov\"/" ".ipcrae/config.yaml"
  else
    printf 'default_provider: "%s"\n' "$default_prov" >> ".ipcrae/config.yaml"
  fi
  grep -q '^auto_git_sync:' ".ipcrae/config.yaml" 2>/dev/null || printf 'auto_git_sync: true\n' >> ".ipcrae/config.yaml"
fi
loginfo "Provider par défaut configuré sur : $default_prov"

# ═══════════════════════════════════════════════════════════════════════════
# FIN
# ═══════════════════════════════════════════════════════════════════════════

printf '\n%b✅ Installation terminée avec succès dans : %s%b\n' "$GREEN" "$IPCRAE_ROOT" "$NC"
if [ "$DRY_RUN" = true ]; then
  printf '%b⚠ ATTENTION : Ceci était une DRY-RUN (Simulation). Aucun fichier n a été écrit.%b\n' "$YELLOW" "$NC"
fi
