---
type: process
tags: [ipcrae, ingestion, projet, process, checklist]
domain: devops
status: active
created: 2026-02-21
updated: 2026-02-21
---

# Process : Ingestion d'un nouveau projet dans IPCRAE

## Quand utiliser ce process
- Nouveau repo local à intégrer dans le système IPCRAE
- Projet existant jamais ingéré dans le cerveau global
- Refonte d'un projet → ré-ingestion

## Pré-requis
- `ipcrae` installé et `ipcrae doctor` passe
- `IPCRAE_ROOT` exporté dans le shell (`echo $IPCRAE_ROOT`)
- Se trouver dans le répertoire du projet à ingérer

## Étapes

### 1. Initialiser le projet (si pas encore fait)
```bash
cd /chemin/vers/mon-projet
ipcrae-addProject
# Répond aux questions : domaine, confirm
```
Résultat : `docs/conception/`, `.ipcrae-project/`, `.ipcrae-memory` → symlink, hub dans `Projets/<slug>/`

### 2. Lancer l'ingestion IA
```bash
ipcrae work "$(cat $IPCRAE_ROOT/.ipcrae/prompts/prompt_ingest.md)"
# Ou, si la commande ingest est disponible :
# ipcrae ingest <domaine> --project <slug>
```
L'IA suit le workflow en 6 blocs (prompt_ingest.md v2).

### 2bis. Rechercher et mettre à jour les Knowledge existantes liées (OBLIGATOIRE)

Avant de créer de nouvelles notes, vérifier si des Knowledge existantes couvrent déjà les mêmes sujets :

```bash
# Identifier les tags clés du projet
# Ex. pour EscapeCode : mqtt, iot, nodered, multi-tenant, redis
ipcrae tag mqtt        # → lister les notes existantes sur MQTT
ipcrae tag iot         # → lister les notes IoT
ipcrae search "MQTT multi-tenant"  # → recherche full-text
```

Pour chaque note existante liée :
- **Enrichir** : ajouter une section ou un exemple issu du projet ingéré
- **Sourcer** : ajouter dans `sources:` → `project:<slug>/fichier.md`
- **Lier** : ajouter un wikilink `[[Knowledge/...]]` dans la nouvelle note ET dans la note existante
- **Staler** : si la note existante contient des infos obsolètes, mettre `status: outdated` et documenter le changement

Si la note existante est quasi-identique à ce que tu allais créer → **mettre à jour plutôt que dupliquer**.

### 3. Vérifier la Definition of Done
```bash
# Vérifications manuelles :
ls $IPCRAE_ROOT/Projets/<slug>/         # index.md, tracking.md, memory.md
ls $IPCRAE_ROOT/Knowledge/              # au moins 1 note
ls $IPCRAE_ROOT/Zettelkasten/_inbox/    # au moins 2 notes
cat $IPCRAE_ROOT/memory/<domaine>.md    # entrée datée
ls $IPCRAE_ROOT/Journal/Daily/$(date +%Y)/$(date +%F).md  # journal
```

### 4. Créer le tag Git d'ingestion
```bash
# Vault : tag de milestone
GIT_DIR=$IPCRAE_ROOT/.git GIT_WORK_TREE=$IPCRAE_ROOT \
  git tag -a "ingestion-<slug>-$(date +%Y%m%d)" \
  -m "Ingestion du projet <slug> dans le cerveau IPCRAE"

# DEV/projet (si le projet est un repo) : tag de référence
git tag -a "ipcrae-integrated-$(date +%Y%m%d)" \
  -m "Projet intégré à IPCRAE (ingestion initiale)"
```

### 5. Clôturer la session
```bash
ipcrae close <domaine> --project <slug>
```

## Checklist de qualité (post-ingestion)
- [ ] Zéro [À Remplir] dans `Projets/<slug>/index.md`
- [ ] `tracking.md` : ≥5 next actions concrètes
- [ ] `memory/<domaine>.md` : ≥1 entrée datée
- [ ] `Knowledge/` : ≥1 note avec frontmatter complet (pas de chemin absolu dans `sources:`)
- [ ] `Zettelkasten/_inbox/` : ≥2 notes avec liens croisés
- [ ] `Journal/Daily/<date>.md` : session documentée
- [ ] Tags Git créés (vault + projet)
- [ ] `ipcrae health` : pas d'alerte rouge

## Fréquence
À chaque nouveau projet ou refonte majeure. Pas de cadence fixe.
