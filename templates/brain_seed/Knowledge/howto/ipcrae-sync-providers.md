---
type: knowledge
tags: [ipcrae, sync, providers, claude, gemini, context, generation, workflow]
domain: devops
status: stable
sources: [vault:.ipcrae/context.md, vault:CLAUDE.md, project:IPCRAE/ipcrae-install.sh]
created: 2026-02-22
updated: 2026-02-22
---

# ipcrae sync — Génération des Fichiers Provider IA

## Concept

IPCRAE maintient plusieurs fichiers d'instructions pour différents agents IA :
- `CLAUDE.md` → Claude (Anthropic)
- `GEMINI.md` → Gemini (Google)
- `AGENTS.md` → OpenAI / Codex
- `.kilocode/rules/ipcrae.md` → Kilocode

Ces fichiers sont **générés automatiquement** depuis deux sources de vérité :
1. `.ipcrae/context.md` — contexte global + projets + working set
2. `.ipcrae/instructions.md` — règles métier + workflow IA

## Règle absolue

**Ne jamais éditer CLAUDE.md / GEMINI.md manuellement.**

Toute modification → éditer `.ipcrae/context.md` ou `.ipcrae/instructions.md`, puis :
```bash
ipcrae sync
# ou avec IPCRAE_ROOT explicite :
IPCRAE_ROOT=/home/eric/IPCRAE ~/bin/ipcrae sync
```

## Ce que fait `ipcrae sync`

1. Lit `.ipcrae/context.md` (données structurées)
2. Lit `.ipcrae/instructions.md` (règles IA)
3. Génère les 4 fichiers provider (template Markdown)
4. Affiche les fichiers modifiés

## Déclencheurs obligatoires

`ipcrae sync` doit être lancé après :
- Modification de `.ipcrae/context.md` (nouveau projet, working set, phase)
- Modification de `.ipcrae/instructions.md` (nouvelles règles)
- Modification de `.ipcrae/prompts/*.md` (prompts core, agents)
- Avant `ipcrae close` si des prompts ont changé

## Cohérence globale (obligatoire)

Quand une source de vérité bouge, **tous les fichiers liés doivent être mis à jour** :
- Si tu changes un prompt ou une règle → mettre à jour la doc associée + relancer `ipcrae sync`.
- Si tu changes une structure (seed/process/knowledge) → mettre à jour `templates/brain_seed/` et la doc.
- Si tu ajoutes/supprimes des tags → relancer `ipcrae index`.

**Règle** : pas de fermeture de tâche tant que les fichiers liés + index ne sont pas à jour.

## Architecture `.ipcrae/`

```
.ipcrae/
├── context.md          ← source de vérité contexte
├── instructions.md     ← règles métier IA
├── config.yaml         ← config launcher (remotes git, etc.)
├── cache/
│   └── tag-index.json  ← cache reconstructible (ipcrae index)
├── auto/               ← état auto-amélioration + inbox scan
│   ├── inbox-agent-prefs.yaml
│   ├── inbox-pending.md
│   └── last_audit_*.txt
└── prompts/            ← agents + core prompts
    ├── agent_devops.md
    ├── core_ai_workflow_ipcra.md
    └── ...
```

## Diagnostic — `ipcrae health`

Vérifie l'état du système :
```bash
ipcrae health
# Vérifie :
# - Inbox stale (fichiers > 7 jours non traités)
# - Waiting-for expirés
  # - CLAUDE.md synchronisé avec context.md
  # - tag-index.json valide

## Diagnostic — `ipcrae doctor`

`ipcrae doctor` vérifie aussi la **cohérence sync/index** :
- changements prompts/instructions → `ipcrae sync`
- changements Knowledge/Zettelkasten/Process/Ressources → `ipcrae index`
```

## Liens
- [[session-protocol-ipcrae]] — Ordre d'appel dans les cycles
- [[tag-first-navigation]] — Cache tag-index.json
- [[auto-amelioration-ipcrae]] — ipcrae-audit-check
