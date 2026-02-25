# Process — PSS-290 MaxDaisyedMultiESP : Hack Modulaire Ultime

## Déclencheur (quand lancer ce process ?)
- Nouvelle session travail synthé/électronique sur ce projet
- Phase active : musique-diy / électronique embarquée
- Trigger manuel : `ipcrae work "..." --project pss290-maxdaisyed`

## Entrées (inputs nécessaires)

### Inputs Dynamiques
- État avancement (`Projets/PSS-290 MaxDaisyedMultiESP/tracking.md`)
- Mémoire session (`memory/musique.md`, `memory/electronique.md`)
- Budget restant (<100€ total)
- Phase active (conception/veille → proto/achat → assemblage → test → finalisation)
- Feedback itération précédente

### Inputs Statiques
- Teardowns PSS-290 (service manual Yamaha, schémas boards AM/PS/VR/RE)
- Datasheets (YM2413, TMS chips, Daisy Seed STM32H7, ESP32)
- GitHub repos (DaisySP, ML_SynthTools, esp32_basic_synth, PSS MIDI retrofit)
- Forums (electro-music.com PSS-290, circuitbenders.co.uk)
- Specs synthés référence 2026 (Sequential Take5/Pro-800, MODX8+, Typhon)
- Knowledge IPCRAE (`Knowledge/howto/`, `Knowledge/runbooks/`)

## Checklist

### Phase 1 : Veille + Analyse Marché (OBLIGATOIRE 1er message)
- [ ] Lancer veille exhaustive (WebSearch + WebFetch)
- [ ] Produire rapports structurés (Matériel, Firmware, Projets, Bends, Marché 2026)
- [ ] Tables comparatives vs synthés pro
- [ ] Identifier gaps/quick wins
- [ ] Sauvegarder dans `Projets/PSS-290 MaxDaisyedMultiESP/veille/`

### Phase 2 : Conception Itérative
- [ ] Optimiser prompt avec contexte projet/mémoire/Knowledge (OBLIGATOIRE)
- [ ] Blueprints architecture (Daisy cœur + ESP32 principal + slots extensibles)
- [ ] Schémas Fritzing/KiCad (alim 5V/3.3V, audio I/O, MIDI DIN/USB, bus I2C/SPI)
- [ ] BOM pièces (<100€) avec liens
- [ ] Code firmware (Daisy VA poly + FM, ESP32 app web MIDI, slots I2C auto-detect)
- [ ] Benchmarks perf (latency MIDI, CPU usage, memory, polyphonie max)

### Phase 3 : Prototypage
- [ ] Ouverture PSS-290 safe (photos boards, repérage pins)
- [ ] Calculs tension/courant (alim 5V→3.3V, limites mA, protections diodes)
- [ ] Soudures réversibles (switches bypass, headers plug-and-play)
- [ ] Intégration bends PSS existants (LTC1799 clock, glitch pins 51-57, YM2413 cut)
- [ ] Montage Daisy + ESP32 (perfboard, câblage audio I/O, MIDI, bus)

### Phase 4 : Tests
- [ ] Validation hardware (multimeter tensions, scope signaux audio, probe continuité)
- [ ] Tests firmware (MIDI in/out, polyphonie, FX chain, app web WiFi)
- [ ] Benchmarks réels (latency, CPU load, battery life si portable)
- [ ] Enregistrement audio démo

### Phase 5 : Documentation
- [ ] Schémas finaux (photos boards annotées, Fritzing/KiCad)
- [ ] BOM final avec coûts réels
- [ ] Code source clean (README, exemples)
- [ ] Mise à jour mémoire (`memory/musique.md`, `memory/electronique.md`)

## Sorties (outputs attendus)

| Type | Destination |
|------|-------------|
| Rapports Veille | `Projets/PSS-290 MaxDaisyedMultiESP/veille/` |
| Blueprints/Schémas | `Projets/PSS-290 MaxDaisyedMultiESP/conception/blueprints/` |
| BOM | `Projets/PSS-290 MaxDaisyedMultiESP/conception/` |
| Code firmware | `Projets/PSS-290 MaxDaisyedMultiESP/code/` |
| Tests/Benchmarks | `Projets/PSS-290 MaxDaisyedMultiESP/tests/` |
| Knowledge réutilisable | `Knowledge/howto/pss290-ultimate-mod.md` |
| Mémoire | `memory/musique.md`, `memory/electronique.md` |
| Ressources brutes | `Ressources/synth-diy/` |

## Definition of Done
- [ ] Veille complète documentée (Matériel + Firmware + Projets + Marché)
- [ ] Architecture validée (blueprints + BOM <100€)
- [ ] Firmware testé sur hardware réel (latency, polyphonie mesurées)
- [ ] Mémoire domaine mise à jour (format canonique avec date)
- [ ] Knowledge créée dans `Knowledge/howto/`

## Agent IA recommandé
`agent_synth_bidouille` (fusion musique + électronique + circuit bending)

## Critères Qualité
- ✅ Vérifiabilité : chaque affirmation citée (datasheet, GitHub, forum)
- ✅ Low-cost : BOM <100€ hors PSS (déjà possédé)
- ✅ Réversibilité : switches bypass, headers plug-and-play
- ✅ Testabilité : multimeter/scope checkpoints, benchmarks mesurables
- ✅ Code propre : C++/Arduino clean, pas de libs bloat

## Décision Agent vs Automatisation
**Agent supervisé** — validation humaine obligatoire pour :
- Achat pièces (BOM validé avant commande)
- Priorisation features (arbitrages créatifs)
- Soudures irréversibles sur PSS-290

## Liens
- Hub projet : `[[Projets/PSS-290 MaxDaisyedMultiESP/index]]`
- Agent : `[[.ipcrae/prompts/agent_synth_bidouille]]`
- Mémoire musique : `[[memory/musique]]`
- Mémoire électronique : `[[memory/electronique]]`
