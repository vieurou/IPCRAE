---
type: howto
tags: [ipcrae, allcontext, implementation, pipeline, ingestion]
project: IPCRAE
domain: devops
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Implémentation de la commande `ipcrae allcontext`

## Contexte

La commande `ipcrae allcontext` permet d'analyser et ingérer des demandes utilisateur avec le contexte complet du système IPCRAE. C'est un pipeline universel qui:

1. Analyse la demande (intention, objectifs)
2. Identifie les rôles appropriés (principal, secondaires)
3. Priorise l'information (documents pertinents)
4. Extrait le contexte (lecture des documents)
5. Suit les demandes (création fichier, index)

## Script Implémenté

Le script [`scripts/ipcrae-allcontext.sh`](scripts/ipcrae-allcontext.sh) a été créé avec les fonctionnalités suivantes:

### Fonctions du Pipeline

#### `analyze_request(request)`
- Analyse la demande utilisateur
- Détecte l'intention (Feature, Bug, Review, Question, Architecture)
- Extrait les objectifs principaux

#### `identify_roles(request, intention)`
- Mappe l'intention vers des rôles appropriés
- Ajoute des rôles secondaires selon les mots-clés
- Retourne la liste des rôles suggérés

#### `prioritize_information(request, intention)`
- Identifie les documents toujours prioritaires
- Ajoute des documents selon l'intention
- Ajoute des documents selon les mots-clés

#### `extract_context(priority_docs, show_context)`
- Lit les documents prioritaires
- Extrait le contexte pertinent
- Retourne le contexte extrait

#### `track_request(request, intention, roles, priority_docs)`
- Crée le fichier d'analyse dans `Projets/IPCRAE/demandes/`
- Met à jour l'index des demandes
- Suit l'avancement

### Options de la Commande

```bash
ipcrae allcontext "<texte>" [OPTIONS]
```

**Options:**
- `-a, --agent <nom>`: Spécifier l'agent (claude|gemini|codex)
- `--show-context`: Afficher le contexte ingéré
- `--show-extracted`: Afficher les informations extraites
- `--show-prioritization`: Afficher la priorisation
- `--show-all`: Afficher toutes les informations
- `--dry-run`: Afficher sans créer de fichiers
- `-h, --help`: Afficher l'aide

**Exemples:**
```bash
ipcrae allcontext "ajoute une commande pour scanner l'Inbox"
ipcrae allcontext "implémente le mode auto-amélioration" --show-context
ipcrae allcontext "audit le système IPCRAE" --show-all
ipcrae allcontext "crée un pipeline d'ingestion" --agent claude --dry-run
```

## Modifications Nécessaires dans le Launcher

Pour intégrer la commande `allcontext` dans le launcher principal (`~/bin/ipcrae`), les modifications suivantes sont nécessaires:

### 1. Ajouter la fonction `cmd_allcontext`

Ajouter après la fonction `cmd_consolidate` (ligne ~1269):

```bash
# ── AllContext ─────────────────────────────────────────────────
cmd_allcontext() {
  need_root
  local script_path="${IPCRAE_ROOT}/scripts/ipcrae-allcontext.sh"
  
  if [ ! -f "$script_path" ]; then
    logerr "Script AllContext introuvable: $script_path"
    logerr "Exécutez 'ipcrae update' pour installer les scripts manquants"
    return 1
  fi
  
  # Passer tous les arguments au script
  bash "$script_path" "$@"
}
```

### 2. Ajouter la commande dans le case statement

Ajouter dans le case statement principal (ligne ~1542):

```bash
allcontext)        cmd_allcontext "${cmd_args[@]:-}" ;;
```

### 3. Mettre à jour l'aide

Ajouter dans la fonction `usage()`:

```bash
allcontext "<texte>"    Pipeline d'analyse/ingestion universel
```

## Tests

### Test de base
```bash
cd ~/IPCRAE
bash scripts/ipcrae-allcontext.sh "test de la commande allcontext" --dry-run
```

### Test avec options
```bash
bash scripts/ipcrae-allcontext.sh "implémente une nouvelle fonctionnalité" --show-all
```

### Test complet (après intégration dans le launcher)
```bash
ipcrae allcontext "crée un système de suivi des demandes"
```

## Intégration avec le Système de Demandes

La commande `allcontext` crée automatiquement:

1. Un fichier d'analyse dans `Projets/IPCRAE/demandes/[timestamp]_allcontext.md`
2. Une entrée dans l'index `Projets/IPCRAE/demandes/index.md`
3. Un suivi de l'avancement

## Prochaines Étapes

1. Intégrer la commande dans le launcher principal
2. Tester la commande en conditions réelles
3. Documenter les cas d'utilisation
4. Créer des tests automatisés
5. Intégrer avec le mode auto-amélioration

## Références

- Demande d'analyse: [`Projets/IPCRAE/demandes/2026-02-21_1340_extension-allcontext-analyse.md`](Projets/IPCRAE/demandes/2026-02-21_1340_extension-allcontext-analyse.md)
- Script principal: [`scripts/ipcrae-allcontext.sh`](scripts/ipcrae-allcontext.sh)
- Index des demandes: [`Projets/IPCRAE/demandes/index.md`](Projets/IPCRAE/demandes/index.md)
