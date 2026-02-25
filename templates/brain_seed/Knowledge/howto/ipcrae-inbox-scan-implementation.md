---
type: howto
tags: [ipcrae, inbox, scan, implementation, bash]
project: IPCRAE
domain: devops
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Implémentation de la commande `ipcrae inbox scan`

## Contexte

La commande `ipcrae inbox scan` permet de scanner automatiquement l'Inbox IPCRAE (bash pur, < 1 seconde). Si des fichiers sont détectés, un flag est posé pour que le prochain agent les traite.

## Script Implémenté

Le script [`scripts/ipcrae-inbox-scan.sh`](scripts/ipcrae-inbox-scan.sh) a été créé avec les fonctionnalités suivantes:

### Fonctions Principales

#### `scan_folder(folder)`
- Scanne un dossier spécifique de l'Inbox
- Compte les fichiers (en ignorant README.md)
- Liste les fichiers avec leur date de modification
- Retourne le nombre de fichiers détectés

#### `scan_all_folders()`
- Scanne tous les sous-dossiers de l'Inbox
- Compte le total des fichiers
- Affiche un résumé par dossier

#### `generate_pending_report(total_files)`
- Génère le fichier `.ipcrae/auto/inbox-pending.md`
- Contient la liste des fichiers détectés
- Contient des actions suggérées

#### `ensure_auto_dir()`
- Crée le répertoire `.ipcrae/auto/` s'il n'existe pas

#### `ensure_prefs()`
- Crée les préférences d'agent `.ipcrae/auto/inbox-agent-prefs.yaml`
- Définit l'agent par défaut pour chaque dossier

### Options de la Commande

```bash
ipcrae inbox scan [OPTIONS]
```

**Options:**
- `-f, --folder <nom>`: Scanner un dossier spécifique seulement
- `-d, --domain <domaine>`: Spécifier le domaine pour le traitement
- `-v, --verbose`: Afficher les détails du scan
- `--dry-run`: Afficher sans créer de fichiers
- `-h, --help`: Afficher l'aide

**Exemples:**
```bash
ipcrae inbox scan
ipcrae inbox scan --folder idees
ipcrae inbox scan --verbose
ipcrae inbox scan --dry-run
```

### Dossiers Inbox

| Dossier | Type de capture | Traitement |
|---------|----------------|-----------|
| `infos à traiter/` | Texte brut, discussions | Analyse → Knowledge/Process/Ressources |
| `idees/` | Brainstorm | → Zettelkasten/_inbox/ |
| `taches/` | Actions | → Casquette/Projet tracking |
| `liens/` | URLs | → Ressources/<domaine>/ |
| `projets-entrants/` | Idées projet | → process-ingest-projet |
| `media/` | Captures visuelles | → Ressources/ |
| `snippets/` | Code fragments | → Knowledge/howto/ |
| `demandes-brutes/` | Requests utilisateur | → Vérification traitement |

## Pipeline

```
COUCHE 1 — Bash pur (zéro IA)
  ipcrae-inbox-scan
    → Scanne Inbox/*/
    → Ignore README.md et traites/
    → Génère .ipcrae/auto/inbox-pending.md
    → Crée flag .ipcrae/auto/inbox-needs-processing
    → Exit 0 (rien) | 1 (items détectés)

COUCHE 2 — Agent IA (si flag présent)
  → Lit inbox-pending.md
  → Traite selon Process/inbox-scan.md
  → Archive dans traites/
  → Supprime le flag
```

## Bug à Corriger

Le script a un bug dans la fonction `main()` à la ligne 263:

```bash
total_files=$(scan_folder "$SCAN_FOLDER" | grep -c "^- \[" || echo "0")
```

Le problème est que `scan_folder` affiche aussi des messages avec `section()` et `loginfo()`, donc le `grep` ne fonctionne pas correctement.

### Correction Nécessaire

Modifier la fonction `scan_folder` pour qu'elle retourne le nombre de fichiers à la fin:

