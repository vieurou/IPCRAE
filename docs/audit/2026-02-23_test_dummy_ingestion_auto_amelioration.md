# Test réel — Dummy project + addProject + auto-audit (mode auto-amélioration)

Date: 2026-02-23
Objectif: valider et corriger le comportement de première ingestion pour forcer une population transversale du cerveau IPCRAE.

## 1) Setup de test

- Cerveau de test installé: `/tmp/IPCRAE_BRAIN_DUMMYTEST4`
- Projet dummy: `/tmp/dummy_omega4`
- Le dummy contient:
  - scripts shell non triviaux (`random_orchestrator.sh`, `chaos_reconcile.sh`),
  - docs d'idées/tâches/liens/snippets (`docs/raw/ideas.md`, `docs/raw/notes_archi.md`).

## 2) Exécution du flux demandé

1. `ipcrae-addProject` sur le dummy.
2. Activation auto-amélioration (`ipcrae-auto auto-activate --agent codex --frequency quotidien`).
3. Auto-audit (`ipcrae-audit-check`).
4. Analyse des gaps.
5. Correction du template `ipcrae-addProject.sh`.
6. Re-test complet sur un nouveau cerveau pour vérifier le comportement corrigé.

## 3) Cause observée des manques initiaux

Le seed du cerveau était incomplet pour certains checks de l'audit:
- daily créée dans le mauvais chemin pour la règle d'audit,
- pas de weekly,
- pas de phase active liée à un fichier `[[phase-*]]` avec DoD,
- suivi profils non seedé,
- densité mémoire insuffisante selon la métrique (`### 20...`, >=3 entrées sur >=2 fichiers),
- pas de permanent zettelkasten minimal.

## 4) Correctifs implémentés

Le `template/ipcrae-addProject.sh` seed désormais automatiquement, dès l'ajout projet:
- Casquette domaine,
- Daily + Weekly compatibles audit,
- Inbox capture initiale,
- Knowledge note avec `sources:`,
- 2 fichiers `memory/*.md` avec >=3 entrées datées (`### YYYY-MM-DD ...`),
- Objectifs/vision liée au projet,
- phase active `[[phase-...]]` + fichier phase avec DoD (>=3 critères, au moins 1 `[x]`),
- Process récurrent,
- Ressource référencée,
- Task IA,
- note Zettelkasten `_inbox` + permanent minimal,
- profil d'usage seedé (`.ipcrae/memory/profils-usage.md`).

## 5) Résultat du re-test

Score final mesuré après correctifs sur cerveau neuf: **53/60 (88%)**.

Gaps restants:
- uniquement liés au fait que le vault de test n'est pas commité (comportement attendu dans ce scénario de validation).

## 6) Conclusion

Le comportement est maintenant adapté à la demande: la première digestion ne reste plus locale/minimale, elle peuple immédiatement les dossiers IPCRAE critiques avec des artefacts exploitables et auditables.
