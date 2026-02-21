# OS IA IPCRAE — Modèle en 3 couches

## Objectif
Formaliser la séparation **stockage local / agent / interface terminal** et les sources de vérité pour rendre le contexte IA robuste, auditable et dynamique.

## Couche 1 — Stockage local (Vault)
- Répertoire source: le vault IPCRAE (`Knowledge/`, `Zettelkasten/`, `memory/`, `.ipcrae/`, `Projets/`).
- Sources de vérité minimales:
  1. `.ipcrae/context.md` (état actif: working set, priorités, projet/phase).
  2. `.ipcrae/instructions.md` (règles d'exécution agentiques).
  3. `memory/<domaine>.md` (historique décisionnel consolidé).
  4. `.ipcrae/cache/tag-index.json` (index opérationnel pour recherche rapide par tags).
- Le cache tags est dérivé, pas primaire.

## Couche 2 — Agent (Claude/Gemini/Codex/Kilo)
- Les fichiers provider (`CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `.kilocode/rules/ipcrae.md`) sont **générés** depuis:
  - `.ipcrae/context.md`
  - `.ipcrae/instructions.md`
- Règle: ne pas éditer les fichiers provider à la main; utiliser `ipcrae sync`.

## Couche 3 — Interface terminal (CLI + scripts)
- Commandes canoniques du cycle de session:
  - `ipcrae start` → initialise le contexte de session (phase/weekly/projet).
  - `ipcrae work "<objectif>"` → exécution IA avec contexte minimisé (tokenpack logique + tags pertinents).
  - `ipcrae close <domaine> --project <slug>` → consolidation dynamique post-session.
  - `ipcrae sync` → régénération provider/agents.
- Commandes d'indexation:
  - `ipcrae index` / `ipcrae-index`
  - `ipcrae tag <tag>` / `ipcrae-tag <tag>`

## Invariants système (v3.3)
1. `.ipcrae/context.md` existe.
2. `.ipcrae/instructions.md` existe.
3. Providers générés et synchronisés avec les sources.
4. `.ipcrae/cache/tag-index.json` présent.
5. En mode projet local: symlink/hub projet cohérent (mode dégradé toléré mais signalé).

Ces invariants sont vérifiés par `ipcrae doctor`.
