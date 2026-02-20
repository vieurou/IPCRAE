# Architecture Technique et Stack

> **🤖 AUTO-ADAPTATION REQUISE (AGENT IA)**
> Si ce fichier contient encore les exemples par défaut entre crochets `[...]`, tu DOIS analyser l'architecture du projet courant.
> Déduis la stack technique réelle et l'arborescence, puis **METS À JOUR** ce document de façon permanente pour refléter fidèlement l'architecture du projet.

## 1. Stack Technique Retenue
- **Frontend** : [Ex: Vanilla HTML/JS/CSS, React, Vue...]
- **Backend** : [Ex: Node.js, FastAPI...]
- **Base de Données** : [Ex: SQLite pour la simplicité, ou PostgreSQL]
- **Outils de Build / DevOps** : [Ex: Vite, Docker, GitHub Actions]

## 2. Arborescence Cible (A respecter par l'IA)
```text
/src/
  /components/     # UI
  /services/       # Logique métier et appels API
  /assets/
```

## 3. Décisions Architecturales Majeures (ADR)
| Date | Décision | Justification |
|------|----------|---------------|
| YYYY-MM-DD | Choix de SQLite | Pas besoin de scalabilité horizontale pour l'instant, simplifie le déploiement |
