---
type: documentation
tags: [tags, system, v3.2.1]
project: ipcrae
domain: system
version: 3.2.1
status: implemented
created: 2026-02-21
---

# Système de Tags v3.2.1

## 📋 Vue d'ensemble

Le système de tags v3.2.1 permet d'indexer et de rechercher efficacement les fichiers markdown dans le cerveau IPCRAE. Il utilise un cache JSON pour une recherche rapide et des scripts CLI pour une utilisation intuitive.

## 🎯 Objectifs

1. **Indexation rapide**: Recherche instantanée de fichiers par tag
2. **Recherche avancée**: Filtrage avec pattern grep
3. **Analyse statistique**: Visualisation des tags les plus utilisés
4. **Intégration**: Installation automatique via ipcrae-install.sh

## 📦 Scripts

### 1. `ipcrae-tag-index.sh`

**Fonction**: Reconstruit le cache des tags

**Commande**:
```bash
ipcrae-tag-index
```

**Output**:
```
✓ Cache reconstruit (15 tags)
```

**Fichiers analysés**:
- `Knowledge/`
- `Zettelkasten/permanents/`

**Format du cache**: JSON
```json
{
  "generated_at": "2026-02-21T14:30:00+01:00",
  "version": "1",
  "tags": {
    "system": ["file1.md", "file2.md"],
    "project": ["file1.md"],
    "domain": ["file1.md", "file3.md"]
  }
}
```

**Emplacement du cache**: `.ipcrae/cache/tag-index.json`

---

### 2. `ipcrae-tag.sh`

**Fonction**: Recherche des fichiers par tag

**Commande**:
```bash
ipcrae-tag <tag> [grep-pattern]
```

**Exemples**:
```bash
# Recherche tous les fichiers avec le tag "system"
ipcrae-tag system

# Recherche tous les fichiers avec le tag "system" contenant "audit"
ipcrae-tag system audit
```

**Output**:
```
 1: file1.md
 2: file2.md
 3: file3.md
(3 fichiers)
```

**Utilisation**:
- `tag`: Nom du tag à rechercher (obligatoire)
- `grep-pattern`: Pattern de recherche optionnel pour filtrer les résultats

---

### 3. `ipcrae-index.sh`

**Fonction**: Affiche les 10 tags les plus utilisés

**Commande**:
```bash
ipcrae-index
```

**Output**:
```
📊 Top 10 tags:
ipcrae         45
system         32
project        28
domain         24
...
```

**Utilisation**:
- Affiche les tags les plus fréquents
- Utile pour comprendre la structure du cerveau

---

## 📝 Format des Tags

### Structure Frontmatter

Chaque fichier markdown doit contenir un frontmatter avec les tags:

```yaml
---
type: documentation
tags: [system, ipcrae]
project: ipcrae
domain: system
---
```

### Tags Supportés

1. **type**: Type du contenu (documentation, script, template, etc.)
2. **tags**: Liste de tags pour la recherche
3. **project**: Projet associé
4. **domain**: Domaine technique

---

## 🔄 Cycle de Vie

### 1. Création/Modification de fichiers
```bash
# Créer un nouveau fichier avec tags
vim Knowledge/nouveau_fichier.md
# Ajouter le frontmatter avec tags
```

### 2. Mise à jour du cache
```bash
# Reconstruire le cache
ipcrae-tag-index
```

### 3. Recherche de fichiers
```bash
# Rechercher par tag
ipcrae-tag system

# Rechercher avec pattern
ipcrae-tag system audit
```

### 4. Analyse des tags
```bash
# Voir les tags les plus utilisés
ipcrae-index
```

---

## 📊 Utilisation Avancée

### Combiner avec grep
```bash
# Rechercher dans tous les fichiers du tag "system"
ipcrae-tag system | xargs grep -l "mot-clé"
```

### Trouver des tags spécifiques
```bash
# Trouver tous les fichiers avec le tag "ipcrae"
ipcrae-tag ipcrae

# Trouver tous les fichiers avec le tag "ipcrae" et le mot "audit"
ipcrae-tag ipcrae audit
```

