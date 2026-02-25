# Process — Scan et traitement automatique de l'Inbox

## Déclencheur (quand lancer ce process ?)
- Chaque matin après `ipcrae daily` (cycle quotidien)
- Avant chaque session de travail focalisée
- Quand un nouveau fichier est déposé dans `Inbox/infos à traiter/`
- Manuellement : `ipcrae inbox scan`

## Entrées (inputs nécessaires)
- Fichiers `.md` présents dans les sous-dossiers Inbox (non encore traités)
- Index des tags courant (`.ipcrae/cache/tag-index.json`)
- Mémoire domaines pertinents (`memory/<domaine>.md`)

## Checklist

### Étape 0 : Inventaire
- [ ] Lister tous les fichiers non traités dans chaque sous-dossier Inbox
- [ ] Filtrer : exclure `README.md`, fichiers dans `traites/`
- [ ] Trier par date (plus ancien en premier)

### Étape 1 : Analyse de chaque fichier
Pour chaque fichier non traité :
- [ ] Lire le contenu complet
- [ ] Identifier : domaine, type (info/idée/tâche/lien/projet/connaissance), urgence
- [ ] Vérifier si une note similaire existe déjà (`ipcrae search`)

### Étape 2 : Traitement selon le type

**Type : connaissance technique réutilisable**
- [ ] Créer note `Knowledge/howto/` ou `Knowledge/patterns/` avec frontmatter YAML canonique
- [ ] Indexer : `ipcrae index`

**Type : procédure / workflow**
- [ ] Créer ou enrichir `Process/<nom>.md` depuis `_template_process.md`
- [ ] Ajouter entrée dans `Process/index.md`

**Type : ressource brute (extrait, ref, lien)**
- [ ] Ajouter dans `Ressources/<domaine>/` avec source citée
- [ ] Si URL : `ipcrae fetch <url>` → Ressources

**Type : idée atomique**
- [ ] Créer note `Zettelkasten/_inbox/<slug>.md` avec un seul concept
- [ ] Lier à au moins une note existante `[[lien]]`

**Type : tâche actionnable**
- [ ] Suivre le processus `[[Process/routing-taches-casquettes]]` pour assigner la tâche à la bonne casquette ou projet.
- [ ] Si <2 min → traiter immédiatement.

**Type : nouveau projet entrant**
- [ ] Lancer `process-ingest-projet` : créer `Projets/<slug>/` complet

**Type : mémoire domaine**
- [ ] Ajouter entrée datée dans `memory/<domaine>.md` (format canonique `### YYYY-MM-DD`)

### Étape 3 : Mise à jour mémoire
- [ ] `memory/<domaine>.md` : décisions/contraintes extraites
- [ ] `Journal/Daily/<YYYY>/<YYYY-MM-DD>.md` : items traités listés

### Étape 4 : Archivage
- [ ] Déplacer chaque fichier traité vers `Inbox/<sous-dossier>/traites/YYYY-MM-DD-<nom>.md`
- [ ] Ajouter note de traitement en commentaire HTML : `<!-- traité: 2026-02-22 → Knowledge/... -->`

### Étape 5 : Commit vault
- [ ] `git -C $IPCRAE_ROOT add -A && git commit -m "feat(inbox): scan traitement YYYY-MM-DD"`

## Sorties (outputs attendus)
- Notes créées dans `Knowledge/`, `Process/`, `Ressources/`, `Zettelkasten/_inbox/`
- Tâches ajoutées dans trackings projets / casquettes
- Fichiers archivés dans `traites/`
- Mémoire domaine mise à jour

## Definition of Done
- [ ] Zéro fichier non-README non traité dans les sous-dossiers Inbox
- [ ] Chaque item tracé dans au moins un fichier de destination
- [ ] Vault commité

## Agent IA recommandé
Agent adapté au domaine du contenu détecté :
- `agent_devops` → contenus infra/docker/git
- `agent_electronique` → ESP32/Arduino/hardware
- `agent_musique` → synth/audio/MIDI
- `agent_synth_bidouille` → circuit bending/PSS-290
- Orchestrateur généraliste si multi-domaine

## Implémentation CLI (à développer dans DEV/IPCRAE)
```bash
ipcrae inbox scan [--folder <nom>] [--dry-run] [--domain <domaine>]
```
- Scanner un ou tous les sous-dossiers
- `--dry-run` : afficher le plan de traitement sans exécuter
- `--domain` : forcer le domaine de traitement (sinon détecté auto)
- Status : **À implémenter** → voir `Projets/IPCRAE/tracking.md`