```bash
### Scanner un dossier spécifique
scan_folder() {
  local folder="$1"
  local folder_path="${INBOX_DIR}/${folder}"
  
  if [ ! -d "$folder_path" ]; then
    return 0
  fi
  
  # Ignorer README.md et le dossier traites/
  if [ "$folder" = "README.md" ] || [ "$folder" = "traites" ]; then
    return 0
  fi
  
  # Compter les fichiers
  local file_count
  file_count=$(find "$folder_path" -type f ! -name "README.md" 2>/dev/null | wc -l)
  
  if [ "$file_count" -gt 0 ]; then
    echo "### 📁 $folder ($file_count fichier(s))"
    
    # Lister les fichiers avec leur date de modification
    find "$folder_path" -type f ! -name "README.md" -printf "%TY-%Tm-%Td %TH:%TM %p\n" 2>/dev/null | sort -r | while read -r date_time filepath; do
      local filename
      filename=$(basename "$filepath")
      local relpath="${filepath#$IPCRAE_ROOT/}"
      echo "- [$filename]($relpath) — $date_time"
    done
    
    echo ""
  fi
  
  # Retourner le nombre de fichiers
  echo "$file_count"
}
```

Et modifier la fonction `main()` pour capturer correctement le nombre de fichiers:

```bash
# Scan de l'Inbox
local total_files
if [ -n "$SCAN_FOLDER" ]; then
  section "Scan du dossier: $SCAN_FOLDER"
  total_files=$(scan_folder "$SCAN_FOLDER" | tail -1)
else
  total_files=$(scan_all_folders | tail -1)
fi
```

## Modifications Nécessaires dans le Launcher

Pour intégrer la commande `inbox scan` dans le launcher principal (`~/bin/ipcrae`), les modifications suivantes sont nécessaires:

### 1. Ajouter la fonction `cmd_inbox`

Ajouter après la fonction `cmd_allcontext`:

```bash
# ── Inbox ───────────────────────────────────────────────────
cmd_inbox() {
  need_root
  local script_path="${IPCRAE_ROOT}/scripts/ipcrae-inbox-scan.sh"
  
  if [ ! -f "$script_path" ]; then
    logerr "Script Inbox Scan introuvable: $script_path"
    logerr "Exécutez 'ipcrae update' pour installer les scripts manquants"
    return 1
  fi
  
  # Passer tous les arguments au script
  bash "$script_path" "$@"
}
```

### 2. Ajouter la commande dans le case statement

Ajouter dans le case statement principal:

```bash
inbox)            cmd_inbox "${cmd_args[@]:-}" ;;
```

### 3. Mettre à jour l'aide

Ajouter dans la fonction `usage()`:

```bash
inbox scan [OPTIONS]  Scan automatique de l'Inbox
```

## Tests

### Test de base
```bash
cd ~/IPCRAE
bash scripts/ipcrae-inbox-scan.sh --dry-run
```

### Test avec options
```bash
bash scripts/ipcrae-inbox-scan.sh --folder idees --verbose
```

### Test complet (après intégration dans le launcher et correction du bug)
```bash
ipcrae inbox scan
ipcrae inbox scan --folder idees
```

## Intégration avec le Système de Boot

La commande `inbox scan` peut être intégrée dans le processus de boot:

```bash
# Dans cmd_start ou Process/session-boot.md
if bash scripts/ipcrae-inbox-scan.sh; then
  # Rien à traiter
  :
else
  # Fichiers détectés, proposer traitement
  logwarn "Fichiers Inbox détectés — Lancez 'ipcrae work' pour les traiter"
fi
```

## Références

- Documentation: [`Knowledge/howto/inbox-scan-automatique.md`](Knowledge/howto/inbox-scan-automatique.md)
- Script principal: [`scripts/ipcrae-inbox-scan.sh`](scripts/ipcrae-inbox-scan.sh)
- Process de traitement: [`Process/inbox-scan.md`](Process/inbox-scan.md)
- Process de boot: [`Process/session-boot.md`](Process/session-boot.md)
