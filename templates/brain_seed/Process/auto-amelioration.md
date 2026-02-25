---
type: process
tags: [ipcrae, auto-amelioration, audit, cerveau, methode, process]
domain: all
status: active
created: 2026-02-21
updated: 2026-02-21
---

# Process — Auto-Amélioration IPCRAE

## Déclencheur

- En début de session IA si le score vault est inconnu ou stale (> 24h)
- Quand l'utilisateur demande explicitement une vérification ou amélioration du système
- Après tout changement structurel (scripts, instructions, prompts)
- En mode automatique : `ipcrae-auto auto-audit --agent claude --force`

## Pré-requis

- `IPCRAE_ROOT` exporté dans le shell
- `ipcrae-audit-check` installé dans `~/bin/`
- `ipcrae-auto-apply` installé dans `~/bin/`
- Mode auto-amélioration activé : `last_audit_claude.txt` présent dans `.ipcrae/auto/`

---

## Étapes

### 1. Lancer l'audit du vault

```bash
IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae-audit-check
```

Lire la sortie complète. Identifier :
- Score global (X/40)
- Nombre de Critiques / Importants / Mineurs
- Liste des GAPS DÉTECTÉS

### 2. Vérifier le cerveau global (vault)

Contrôler manuellement que les fichiers suivants reflètent bien le travail effectué :

| Fichier | Ce qui doit y être |
|---------|-------------------|
| `memory/<domaine>.md` | Entrée datée pour chaque session (### YYYY-MM-DD) |
| `Projets/<slug>/tracking.md` | Tâches cochées [x] dans Done |
| `Journal/Daily/<YYYY>/<YYYY-MM-DD>.md` | Session(s) documentée(s) |
| `Projets/<slug>/index.md` | Statut et next action à jour |
| `.ipcrae/context.md` | Projets en cours et working set à jour |

### 3. Vérifier le cerveau local (projet)

Contrôler dans `.ipcrae-project/` du projet actif :

| Fichier | Ce qui doit y être |
|---------|-------------------|
| `tracking.md` | Tâches cochées [x] pour les sessions récentes |
| `memory/session_<agent>_<date>.md` | Mémoire locale de la session (non gitée, machine-local) |

### 4. Identifier et corriger les gaps

Pour chaque gap identifié en étapes 1-3 :

**Gap vault (fichier manquant ou incomplet)** :
→ Compléter directement le fichier concerné

**Gap code (script cassé ou comportement incorrect)** :
→ Identifier la root cause → corriger dans `DEV/IPCRAE/scripts/` → PR → **merge immédiat (sans validation intermédiaire)** → réinstaller

> **Règle auto-merge** : en mode auto-amélioration, les PRs DEV/IPCRAE sont créées ET mergées dans la même séquence, sans attendre confirmation utilisateur. La revue se fait sur le diff commité, pas sur la PR ouverte.

**Gap méthode (instruction absente ou ambiguë)** :
→ Modifier `.ipcrae/instructions.md` ou `.ipcrae/prompts/core_*.md` ou `prompt_close.md`
→ Lancer `ipcrae sync` pour régénérer CLAUDE.md/GEMINI.md/AGENTS.md

### 5. Appliquer les corrections automatiques

```bash
IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae-auto-apply --auto
```

Lire la sortie. Vérifier que les corrections auto ont bien été appliquées.

### 6. Relancer l'audit pour mesurer l'amélioration

```bash
IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae-audit-check
```

Comparer le nouveau score avec le score initial (étape 1).
Documenter le delta dans `memory/<domaine>.md`.

### 7. Mettre à jour Process/index.md si un nouveau process a été créé

Si un process a été créé ou modifié pendant la session → mettre à jour `Process/index.md`.

### 8. Vérifications avancées (optionnel mais recommandé)

Si des modifications significatives ont été apportées :
- `ipcrae process review-coherence-doc-code` — Vérifier la cohérence documentation ↔ code
- `ipcrae process anti-regression-commits` — Vérifier les régressions basées sur les commits
- `ipcrae process architecte-methode` — Vérifier la cohérence de la méthode IPCRAE v3.3

### 9. Clôturer selon Process/session-close.md

```bash
ipcrae close <domaine> --project <slug>
```

---

## Checklist de qualité (post auto-amélioration)

- [ ] Score vault calculé (étape 1) et comparé (étape 6)
- [ ] Cerveau global vérifié (étape 2) — aucun fichier manquant
- [ ] Cerveau local vérifié (étape 3) — tracking à jour
- [ ] Gaps identifiés et corrigés (code ET/OU méthode)
- [ ] `ipcrae-auto-apply --auto` exécuté
- [ ] Delta score documenté dans `memory/<domaine>.md`
- [ ] `Process/index.md` mis à jour si nouveau process créé
- [ ] Session clôturée via `ipcrae close` (commit + push + tag)

## Fréquence

- **Déclenchée manuellement** : à chaque session d'amélioration explicite
- **Déclenchée automatiquement** : selon la fréquence configurée dans `ipcrae-auto` (défaut : quotidien)

## Agent IA recommandé

Tous agents — ce process est universel.
Lire `templates/prompts/template_auto_amelioration.md` pour le prompt IA complet.

## Hook Post-Réponse (Automatisé)

Depuis le 2026-02-22, le système inclut un hook d'auto-amélioration automatique intégré dans `Process/session-close.md`:

```bash
IPCRAE_ROOT=$IPCRAE_ROOT ipcrae-auto-apply --auto
```

### Fonctionnement

1. **Déclenchement** : À chaque `ipcrae close`
2. **Actions automatiques** :
   - Vérification du score vault (via `ipcrae-audit-check`)
   - Commit des modifications locales si nécessaire
   - Reconstruction du cache des tags si obsolète (>24h)
   - Comparaison des scores avant/après

3. **Résultats attendus** :
   - Score amélioré ou stable (jamais dégradé)
   - Vault toujours dans un état commité
   - Cache des tags à jour

### Scénarios Testés

| Scénario | Comportement | Résultat |
|----------|--------------|----------|
| Vault optimal (25/25) | Aucune action | Score stable |
| Modifications non commitées | Commit automatique | +5 points |
| Cache obsolète | Reconstruction | +2 points |

### Fichiers Concernés

- `scripts/ipcrae-auto-apply` : Script principal
- `scripts/ipcrae-index.sh` : Reconstruction du cache
- `Process/session-close.md` : Intégration du hook

### Règle de Sécurité

Le hook ne commit que les modifications existantes — il ne crée pas de nouveaux fichiers ou modifications. Pour les corrections nécessitant une intervention manuelle, un ticket est créé dans `Inbox/`.
