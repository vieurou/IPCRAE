---
type: knowledge
tags: [ipcrae, rag, embeddings, scalabilite, recherche]
domain: devops
status: draft
sources:
  - path: Inbox/demandes-brutes/traites/audit-passe-finale-amelioration-2026-02-22.md
created: 2026-02-24
updated: 2026-02-24
---

# RAG avec Embeddings Vectoriels (Optimisation H)

## Problème

`context.md` devient un goulot d'étranglement au-delà de 50 projets. L'injection de tout le vault dépasse la fenêtre de contexte des agents.

## Solution : Retrieval-Augmented Generation local

```
Notes Markdown → sentence-transformers → vecteurs
                                              ↓
                                       ChromaDB / FAISS local
                                              ↓
Requête agent → Top-K notes pertinentes récupérées dynamiquement
                                              ↓
                              Contexte assemblé (3-5 KB au lieu de 18 KB)
```

## Stack technique

- **Embeddings** : `sentence-transformers` (all-MiniLM-L6-v2, ~80 MB, CPU)
- **Vector store** : ChromaDB (local, persistent) ou FAISS (plus rapide, pas de serveur)
- **Trigger** : `ipcrae index --embeddings` après chaque `close`

## Comparaison

| Métrique | Context.md actuel | RAG |
|----------|-------------------|-----|
| Taille contexte | 15-25 KB | 3-5 KB |
| Pertinence | 60-70% | 85-95% |
| Scalabilité | ~50 projets | 500+ projets |
| Complexité | faible | haute |

## Statut

Concept recherche (Phase 3 — horizon 2 mois). Complexité élevée. Prérequis :
- [[howto/ipcrae-context-compact]] en production d'abord (gain immédiat, faible complexité)
- [[patterns/ipcrae-context-engineering-hierarchique]] comme étape intermédiaire

## Liens

- [[howto/ipcrae-context-compact]] — version simple à implémenter en premier
- [[patterns/ipcrae-context-engineering-hierarchique]] — étape intermédiaire
