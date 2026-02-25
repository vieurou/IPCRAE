---
type: knowledge
subtype: howto
tags: [openclaw, ipcrae, integration, plugin, vault, contexte, devops]
project: openclawIPCRAE
domain: devops
status: en-cours
created: 2026-02-24
sources: project:openclawIPCRAE/extensions/voice-call/index.ts
---

# Howto — Intégrer OpenClaw avec IPCRAE

## Objectif

Faire fonctionner OpenClaw selon la méthode IPCRAE :
- Vault comme mémoire long terme (contexte injecté dans chaque prompt)
- Journal de session automatique dans `Journal/Daily/<date>/openclaw.md`
- Capture inbox via commande `/capture`
- Protection des données vault (RÈGLE 0)

## Architecture cible

```
DEV/openclawIPCRAE/
├── extensions/
│   └── ipcrae/              ← plugin à créer
│       ├── package.json
│       ├── openclaw.plugin.json  (optionnel, métadonnées)
│       ├── index.ts          ← entry point plugin
│       └── src/
│           ├── context.ts    ← buildIPCRAEContext()
│           ├── vault.ts      ← writeJournalEntry(), captureInbox()
│           └── config.ts     ← IPCRAEConfig + resolveConfig()
├── skills/
│   └── ipcrae/
│       └── SKILL.md          ← description système pour agents
```

## Fichiers vault impliqués

| Fichier vault | Rôle dans le plugin |
|---------------|---------------------|
| `.ipcrae/context.md` | Contexte principal injecté |
| `memory/<domaine>.md` | Mémoire domaine injectée |
| `Phases/index.md` | Phase active pour /ipcrae-status |
| `Projets/<slug>/tracking.md` | Tracking projet pour /ipcrae-status |
| `Journal/Daily/<date>/openclaw.md` | Journal session (session_end) |
| `Inbox/idees/<slug>.md` | Capture /capture |
| `.ipcrae/prompts/core_ai_pretreatment_gate.md` | RÈGLE 0 (à injecter) |

## Hooks utilisés

### 1. `before_prompt_build` → injection contexte

```typescript
api.on("before_prompt_build", async (event, ctx) => {
  const context = await buildIPCRAEContext(ipcraeRoot, contextMode);
  return { prependContext: context };
});
```

`buildIPCRAEContext()` lit (cache 5 min TTL) :
- `context.md` (identité, structure, projets actifs)
- `memory/<domaine>.md` (mémoire domaine si détectable)
- Phase active depuis `Phases/index.md`
- `core_ai_pretreatment_gate.md` (RÈGLE 0)

Mode `compact` → < 3 KB. Mode `full` → tout. Mode `minimal` → juste context.md.

### 2. `session_end` → journal vault

```typescript
api.on("session_end", async (event, ctx) => {
  if (autoJournal) {
    await writeJournalEntry(ipcraeRoot, new Date(), {
      sessionId: event.sessionId,
      messageCount: event.messageCount,
      durationMs: event.durationMs,
    });
  }
});
```

### 3. `message_received` → détection /capture (géré via registerCommand)

## Commandes auto-reply

| Commande | Description |
|----------|-------------|
| `/capture <texte>` | Écrit dans `Inbox/idees/` du vault |
| `/ipcrae-status` | Affiche phase active + projet actif |

## Config `~/.openclaw/config.yaml`

```yaml
plugins:
  entries:
    ipcrae:
      enabled: true
      config:
        ipcraeRoot: ~/IPCRAE
        contextMode: compact       # full | compact | minimal
        autoJournal: true
        autoCapture: true
agents:
  defaults:
    workspace: ~/IPCRAE
    memory:
      longTermFile: memory/openclaw.md
```

## Ordre de création (feature branch DEV)

1. `extensions/ipcrae/package.json`
2. `extensions/ipcrae/src/config.ts`
3. `extensions/ipcrae/src/context.ts`
4. `extensions/ipcrae/src/vault.ts`
5. `extensions/ipcrae/index.ts`
6. `skills/ipcrae/SKILL.md`
7. `extensions/ipcrae/README.md`
8. `ipcrae close devops --project openclawIPCRAE`

## État (2026-02-24)

- [x] Plan défini et documenté dans cerveau
- [x] API OpenClaw explorée et documentée
- [x] core_ai_pretreatment_gate.md créé
- [ ] Plugin extensions/ipcrae/ créé
- [ ] Skill IPCRAE créé
- [ ] PR mergée
- [ ] Test `openclaw plugins list` montre plugin ipcrae

## Liens

- [[Knowledge/patterns/openclaw-plugin-api]]
- Source : `DEV/openclawIPCRAE/src/plugins/types.ts:245`
- Référence extension voix : `DEV/openclawIPCRAE/extensions/voice-call/`
- Règle 0 : `IPCRAE/.ipcrae/prompts/core_ai_pretreatment_gate.md` (à créer)
