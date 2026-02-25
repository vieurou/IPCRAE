---
type: howto
tags: [ipcrae, agent, bootstrap, conformite, session]
domain: devops
project: IPCRAE
status: active
created: 2026-02-22
updated: 2026-02-22
sources: [project:IPCRAE/Plans/phase1-audit-context-injection.md]
---

# ipcrae-agent-bootstrap — Protocole de démarrage agent

## Rôle

Script de bootstrap exécuté à chaque `ipcrae start`. Remplit deux fonctions :

1. **Rappel visuel** des règles critiques IPCRAE (bannière 🔴/🟠/🟡)
2. **Traçabilité** : log de chaque session dans `.ipcrae/auto/bootstrap-log.txt`

La Section 9 de l'audit mesure la conformité via ce log.

## Localisation

```
~/bin/ipcrae-agent-bootstrap
```

## Usage

```bash
# Mode auto (non-interactif) — appelé par ipcrae start
ipcrae-agent-bootstrap --auto --project IPCRAE

# Mode interactif — confirmation manuelle
ipcrae-agent-bootstrap --project IPCRAE
# → attend la saisie : IPCRAE:VALIDATED
```

## Log produit

Fichier : `$IPCRAE_ROOT/.ipcrae/auto/bootstrap-log.txt`

Format d'une ligne :
```
2026-02-22 18:45:00 | project=IPCRAE | domain=devops | mode=auto
```

## Intégration dans ipcrae start

Dans `~/bin/ipcrae`, `cmd_start()` appelle bootstrap après le parsing des args :

```bash
if command -v ipcrae-agent-bootstrap &>/dev/null; then
  ipcrae-agent-bootstrap --auto --project "${project:-}" 2>/dev/null || true
fi
```

L'appel est `|| true` pour ne jamais bloquer le flux `ipcrae start`.

## Section 9 — Conformité Agent

| Critère | Points | Condition |
|---------|--------|-----------|
| 9.1 Bootstrap loggué < 24h | 2 (CRITIQUE) | log < 24h |
| 9.2 Tags lowercase sur notes récentes (7j) | 2 (IMPORTANT) | 0 note avec majuscules |
| 9.3 Pas de bypass Zettelkasten/permanents/ | 1 (MINEUR) | 0 note directe < 24h |

**Total section : 5 pts / MAX_SCORE=65**

## Règles rappelées par la bannière

### 🔴 Critiques
- Tags frontmatter **toujours en minuscules**
- Nouvelles notes → `Inbox/` ou `Zettelkasten/_inbox/` (jamais `permanents/` directement)
- Pattern grep : `grep "..." | wc -l | tr -d ' \t'` (jamais `grep -c ... || echo 0`)

### 🟠 Obligatoires
- 3 fichiers à mettre à jour en fin de session : `memory/`, `tracking.md`, `Journal/Daily/`
- Toujours clôturer avec `ipcrae close <domaine> --project <slug>`

### 🟡 Importantes
- Chargement sélectif : `session-context.md` en premier
- Knowledge notes pour chaque pattern réutilisable
- Recherche par tags avant arborescence

## Liens

- [[ipcrae-session-workflow]] — workflow complet start/work/close
- [[ipcrae-audit-check]] — script d'audit (Section 9)
- [[ipcrae-knowledge-tags]] — conventions de tags
