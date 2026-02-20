# Analyse approfondie — Evolution du système de prompts IPCRAE

## Constats sur l'état actuel
1. **Prompts riches mais monolithiques** : `global_instructions.md` mélange rôle, workflow, qualité, outils et mémoire dans un seul fichier, ce qui rend les évolutions fragiles.
2. **Spécialisation agent hétérogène** : les prompts `agent_*.md` ont des structures différentes, donc qualité variable selon l'agent.
3. **Mémoire IPCRAE sous-spécifiée en exécution** : la séparation local/projet/global existe conceptuellement, mais manque d'un protocole unique opératoire.
4. **Faible composabilité** : peu de mécanismes explicites pour appliquer un noyau commun puis des surcharges agent.

## Améliorations proposées (et implémentées dans ce dépôt)

### 1) Factorisation en "noyau IA" commun
Ajout de trois briques:
- `core_ai_functioning.md` : contrat d'exécution commun (clarifier → agir → vérifier → mémoriser).
- `core_ai_workflow_ipcra.md` : workflow IPCRAE orienté Agile/GTD.
- `core_ai_memory_method.md` : méthode mémoire avec matrice de décision.

### 2) Refactor du prompt global
- `global_instructions.md` devient l'orchestrateur qui définit l'ordre d'application des couches : noyau commun puis agent métier.
- La politique qualité/outils est conservée mais clarifiée en contrat court.

### 3) Uniformisation des agents spécialisés
- Tous les `agent_*.md` suivent désormais le même squelette :
  - Positionnement (dépendance au noyau commun)
  - Rôle
  - Workflow spécialisé
  - Contrôle qualité
- Résultat : sorties plus prévisibles, meilleure maintenance.

### 4) Pont avec les instructions projet
- `init_AI_INSTRUCTIONS.md` inclut explicitement le noyau méthodologique et l'ordre de chargement anti-bloat.

## Bénéfices attendus
- **Moins de dérive comportementale** entre agents.
- **Meilleure gestion mémoire** compatible IPCRAE (local/projet/global).
- **Maintenance simplifiée** : évoluer le noyau une fois, impacter tous les agents.
- **Meilleure auditabilité** : contrats clairs et vérifiables.

## Prochaine étape recommandée
1. Ajouter un script de génération de prompt final (`ipcrae prompt build --agent <domaine>`) qui concatène automatiquement les couches.
2. Ajouter des tests de cohérence de prompts (présence des sections obligatoires).
3. Ajouter une checklist de consolidation mémoire post-session automatique dans `ipcrae close`.
