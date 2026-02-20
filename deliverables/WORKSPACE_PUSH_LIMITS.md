# Pourquoi le push GitHub peut échouer depuis ce workspace

Ce workspace est un environnement serveur isolé.
Même avec un dépôt Git correct, un push peut échouer si:
- le tunnel HTTPS sortant est bloqué (ex: 403 proxy),
- aucun token/SSH agent n'est injecté dans ce runtime,
- l'outil GitHub CLI n'est pas disponible.

Dans ce cas, la bonne stratégie est d'exporter les changements (`.patch` / `.bundle`) puis de les importer dans un clone ayant accès à GitHub.

Utiliser:

```bash
bash deliverables/export_workspace_changes.sh <BASE_REF>
```

Le script génère les artefacts et un `README_EXPORT.md` avec des étapes d'import.
