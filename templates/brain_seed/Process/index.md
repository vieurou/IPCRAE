# Process — Index

## Processus disponibles

## Process Sessions & Système

| Process | Déclencheur | Domaine |
|---------|-------------|---------|
| [[session-boot]] | **PREMIER** : boot système + scan inbox (bash pur) | tous |
| [[session-start]] | Début de toute session IA — après boot | tous |
| [[session-close]] | Fin de toute session IA | tous |
| [[auto-amelioration]] | Audit + corrections + amélioration méthode | tous |
| [[inbox-scan]] | Traitement fichiers Inbox détectés par session-boot | tous |

## Process Cycles de Revue

| Process | Déclencheur | Domaine |
|---------|-------------|---------|
| [[daily]] | Chaque matin — cycle quotidien | tous |

## Process Ingestion

| Process | Déclencheur | Domaine |
|---------|-------------|---------|
| [[process-ingest-projet]] | Nouveau projet à intégrer dans IPCRAE | devops |

## Process Développement Logiciel

| Process | Déclencheur | Ordre |
|---------|-------------|-------|
| [[dev-concept-solution]] | Avant toute implémentation non triviale | 1 |
| [[dev-bash-specialist]] | Écriture/modification script bash | 2 |
| [[dev-test]] | Avant merge PR — validation | 3 |
| [[dev-review]] | Avant merge — bonnes pratiques | 4 |
| [[dev-veille-domaine]] | Knowledge manquante / stale | transversal |

## Process Vérification & Qualité

| Process | Déclencheur | Domaine |
|---------|-------------|---------|
| [[verification-travail]] | Vérification complète des demandes + mémoire IPCRAE | tous |
| [[decomposition-demande]] | Avant toute demande complexe (> 2 actions) — pré-traitement obligatoire | tous |
| [[calibrage-effort-raisonnement]] | Avant demande non triviale — calibrer le niveau de raisonnement (low→extra high) | tous |
| [[reexamen-fin-traitement-demande]] | Avant réponse finale — vérifier satisfaction complète après décomposition | tous |
| [[non-regression]] | Après modification significative / avant déploiement / après auto-amélioration | tous |
| [[review-coherence-doc-code]] | Avant merge PR / après auto-amélioration / mensuellement | tous |
| [[anti-regression-commits]] | Avant merge PR / après auto-amélioration / mensuellement | tous |
| [[architecte-methode]] | À la demande / mensuellement / après auto-amélioration significative | tous |

## Process Projets Spécifiques

| Process | Déclencheur | Domaine |
|---------|-------------|---------|
| [[hack-pss290-modulaire]] | Session travail PSS-290 MaxDaisyedMultiESP | electronique/musique |

## Créer un process

1. Copier `Process/_template_process.md`
2. Nommer le fichier : `process-<nom-court>.md` (kebab-case)
3. Ajouter le lien dans ce tableau

## Règle d'utilisation (pour les agents IA)

Avant de démarrer une action récurrente : vérifier si un process existe ici.
Si oui → le lire et le suivre.
Si non → improviser, puis documenter le process résultant dans ce dossier.
