# Vision et Objectifs du Projet

**Dernière mise à jour** : 2026-02-21
**Statut global** : 🔵 En Développement

## 1. Pitch du Projet
IPCRAE est un système de gestion de vie et de travail 100% local, CLI-first et piloté par l'IA. Il structure la connaissance, les projets et la mémoire dans des fichiers Markdown versionnables (Git), et fournit des scripts shell permettant à n'importe quel agent IA (Claude, Gemini, Codex, Kilo) de travailler avec un contexte minimal, fiable et reproductible — sans dépendre de la mémoire interne des chats.

## 2. Objectifs Business / Métier
- **Objectif 1** : Éliminer le bruit de mémoire des sessions IA — toute vérité réside dans des fichiers locaux git-versionnés, pas dans le chat.
- **Objectif 2** : Fournir un cycle de travail IA reproductible (`start → work → close`) qui réduit la charge cognitive et capitalise les apprentissages dans `memory/<domaine>.md`.
- **Objectif 3** : Permettre à plusieurs agents IA (Claude, Gemini, Codex, Kilo) d'intervenir sur le même vault avec des contextes normalisés, sans lock-in fournisseur.

## 3. Personas / Utilisateurs cibles
- **Praticien solo DevOps/DIY** : gère des projets techniques, électroniques, musicaux et domestiques en parallèle ; a besoin d'un système unique, léger, CLI-friendly, compatible Obsidian et multi-IA — sans friction d'adoption.

## 4. Ce que le projet N'EST PAS (Anti-objectifs)
- Ce n'est pas un SaaS multi-tenant ni un outil avec interface graphique.
- Ce n'est pas un remplacement d'Obsidian : il s'y intègre (vault Markdown), il ne le remplace pas.
- Ce n'est pas un système d'automatisation IA full-autonome : l'humain reste maître de la source de vérité.
- Ce n'est pas un outil dépendant d'un seul provider IA : la neutralité multi-agent est un principe fondateur.
