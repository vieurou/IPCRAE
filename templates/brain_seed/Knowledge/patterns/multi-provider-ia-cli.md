---
type: knowledge
tags: [ia, multi-agent, cli, token-optimization, no-lock-in, bridge]
project: IPCRAE
domain: devops
status: stable
sources:
  - project:IPCRAE/templates/scripts/ipcrae-agent-bridge.sh
  - project:IPCRAE/templates/scripts/ipcrae-tokenpack.sh
created: 2026-02-21
updated: 2026-02-21
---

# Pattern : Orchestration multi-provider IA via CLI

## Problème
Dépendre d'un seul provider IA CLI crée un lock-in. Les agents ont des forces différentes. Tester manuellement plusieurs agents pour une même demande est coûteux.

## Solution : Bridge + Tokenpack + Prompt Optimize

### 1. Réduire les tokens avant d'envoyer
```bash
# Génère un contexte compact (supprime vides, commentaires, applique limite taille)
ipcrae-tokenpack core              # contexte global
ipcrae-tokenpack project mon-projet  # contexte projet spécifique
```

### 2. Optimiser le prompt selon l'agent
```bash
ipcrae-prompt-optimize claude "Refactoriser l'installateur bash"
ipcrae-prompt-optimize gemini "Refactoriser l'installateur bash"
```

### 3. Déléguer en parallèle avec cache
```bash
ipcrae-agent-bridge "Plan de migration v3.2 → v3.3"
ipcrae-agent-bridge --no-cache "Plan de migration v3.2 → v3.3"
ipcrae-agent-bridge --ttl 3600 "Plan de release"
```

## Stratégie de routing par type de tâche
| Type de tâche | Agent recommandé | Raison |
|--------------|-----------------|--------|
| Architecture, arbitrage, risques | Claude | Raisonnement long, cohérence |
| Code/outils/enchaînements CLI | Gemini | Fort en tool use et terminal |
| Patch minimal, validation diff | Codex | Efficace sur changements ciblés |
| Rédaction, documentation | Claude | Qualité rédactionnelle |

## Cache de réponses
- Stocké dans `.ipcrae/cache/` avec hash (prompt + contexte)
- TTL par défaut configurable
- Ne jamais traiter le cache comme source de vérité — dérivé, reconstructible

## Anti-patterns
- Envoyer un contexte plein (non-tokenpacké) à chaque agent = gaspillage tokens
- Utiliser toujours le même agent sans considérer ses forces = sorties sous-optimales
- Confondre cache de réponses et mémoire IA (mémoire = `memory/<domaine>.md`, jamais le cache)
