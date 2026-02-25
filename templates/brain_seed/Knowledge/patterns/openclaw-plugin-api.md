---
type: knowledge
subtype: pattern
tags: [openclaw, plugin, api, hooks, typescript, devops]
project: openclawIPCRAE
domain: devops
status: stable
created: 2026-02-24
sources: project:openclawIPCRAE/src/plugins/types.ts
---

# Pattern — OpenClaw Plugin API (structure et hooks)

## Structure d'un plugin

Un plugin OpenClaw est un objet TypeScript exporté par défaut :

```typescript
const monPlugin = {
  id: "mon-plugin",
  name: "Mon Plugin",
  description: "...",
  configSchema: { parse(v) { ... } },  // optionnel
  register(api: OpenClawPluginApi) {
    // enregistrer hooks, commandes, services ici
  },
};

export default monPlugin;
```

Alternatif : export par défaut d'une fonction `(api) => void`.

## API disponible (`OpenClawPluginApi`)

### Hooks lifecycle — `api.on(hookName, handler, opts?)`

| Hook | Événement | Retour possible |
|------|-----------|-----------------|
| `before_prompt_build` | Avant construction du prompt | `{ systemPrompt?, prependContext? }` |
| `before_model_resolve` | Avant choix du modèle | `{ modelOverride?, providerOverride? }` |
| `session_start` | Début de session | void |
| `session_end` | Fin de session | void |
| `message_received` | Message entrant reçu | void |
| `message_sending` | Avant envoi réponse | `{ content?, cancel? }` |
| `before_tool_call` | Avant appel outil agent | `{ params?, block?, blockReason? }` |
| `after_tool_call` | Après appel outil agent | void |
| `before_compaction` | Avant compaction contexte | void |
| `gateway_start` / `gateway_stop` | Cycle vie gateway | void |

**Hook clé pour injection contexte IPCRAE** :
```typescript
api.on("before_prompt_build", async (event, ctx) => {
  const ctx = await buildIPCRAEContext(root, mode);
  return { prependContext: ctx };
});
```

### Commandes auto-reply — `api.registerCommand(def)`

```typescript
api.registerCommand({
  name: "capture",          // /capture sans slash
  description: "...",
  acceptsArgs: true,
  requireAuth: true,        // défaut: true
  handler: async (ctx) => {
    // ctx.args, ctx.channel, ctx.senderId, ctx.config
    return { text: "Capturé !" };  // ReplyPayload
  },
});
```

### Services background — `api.registerService(service)`

```typescript
api.registerService({
  id: "mon-service",
  start: async (ctx) => { /* ctx.stateDir, ctx.config, ctx.logger */ },
  stop: async (ctx) => { /* nettoyage */ },
});
```

### Autres méthodes

- `api.registerTool(tool, opts?)` — outil agent LLM
- `api.registerHttpRoute({ path, handler })` — endpoint HTTP
- `api.registerGatewayMethod(method, handler)` — méthode gateway JSON-RPC
- `api.registerChannel(registration)` — nouveau canal de messagerie
- `api.registerCli(registrar, opts?)` — commandes CLI `openclaw`
- `api.resolvePath(input)` — résout chemin relatif à workspace
- `api.logger` — logger structuré du plugin
- `api.pluginConfig` — configuration du plugin (depuis `~/.openclaw/config.yaml`)
- `api.config` — configuration globale OpenClaw
- `api.runtime` — accès runtime (tts, etc.)

## Workspace pnpm

`extensions/*` est déjà dans `pnpm-workspace.yaml` — tout nouveau dossier sous `extensions/` est automatiquement inclus. **Pas besoin de modifier le fichier.**

## Package.json pattern

```json
{
  "name": "@openclaw/mon-plugin",
  "version": "YYYY.M.D",
  "type": "module",
  "devDependencies": { "openclaw": "workspace:*" },
  "openclaw": { "extensions": ["./index.ts"] }
}
```

## Liens

- [[Knowledge/howto/openclaw-ipcrae-integration]]
- Source : `DEV/openclawIPCRAE/src/plugins/types.ts`
- Référence extension : `DEV/openclawIPCRAE/extensions/voice-call/`
