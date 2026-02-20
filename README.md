# 🧠 IPCRA v3.1

> **I**nbox · **P**rojets · **C**asquettes · **R**essources · **A**rchives
> Un système de gestion de vie complet, piloté par l'IA, 100% local, versionnable et CLI-friendly.

---

## Pourquoi IPCRA ?

Les assistants IA oublient tout entre les sessions. Les outils cloud (Notion, Obsidian Sync…) centralisent tes données chez un tiers. Les méthodes classiques (GTD, PARA, Zettelkasten) sont puissantes mais rarement intégrées entre elles.

**IPCRA résout les trois problèmes à la fois :**

- La vérité est dans des **fichiers Markdown locaux**, versionnés sous Git
- L'IA reçoit un **contexte structuré et à jour** à chaque session
- La méthode combine **GTD + PARA + Zettelkasten + journaling** dans un seul système cohérent
- Compatible avec **Claude Code, Gemini CLI, Codex, Kilo Code** (VS Code)

---

## Table des matières

- [Concepts](#concepts)
- [Architecture](#architecture)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Providers IA](#providers-ia)
- [Méthodologie](#méthodologie)
- [Zettelkasten](#zettelkasten)
- [Mémoire par domaine](#mémoire-par-domaine)
- [Agents spécialisés](#agents-spécialisés)
- [Rituels](#rituels)
- [Conception & Développement (CDE)](#conception--développement-cde)
- [Workflows Avancés (Consolidation & Ingestion)](#workflows-avancés-consolidation--ingestion)

---

## Concepts

### Le problème de la mémoire IA

Chaque conversation repart de zéro. Si tu travailles sur un projet complexe, l'IA ne sait pas ce que tu as décidé hier, quels sont tes standards, ni tes contraintes. IPCRA injecte ce contexte **automatiquement** à chaque lancement.

### IPCRA = PARA adapté

IPCRA s'inspire directement de la méthode **PARA** (Tiago Forte) :

| PARA | IPCRA | Rôle |
|------|-------|------|
| Projects | `Projets/` | Objectif + fin définie |
| Areas | `Casquettes/` | Responsabilités continues |
| Resources | `Ressources/` | Connaissance brute par domaine |
| Archive | `Archives/` | Terminé / gelé |

Avec en plus : `Inbox/`, `Zettelkasten/`, `memory/`, `Agents/`, `Journal/`, `Phases/`, `Process/`, `Objectifs/`.

---

## Architecture

```
~/IPCRA/
├── .ipcra/
│   ├── context.md          ← Identité, méthode, projets en cours (source de vérité)
│   ├── instructions.md     ← Règles IA communes à tous les providers
│   └── config.yaml         ← Provider par défaut, chemins
│
├── Inbox/                  ← Capture brute : idées, tâches, liens
│   └── waiting-for.md      ← Éléments délégués en attente
│
├── Projets/                ← Projets avec objectif et fin
│   └── _template_projet.md
│
├── Casquettes/             ← Responsabilités continues (Areas de PARA)
│   └── _template_casquette.md
│
├── Ressources/             ← Documentation brute par domaine
│   ├── Tech/{DevOps,Linux,Docker,NodeJS,SvelteKit,Embedded,Healthcare-IT,Security,Database}
│   ├── Electronique/{ESP32,Arduino,Circuits,IoT,Datasheets}
│   ├── Musique/{Production,Synthese,Hardware,Plugins}
│   ├── Maison/{Domotique,Renovation,Energie,Jardinage}
│   ├── Sante/{Nutrition,Sport,Sommeil}
│   ├── Finance/{Budget,Investissement,Fiscalite}
│   └── Apprentissage/{Methodes,Cours,Certifications}
│
├── Zettelkasten/           ← Notes atomiques permanentes (pensée digérée)
│   ├── _inbox/             ← Brouillons en attente de traitement
│   ├── permanents/         ← Notes validées, reliées entre elles
│   └── MOC/                ← Maps of Content (index thématiques)
│
├── Archives/               ← Projets/ressources terminés
│
├── Journal/
│   ├── Daily/YYYY/         ← Notes quotidiennes
│   ├── Weekly/YYYY/        ← Revues hebdomadaires (numérotation ISO)
│   └── Monthly/YYYY/       ← Revues mensuelles
│
├── Phases/                 ← Phases de vie actives → pilotent les priorités
├── Process/                ← Procédures récurrentes (checklists)
├── Objectifs/              ← Vision annuelle, trimestrielle, Someday/Maybe
│
├── memory/                 ← Mémoire IA par domaine
│   ├── devops.md
│   ├── electronique.md
│   ├── musique.md
│   ├── maison.md
│   ├── sante.md
│   └── finance.md
│
├── Agents/                 ← Rôles IA spécialisés par domaine
│   ├── agent_devops.md
│   ├── agent_electronique.md
│   ├── agent_musique.md
│   ├── agent_maison.md
│   ├── agent_sante.md
│   └── agent_finance.md
│
├── CLAUDE.md               ← Contexte généré pour Claude Code
├── GEMINI.md               ← Contexte généré pour Gemini CLI
├── AGENTS.md               ← Contexte généré pour Codex/OpenAI
├── .kilocode/rules/        ← Contexte généré pour Kilo Code (VS Code)
├── .claudeignore
├── .geminiignore
└── index.md                ← Dashboard de navigation
```

---

## Installation

### Prérequis

- `bash` >= 4.0
- `git`
- Au moins un provider IA : `claude`, `gemini`, `codex` (voir [Providers IA](#providers-ia))
- `python3` (streak daily + encodage URL)
- `iconv` (inclus dans `glibc` sur Debian/Ubuntu)
- Optionnel : [Obsidian](https://obsidian.md) pour la navigation visuelle

### Installation rapide

```bash
chmod +x ipcra-install.sh
./ipcra-install.sh
```

L'installateur est **interactif** et guide chaque étape :

1. Choix du dossier racine (défaut : `~/IPCRA`)
2. Initialisation Git optionnelle (`.gitignore` inclus)
3. Création de l'arborescence complète
4. Écriture des fichiers sources (`.ipcra/context.md`, `instructions.md`, `config.yaml`)
5. Installation des templates (Daily, Weekly, Monthly, Projet, Phase, Process)
6. Installation des agents spécialisés
7. Génération des fichiers provider (`CLAUDE.md`, `GEMINI.md`, etc.)
8. Installation du lanceur `~/bin/ipcra` + raccourcis `ipcra-claude`, `ipcra-gemini`, `ipcra-codex`
9. Installation du scaffold de conception `~/bin/ipcra-init-conception`

### Mode non-interactif (CI / bootstrap)

```bash
./ipcra-install.sh --yes /chemin/vers/vault
```

### Post-installation

Vérifier que `~/bin` est dans le `PATH` :

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
ipcra --version
```

Pour utiliser un vault différent de `~/IPCRA` :

```bash
export IPCRA_ROOT=/data/vault
```

---

## Utilisation

### Commandes disponibles

| Commande | Description |
|----------|-------------|
| `ipcra` | Menu interactif |
| `ipcra daily` | Ouvrir/créer la note du jour |
| `ipcra daily --prep` | L'IA génère un brouillon de daily |
| `ipcra weekly` | Ouvrir/créer la revue hebdo (ISO) |
| `ipcra monthly` | Ouvrir/créer la revue mensuelle |
| `ipcra close [domaine]` | Clôture session : l'IA met à jour `memory/` |
| `ipcra capture "texte"` | Capture rapide dans `Inbox/` |
| `ipcra zettel "titre"` | Créer une note atomique Zettelkasten |
| `ipcra moc "thème"` | Créer/ouvrir une Map of Content |
| `ipcra sync` | Régénère `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, Kilo |
| `ipcra health` | Diagnostic du système |
| `ipcra review phase` | Revue de phase guidée par l'IA |
| `ipcra review project` | Rétrospective de projet |
| `ipcra review quarter` | Revue trimestrielle |
| `ipcra process "nom"` | Ouvrir/créer un process |
| `ipcra-init-conception` | Scaffold documentaire CDE dans un dépôt de code (projet) |
| `ipcra consolidate` | Consolide les notes d'un projet local vers la mémoire globale |
| `ipcra ingest [domaine]` | Analyse détaillée / audit d'un projet existant vers la mémoire |
| `ipcra launch [domaine]` | Lancer l'IA en mode expert |
| `ipcra -p gemini <cmd>` | Forcer un provider spécifique |
| `ipcra providers` | Lister les providers disponibles |

### Raccourcis provider

```bash
ipcra-claude "question"
ipcra-gemini "question"
ipcra-codex  "question"
```

### Exemples courants

```bash
# Début de journée
ipcra daily --prep
# → L'IA prépare le brouillon depuis hier + phases + waiting-for

# Pendant le travail
ipcra capture "Idée ESP32 deep sleep pour capteur temp"
ipcra zettel "MQTT QoS niveaux et cas d'usage"

# Fin de session (Mémoire Globale)
ipcra close devops
# → L'IA résume et met à jour memory/devops.md

# Diagnostic
ipcra health

# Revue du dimanche
ipcra weekly
ipcra review phase
```

---

## Providers IA

Les assistants IA utilisés par IPCRA ont des capacités et des limites distinctes. IPCRA tente d'unifier leur comportement via les fichiers de contexte injectés.

| Provider | Commande | Capacités & Limites |
|----------|----------|---------------------|
| **Claude Code** | `claude` | **Recommandé**. Excellente compréhension globale de projets. Idéal pour `ipcra ingest`. *Limite : Ne peut pas exécuter `ipcra consolidate` en natif si désactivé en Headless.* |
| **Gemini CLI** | `gemini` | Rapide. Bon pour la préparation de notes et la synthèse (`ipcra daily --prep`). *Limite : Le flag `--context` n'est pas supporté par tous les wrappers CLI (IPCRA fallback sur une concaténation).* |
| **Codex** | `codex` | Mode agent robuste (OpenAI). |
| **Kilo Code** | VS Code | Intégration IDE poussée. Lit automatiquement `.kilocode/rules/ipcra.md`. |

### Changer le provider par défaut

```yaml
# .ipcra/config.yaml
default_provider: gemini
```

### Comment l'IA reçoit le contexte

```
.ipcra/context.md      ┐
                       ├──→ ipcra sync ──→ CLAUDE.md
.ipcra/instructions.md ┘                 → GEMINI.md
                                         → AGENTS.md
                                         → .kilocode/rules/ipcra.md
```

> ⚠️ Attention : Les fichiers d'instructions (ex: `.claude.md`) ne surchargent pas magiquement le comportement de l'IA de la même façon selon le provider. Toujours s'assurer que l'outil CLI cible lit bien le fichier de règles généré dans le répertoire courant. Ne jamais éditer `CLAUDE.md` directement — éditer `.ipcra/context.md` puis `ipcra sync`.

---

## Méthodologie

### Flux GTD adapté

```
Capturer (Inbox/)
    └─→ Clarifier : actionnable ?
         ├─ Non  → Ressources/ | Someday/Maybe | Supprimer
         └─ Oui  → < 2 min ?
                    ├─ Oui → Faire maintenant
                    └─ Non → Projet/ ou Next Action (Casquette/)
                             Délégué → Inbox/waiting-for.md
```

### Matrice de priorités

| Quadrant | Action |
|----------|--------|
| 🔴 Urgent + Important | Faire **maintenant** |
| 🟠 Important, non urgent | **Planifier** (Phase/Projet) |
| 🟡 Urgent, non important | **Déléguer** ou quick-win |
| ⚪ Ni urgent ni important | **Someday/Maybe** ou supprimer |

### Phases de vie

Le dossier `Phases/` contient la **phase de vie active** : une intention de période (ex : *"Déployer l'infra monitoring"*, *"Rénover la cuisine"*). Elle pilote les priorités.

> **Règle** : si un projet n'est pas autorisé par la phase active, il est en pause.

---

## Mémoire par domaine

Chaque domaine a un fichier dans `memory/` que l'IA lit **en priorité** avant de répondre.

| Fichier | Contenu typique |
|---------|-----------------|
| `memory/devops.md` | Stack, infra, décisions d'archi, erreurs connues |
| `memory/electronique.md` | MCU, projets, erreurs de câblage passées |
| `memory/musique.md` | Setup audio, chaîne signal, matériel |
| `memory/maison.md` | Travaux en cours, contraintes, devis |
| `memory/sante.md` | Routines, objectifs, points de vigilance |
| `memory/finance.md` | Enveloppes, objectifs, échéances |

### Format d'entrée recommandé

```markdown
## 2026-02-20 - Passage Traefik v2 → v3

**Contexte** : Migration reverse proxy Docker
**Décision** : Rester sur Traefik v2 jusqu'à stabilisation plugins
**Raison** : Plugin oauth2-proxy incompatible v3 au 2026-02-20
**Résultat** : ✅ Production stable
```

### Mise à jour automatique

```bash
ipcra close          # L'IA identifie le domaine et écrit dans memory/
ipcra close devops   # Forcer le domaine si session multi-sujets
```

---

## 🧭 Quelle note va où ? (Matrice Stratégique)

IPCRA repose sur une source de vérité unique. L'objectif est de ne jamais dupliquer l'information. Voici le contrat de confiance absolu sur où écrire l'information :

| Type d'information | Emplacement | Durée de vie | Rôle & Traitement |
|-------------------|-------------|--------------|-------------------|
| **Action / Idée rapide** | `Inbox/*.md` | Très Courte | À clarifier/classer lors du Daily/Weekly. |
| **Brouillon de Projet** | `.ipcra-project/local-notes/` | Courte (le temps de l'itération) | Contexte local temporaire. À purger via `ipcra consolidate`. |
| **Logique de Projet Fixée** | `Projets/[Nom]/` | Moyenne (le temps du projet) | Ce qu'il faut accomplir (*What/How*). Migre dans `Archives/`. |
| **Décision Technique Durable**| `.ipcra-memory/memory/[Domaine].md` | Longue | Règle d'or, contraintes, leçons. Ce que l'IA **doit lire** (*Why*). |
| **Concept Atomique Isolable**| `Zettelkasten/permanents/`| Longue | Savoir digéré (agnostique du projet), réutilisable pour la réflexion. |
| **Doc de référence externe** | `Ressources/` | Longue | Datasheet, manuel, PDF... Source brute de connaissance. |
| **Traces et Historique** | `Archives/` & `Journal/` | Éternelle | Ne sont consultés que sur recherche active, jamais par défaut. |

---

## Agents spécialisés

Les fichiers `Agents/agent_<domaine>.md` définissent le **rôle, les contraintes et le workflow** de l'IA par domaine.

| Agent | Profil |
|-------|--------|
| `agent_devops` | Architecte DevOps/SRE Linux/Docker, IT santé, compliance HDS/RGPD |
| `agent_electronique` | Ingénieur embedded ESP32/Arduino, vérifie datasheets et niveaux logiques |
| `agent_musique` | Ingénieur son + bidouilleur hardware, synthèse, circuit bending |
| `agent_maison` | Conseiller rénovation/énergie, normes NF C 15-100, DTU, RE2020 |
| `agent_sante` | Sources HAS/OMS uniquement, jamais de diagnostic |
| `agent_finance` | Fiscal français, plafonds vérifiés avec date de validité |

Chaque agent :

1. Lit `memory/<domaine>.md` en premier
2. Applique les contraintes spécifiques du domaine
3. Produit des livrables adaptés (commandes shell, schémas, code firmware, etc.)

---

## Rituels Formels

Pour que le système ne s'effondre pas sous l'obsolescence, IPCRA impose une cadence de "garbage collection" (nettoyage).

| Cycle | Moment | Durée | Commande | Résultat Attendu |
|-------|--------|-------|----------|------------------|
| **Daily** | Chaque matin | 5–10 min | `ipcra daily --prep` | L'IA trie votre inbox. Le cap est fixé pour la journée. |
| **Close** | Fin de session IA | 5 min | `ipcra close` | Fin de journée de dev : la mémoire de domaine est à jour. |
| **Consolidate** | **Fin d'une Feature** | 5 min | `ipcra consolidate` | Remontée des `local-notes` volatiles vers la mémoire globale. |
| **Weekly** | Dimanche soir | 30 min | `ipcra weekly` + `ipcra review phase` | Alignement avec les `Phases`. Vidage manuel de la `Inbox`. |
| **Monthly** | 1er du mois | 1 h | `ipcra monthly` + `ipcra review quarter` | Déplacement massif vers les `Archives/`. Ajustement d'Objectifs. |
| **Health** | À la demande | < 1 min | `ipcra health` | Diagnostic : traque les notes moisies en Inbox et Zettelkasten. |

---

## Conception & Développement (CDE)

Le script de scaffold `ipcra-init-conception` permet de lier la puissance documentaire d'IPCRA à vos environnements de développement locaux, sans jamais polluer vos dépôts Git avec vos notes globales.

**Position méthodologique (Stratégie Centralisée Hub & Spoke)** :
- `~/IPCRA` (ou `$IPCRA_ROOT`) est la **source de vérité** pour la mémoire durable.
- Un projet local ne duplique pas toute la hiérarchie IPCRA. Le dossier local sert de **contexte court terme** et l'IA pointe vers le global via des liens symboliques.

En exécutant `ipcra-init-conception` à la racine de n'importe quel code ou projet (par ex. `~/DEV/MonApp/`), le script déploie ce pont :

1. **Architecture Documentaire Locale** : Génération d'un dossier `docs/conception/` contenant `00_VISION.md`, `01_AI_RULES.md`, `02_ARCHITECTURE.md`, et le guide de lecture `03_IPCRA_CONTEXT_LINKS.md`.
2. **Notes Volatiles Lègères** : Création de `.ipcra-project/local-notes/` pour documenter le travail en cours sans alourdir le repo.
3. **Le Lien Cerveau (`.ipcra-memory`)** : Crée un lien symbolique `.ipcra-memory -> ~/IPCRA` et des raccourcis spécifiques (`memory-global`, `archives-global`). L'Agent IA accède instantanément en lecture à TOUTES les notes du Cerveau Global pertinentes.
4. **Génération Mutante des Règles IA** : Importe vos instructions globales (`context.md`) et les fusionne aux directives spécifiques du projet (`01_AI_RULES.md`) pour instancier les `.clinerules`, `.claude.md`, etc.

---

## Workflows Avancés (Consolidation & Ingestion)

IPCRA V3.1 introduit des workflows puissants pour faire le lien entre vos projets de code locaux et votre second cerveau global.

### Le Workflow de Consolidation (`ipcra consolidate`)
Conçu pour refermer proprement la boucle d'un projet CDE en cours après une itération.
1. **Collecte** : Le script scanne le brouillon volatil dans `.ipcra-project/local-notes/`.
2. **Synthèse IA** : Appel Headless au LLM pour extraire uniquement les décisions durables, leçons et patterns.
3. **Revue Humaine** : Le brouillon s'ouvre dans votre éditeur (`nano`/`vim`) pour validation et édition.
4. **Injection & Garbage Collection** : Si validé, la synthèse atomique est poussée dans la mémoire globale (`.ipcra-memory/memory/[domaine].md`) et le dossier volatil local est purgé pour repartir sur une base vierge.

### Le Workflow d'Ingestion & Audit (`ipcra ingest [domaine]`)
Conçu pour intégrer d'anciens dossiers de code ou de projets orphelins dans votre Cerveau IPCRA.
C'est une commande **profondément agentique** (interactive) s'appuyant sur un Prompt Maître :
1. **Analyse Documentaire** : L'IA lit les `README` et `docs/` existants pour documenter l'objectif métier et l'architecture locale dans la mémoire globale IPCRA.
2. **Audit de Code (Deep Dive)** : L'IA explore le code source avec ses propres outils (ls, cat, ast-grep) pour documenter les hacks, la dette, les choix technologiques et les patterns d'implémentation.
3. **Zettelkasten Atomique** : Si l'IA détecte des algorithmes universels ou des patterns de conception précieux, elle crée de son propre chef des notes atomiques isolées directement dans `Zettelkasten/_inbox/`.

---

## 🔥 Quickstart : Le Workflow Recommandé de bout en bout

Pour être pleinement efficace, utilisez la séquence (Runbook) suivante :

### 1. Démarrer sa journée
1. Lancez votre terminal.
2. Tapez `ipcra daily --prep` : l'IA lit vos priorités passées et l'état d'hier pour vous rédiger votre brouillon du jour.
3. Vérifiez la santé système : `ipcra health`.

### 2. Démarrer un nouveau projet local de dev
1. Naviguez dans votre dépôt de code (ex: `cd ~/DEV/NouveauProjet`).
2. Scaffoldez les liens IPCRA : `ipcra-init-conception`
3. Remplissez le `docs/conception/00_VISION.md`
4. Capturez vos notes brutes, debug, todo jetable pendant le dev dans `.ipcra-project/local-notes/`.

### 3. Coder avec l'IA
1. Les hooks sont générés : votre assistant IA cible a déjà chargé `.clinerules` (ou équivalent) comprenant les `.ipcra-memory/memory/`. Il connait tout de vous.
2. Coder itérativement.

### 4. Clôturer proprement l'itération
1. Vous avez terminé une feature majeure. Il y a eu de nombreuses leçons techniques tirées.
2. Tapez `ipcra consolidate devops` (remplacez devops par votre domaine).
3. Visualisez le résumé magique généré par l'IA des erreurs surmontées. Validez.
4. Le dossier brouillon est purgé. Votre mémoire globale est renforcée pour toujours.

---

## 🛠 Troubleshooting & Migration

### Migration depuis une installation non centralisée (v2.x)
Si vous aviez précédemment dupliqué des dossiers entiers d'IPCRA (ex: dossiers .ipcra isolés) au lieu d'utiliser le modèle centralisé (Hub & Spoke), agissez ainsi :
1. Choisissez un Vault "Maître" (votre IPCRA Source of Truth).
2. Utilisez **`ipcra ingest [domaine]`** sur vos anciens répertoires locaux afin d'auditer et pomper la connaissance pour l'injecter au Maître.
3. Effacez le dossier `.ipcra` répliqué et remplacez-le en exécutant `ipcra-init-conception` pour placer les liens symboliques vers `.ipcra-memory`.

### Problèmes Courants
- **`ipcra: command not found`** : Le dossier `~/bin` n'est pas dans votre variable `$PATH`. Exécutez : `echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc` puis `source ~/.bashrc`.
- **Lien symbolique cassé (mémoire indisponible)** : Vérifiez la variable d'environnement `$IPCRA_ROOT`. Vous pouvez forcer le chemin dans `~/.bashrc` via `export IPCRA_ROOT=/chemin/vers/VraiIPCRA`.
- **"Aucun contenu trouvé à consolider"** : La commande `ipcra consolidate` cherche des fichiers `.md` modifiés dans le dossier précis `.ipcra-project/local-notes/`. Si vous écrivez vos brouillons à la racine de votre projet de code, ils seront ignorés par sécurité.
- **Vérifier l'état du lanceur** : Utilisez à tout moment `ipcra doctor`.

---

## Exemple de sortie `ipcra health`

```
📊 Health Check — 2026-02-20

📥 Inbox: 3 notes (⚠ 1 > 7 jours)
⏳ Waiting-for: 2 items
🚀 Projets: 4
🗃️  Zettelkasten: 5 inbox (⚠ 2 > 7j) | 23 permanents | 4 MOC
🧠 Mémoire: 3 domaines avec entrées
📝 Streak daily: 7 jours consécutifs

📝 Modifié récemment (7j)
  • Projets/monitoring-infra/
  • memory/devops.md
  • Journal/Daily/2026/2026-02-20.md
```

---

## Licence

MIT — Utilisation libre, personnelle et commerciale.

---

## Contribuer

Les PR sont bienvenues.
Avant toute soumission : `bash -n ipcra-install.sh` + `shellcheck ipcra-install.sh`.
