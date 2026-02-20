#!/usr/bin/env bash
set -euo pipefail

# Exporte les changements locaux pour intégration GitHub sans push direct.
# Usage:
#   bash deliverables/export_workspace_changes.sh [BASE_REF] [OUT_DIR]
# Ex:
#   bash deliverables/export_workspace_changes.sh ec3cfca deliverables/out

BASE_REF="${1:-$(git rev-parse HEAD~1)}"
OUT_DIR="${2:-deliverables/out}"

mkdir -p "$OUT_DIR"
BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
HEAD_SHA="$(git rev-parse --short HEAD)"
RANGE="${BASE_REF}..HEAD"

PATCH_FILE="$OUT_DIR/${BRANCH_NAME//\//-}-${HEAD_SHA}.patch"
BUNDLE_FILE="$OUT_DIR/${BRANCH_NAME//\//-}-${HEAD_SHA}.bundle"
META_FILE="$OUT_DIR/README_EXPORT.md"

# Patch lisible/importable
 git diff --binary "$RANGE" > "$PATCH_FILE"

# Bundle git portable (cherry-pick possible)
 git bundle create "$BUNDLE_FILE" "$BRANCH_NAME" "$BASE_REF"

cat > "$META_FILE" <<META
# Export workspace -> GitHub

## Fichiers générés
- Patch: $PATCH_FILE
- Bundle: $BUNDLE_FILE

## Métadonnées
- Branche source: $BRANCH_NAME
- Commit HEAD: $(git rev-parse HEAD)
- Base: $BASE_REF
- Range: $RANGE

## Intégration GitHub (sans push direct depuis ce workspace)
### Option A — appliquer le patch dans un autre clone connecté à GitHub
\`\`\`bash
git checkout -b "$BRANCH_NAME"
git apply "$PATCH_FILE"
git add -A
git commit -m "Import patch from workspace ($HEAD_SHA)"
git push -u origin "$BRANCH_NAME"
\`\`\`

### Option B — importer le bundle
\`\`\`bash
git clone <URL_DU_REPO> repo-import
cd repo-import
git fetch "$BUNDLE_FILE" "$BRANCH_NAME:$BRANCH_NAME"
git checkout "$BRANCH_NAME"
git push -u origin "$BRANCH_NAME"
\`\`\`
META

echo "Export terminé:"
echo "- $PATCH_FILE"
echo "- $BUNDLE_FILE"
echo "- $META_FILE"
