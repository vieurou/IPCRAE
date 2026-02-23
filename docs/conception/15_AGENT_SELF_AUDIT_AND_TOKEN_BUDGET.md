---
type: conception
tags: [audit, token-budget, auto-amelioration, methodologie, ipcrae]
status: proposed
created: 2026-02-23
---

# Extension méthodologique : Self-audit agent + budget tokens

## Objectif
Ajouter un rituel explicite, léger et systématique pour que l'agent:
1. vérifie sa conformité à IPCRAE;
2. mesure son coût tokens estimé;
3. propose une amélioration immédiate du process.

## Processus proposé (fin de tâche)

### Étape A — Contrôle conformité IPCRAE
Checklist minimale:
- Demande utilisateur capturée (task/inbox).
- Exécution traçable (commandes, décisions, preuves).
- Vérifications exécutées (ou absence justifiée).
- Mémoire durable mise à jour (si apprentissage réutilisable).
- Commit réalisé si des fichiers ont été modifiés.

### Étape B — Audit coût tokens (estimation)
Métriques simples à reporter:
- Taille contexte chargé (nombre de fichiers + lignes clés).
- Taille réponse finale (courte/moyenne/longue).
- Nombre d'itérations correctives (boucles debug).
- Niveau de compression appliqué (tokenpack, résumé, découpage).

Échelle interne:
- **Bas**: 0–2k tokens estimés
- **Moyen**: 2k–8k
- **Élevé**: >8k

### Étape C — Action d'optimisation
Toujours proposer 1 optimisation à appliquer au tour suivant:
- réduire les lectures non nécessaires;
- réutiliser template existant;
- utiliser tokenpack avant build prompt;
- découper la tâche en 2 passes (analyse puis patch).

## Ajouts process recommandés
1. Ajouter un hook `ipcrae session end` qui écrit automatiquement un `self-audit` court.
2. Ajouter un score composite: `qualité / risque / coût tokens`.
3. Ajouter un seuil d'alerte quand 3 tours consécutifs sont en coût "Élevé".

## Définition de Done (extension)
- [ ] Self-audit conformité produit.
- [ ] Coût tokens estimé reporté.
- [ ] 1 optimisation proposée.
