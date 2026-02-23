# Noyau IA — Méthode mémoire (IPCRAE)

> **⚠️ RÈGLE ABSOLUE POUR LES AGENTS IA : REMPLIR LE CERVEAU**
> En tant qu'IA, tu n'as *aucune mémoire persistante* entre les sessions. Ton intelligence repose **EXCLUSIVEMENT** sur ce que tu vas écrire maintenant dans les dossiers.

## Principe de routage (local → projet → global)
- **Court terme** : `.ipcrae-project/local-notes/` → brouillons, debug, todo.
- **Projet** : `.ipcrae-project/memory/` → contraintes et décisions propres au repo.
- **Long terme global** : `.ipcrae-memory/memory/` → connaissances réutilisables multi-projets.
- **Connaissance opérationnelle** : `.ipcrae-memory/Knowledge/` → how-to, runbooks, patterns prêts à être retrouvés.

## Source de vérité tags
- La vérité est dans le **frontmatter YAML** des fichiers Markdown.
- Les attributs minimaux recommandés :
  - `type`, `tags`, `project`, `domain`, `status`, `sources`, `created`, `updated`
- Les tags sont normalisés : minuscules, tirets, pas d'espaces.
- La provenance projet doit exister via `project:` (et optionnellement `project:<slug>` dans `tags`).

## Matrice de décision mémoire
- Information valable > 1 projet ? → `Knowledge/` (ou `memory/<domaine>.md` si c'est une heuristique courte).
- Information spécifique stack/projet ? → `.ipcrae-project/memory/`.
- Information volatile (journal de travail, essais) ? → `.ipcrae-project/local-notes/`.

## Routage de recherche (obligatoire)
1. Essayer d'abord la recherche par tags : `ipcrae tag <tag>`.
2. Si l'index est absent/obsolète : `ipcrae index`.
3. Puis `ipcrae search <mots|tags>` pour le fallback full-text.

## Hygiène mémoire
- Éviter les doublons entre local/projet/global.
- Supprimer le bruit après consolidation (weekly/monthly).
- Lier les notes Knowledge aux sources (`docs/conception/*`, ADR, etc.).
- Les entrées de `memory/<domaine>.md` doivent nommer explicitement le projet (`Projet:`), ou `cross-project` si plusieurs.
- Séparer les imports bruts des entrées consolidées (`Statut: import-brut|consolidé|à-compacter`).
- Préfixer les titres ambigus avec le projet (`[IPCRAE]`, `[velotrack]`, etc.) pour lecture rapide multi-agents.

## Contrat de format (memory/<domaine>.md)
- Format minimal recommandé :
  - `### YYYY-MM-DD — [Projet] Titre`
  - `**Projet** : <slug|cross-project>`
  - `**Portée** : <project-specific|cross-project|incident|review>`
  - `**Statut** : <consolidé|import-brut|à-compacter>`
  - `**Contexte** / **Décision** / **Raison** / **Résultat**`
- Si une entrée devient longue, déplacer la matière détaillée dans `Knowledge/` ou `.ipcrae-project/memory/` et garder un résumé + lien dans la mémoire domaine.