### Analyser la structure
```bash
# Voir les tags les plus fréquents
ipcrae-index

# Trouver tous les fichiers d'un projet spécifique
ipcrae-tag project:ipcrae
```

---

## 🚀 Installation

### Via ipcrae-install.sh

Les scripts sont installés automatiquement lors de l'installation IPCRAE v3.2.1:

```bash
bash ipcrae-install.sh
```

### Manuellement

```bash
# Copier les scripts dans ~/bin
cp templates/scripts/ipcrae-tag-index.sh ~/bin/ipcrae-tag-index
cp templates/scripts/ipcrae-tag.sh ~/bin/ipcrae-tag
cp templates/scripts/ipcrae-index.sh ~/bin/ipcrae-index

# Rendre exécutables
chmod +x ~/bin/ipcrae-tag-index
chmod +x ~/bin/ipcrae-tag
chmod +x ~/bin/ipcrae-index

# Ajouter ~/bin au PATH si nécessaire
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
```

---

## 📈 Intégration dans le Workflow IPCRAE

### Dans les scripts IPCRAE

Les scripts IPCRAE peuvent utiliser le système de tags pour:

1. **Indexer automatiquement**: Reconstruire le cache lors de modifications
2. **Rechercher des ressources**: Trouver des fichiers par tag
3. **Analyser la structure**: Comprendre la distribution des tags
4. **Documenter les dépendances**: Identifier les fichiers liés par tags

### Exemple d'utilisation dans un script

```bash
# Dans ipcrae-auto.sh
case "$1" in
  tag-index)
    "$HOME/bin/ipcrae-tag-index"
    ;;
  tag)
    "$HOME/bin/ipcrae-tag" "$2" "$3"
    ;;
  index)
    "$HOME/bin/ipcrae-index"
    ;;
esac
```

---

## 🔧 Maintenance

### Nettoyage du cache

Si le cache est corrompu ou obsolète:

```bash
# Supprimer le cache
rm .ipcrae/cache/tag-index.json

# Reconstruire le cache
ipcrae-tag-index
```

### Vérification de l'intégrité

```bash
# Vérifier que le cache existe
test -f .ipcrae/cache/tag-index.json && echo "✓ Cache existant"

# Vérifier que le cache est valide JSON
jq . .ipcrae/cache/tag-index.json
```

---

## 📝 Notes d'Implémentation

### Algorithme d'indexation

1. **Parcours des fichiers**: Recherche dans `Knowledge/` et `Zettelkasten/permanents/`
2. **Extraction des tags**: Analyse du frontmatter YAML
3. **Regroupement par tag**: Agrégation des fichiers par tag
4. **Génération du cache**: Création du fichier JSON
5. **Tri et déduplication**: Organisation et nettoyage

### Performance

- **Temps de construction**: ~1-2 secondes pour 1000 fichiers
- **Temps de recherche**: ~100ms pour une recherche simple
- **Taille du cache**: ~50KB pour 1000 fichiers

### Limitations

1. **Tags uniques**: Un fichier ne peut avoir qu'un seul tag par catégorie
2. **Cache manuel**: Le cache doit être reconstruit manuellement
3. **Pas de mise à jour automatique**: Les scripts ne mettent pas à jour le cache automatiquement

---

## 🎯 Prochaines Étapes

### À venir
- [ ] Mise à jour automatique du cache lors des modifications
- [ ] Support des tags imbriqués
- [ ] Interface web pour visualiser les tags
- [ ] Intégration avec le système de demandes

---

## 📚 Ressources

- [`ipcrae-tag-index.sh`](../templates/scripts/ipcrae-tag-index.sh) - Script d'indexation
- [`ipcrae-tag.sh`](../templates/scripts/ipcrae-tag.sh) - Script de recherche
- [`ipcrae-index.sh`](../templates/scripts/ipcrae-index.sh) - Script d'analyse
- [`ipcrae-install.sh`](../ipcrae-install.sh) - Script d'installation
