---
type: prompt
tags: [auto-amelioration, audit, conformite, ipcrae]
domain: system
status: active
created: 2026-02-21
updated: 2026-02-21
---

# Prompt — Auto-Amélioration IPCRAE

## Contexte

Agent: {{agent}} | Date: {{date}} | Score précédent: {{last_score}}/40

Ce prompt déclenche un cycle complet d'auto-amélioration du vault IPCRAE.
Il suit le même format séquentiel que `prompt_sprint.md` et `prompt_ingest.md`.

**Pré-conditions** :
- `IPCRAE_ROOT` est défini et pointe vers le vault actif
- Les scripts `ipcrae-audit-check` et `ipcrae-auto-apply` sont installés dans `~/bin/`
- Le mode auto-amélioration est activé (`last_audit_{{agent}}.txt` présent dans `.ipcrae/auto/`)

---

## BLOC 1 — AUDIT [obligatoire en premier]

**Objectif** : obtenir le score actuel du vault et identifier les gaps.

T1.1 — Lancer l'audit :
```bash
IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae-audit-check
```
Lire la sortie complète. Noter le score global et le nombre de Critiques/Importants/Mineurs.

T1.2 — Identifier les 3 gaps prioritaires (ordre : Critique > Important > Mineur).
Documenter dans un tableau :

| # | Gap | Sévérité | Commande de correction |
|---|-----|----------|----------------------|
| 1 | ... | Critique | ... |
| 2 | ... | Important | ... |
| 3 | ... | Mineur | ... |

T1.3 — Si le score est ≥ 35/40 et 0 Critique : passer directement au BLOC 3.

---

## BLOC 2 — CORRECTIONS [si score < 35 ou Critiques > 0]

**Objectif** : réduire les gaps par ordre de sévérité.

### 2a — Corrections auto (sûres, toujours applicables)
```bash
IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae-auto-apply --auto
```
Lire la sortie. Vérifier que les corrections auto ont bien été appliquées.

### 2b — Corrections guidées (demander confirmation si interactif)
Pour chaque gap Important identifié en T1.2 :

- **Daily manquante** → `ipcrae daily`
- **Weekly manquante** → `ipcrae weekly`
- **tag-index stale** → `ipcrae index`
- **CLAUDE.md désync** → `ipcrae sync`
- **Vault non commité** → `git -C $IPCRAE_ROOT add -A && git commit`
- **Mémoire domaine > 7j** → `ipcrae close <domaine> --project <slug>`

T2.3 — Lister les corrections manuelles pour suivi (ne pas les appliquer sans confirmation) :
- Permanents Zettelkasten vides → initier workflow de validation
- Phase non définie → créer depuis Process/
- Objectifs absents → créer Objectifs/vision.md

---

## BLOC 3 — DOCUMENTATION [obligatoire]

**Objectif** : tracer l'audit et l'évolution du score.

T3.1 — Écrire le rapport daté :
```bash
REPORT_DIR="$IPCRAE_ROOT/.ipcrae/auto"
REPORT_FILE="$REPORT_DIR/report-{{date}}.md"
```

Le rapport doit contenir :
```markdown
# Rapport Auto-Amélioration — {{date}}
Agent: {{agent}} | Score: XX/40 (YY%)
Score précédent: {{last_score}}/40 | Delta: ±Z pts

## Gaps identifiés
| Sévérité | Gap | Corrigé |
|----------|-----|---------|
| Critique | ... | ✓/✗ |
| Important | ... | ✓/✗ |
| Mineur | ... | ✓/✗ |

## Corrections appliquées
- Auto : [liste]
- Guidées : [liste]
- Manuelles à faire : [liste]

## Prochain audit
Date suggérée: {{next_audit_date}}
```

T3.2 — Mettre à jour l'historique :
```bash
echo "$(date '+%Y-%m-%d %H:%M') | Score: XX/40 | Agent: {{agent}}" >> "$REPORT_DIR/history.md"
```

T3.3 — Comparer avec le score précédent :
- Delta positif → noter les actions ayant eu de l'impact
- Delta négatif → identifier la régression et créer une tâche corrective
- Delta nul → vérifier que les gaps sont bien documentés

---

## BLOC 4 — CLÔTURE [toujours dernier]

**Objectif** : persister l'état et programmer le prochain cycle.

T4.1 — Commiter le vault si des modifications ont été appliquées :
```bash
git -C "$IPCRAE_ROOT" status --porcelain | grep -q . && \
  git -C "$IPCRAE_ROOT" add -A && \
  git -C "$IPCRAE_ROOT" commit -m "chore(ipcrae): auto-amelioration $(date '+%Y-%m-%d')"
```

T4.2 — Mettre à jour le timestamp du dernier audit :
```bash
date +%s > "$IPCRAE_ROOT/.ipcrae/auto/last_audit_{{agent}}.txt"
```

T4.3 — Afficher le résumé final :
```
Score initial : {{last_score}}/40
Score final   : XX/40
Delta         : ±Z pts
Critiques restants : N
Prochain audit : {{next_audit_date}}
```

---

## Définition de Done

- [ ] Score global calculé et affiché (ipcrae-audit-check exécuté)
- [ ] Gaps critiques identifiés et documentés (tableau T1.2)
- [ ] Auto-corrections appliquées (ipcrae-auto-apply --auto exécuté)
- [ ] Corrections guidées proposées ou appliquées
- [ ] Rapport daté écrit dans `.ipcrae/auto/report-{{date}}.md`
- [ ] Historique mis à jour (`history.md`)
- [ ] Delta score calculé et commenté
- [ ] Vault commité si modifications appliquées
- [ ] `last_audit_{{agent}}.txt` mis à jour avec timestamp Unix

---

## Valeurs de référence

| Score | Interprétation | Action |
|-------|---------------|--------|
| 35–40 | Excellent | Maintenance uniquement |
| 25–34 | Correct | Corriger les Importants |
| 15–24 | Dégradé | Traiter tous les gaps |
| < 15  | Critique | Session dédiée obligatoire |
