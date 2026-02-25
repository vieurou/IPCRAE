---
type: knowledge
tags: [auto-amelioration, audit, ipcrae, score, vault, qualité]
domain: devops
status: active
sources:
  - project:IPCRAE/Process/auto-amelioration.md
  - project:IPCRAE/scripts/ipcrae-auto.sh
created: 2026-02-22
updated: 2026-02-22
---

# Pattern : Auto-amélioration IPCRAE

## Concept
Le système IPCRAE s'auto-audite et s'auto-améliore. L'agent IA est responsable de détecter les gaps et de les corriger sans attendre instruction explicite, tant qu'il est "en mode auto-amélioration".

## Ce que l'agent doit faire en auto-amélioration

**À chaque session :**
1. Lire `Process/session-start.md` → charger les 3 fichiers de contexte
2. Capturer la demande brute : `ipcrae-capture-request "..."`
3. Créer les tâches dans `tracking.md` AVANT d'exécuter
4. Cocher `[x]` au fil de l'eau (pas en bloc)
5. Créer des `Knowledge/` pour tout concept réutilisable
6. Créer des `Zettelkasten/_inbox/` pour toute idée atomique
7. Mettre à jour `memory/<domaine>.md` avec les décisions
8. Écrire le `Journal/Daily/<YYYY>/<YYYY-MM-DD>.md`
9. Lancer `ipcrae close <domaine> --project <slug>` (commit + tag)

**En fin de session :**
10. Auto-audit : lancer `ipcrae-audit-check` → score vault
11. Identifier les gaps (critiques, importants, mineurs)
12. Corriger les gaps si possible immédiatement
13. Sinon : ouvrir des `- [ ]` dans `Projets/IPCRAE/tracking.md`

## Score vault (40 points)

| Section | Points | Ce qui est mesuré |
|---------|--------|------------------|
| Structure | 4 | Dossiers obligatoires présents |
| Process | 10 | Fichiers process + session-start/close |
| Workflow | 8 | Inbox, waiting-for, daily, knowledge |
| Mémoire | 10 | memory/*.md à jour, context.md, Knowledge |
| Git | 13 | Commits récents, permanents, phases, objectifs |

- **≥ 36/40 (90%)** : excellent
- **30-35** : acceptable, gaps à corriger
- **< 30** : problème — ouvrir ticket Inbox

## Scripts d'auto-amélioration

```bash
ipcrae-audit-check            # Score vault (sortie texte)
ipcrae-auto-apply --auto      # Corrections automatiques
ipcrae-auto                   # Orchestrateur complet (audit + apply + commit)
```

## Failles récurrentes à surveiller
- Knowledge/ non alimentée après session
- Journal daily absent
- `ipcrae close` non exécuté (pas de tag session)
- Demandes brutes non capturées
- Process/index.md non mis à jour après création d'un process
- CLAUDE.md désynchronisé (`ipcrae sync` oublié)

## Liens
- [[Process/auto-amelioration]] — Process complet
- [[Process/session-close]] — Clôture canonique
- [[capture-demande-brute]] — Capture des demandes
