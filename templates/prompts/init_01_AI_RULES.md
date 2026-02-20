# Règles et Contraintes pour l'IA (AI Rules)

> **🤖 AUTO-ADAPTATION REQUISE (AGENT IA)**
> Si ce fichier contient encore les exemples par défaut entre crochets `[...]`, tu DOIS analyser le projet courant (fichiers de configuration comme `package.json`, `pyproject.toml`, headers).
> Déduis la stack réelle, le langage principal, les conventions, puis **METS À JOUR** ce document de façon permanente pour remplacer les exemples par les vraies règles.

## Protocole d'Optimisation par Modèle
**AUTO-DÉTECTION REQUISE :** Identifie ton modèle/IDE (Gemini Antigravity, Claude, ou IDE-natif) et applique l'optimisation correspondante.

- **🤖 Gemini (Antigravity)** : Utilise tes outils (Terminal, Perplexity, Browser) pour valider chaque étape du scaffolding. Use `ipcra concept` pour tester tes propres idées.
- **🧠 Claude** : Analyse l'architecture globale avant de proposer des modifications locales. Utilise le Chain-of-Thought pour justifier chaque choix technique.
- **⚡ IDE-Natif (Kilocode/Copilot)** : Reste focalisé sur le contexte immédiat et les fichiers ouverts pour une intégration fluide et rapide.

!!! ATTENTION AGENT IA !!!
Ce document contient des directives absolues. Vous devez les respecter sans exception pour ne pas diverger des attentes architecturales.

## 1. Règles de Codage & Langage
- **Langage / Version** : [Ex: Python 3.12, ou TypeScript 5.0]
- **Style guide** : [Ex: PEP8, ESLint Standard, ou "Pas de commentaires superflus si le code est explicite"]
- **Gestion des erreurs** : [Ex: Ne jamais ignorer les exceptions silencieusement, toujours utiliser notre logger interne]

## 2. Exclusions (Ce qu'il ne faut JAMAIS utiliser)
- ❌ **Bibliothèques interdites** : [Ex: Lodash (préférer vanilla JS), ou Tailwind CSS (préférer Vanilla CSS)]
- ❌ **Patterns à proscrire** : [Ex: Variables globales, classes massives]

## 3. Processus de Validation
- Avant de proposer un nouveau fichier, vérifiez qu'il respecte l'arborescence définie dans `02_ARCHITECTURE.md`.
- Assurez-vous d'écrire ou mettre à jour un test unitaire pour chaque nouvelle fonction de logique métier.

## 4. Autonomie de l'Agent
- N'hésite pas à réorganiser les fichiers dans `.ipcra-project/local-notes/` ou la mémoire globale `memory/<domaine>.md` si tu juges que la documentation existante est devenue brouillonne ou obsolète.
- Fais preuve d'initiative en créant ton propre ficher de compétences `Agents/agent_<ton-domaine>_skills.md` pour y documenter des méthodes spécifiques ou hacks que tu as découverts sur ce projet.
