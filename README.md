# IPCRAE

Script d'installation et de bootstrap IPCRA (installateur + launcher + init conception).

## Position méthodologique (important)

Ce dépôt suit une stratégie **centralisée** :

- `~/IPCRA` (ou `$IPCRA_ROOT`) est la **source de vérité** pour la mémoire durable.
- Un projet local ne doit pas dupliquer toute la hiérarchie IPCRA.
- Le local sert de **contexte court terme** et pointe vers le global via des liens.

## Quickstart complet

```bash
# 1) Installer IPCRA (vault central)
bash ipcra-install.sh -y "$HOME/IPCRA"

# 2) Aller dans un repo projet local
cd /chemin/vers/mon-projet

# 3) Initialiser la couche conception + liens vers mémoire globale
IPCRA_ROOT="$HOME/IPCRA" "$HOME/bin/ipcra-init-conception"

# 4) Vérifier l'environnement
"$HOME/bin/ipcra" doctor
```

## Politique “où écrire quoi”

| Emplacement | Rôle | Durée |
|---|---|---|
| `.ipcra-project/local-notes/` | contexte de travail local (todo, debug, brouillons) | court terme |
| `.ipcra-memory/memory/` | décisions durables et patterns réutilisables | long terme |
| `.ipcra-memory/Journal/` | historique de l’activité | long terme |
| `.ipcra-memory/Archives/` | éléments clôturés | long terme |

## Workflow recommandé

1. Capturer dans `.ipcra-project/local-notes/` pendant le travail.
2. En fin de feature / session, consolider l’essentiel vers `.ipcra-memory/memory/`.
3. Garder l’historique dans `Journal/` et nettoyer le bruit local.

## Compatibilité providers (important)

- Le launcher IPCRA gère `claude`, `gemini`, `codex`.
- Le niveau d’injection de contexte dépend du provider CLI installé et de ses options.
- Utiliser `ipcra sync` pour régénérer les fichiers provider (`CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, Kilo).
- Utiliser `ipcra doctor` pour vérifier dépendances/fichiers avant une session IA.

## Troubleshooting

- **`ipcra` introuvable** : vérifier `$HOME/bin` dans `PATH` puis relancer le shell.
- **Symlink mémoire cassé** : relancer `ipcra-init-conception` dans le repo projet.
- **Contexte incomplet** : lancer `ipcra sync` puis `ipcra doctor`.
- **Fichiers `.ipcra/*` absents** : vérifier la validité de `$IPCRA_ROOT`.

## Vérification rapide

```bash
bash -n ipcra-install.sh
HOME=$(mktemp -d) bash ipcra-install.sh -y "$(mktemp -d)/vault"
```
