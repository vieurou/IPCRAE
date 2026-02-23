# Synthèse VISION vs ARCHITECTURE

Ce document fait le pont entre la vision stratégique d'IPCRAE (00_VISION.md) et son implémentation technique (02_ARCHITECTURE.md).

## Mapping Vision → Architecture

### Objectif 1 : Éliminer le bruit de mémoire des sessions IA

**Vision** : Toute vérité réside dans des fichiers locaux git-versionnés, pas dans le chat.

**Architecture correspondante** :
- **Couche 1 (Vault/Stockage)** : `memory/<domaine>.md` stocke la connaissance consolidée
- **Flux de données canonique** : `ipcrae start` → contexte minimisé → `ipcrae work` → `ipcrae close` → consolidation mémoire
- **ADR-004** : Fichiers providers générés depuis sources — source unique de vérité
- **ADR-006** : Cache tags dérivé, jamais source de vérité — reconstructible

**Commandes clés** :
- `ipcrae start <provider>` - Injecte contexte minimisé
- `ipcrae close <domaine>` - Consolide la mémoire
- `ipcrae sync` - Régénère les fichiers providers

---

### Objectif 2 : Cycle de travail IA reproductible

**Vision** : Fournir un cycle `start → work → close` qui capitalise les apprentissages.

**Architecture correspondante** :
- **Mode CDE (Context Driven Engineering)** : Intégration dans repos locaux via `.ipcrae-memory` symlink
- **Mémoire IA par domaine (ADR-003)** : `memory/devops.md`, `memory/musique.md` — réduction du bruit contextuel
- **Protocole Multi-Agent File-Based** : Coordination via `.ipcrae/multi-agent/` (state, tasks, notifications)

**Commandes clés** :
- `ipcrae start <provider>` - Démarrage session avec contexte
- `ipcrae work "<objectif>"` - Travail guidé par l'IA
- `ipcrae close <domaine>` - Consolidation et capitalisation

**Workflows typiques** (voir `docs/workflows.md`) :
- Capture → Clarifier → Organiser → Agir (GTD)
- Session de développement (daily → start → work → close → sync-git)

---

### Objectif 3 : Multi-provider IA sans lock-in

**Vision** : Permettre à plusieurs agents IA d'intervenir sur le même vault avec des contextes normalisés.

**Architecture correspondante** :
- **Multi-provider IA (ADR-002)** : Support Claude/Gemini/Codex/Kilo
- **Files providers générés** : `CLAUDE.md`, `GEMINI.md`, `AGENTS.md` depuis `context.md + instructions.md`
- **Agent-bridge** : Compare les sorties entre providers

**Commandes clés** :
- `ipcrae agent bridge "<commande>"` - Interroge agents disponibles
- `ipcrae agent hub <lead> <assistants>` - Coordonne session multi-agents
- `ipcrae allcontext "<texte>"` - Pipeline d'analyse universel

**Protocole Multi-Agent** :
- `state.env` - État de session partagé
- `tasks.tsv` - Backlog de tâches partagées
- `notifications.log` - Historique inter-agents

---

## Anti-objectifs → Contraintes techniques

### Ce n'est pas un SaaS multi-tenant

**Contrainte** : 100% local, aucun service externe.

**Architecture** :
- **ADR-001** : Stockage 100% Markdown local
- Scripts shell dans `~/bin` pour accès local
- Pas de dépendance à une base de données externe

---

### Ce n'est pas un remplacement d'Obsidian

**Contrainte** : S'intègre à Obsidian, ne le remplace pas.

**Architecture** :
- Vault Obsidian natif (Markdown + frontmatter YAML)
- Compatible Obsidian Graph View
- Commandes CLI invocables depuis Obsidian (via plugins)

---

### Ce n'est pas un système d'automatisation IA full-autonome

**Contrainte** : L'humain reste maître de la source de vérité.

**Architecture** :
- `ipcrae work` nécessite un objectif explicite
- `write_safe` avec backup automatique (ADR-005)
- Mode `--dry-run` pour vérification avant modification

---

### Ce n'est pas un outil dépendant d'un seul provider IA

**Contrainte** : Neutralité multi-agent.

**Architecture** :
- `default_provider` configurable dans `.ipcrae/config.yaml`
- Commandes `ipcrae start` acceptent n'importe quel provider
- `ipcrae-agent-hub` permet coordination multi-provider

---

## Persona cible → Implémentation CLI

### Praticien solo DevOps/DIY

**Besoins** : Système unique, léger, CLI-friendly, compatible Obsidian, multi-IA, sans friction.

