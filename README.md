# 🧠 IPCRAE Étendu (méthode v3.3 / scripts v3.3.0)

> **I**nbox · **P**rojets · **C**asquettes · **R**essources · **A**rchives
> Un système de gestion de vie complet, piloté par l'IA, 100% local, versionnable et CLI-friendly.

Ce document décrit **exactement** la méthode IPCRAE : structure des dossiers, règles, workflows, et conventions pour que le système soit compris et appliqué aussi bien par des développeurs que par des IA.

## 1) Objectif et principes

### Objectif
IPCRAE est un système de gestion de travail et de vie (pro + perso) qui :
- Stocke la vérité dans des **fichiers locaux** (Markdown) versionnables.
- Permet à une IA d’être efficace **sans mémoire interne fiable**, grâce à un contexte structuré.
- Combine organisation (PARA/GTD) + journalisation + Zettelkasten + mémoire IA par domaine.

### Principes non négociables
1. **La source de vérité est dans les fichiers**, pas dans le chat.
2. **Tout doit être vérifiable** : pas d’approximation technique (versions, options, commandes).
3. **Le système doit rester léger** : si ça devient pénible, il ne sera pas utilisé.
4. **Séparation des rôles** : brut vs digéré, projets vs responsabilités, global vs local.

---

## 2) Modèle mental : IPCRA + extensions

