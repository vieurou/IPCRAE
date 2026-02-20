# Règles et Contraintes pour l'IA (AI Rules)

> **🤖 AUTO-ADAPTATION REQUISE (AGENT IA)**
> Si ce fichier contient encore les exemples par défaut entre crochets `[...]`, tu DOIS analyser le projet courant (fichiers de configuration comme `package.json`, `pyproject.toml`, headers).
> Déduis la stack réelle, le langage principal, les conventions, puis **METS À JOUR** ce document de façon permanente pour remplacer les exemples par les vraies règles.

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