**Architecture** :
- **CLI-first** : Toutes les commandes via `ipcrae` launcher
- **Léger** : Scripts shell, pas de dépendances lourdes
- **Multi-domaine** : Mémoires par domaine (devops, musique, maison, etc.)
- **Zero-friction** : `ipcrae capture` pour capture rapide, `ipcrae daily` pour workflow quotidien
- **Git-native** : `ipcrae sync-git` pour synchronisation automatique

---

## Flux de données complet (Vision → Architecture)

```
[VISION: Éliminer bruit mémoire]
              ↓
[ARCHITECTURE: Couche 1 - Vault]
              ↓
Fichiers: memory/<domaine>.md, Knowledge/, Projets/
              ↓
[ARCHITECTURE: Couche 2 - Agents IA]
              ↓
Providers: CLAUDE.md, GEMINI.md, AGENTS.md
              ↓
[ARCHITECTURE: Couche 3 - CLI]
              ↓
Commandes: ipcrae start → work → close
              ↓
[VISION: Cycle reproductible]
              ↓
Consolidation: memory/<domaine>.md mis à jour
              ↓
[VISION: Multi-provider sans lock-in]
              ↓
Agents peuvent être remplacés sans changement de vault
```

---

## Décisions techniques vs Vision

| Vision | Décision technique | Justification |
|--------|-------------------|---------------|
| Eliminer bruit mémoire | Mémoire par domaine (ADR-003) | Réduction du bruit contextuel |
| Cycle reproductible | Flux canonique start/work/close | Standardisation du workflow IA |
| Multi-provider | Fichiers providers générés (ADR-004) | Source unique de vérité |
| Local uniquement | Stockage Markdown local (ADR-001) | Pas de dépendance externe |
| Humain maître | write_safe avec backup (ADR-005) | Rollback possible |
| Multi-agent | Protocole file-based | Coordination sans serveur |
| Git-native | Sync automatique | Versionning natif |

---

## Alignement avec les workflows GTD

### Vision : Structure la connaissance, les projets et la mémoire

**Architecture GTD** :
- **Capture** : `ipcrae capture`, `Inbox/demandes-brutes/`
- **Clarifier** : Frontmatter YAML enrichi automatiquement
- **Organiser** : `Projets/<slug>/demandes/`, `Knowledge/`, `Casquettes/`
- **Agir** : `ipcrae work "<objectif>"`

**Voir `docs/workflows.md`** pour les workflows détaillés :
- Capture et traitement automatique des idées
- Création de nouveaux projets avec CDE
- Intégration de projets existants
- Collaboration multi-agents

---

## Évolution future (Roadmap)

### Court terme (v1.1.0)
- [ ] Génération automatique de `08_COMMANDS_REFERENCE.md` depuis `ipcrae-launcher.sh`
- [ ] Tests de non-régression des commandes
- [ ] Plugin Obsidian pour invocation directe des commandes

### Moyen terme (v1.2.0)
- [ ] Interface web minimaliste (optionnelle) pour visualisation
- [ ] Intégration avec d'autres outils de productivité (Notion, Todoist)
- [ ] Mode "assistant vocal" pour capture mains libres

### Long terme (v2.0.0)
- [ ] Machine learning pour classification automatique GTD
- [ ] Recommandations de tâches basées sur historique
- [ ] Mode "IA autonome" pour tâches répétitives (sous supervision humaine)

---

## Mesures de succès

### Vision
- ✅ 100% des décisions IA sont dans `memory/<domaine>.md`
- ✅ Cycle start/work/close est utilisé systématiquement
- ✅ Multi-provider fonctionne sans friction

### Architecture
- ✅ Toutes les ADR sont respectées
- ✅ Cache tags est reconstructible (`ipcrae index`)
- ✅ Protocole multi-agent file-based fonctionne

### Expérience utilisateur
- ✅ CLI est rapide et intuitive
- ✅ Obsidian integration est transparente
- ✅ Git sync est automatique et fiable

---

## Conclusion

IPCRAE est un système **vision-first** avec une **architecture solide** qui soutient chaque aspect de la vision :

1. **Elimination du bruit mémoire** → Mémoires par domaine + flux canonique
2. **Cycle reproductible** → Commandes start/work/close + consolidation automatique
3. **Multi-provider sans lock-in** → Fichiers providers générés + protocole multi-agent
4. **Local uniquement** → Stockage Markdown local + scripts shell
5. **Humain maître** → write_safe + backups + mode dry-run
6. **Intégration Obsidian** → Vault natif + frontmatter YAML
7. **CLI-friendly** → Launcher unique + commandes intuitives

L'architecture n'est pas une contrainte, mais un **enabler** de la vision.

---

**Documents liés** :
- `docs/conception/00_VISION.md` - Vision et objectifs
- `docs/conception/02_ARCHITECTURE.md` - Architecture technique
- `docs/conception/08_COMMANDS_REFERENCE.md` - Référence des commandes
- `docs/workflows.md` - Workflows GTD détaillés