---
type: knowledge
tags: [ressources, zettelkasten, distinction, ipcrae, capture, connaissance]
domain: devops
status: stable
sources: [vault:IPCRAE/CLAUDE.md, vault:Ressources/, vault:Zettelkasten/]
created: 2026-02-22
updated: 2026-02-22
---

# Ressources/ vs Zettelkasten/ — Distinction Fondamentale

## Règle de Routage

| Type de contenu | Destination | Format |
|-----------------|-------------|--------|
| Extrait brut d'un article, lien, référence | `Ressources/<domaine>/` | Markdown brut, copie fidèle |
| Pensée digérée, reformulée dans tes mots | `Zettelkasten/_inbox/<id>-<slug>.md` | Note atomique |
| Connaissance réutilisable (howto, pattern) | `Knowledge/<type>/<nom>.md` | Structurée, avec frontmatter |
| Concept personnel validé et lié | `Zettelkasten/permanents/<id>-<slug>.md` | Note atomique liée |

## `Ressources/` — Matière Brute

Contient des **références externes** non digérées :
- Articles, extraits de documentation
- Datasheets composants électroniques
- Tutoriels copiés pour consultation
- Liens annotés

Structure recommandée :
```
Ressources/
├── Tech/
│   ├── DevOps/         ← Docker, CI/CD, infra
│   ├── Electronique/   ← datasheets, tutos KiCad
│   └── Musique/        ← specs MIDI, DaisySP ref
├── DIY/
├── Sante/
└── Finance/
```

**Ne jamais** mettre une pensée personnelle dans `Ressources/`. C'est une bibliothèque, pas un carnet de notes.

## `Zettelkasten/` — Pensée Digérée

La note Zettelkasten est **toujours dans tes mots** — une reformulation de ce que tu as compris, pas une copie.

Processus :
1. Tu lis une ressource dans `Ressources/`
2. Tu formes une idée → tu l'écris dans `Zettelkasten/_inbox/` (brouillon)
3. Tu la valides, tu la lies à d'autres → `Zettelkasten/permanents/`

## `Knowledge/` — Entre les deux

Knowledge est **structurée pour la réutilisation** (procédures, patterns, runbooks).
- Plus longue et structurée qu'une note Zettelkasten
- Plus personnelle et synthétique qu'une Ressource brute
- Frontmatter complet avec `type`, `tags`, `sources`, `status`

## Exemples de Classement

| Contenu | Où ? |
|---------|------|
| Extrait doc ESP32 sur le deep sleep | `Ressources/Tech/Electronique/esp32-deepsleep-ref.md` |
| "Le deep sleep ESP32 nécessite de sauvegarder en RTC memory" | `Zettelkasten/_inbox/<id>-esp32-rtc-memory.md` |
| Guide complet deep sleep ESP32 avec exemples | `Knowledge/electronique/esp32-deep-sleep.md` |
| Lien vers datasheet ESP32-WROOM | `Ressources/Tech/Electronique/` |

## Liens
- [[zettelkasten-workflow]] — Workflow complet Zettelkasten
- [[tag-first-navigation]] — Retrouver une ressource par tag
- [[gtd-adapte-ipcrae]] — Où atterrit chaque type d'information