IPCRAE repose sur la structure IPCRA :
- **Inbox/** : capture brute (idées, tâches, liens).
- **Projets/** : unités de travail avec objectif et fin.
- **Casquettes/** : responsabilités continues (areas), par domaine de vie.
- **Ressources/** : documentation brute (matière première).
- **Archives/** : terminé / gelé.

Extensions “Étendu” :
- **Journal/** : daily / weekly / monthly (rituels).
- **Phases/** : phase(s) de vie actives qui pilotent les priorités.
- **Process/** : procédures récurrentes (checklists, Definition of Done).
- **Objectifs/** : vision annuelle / trimestrielle / Someday/Maybe.
- **Zettelkasten/** : notes atomiques permanentes (pensée digérée).
- **Knowledge/** : connaissances opérationnelles réutilisables (how-to, runbooks, patterns).
- **memory/** : mémoire IA par domaine (décisions, erreurs, heuristiques).
- **Agents/** : rôles IA spécialisés (devops, électronique, musique, maison, santé, finance).

---

## 3) Arborescence canonique du vault IPCRAE

Le vault IPCRAE (par défaut `~/IPCRAE`) contient au minimum :

```text
IPCRAE_ROOT/
├── .ipcrae/
│   ├── context.md          # Contexte global : identité, valeurs, structure, projets en cours
│   ├── instructions.md     # Règles IA communes (qualité, vérification, styles)
│   ├── config.yaml         # Provider par défaut, options
│   └── prompts/            # Architecture v3.3 des prompts par domaine/fonction
├── Inbox/
│   ├── waiting-for.md      # Délégué / en attente
│   └── capture-*.md        # Captures rapides
├── Projets/                # Central Hubs pour chaque projet technique
├── Casquettes/
├── Ressources/
├── Zettelkasten/
│   ├── _inbox/
│   ├── permanents/
│   └── MOC/
├── Knowledge/
│   ├── howto/
│   ├── runbooks/
│   ├── patterns/
│   └── MOC/
├── Journal/
│   ├── Daily/YYYY/
│   ├── Weekly/YYYY/
│   └── Monthly/YYYY/
├── Phases/
├── Process/
├── Objectifs/
├── memory/
│   ├── devops.md
│   ├── electronique.md
│   ├── musique.md
│   ├── maison.md
│   ├── sante.md
│   └── finance.md
├── Agents/                 # Scripts et descriptions de rôles (agent_devops.md...)
├── CLAUDE.md / GEMINI.md   # Contextes IA générés auto (source : context.md + instructions.md)
└── index.md                # Dashboard central
```

### Règle “brut vs digéré”
- `Ressources/` = **brut** (extraits, liens, docs, notes littérales).
- `Zettelkasten/permanents/` = **digéré atomique** (une idée = une note).
- `Knowledge/` = **opérationnel réutilisable** (how-to, runbooks, patterns), taggé avec frontmatter YAML.

---

## 4) Quickstart & Installation

### 4.1 Quickstart complet (Workflow recommandé)

```bash
# 1) Installer IPCRAE (vault central)
git clone https://github.com/vieurou/IPCRAE.git
cd IPCRAE
bash ipcrae-install.sh -y "$HOME/IPCRAE"

# 2) Aller dans un repo projet local
cd /chemin/vers/mon-projet

# 3) Initialiser la couche conception + liens vers mémoire globale
IPCRAE_ROOT="$HOME/IPCRAE" "$HOME/bin/ipcrae-addProject"

# 4) Vérifier l'environnement
"$HOME/bin/ipcrae" doctor
```

### 4.2 Installation détaillée

L'installateur peut être exécuté en mode interactif (sans `-y`) pour vous guider lors de la première configuration (initialisation Git, choix du provider IA).

Vérifiez que `~/bin` est dans votre `PATH` :
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 4.3 Mise à jour en production (sans perte de données)
Pour un cerveau existant déjà en prod, utiliser la migration safe :
```bash
ipcrae migrate-safe
```
### 4.4 Versioning (méthode vs scripts)
- **METHOD_VERSION** : version documentaire de la méthode (README, conventions, contrat CDE).
- **SCRIPT_VERSION** : version des scripts shell (`ipcrae-install.sh`, `ipcrae`).
- Tant que non aligné, documenter explicitement l'écart (aucune ambiguïté en release notes).

Algorithme appliqué :
1. Backup complet du vault (archive `tar.gz`) avant toute modification.
2. Merge non destructif des prompts (`.ipcrae/prompts/`) : fichier absent généré, fichier différent gardé en `.new-<timestamp>`.
3. Mise à jour des scripts CLI avec backup local.
4. Enrichissement de configuration sans overwrite (`default_provider`, `auto_git_sync`).
5. Rapport de migration écrit dans `.ipcrae/backups/`.

---

## 5) Contrat IA et Prompts (v3.3)

### Fichiers racines
- **`.ipcrae/context.md`** : Identité, structure, projets en cours.
- **`.ipcrae/instructions.md`** : Règles "écrire dans les fichiers", pas "retenir dans la conversation". Interdiction d'inventer des options, obligation de vérification.

### Architecture factorisée des prompts
Le système est désormais en couches (`.ipcrae/prompts/`) :
1. `core_ai_functioning.md` : fonctionnement IA commun.
2. `core_ai_workflow_ipcra.md` : workflow Agile/GTD IPCRAE.
3. `core_ai_memory_method.md` : gouvernance mémoire (local/projet/global).
4. `agent_<domaine>.md` : spécialisation métier.

*Rechargez ces fichiers générés (CLAUDE.md, etc.) avec `ipcrae sync`.*

### Pré-traitement des demandes (obligatoire)
Avant de traiter une demande utilisateur, l'IA doit **reconstruire un prompt optimisé** enrichi par :
- le contexte projet (`docs/conception/*`, hub projet),
- la mémoire/Knowledge pertinente (`memory/`, `Knowledge/`, tags),
- les contraintes techniques et le format de sortie attendu.

Puis seulement exécuter ce prompt optimisé.


---

## 6) Mémoire IA par domaine (`memory/`)

La mémoire IA sert à éviter de refaire les mêmes erreurs.
- **Règle** : Une mémoire par domaine (devops, electronique, etc.) pour réduire le bruit.
- **Commande** : Mise à jour en fin de session via `ipcrae close <domaine> --project <slug>` (flux canonique).
- **Hygiène (TTL)** : `ipcrae memory gc --domain <domaine> --ttl-days 180` archive les entrées anciennes vers `Archives/memory/`.

### Format canonique
```markdown
## YYYY-MM-DD - Titre court
**Contexte** : 
**Décision** : 
**Raison** : 
**Résultat** : 
```

---

## 7) Workflows opérationnels (Rituels)

### 7.0 Cycle canonique start → work → close
- `ipcrae start --project <slug> --phase <phase>` : initialise le contexte de session.
- `ipcrae work "<objectif>"` : lance l'agent avec contexte minimisé et tags pertinents.
- `ipcrae close <domaine> --project <slug>` : consolide `memory/<domaine>.md`, met à jour `.ipcrae/context.md`, puis reconstruit `.ipcrae/cache/tag-index.json`.
- **Point d'entrée unifié** : `ipcrae session start|end|run` (avec `--skip-audit` pour mode rapide).


### 7.1 Capture (Inbox)
Objectif : ne jamais perdre une idée.
- Commande : `ipcrae capture "..."` produit un `Inbox/capture-<timestamp>.md`.
- Lors de la daily/weekly, la note part en Projet, Ressource, ou Zettel.

### 7.2 Daily
- Commande : `ipcrae daily --prep` (l’IA prépare un brouillon à partir de : hier, weekly, waiting-for, phases).
- Contient : Top 3 du jour, next actions par casquette, journal, décisions.

### 7.3 Weekly (Revues)
- Commande : `ipcrae weekly`
- But : Nettoyer l'Inbox, revoir les projets actifs, recadrer avec la Phase active.

### 7.4 Monthly
- Commande : `ipcrae monthly`
- Bilan, ajustements d’objectifs, “reset”.

### 7.5 Close session
- Commande : `ipcrae close devops --project mon-projet`
- L'IA résume la session, extrait la sève dans `memory/<domaine>.md` et purge le reste.

### 7.7 Process OS exécutable (CMA: Clarifier → Mapper → Amplifier)
- `Process/map.md` devient la source de vérité (daily/weekly/monthly/on-trigger/manuel).
- `Process/priorites.md` porte la matrice **Impact × Facilité** + statut d’exécution.
- `ipcrae process run <slug>` exécute une fiche process avec contexte minimal.
- Les fiches process peuvent déclarer des paramètres d’exécution (`Agent`, `Context tags`, `Output path`, `Collector script`) consommés par la commande `process run`.
- `ipcrae process run --dry-run <slug>` affiche le plan sans exécuter.
- `ipcrae process next` propose les 3 quick wins prioritaires.
- `ipcrae inbox --process` lance le process canonique `inbox-triage`.

### 7.6 Workflows Avancés (Nouvelle Idée & Projets)
Pour des guides pas-à-pas sur la création de projets, l'intégration de projets existants, ou le traitement automatique d'une nouvelle idée, consultez le document détaillé :
👉 **[docs/workflows.md](docs/workflows.md)**

---

## 8) Zettelkasten (Notes atomiques)

- **Création** : `ipcrae zettel "Titre"` (part dans `_inbox/`).
- **Passage en permanent** : Dès que l'idée est unique, formulée dans vos mots, et liée (`[[Autre_Note]]`).
- **MOC** : `ipcrae moc "Thème"` (Map of Content, index thématique reliant les notes).

---

## 9) Focus Method : Phases & Objectifs

`Phases/index.md` est une source de vérité sur la phase active.
- **Règle** : une phase active = priorité > tout le reste.
- Les projets hors phase sont “en pause” par défaut.

---

## 10) Mode “Projet Local” : CDE (Context Driven Engineering)

Référence conception: `docs/conception/00_OS_IA_3_COUCHES.md` (stockage/agent/interface + sources de vérité).


Quand un repo local (code applicatif, dossier musique...) doit bénéficier d'IPCRAE, utilisez :
```bash
# Dans ~/DEV/mon-projet
ipcrae-addProject
```

Cette commande initialise :
1. L'architecture documentaire `docs/conception/` (`00_VISION.md`, `01_AI_RULES.md`, etc.).
2. Un dossier pour notes volatiles (`.ipcrae-project/local-notes/`).
3. Le **Hub Central Projet** injecté dans le cerveau (`~/IPCRAE/Projets/mon-projet/`).
4. Le **Lien Mémoire Global** (`.ipcrae-memory -> ~/IPCRAE`).
5. Le manifeste `.ai-instructions.md` qui indique à l'IA d'utiliser la mémoire globale mais de stocker le debug dans les "local-notes".

---

## 11) Git & Workflows Avancés

### Auto Git Sync
Par défaut (`auto_git_sync: true`), IPCRAE va auto-commit vos nouvelles mémoires (captures, closes, daily) en background si le Vault est tracké. Le push automatique est désactivé par défaut (`auto_git_push: false`) et peut être activé explicitement via config ou `export IPCRAE_AUTO_GIT_PUSH=true`. Override commit via `export IPCRAE_AUTO_GIT=false`.

### Mode dégradé (sans certaines dépendances)
- Sans `rg` : `ipcrae search` bascule automatiquement sur `find + grep` (plus lent).
- Sans `git` : pas d'auto-commit/push ni de tags de session Git.
- Sans `python3` : index tags (`ipcrae index`) indisponible, enrichissement tags dans `work` désactivé, mise à jour dynamique avancée limitée.
- Kill-switch sécurité : `IPCRAE_AUTO_GIT=0` désactive auto-commit/push (prioritaire sur la config).

### Outils de Refactoring IA
- `ipcrae consolidate [domaine]` : Ferme la feature CDE d'un projet local, extrait l'intel vers `memory/` et purge les brouillons.
- `ipcrae ingest [domaine]` : Scan IA profond d'un repo tiers inactif, rédige son readme technique et l'injecte dans le vault IPCRAE.

---

## 12) Commandes Références

- `ipcrae sync` : Régénère le contexte statique.
- `ipcrae health` : Affiche l'Inbox "stale", les strikes daily et la charge mentale actuelle.
- `ipcrae index` : reconstruit le cache tags (`.ipcrae/cache/tag-index.json`) à partir du frontmatter de `Knowledge/` et `Zettelkasten/`.
- `ipcrae tag <tag>` : liste les fichiers liés à un tag.
- `ipcrae search <mots|tags>` : recherche avec cache tags + fallback `rg` puis `find+grep` si `rg` absent.
- `ipcrae review project` : Rétrospective d'un projet guidée.
- `ipcrae process map` : ouvre la cartographie process centrale.
- `ipcrae process run <slug>` : exécute un process documenté.
- `ipcrae process next` : propose les prochains quick wins impact×facilité.
- `ipcrae inbox --process` : déclenche le tri Inbox supervisé.

---

## 13) Diagnostics et Définition de Done (DoD)

La méthode est stable si :
- `Inbox/` n’accumule pas de notes de plus de 7 jours.
- Une daily existe pour les jours travaillés.
- La revue `Weekly` est tenue.
- La `memory/` n'est pas remplie de vide mais de vraies leçons.
- Les projets actifs (`Projets/`) ont des `Next actions` explicités dans `tracking.md`.

*IPCRAE n’est pas un outil, c’est un protocole. Si une partie n’est pas utilisée, elle doit être supprimée pour que le système survive.*

---

## 14) Précisions techniques et Robustesse

### Notes sur l'installateur
- Certaines fonctionnalités sont **optionnelles** selon la présence des templates (`templates/prompts`, `templates/scripts`) : l'installateur affiche un warning et continue en mode dégradé.
- Le lien `.ipcrae-memory` dans un repo projet est un artefact local CDE : à ignorer en VCS (ou à documenter explicitement pour un repo de démo).
- La fonction `write_safe` accepte **2 modes d'écriture** :
  1. `write_safe "chemin" "contenu"` (argument inline)
  2. `write_safe "chemin" <<'EOF' ... EOF` (heredoc via stdin)
- En mode strict (`set -u`), l'absence de second argument n'entraîne pas d'erreur, mais si la fonction est appelée **sans contenu** d'aucune manière, elle échoue explicitement avec un message d'erreur.

### Troubleshooting (Dépannage)
- **`ipcrae` introuvable** : l'installateur place le binaire dans `$HOME/bin`. Faites `export PATH=$HOME/bin:$PATH` et ajoutez-le à votre `.bashrc`.
- **Lien symbolique `.ipcrae-memory` cassé** : vérifiez de n'avoir pas déplacé `<projet_local>` ou la variable `$IPCRAE_ROOT`. Relancez `ipcrae-addProject` localement.
- **Contexte IA incomplet** : lancer `ipcrae sync` puis `ipcrae doctor` (validation du contrat d'injection de contexte incluse).
- **Fichiers `.ipcrae/*` absents** : vérifier la validité de `$IPCRAE_ROOT`.

### Vérification QA Rapide (pour Devs)
Intuitif à tester en environnement sandbox isolé avant de toucher à votre vrai cerveau :
```bash
# 1) Sanity check syntaxe Bash
bash -n ipcrae-install.sh

# 2) Exécution non-interactive isolée
TMP_HOME=$(mktemp -d)
TMP_VAULT="$(mktemp -d)/vault"
HOME="$TMP_HOME" bash ipcrae-install.sh -y "$TMP_VAULT"

# 3) Contrôle minimal
[ -f "$TMP_VAULT/.ipcrae/context.md" ]
[ -f "$TMP_VAULT/.ipcrae/config.yaml" ]
```

### Améliorations Futures (Roadmap Technique)
- ~~Ajouter un mode `--dry-run` pour l'installateur.~~ ✅ livré
- Ajouter une suite de tests shell (`bats`) — en cours.
- Uniformiser la création des repositories avec `git init -b main`.

> Roadmap complète → `Projets/IPCRAE/tracking.md` dans le vault (source de vérité).

---

## 15) Licence & Contribution

MIT — Utilisation libre, personnelle et commerciale.

Les PR sont bienvenues. Avant toute soumission exécutez un Linter agressif :
`bash -n ipcrae-install.sh` + `shellcheck ipcrae-install.sh`.


## 16) Scripts prêts à l'emploi (optimisation tokens + orchestration agents)

Nouveaux scripts livrés pour réduire les tokens et accélérer les réponses IA :

```bash
# Génère un contexte compact (core)
ipcrae-tokenpack core

# Génère un contexte compact pour un projet
ipcrae-tokenpack project mon-projet

# Interroge automatiquement les IA CLI disponibles (claude/gemini/codex)
ipcrae-agent-bridge "Donne le plan de migration"

# Forcer un refresh (sans cache)
ipcrae-agent-bridge --no-cache "Donne le plan de migration"

# TTL cache custom (1h)
ipcrae-agent-bridge --ttl 3600 "Plan de release"

# Produit un prompt court optimisé selon l'agent cible
ipcrae-prompt-optimize claude "Créer une weekly actionable"
```

### Pourquoi ça consomme moins de tokens
- Le contexte est tronqué et nettoyé (`ipcrae-tokenpack`) : suppression des lignes vides/commentaires + limite de taille.
- Les prompts imposent une sortie **courte et actionnable** (contrat quick win + plan robuste).
- Le bridge multi-agent évite les prompts longs manuels répétés, standardise le format de demande, et met en cache les réponses pour éviter les appels identiques.

### Veille agents CLI et stratégie d'usage
- **Claude CLI** : excellent pour architecture, arbitrages, risques.
- **Gemini CLI** : bon en enchaînement terminal/outils.
- **Codex CLI** : efficace pour patch minimal + validations techniques.

Recommandation : utiliser `ipcrae-prompt-optimize` avant chaque délégation, puis `ipcrae-agent-bridge` pour comparer rapidement les sorties quand l'enjeu est critique.

### Améliorations utiles à ajouter ensuite

> Ces items sont suivis dans `Projets/IPCRAE/tracking.md` (Backlog long terme) dans le vault.
> Ne pas dupliquer ici pour éviter la désynchronisation.

