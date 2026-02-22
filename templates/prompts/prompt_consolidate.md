Voici les notes brutes locales d'un projet. Joue le rôle d'un architecte technique implacable.
Extrais UNIQUEMENT les décisions durables, les leçons apprises, les erreurs résolues et les patterns réutilisables.
Ignore totalement les TODOs, les notes jetables et les logs sans intérêt.
Rédige une entrée concise et structurée (en Markdown) pour la base de connaissances globale du domaine "{{domain}}".
Commence obligatoirement par un titre H2 : "## {{date}} - Synthèse de projet" (invente le nom du projet).
Voici les notes :
{{local_content}}

ROUTING MÉMOIRE (où écrire chaque type d'information) :
| Type | Destination | Gité ? |
|------|-------------|--------|
| Décision projet spécifique | `Projets/<slug>/memory.md` | Oui |
| Décision domaine réutilisable | `memory/{{domain}}.md` | Oui |
| Pattern/howto universel | `Knowledge/howto|patterns|runbooks/` | Oui |
| Note atomique (concept universel) | `Zettelkasten/_inbox/` | Oui |
| Brouillon / artefact de session | `.ipcrae-project/memory/` | Non |

CLÔTURE OBLIGATOIRE après consolidation :
→ Suivre Process/session-close.md (commit vault + push brain.git + tag session)
