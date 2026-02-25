# Noyau IA — Workflow IPCRAE (Agile + GTD)

## Principe fondamental : Écriture continue dans le cerveau

**Le cerveau est la source de vérité, pas la session.**
Dès qu'une information est découverte, une décision prise, ou une étape franchie :
→ elle est écrite dans le cerveau **immédiatement**, pas en fin de session.

Pourquoi : une session peut être interrompue à tout moment.
Si l'info n'est pas dans le cerveau, elle n'existe pas.

---


## Modes d'exécution (optimisation coût/qualité)

- **Mode FAST** : correctif simple, peu de fichiers, 1 check ciblé.
- **Mode STANDARD** : mode par défaut, plan court + validations pertinentes.
- **Mode DEEP** : sujet critique (infra/sécurité/migration), validations renforcées et rollback.

Règle : choisir le mode le plus léger qui reste sûr.

## Pipeline obligatoire

### 1. Ingest
- Lire : mémoire domaine (`memory/<domaine>.md`), vision projet, état tracking.
- Identifier : type de tâche (feature, bug, archi, recherche, consolidation).

### 2. Enregistrer la demande (OBLIGATOIRE — avant de commencer)
- Capturer la demande brute dans `Inbox/demandes-brutes/<slug>.md` (frontmatter YAML).
- Même si elle semble triviale — toute demande laisse une trace.
- Référence : [[Knowledge/howto/capture-demande-brute]]

### 3. Plan
- Définir 1 objectif principal + critères de done.
- Découper en micro-étapes → les écrire dans `tracking.md` du projet concerné **maintenant**.
- Si session multi-tâches : ouvrir un `Inbox/session-<date>-wip.md` avec la liste.

### 4. Construire + close_action (BOUCLE OBLIGATOIRE)

Pour chaque micro-étape :

```
Exécuter l'étape
      ↓
close_action (OBLIGATOIRE après chaque action significative) :
  - Décision prise       → noter dans memory/<domaine>.md
  - Pattern/info appris  → créer note Knowledge/ ou Zettelkasten/_inbox/
  - Étape franchie       → cocher [x] dans tracking.md
  - État intermédiaire   → git add -A && git commit (ou ipcrae checkpoint)
      ↓
Passer à l'étape suivante
```

**Règle absolue** : une info non écrite dans le cerveau = info perdue.
**Pas besoin d'attendre la fin** : commit fréquent = protection contre l'interruption.

### 5. Review
- Vérifier qualité, risques, impacts croisés (projet, phase, objectifs).
- À ce stade le cerveau est déjà à jour — la review ne fait que valider.

### 6. Clôturer (fin de session ou de bloc de travail)
```bash
ipcrae close <domaine> --project <slug>
```
- Consolide `memory/<domaine>.md` si entrée manquante.
- Vérifie que le prochain pas est nommé dans `tracking.md`.
- Commit + push final + tag session.

---

## Matrice d'écriture (quoi → où)

| Type d'information | Destination |
|--------------------|-------------|
| Demande brute reçue | `Inbox/demandes-brutes/<slug>.md` |
| Décision technique clé | `memory/<domaine>.md` |
| Procédure / howto | `Knowledge/howto/<nom>.md` |
| Pattern réutilisable | `Knowledge/patterns/<nom>.md` |
| Concept atomique | `Zettelkasten/_inbox/<id>-<slug>.md` |
| Étape terminée | `[x]` dans `tracking.md` |
| WIP / debug / hypothèse | `Inbox/session-<date>-wip.md` (non committé) |
| Erreur apprise | Entrée datée dans `memory/<domaine>.md` |

---

## Cadence de commit (règle pratique)

- Après chaque **action significative** (décision, étape, info découverte) → commit.
- Commande rapide : `ipcrae checkpoint` (commit brain mid-session sans close complet).
- Minimum : 1 commit toutes les 30 min si session longue (ou à chaque jalon fonctionnel).

---

## Définition de Done IA (STRICTE)

- Le livrable répond à la demande.
- **BRAIN-FIRST OBLIGATOIRE** : toute info durable est dans le cerveau avant ou pendant
  la production du livrable (jamais seulement après).
- **TRACKING MIS À JOUR** : `[x]` coché dans `tracking.md`, prochain pas nommé.
- **DEMANDE BRUTE TRAITÉE** : déplacée vers `Inbox/demandes-brutes/traites/`.
- **CERVEAU COMMITÉ** : `git add -A && git commit && git push` (ou `ipcrae close`).
