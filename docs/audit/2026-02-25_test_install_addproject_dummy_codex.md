# Test terrain — installation IPCRAE + addProject sur projet dummy (Codex)

Date: 2026-02-25

## Objectif
Valider de bout en bout:
1. Installation d'un cerveau IPCRAE neuf.
2. Création d'un projet dummy Git.
3. Exécution de `ipcrae-addProject`.
4. Vérification logique des artefacts, puis pistes d'optimisation.

## Environnement de test
- Repo source scripts: `/workspace/IPCRAE`
- Cerveau cible: `/tmp/ipcrae_brain_codex`
- Projet dummy: `/tmp/ipcrae_dummy_project`

## Actions exécutées

### 1) Installation IPCRAE
Commande:
```bash
bash ./ipcrae-install.sh -y /tmp/ipcrae_brain_codex
```

Résultat observé:
- Installation complète réussie.
- Arborescence standard créée.
- Prompts extraits dans `.ipcrae/prompts/`.
- Scripts CLI installés dans `~/bin` dont `ipcrae`, `ipcrae-addProject`, `ipcrae-strict-check`, `ipcrae-strict-report`.

### 2) Création d'un projet dummy
Commandes:
```bash
mkdir -p /tmp/ipcrae_dummy_project
cd /tmp/ipcrae_dummy_project
git init -b main
```

### 3) Intégration addProject
Commande:
```bash
IPCRAE_ROOT=/tmp/ipcrae_brain_codex ~/bin/ipcrae-addProject -y
```

Résultat observé:
- `docs/conception/` généré (00/01/02/03 + template concept).
- `.ipcrae-project/` généré avec `project.md`, `.gitignore`, `local-notes/README.md`.
- Symlink `.ipcrae-memory -> /tmp/ipcrae_brain_codex` créé.
- Hub global généré dans `/tmp/ipcrae_brain_codex/Projets/ipcrae_dummy_project/`.
- Registre global `/tmp/ipcrae_brain_codex/Projets/index.md` mis à jour.
- Hook Git `post-commit` installé.

## Vérifications logiques

### Cohérences validées
- Le lien symbolique `.ipcrae-memory` pointe bien vers la racine cerveau attendue.
- Le hub global projet contient les 3 fichiers attendus (`index.md`, `tracking.md`, `memory.md`).
- Le registre global contient l'entrée du projet dummy.

### Points incohérents / à clarifier
1. **Message shell trompeur sur le symlink**
   - Log affiché: `Créé : Lien symbolique .ipcrae-memory -> $IPCRAE_ROOT`.
   - Le lien réel est correct, mais le message n'expanse pas la variable (risque de confusion utilisateur).

2. **Hook post-commit dépend d'une variable d'environnement non persistée**
   - Hook utilise `IPCRAE_ROOT` sinon fallback `$HOME/brain`.
   - Si l'utilisateur a installé ailleurs (ex: `/tmp/ipcrae_brain_codex`) sans exporter globalement la variable, les tâches peuvent être écrites au mauvais endroit.

3. **`ipcrae-strict-check` échoue juste après addProject**
   - Échec sur `.ipcrae/session-context.md` manquant.
   - Signale un gap d'expérience: le mode "strict" n'est pas immédiatement satisfaisable après bootstrap standard projet.

## Évaluation globale
- **Installation**: robuste et reproductible en non-interactif.
- **Onboarding projet (`addProject`)**: rapide et cohérent avec la philosophie CDE.
- **Logique générale**: bonne séparation cerveau global vs contexte local repo.
- **DX**: quelques frictions à corriger (messages, strict-mode, hook).

## Optimisations recommandées

### P1 (rapide, faible risque)
1. **Corriger le log de symlink**
   - Afficher la valeur résolue de `IPCRAE_ROOT` au lieu de la chaîne littérale.

2. **Rendre le hook post-commit déterministe**
   - Écrire la valeur résolue de `IPCRAE_ROOT` dans le hook au moment de l'installation `addProject`.
   - Garder une option d'override via variable env si nécessaire.

3. **Ajouter un check de fin de script addProject**
   - Vérifier explicitement que `.ipcrae-memory` existe et que la cible est accessible.

### P2 (expérience utilisateur)
4. **Aligner strict-check avec l'état bootstrap**
   - Soit générer `.ipcrae/session-context.md` minimal dans `addProject`.
   - Soit rétrograder ce point en warning tant qu'une session n'a pas été démarrée (`ipcrae start`).

5. **Message de post-install plus prescriptif**
   - Après `addProject`, afficher un mini-runbook:
     - `ipcrae start --project <slug> --phase <...>`
     - `ipcrae sync`
     - `ipcrae index`
     - `ipcrae-strict-check`

### P3 (fiabilité à long terme)
6. **Test E2E automatisé CI**
   - Ajouter un test scripté qui:
     - installe un cerveau temp,
     - crée un repo dummy,
     - lance `addProject`,
     - valide symlink + hub global + registre + hook + strict-check attendu.

## Conclusion
Le flux "install + addProject" est fonctionnel et globalement logique. Les optimisations proposées visent surtout à réduire l'ambiguïté (logs), fiabiliser l'intégration (hook), et lisser l'expérience stricte immédiatement après bootstrap.


## Mise à jour (itération corrective)
Suite à ce test, les améliorations suivantes ont été implémentées dans `templates/ipcrae-addProject.sh` :
- Le log du symlink affiche désormais la valeur résolue de `IPCRAE_ROOT`.
- Le hook `post-commit` est généré avec un fallback déterministe vers le cerveau configuré à l'installation.
- Un seed minimal `.ipcrae/session-context.md` est créé automatiquement pour éviter l'échec immédiat de `ipcrae-strict-check`.

### Vérification post-correctifs
Sur un nouveau scénario de test (`/tmp/ipcrae_brain_codex_v2` + `/tmp/ipcrae_dummy_project_v2`) :
- `ipcrae-addProject` crée un symlink explicite vers la bonne cible.
- Le hook contient `_IPCRAE_ROOT="${IPCRAE_ROOT:-/tmp/ipcrae_brain_codex_v2}"`.
- `ipcrae-strict-check` ne retourne plus d'échec critique (fail=0), uniquement des warnings non bloquants.

## Mise à jour 2 (discipline stricte + CI)
Implémentations complémentaires appliquées :
- Seed `Tasks/active_session.md` dans le cerveau bootstrap pour supprimer le warning strict "active_session.md missing".
- Création du dossier `.ipcrae/auto/self-audits` au bootstrap pour supprimer le warning strict récurrent.
- Ajout d'un test E2E automatisé `tests/test_e2e_install_addproject_strict.sh`.
- Ajout d'un workflow CI GitHub Actions exécutant syntaxe bash + smoke launcher + E2E strict-check.
