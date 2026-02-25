---
type: knowledge
tags: [phases, objectifs, vision, someday-maybe, ipcrae, planning, gtd]
domain: devops
status: stable
sources: [vault:IPCRAE/CLAUDE.md, vault:Phases/, vault:Objectifs/]
created: 2026-02-22
updated: 2026-02-22
---

# Phases et Objectifs IPCRAE

## Concept de Phase

Une **Phase de Vie** dans IPCRAE = une période définie (mois/trimestre) avec un focus thématique dominant. C'est le lien entre la vision long terme (Objectifs) et les actions quotidiennes (Projets/Casquettes).

```
Vision long terme (Objectifs/Vision.md)
  ↓
Phases actives (Phases/index.md) — trimestre
  ↓
Projets actifs (Projets/<slug>/) — semaines
  ↓
Tâches (tracking.md In Progress) — jours
  ↓
Next Actions (Casquettes) — aujourd'hui
```

## Structure Phases/

```
Phases/
├── index.md          ← source de vérité (phases actives)
└── archives/
    └── 2026-Q1.md   ← phase clôturée
```

### Format Phase (index.md)

```markdown
## Phase active — 2026-Q1 : Fondation Système IA

**Durée** : 2026-01 → 2026-03
**Focus** : Outillage IPCRAE, infrastructure DevOps base
**Objectif principal** : Système IPCRAE autonome opérationnel

### Projets de la phase
- [ ] IPCRAE toolchain v3 complet
- [ ] megadockerapi infrastructure stable

### Critères de clôture
- [ ] Score audit ≥ 38/40
- [ ] Tous les projets actifs ont un hub IPCRAE complet
```

## Objectifs — Hiérarchie GTD

| Horizon | Fichier | Durée | Contenu |
|---------|---------|-------|---------|
| Vision | `Objectifs/Vision.md` | 3-5 ans | Où veux-je être ? |
| Quarterly | `Objectifs/Quarterly.md` | 3 mois | Grands objectifs trimestre |
| Someday/Maybe | `Objectifs/Someday-Maybe.md` | indefini | Idées + rêves à évaluer |

## Someday/Maybe — Gestion des Idées en Suspens

Concept GTD : les idées trop vagues ou trop lointaines pour un projet actif.

Processus :
1. **Capturer** → `Inbox/` (idées/)
2. **Clarifier** → actionnable dans 3 mois ? Non → `Objectifs/Someday-Maybe.md`
3. **Revue hebdomadaire** → est-ce que ça devient un projet ?
4. **Activer** → déplacer vers `Projets/<slug>/` quand le moment vient

Format :
```markdown
## Someday/Maybe

- [ ] Apprendre Rust (dès que IPCRAE stable)
- [ ] Créer un générateur de sons basé sur ML (après USW v1)
- [ ] Monter un cluster k8s home lab (Q3 2026)
```

## Waiting-For — Délégation GTD

Suivi des actions en attente d'un tiers :

```
Inbox/waiting-for.md :
- [ ] [2026-02-22] PR #23 review → vieurou/IPCRAE (merge attendu)
- [ ] [2026-02-22] Commande PCB → JLCPCB (livraison J+14)
```

Revue hebdomadaire : relancer si délai dépassé.

## Liens
- [[casquettes-ipcrae]] — Rôles permanents
- [[gtd-adapte-ipcrae]] — Workflow GTD complet
- [[session-protocol-ipcrae]] — Cycle quotidien
