#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--vault PATH] [--agent NAME] [--project SLUG] [--domain DOMAIN] [--frequency FREQ] [--report PATH]

Exécute un test méthodologique IPCRAE de bout en bout:
  1) install
  2) bootstrap agent
  3) création d'un cerveau opératoire
  4) activation auto-amélioration
  5) baseline audit + auto-audit + ré-audit
  6) génération d'un rapport markdown
USAGE
}

VAULT="/tmp/IPCRAE_CERVEAU_E2E"
AGENT="codex"
PROJECT="ipcrae-methodologie-e2e"
DOMAIN="devops"
FREQUENCY="quotidien"
REPORT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault) VAULT="$2"; shift 2 ;;
    --agent) AGENT="$2"; shift 2 ;;
    --project) PROJECT="$2"; shift 2 ;;
    --domain) DOMAIN="$2"; shift 2 ;;
    --frequency) FREQUENCY="$2"; shift 2 ;;
    --report) REPORT="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Argument inconnu: $1"; usage; exit 1 ;;
  esac
done

TS="$(date +%Y-%m-%d)"
if [[ -z "$REPORT" ]]; then
  REPORT="docs/audit/${TS}_test_methodologie_${AGENT}_auto_install_cerveau_audit.md"
fi

mkdir -p "$(dirname "$REPORT")"

extract_score() {
  local file="$1"
  sed -r 's/\x1B\[[0-9;]*[A-Za-z]//g' "$file" | grep -Eo 'Score Global: [0-9]+/[0-9]+ \([0-9]+%\)' | tail -1 | sed 's/Score Global: //'
}

log_cmd() {
  printf '\n$ %s\n' "$*"
  "$@"
}

printf "[ipcrae-e2e] Vault cible: %s\n" "$VAULT"
rm -rf "$VAULT"

INSTALL_LOG="$(mktemp)"
BOOTSTRAP_LOG="$(mktemp)"
ACTIVATE_LOG="$(mktemp)"
BASELINE_LOG="$(mktemp)"
AUTOAUDIT_LOG="$(mktemp)"
FINAL_LOG="$(mktemp)"
trap 'rm -f "$INSTALL_LOG" "$BOOTSTRAP_LOG" "$ACTIVATE_LOG" "$BASELINE_LOG" "$AUTOAUDIT_LOG" "$FINAL_LOG"' EXIT

bash ipcrae-install.sh -y "$VAULT" | tee "$INSTALL_LOG"
IPCRAE_ROOT="$VAULT" scripts/ipcrae-agent-bootstrap.sh --auto --project "$PROJECT" --domain "$DOMAIN" | tee "$BOOTSTRAP_LOG"

cat > "$VAULT/Knowledge/patterns/cerveau_${AGENT}.md" <<BRAIN
---
title: "Cerveau opératoire ${AGENT}"
tags: [${DOMAIN}, ipcrae, auto-amelioration]
created: ${TS}
---

# Cerveau opératoire ${AGENT}

## Boucle décisionnelle
1. Capturer le besoin brut.
2. Clarifier sortie + contraintes.
3. Exécuter et tracer les preuves.
4. Consolider en mémoire réutilisable.
5. Auditer, corriger, ré-auditer.

## Garde-fous
- Aucune invention de résultat.
- Priorité aux modifications non destructives.
- Validation systématique post-correction.
BRAIN

IPCRAE_ROOT="$VAULT" ~/bin/ipcrae-auto auto-activate --agent "$AGENT" --frequency "$FREQUENCY" | tee "$ACTIVATE_LOG"
IPCRAE_ROOT="$VAULT" ~/bin/ipcrae-audit-check | tee "$BASELINE_LOG"
printf 'n\nn\n' | IPCRAE_ROOT="$VAULT" ~/bin/ipcrae-auto auto-audit --agent "$AGENT" --verbose --force | tee "$AUTOAUDIT_LOG"
IPCRAE_ROOT="$VAULT" ~/bin/ipcrae-audit-check | tee "$FINAL_LOG"

BASELINE_SCORE="$(extract_score "$BASELINE_LOG")"
CYCLE_SCORE="$(extract_score "$AUTOAUDIT_LOG")"
FINAL_SCORE="$(extract_score "$FINAL_LOG")"

cat > "$REPORT" <<EOF_REPORT
# Test appliqué de la méthodologie IPCRAE (${AGENT})

Date: ${TS}  
Contexte: exécution automatisée du scénario "installer IPCRAE + créer cerveau + auto-amélioration + auto-audit".

## 1) Installation IPCRAE sur un vault vierge

Commande:
\`\`\`bash
bash ipcrae-install.sh -y ${VAULT}
\`\`\`

## 2) Bootstrap de session agent

Commande:
\`\`\`bash
IPCRAE_ROOT=${VAULT} scripts/ipcrae-agent-bootstrap.sh --auto --project ${PROJECT} --domain ${DOMAIN}
\`\`\`

## 3) Création du cerveau opératoire

Fichier créé:
- \`Knowledge/patterns/cerveau_${AGENT}.md\`

## 4) Activation auto-amélioration

Commande:
\`\`\`bash
IPCRAE_ROOT=${VAULT} ~/bin/ipcrae-auto auto-activate --agent ${AGENT} --frequency ${FREQUENCY}
\`\`\`

## 5) Auto-audit mesuré

- Baseline: **${BASELINE_SCORE:-N/A}**
- Score en cycle auto-audit: **${CYCLE_SCORE:-N/A}**
- Ré-audit final: **${FINAL_SCORE:-N/A}**

Commandes:
\`\`\`bash
IPCRAE_ROOT=${VAULT} ~/bin/ipcrae-audit-check
IPCRAE_ROOT=${VAULT} ~/bin/ipcrae-auto auto-audit --agent ${AGENT} --verbose --force
IPCRAE_ROOT=${VAULT} ~/bin/ipcrae-audit-check
\`\`\`

## 6) Conclusion

La méthodologie est exécutable de bout en bout avec métriques auditables et reproductibles.
EOF_REPORT

printf "[ipcrae-e2e] Rapport généré: %s\n" "$REPORT"
printf "[ipcrae-e2e] Baseline=%s | Cycle=%s | Final=%s\n" "${BASELINE_SCORE:-N/A}" "${CYCLE_SCORE:-N/A}" "${FINAL_SCORE:-N/A}"
