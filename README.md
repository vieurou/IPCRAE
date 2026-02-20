# IPCRA Étendu (v3.1)

IPCRA (Inbox, Projets, Casquettes, Ressources, Archives) est un système personnel de PKM (Personal Knowledge Management) et de CDE (Context Driven Engineering) piloté par l'IA.

Ce dépôt contient l'installateur unifié, le lanceur CLI et les scripts d'initialisation de projets agiles pour faire le pont entre un "cerveau global" et des espaces de travail de code locaux.

## 🚀 Installation

Un seul script suffit pour déployer l'arborescence, les templates documentaires, les profils d'agents spécialisés et installer les CLI (`ipcra`, `ipcra-claude`, etc.).

```bash
git clone https://github.com/vieurou/IPCRAE.git
cd IPCRAE
bash ipcra-install.sh
```

> **Support :** L'installateur supporte le mode interactif ou silencieux (`-y`). Le script central n'altérera pas les notes existantes s'il est relancé en mise à jour.

---

## 🛠 Composants Principaux

### 1. Le Cerveau Global
Créé dans `~/IPCRA` par défaut, c'est la source de vérité absolue contenant :
- `Zettelkasten/` : Notes atomiques et Maps of Content (MOC).
- `Journal/` & `Phases/` : Organisation temporelle (Daily, Weekly, Monthly) et priorités actives.
- `memory/` : Cerveau partitionné par domaines (DevOps, Musique, Électronique...) pour que l'IA ne lise que ce qui lui est utile.
- `Inbox/` & `Projets/` : Suivi méthodologie GTD (Get Things Done).

### 2. Le Lanceur CLI (`ipcra`)
Installé globalement dans votre `$PATH` (`~/bin`), c'est votre interface quotidienne avec le système :
- `ipcra` : Ouvre le Dashboard et le menu interactif.
- `ipcra daily --prep` : Fait rédiger à Gemini/Claude un brouillon de note quotidienne en analysant la note d'hier, votre weekly en cours et la liste d'attente.
- `ipcra zettel "Titre"` : Création encodée et template d'une note Zettelkasten.
- `ipcra capture "Idée"` : Stocke la chaîne en un éclair dans l'Inbox.
- `ipcra process <nom>` : Charge un process standardisé et identifie si un agent IA spécifique est recommandé pour vous accompagner pendant l'exécution.

### 3. Le Scaffold de Conception (`ipcra-init-conception`)
Destiné à être exécuté **à la racine de vos dépôts de code / projets techniques**, ce script :
1. Démarre l'architecture documentaire `docs/conception/` (Vision, Architecture, Règles Techniques, Concepts).
2. Construit dynamiquement les fichiers locaux de règles IA (`.claude.md`, `.clinerules`, `.cursorrules`, etc.) en fusionnant les instructions vitales de la racine `~/IPCRA/.ipcra/context.md` avec les règles spécifiques du projet local (RAG statique par concaténation).
3. Crée un lien symbolique `.ipcra-memory -> ~/IPCRA` pour exposer la mémoire globale du système à l'agent IA de votre IDE (Hub & Spoke), sans en dupliquer le contenu !
