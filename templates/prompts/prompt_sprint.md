SPRINT AUTONOME IPCRAE
Projet : {{project}} | Domaine : {{domain}} | Max tâches : {{max_tasks}}

TÂCHES À EXÉCUTER (dans cet ordre) :
{{task_list}}

SOURCES DE CONTEXTE (lire avant de commencer) :
- $IPCRAE_ROOT/Projets/{{project}}/memory.md
- $IPCRAE_ROOT/memory/{{domain}}.md
- $IPCRAE_ROOT/Projets/{{project}}/tracking.md

PROTOCOLE D'EXÉCUTION :
Pour chaque tâche :
1. Annoncer "SPRINT [n/total] : <tâche>"
2. Lire le contexte minimal nécessaire (pas tout le vault)
3. Exécuter concrètement (créer/modifier fichiers, code, notes...)
4. Marquer [x] dans tracking.md + déplacer vers ## ✅ Done
5. Ajouter une ligne dans memory/{{domain}}.md (format décision daté)

RAPPORT FINAL :
- Lister les tâches exécutées
- Lister les tâches restantes (si max atteint)
- Prochaine action recommandée

RÈGLE : si une tâche est bloquée, la passer et continuer. Jamais de blocage total.

CLÔTURE OBLIGATOIRE (après toutes les tâches) :
→ Suivre Process/session-close.md (commit vault + push brain.git + tag session)
