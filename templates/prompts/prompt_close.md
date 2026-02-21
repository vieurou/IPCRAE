PROCÉDURE CLOSE SESSION — suivre Process/session-close.md pour le détail complet.

## Checklist obligatoire (toutes les cases DOIVENT être cochées avant de terminer)

- [ ] Résumé de session rédigé (ce qui a été fait, décisions prises, ce qui reste ouvert)
- [ ] Domaine identifié : devops | electronique | musique | maison | sante | finance{{domain_hint}}
- [ ] `memory/<domaine>.md` : entrée datée ajoutée (### YYYY-MM-DD — titre)
- [ ] `Projets/<slug>/tracking.md` : tâches cochées [x], section Done mise à jour
- [ ] `Journal/Daily/<YYYY>/<YYYY-MM-DD>.md` : session documentée
- [ ] `.ipcrae/context.md` section "Projets en cours" : mise à jour si nécessaire
- [ ] Déplacements vers Archives/ : proposés (sans exécuter) pour projets Terminé
- [ ] `ipcrae close <domaine> --project <slug>` lancé → commit vault + push brain.git + tag session

Fallback git si commande indisponible :
`git -C $IPCRAE_ROOT add -A && git commit -m "chore(ipcrae): close session $(date '+%Y-%m-%d %H:%M')" && git push`
