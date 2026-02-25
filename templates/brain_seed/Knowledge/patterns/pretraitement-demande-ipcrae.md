---
type: knowledge
tags: [pretraitement, demande, decomposition, reflexion, ipcrae, workflow, meta-cognition]
domain: devops
status: stable
sources: [vault:.ipcrae/prompts/core_ai_workflow_ipcra.md, vault:CLAUDE.md]
created: 2026-02-22
updated: 2026-02-22
---

# Pré-traitement des Demandes IPCRAE — Phase de Réflexion

## Principe (CLAUDE.md — règle obligatoire)

> "Avant toute exécution, reconstruire un prompt optimisé : objectif explicite, contexte projet utile, connaissances/mémoires pertinentes, contraintes techniques/sécurité, format de sortie et checks attendus. Ne jamais répondre directement à une demande brute si ce pré-traitement n'a pas été fait."

**Cette règle est la plus fréquemment violée** : l'agent exécute directement sans décomposer.

## Template de Décomposition (à afficher avant chaque demande complexe)

```markdown
## Décomposition IPCRAE — [titre court]

**Objectif** : [ce que la demande veut réellement accomplir]

**Contexte IPCRAE pertinent** :
- Projet actif : [slug]
- Domaine : [devops/electronique/musique]
- Mémoire : [décisions passées pertinentes]

**Concepts IPCRAE applicables** :
- [ ] GTD (priorisation/capture)
- [ ] Zettelkasten (notes atomiques à créer ?)
- [ ] Knowledge (notes réutilisables à créer ?)
- [ ] Process (process à suivre/créer ?)
- [ ] Auto-amélioration (audit à faire ?)
- [ ] Casquettes (rôle actif ?)
- [ ] Phases (en lien avec la phase active ?)

**Tâches atomiques** (ordonnées par priorité GTD) :
🔴 [urgent+important] ...
🟠 [important] ...
🟡 [urgent seul] ...

**Checks DoD attendus** :
- [ ] ...

**Contraintes** :
- Sécurité : ...
- Budget : ...
- Réversibilité : ...
```

## Quand déclencher le pré-traitement

| Signal | Action |
|--------|--------|
| Demande > 2 actions | Décomposer avant d'exécuter |
| Plusieurs projets impliqués | Vérifier contexte + mémoire |
| Demande multi-domaines | Identifier l'agent approprié |
| Demande ambiguë | AskUserQuestion AVANT de planifier |
| "continue" / "fais ça" | Vérifier la demande brute originale |

## Inventaire des Concepts IPCRAE sous-exploités (auto-audit)

L'agent doit explicitement cocher les concepts IPCRAE qu'il N'utilise PAS dans sa réponse et se demander si c'est justifié :

- **Casquettes** : ai-je vérifié si la demande relève d'une Casquette ?
- **Phases** : est-ce aligné avec la phase active ?
- **Waiting-for** : y a-t-il des items à déléguer ?
- **Someday-Maybe** : certaines idées devraient-elles aller là plutôt qu'en projet actif ?
- **Ressources/** : y a-t-il une référence externe à archiver ?
- **Zettelkasten/_inbox/** : ai-je eu des insights atomiques à capturer ?

## Lien avec auto-amélioration

La phase de décomposition est elle-même matière à auto-amélioration :
- Le plan était-il bon ? Avait-il des angles morts ?
- Est-ce que j'ai identifié tous les concepts IPCRAE applicables ?
- Y a-t-il un process à créer pour ne plus improviser ce type de demande ?

## Liens
- [[auto-amelioration-ipcrae]] — Checklist auto-audit session
- [[gtd-adapte-ipcrae]] — Framework décisionnel
- [[workflow-dev-ipcrae]] — Process de développement
- [[verification-travail]] — Vérification post-exécution
