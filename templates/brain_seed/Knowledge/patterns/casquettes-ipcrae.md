---
type: knowledge
tags: [casquettes, ipcrae, roles, responsabilites, gtd, contexte, workflow]
domain: devops
status: stable
sources: [vault:IPCRAE/CLAUDE.md, vault:Casquettes/]
created: 2026-02-22
updated: 2026-02-22
---

# Casquettes IPCRAE — Rôles et Responsabilités Continues

## Concept

Dans IPCRAE, une **Casquette** représente un rôle ou une responsabilité continue (pas un projet ponctuel). Analogie GTD : "Areas of Responsibility".

Différence avec un Projet :
- **Projet** : objectif ponctuel avec une fin définie → `Projets/<slug>/`
- **Casquette** : rôle permanent sans fin → `Casquettes/<nom>.md`

## Casquettes actives

| Casquette | Domaine | Responsabilités |
|-----------|---------|----------------|
| Lead Developer | devops | Architecture, code review, CI/CD, sécurité |
| Architecte Hardware | electronique | Conception PCB, choix composants, firmware |
| ipcrae-toolchain | devops | Maintien des scripts CLI, templates, process |

## Structure d'une Casquette

```markdown
---
type: casquette
tags: [casquette, <domaine>, <role>]
domain: <domaine>
status: active
---

# Casquette — <Nom du Rôle>

## Responsabilités permanentes
- ...

## Principes / Standards à maintenir
- ...

## Next Actions récurrentes
- [ ] ...

## Projets rattachés
- [[Projets/<slug>]] — ...
```

## Utilisation dans le workflow GTD

1. **Revue hebdomadaire** : vérifier chaque Casquette → y a-t-il des actions à planifier ?
2. **Priorisation** : les Casquettes définissent les zones de responsabilité → les projets en découlent
3. **Contexte** : quand une tâche est ambiguë, la rattacher à une Casquette clarifier son domaine

## Lien avec les Agents IA

Chaque Casquette correspond généralement à un agent domaine :
- Casquette Lead Developer → `agent_devops.md`
- Casquette Architecte Hardware → `agent_electronique.md`
- Casquette ipcrae-toolchain → `agent_devops.md` (spécialisé IPCRAE)

## Liens
- [[gtd-adapte-ipcrae]] — Concept général GTD dans IPCRAE
- [[phases-objectifs-ipcrae]] — Phases de vie et objectifs long terme
- [[memoire-domaine-ipcrae]] — Mémoire par domaine (décisions passées)
