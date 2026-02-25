---
type: knowledge
tags: [session, start, close, ipcrae, workflow, protocol]
domain: devops
status: active
sources:
  - project:IPCRAE/Process/session-start.md
  - project:IPCRAE/Process/session-close.md
  - project:IPCRAE/Process/session-boot.md
created: 2026-02-22
updated: 2026-02-22
---

# How-to : Protocole de session IA IPCRAE

## Ordre d'exécution obligatoire

```
BOOT    → ipcrae-inbox-scan (bash pur, auto)
  ↓
START   → ipcrae start --project <slug>
  ↓
WORK    → ipcrae work "<objectif>"  [itérer]
  ↓
CLOSE   → ipcrae close <domaine> --project <slug>
```

## BOOT (automatique, dans cmd_start)
- `ipcrae-inbox-scan` → détecte fichiers Inbox en attente
- Si flag → agent traite l'inbox avant le vrai travail

## START (2 min)
Lire dans cet ordre (3 fichiers obligatoires) :
1. `.ipcrae/context.md` → projets en cours, working set, phase
2. `memory/<domaine>.md` → décisions passées, contraintes connues
3. `Projets/<slug>/tracking.md` → backlog, tâches en cours, done récent

Puis :
4. Capturer la demande brute : `ipcrae-capture-request "texte"`
5. Définir l'objectif de session et les critères de done
6. Créer les tâches dans `tracking.md` AVANT d'exécuter

## WORK (itératif)
- Cocher `[x]` au fil de l'eau (pas en bloc)
- Créer `Knowledge/` pour tout concept réutilisable découvert
- Créer `Zettelkasten/_inbox/` pour toute idée atomique

## CLOSE (5 min)
1. Résumer ce qui a été fait (journal daily)
2. Mettre à jour `Knowledge/` si connaissance émergée
3. Mettre à jour `memory/<domaine>.md` (format `### YYYY-MM-DD`)
4. Mettre à jour `context.md` si projet/phase change
5. **Commande canonique** : `ipcrae close <domaine> --project <slug>`
   → commit + push brain.git + tag `session-YYYYMMDD-<domaine>`
6. Auto-audit : `ipcrae-audit-check` → corriger si score < 36

## Commande close : ce qu'elle fait
```bash
ipcrae close devops --project IPCRAE
# 1. Met à jour memory/devops.md (entrée datée)
# 2. Met à jour .ipcrae/context.md (working set)
# 3. ipcrae index (reconstruit tag-index.json)
# 4. ipcrae-moc-auto --min-notes 3 --update --quiet (MOC auto)
# 5. git add -A && git commit && git push (brain.git)
# 6. git tag session-YYYYMMDD-devops (jalon temporel)
```

## Fallback si `ipcrae close` indisponible
```bash
git -C $IPCRAE_ROOT add -A && \
git -C $IPCRAE_ROOT commit -m "chore(ipcrae): close session $(date)" && \
git -C $IPCRAE_ROOT push
```

## Liens
- [[Process/session-boot]] — Boot automatique
- [[Process/session-start]] — Démarrage session
- [[Process/session-close]] — Clôture session
- [[auto-amelioration-ipcrae]] — Auto-audit post-session
