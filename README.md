# 🧠 IPCRAE Étendu (v3.2)

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
│   └── prompts/            # Architecture v3.2 des prompts par domaine/fonction
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
- `Zettelkasten/permanents/` = **digéré** (une idée = une note, écrite dans tes mots, liée à d’autres notes).

---

## 4) Installation & Mise à jour

### Installation rapide
```bash
git clone https://github.com/vieurou/IPCRAE.git
cd IPCRAE
bash ipcrae-install.sh -y
```

### Mise à jour en production (sans perte de données)
Pour un cerveau existant déjà en prod, utiliser la migration safe :
```bash
ipcrae migrate-safe
```
Algorithme appliqué :
1. Backup complet du vault (archive `tar.gz`) avant toute modification.
2. Merge non destructif des prompts (`.ipcrae/prompts/`) : fichier absent généré, fichier différent gardé en `.new-<timestamp>`.
3. Mise à jour des scripts CLI avec backup local.
4. Enrichissement de configuration sans overwrite (`default_provider`, `auto_git_sync`).
5. Rapport de migration écrit dans `.ipcrae/backups/`.

---

## 5) Contrat IA et Prompts (v3.2)

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

---

## 6) Mémoire IA par domaine (`memory/`)

La mémoire IA sert à éviter de refaire les mêmes erreurs.
- **Règle** : Une mémoire par domaine (devops, electronique, etc.) pour réduire le bruit.
- **Commande** : Mise à jour en fin de session via `ipcrae close [domaine]`.

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
- Commande : `ipcrae close devops`
- L'IA résume la session, extrait la sève dans `memory/<domaine>.md` et purge le reste.

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
Par défaut (`auto_git_sync: true`), IPCRAE va auto-commit & push vos nouvelles mémoires (captures, closes, daily) en background si le Vault est tracké. Override via `export IPCRAE_AUTO_GIT=false`.

### Outils de Refactoring IA
- `ipcrae consolidate [domaine]` : Ferme la feature CDE d'un projet local, extrait l'intel vers `memory/` et purge les brouillons.
- `ipcrae ingest [domaine]` : Scan IA profond d'un repo tiers inactif, rédige son readme technique et l'injecte dans le vault IPCRAE.

---

## 12) Commandes Références

- `ipcrae sync` : Régénère le contexte statique.
- `ipcrae health` : Affiche l'Inbox "stale", les strikes daily et la charge mentale actuelle.
- `ipcrae review project` : Rétrospective d'un projet guidée.

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

### Vérification QA Rapide (pour Devs)
```bash
# Sandboxing
TMP_HOME=$(mktemp -d)
TMP_VAULT="$(mktemp -d)/vault"
HOME="$TMP_HOME" bash ipcrae-install.sh -y "$TMP_VAULT"
```
