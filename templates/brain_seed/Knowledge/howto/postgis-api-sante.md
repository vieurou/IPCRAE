---
type: knowledge
tags: [postgis, postgresql, geospatial, sante, fhir, keycloak, nodejs, sequelize, devops]
domain: devops
status: stable
sources: [project:megadockerapi/docs/models_analysis.md, project:megadockerapi/MegaAPI/src/models]
created: 2026-02-22
updated: 2026-02-22
---

# PostGIS + API Santé — Patterns Geospatiaux et Healthcare

## Stack de Base (megadockerapi)

```
PostgreSQL 13 + PostGIS → Sequelize 6 → Express.js → Traefik → (SvelteKit frontend)
                                     ↑
                               Keycloak SSO
                                     ↑
                               HAPI FHIR server (HL7 eSanté)
```

## Modèles Géospatiaux Sequelize + PostGIS

```javascript
// adresse.model.js — Point GPS précis
gpsPoint: {
  type: DataTypes.GEOMETRY('POINT', 4326),
  allowNull: true
}

// zone.model.js — Zone de couverture (polygone)
gpsPoints: {
  type: DataTypes.GEOMETRY('MULTIPOLYGON', 4326),
  allowNull: true
}
```

**Requêtes clés** :
```sql
-- Trouver tous les professionnels dans une zone
SELECT p.* FROM professionnels p
JOIN adresses a ON p.id = a.professionnel_id
WHERE ST_Within(a.gps_point, (SELECT gps_points FROM zones WHERE id = $zoneId));

-- Distance entre deux points
SELECT ST_Distance(p1.gps_point::geography, p2.gps_point::geography) as dist_meters
FROM adresses p1, adresses p2 WHERE p1.id = $a AND p2.id = $b;
```

## Pattern Type System (Référentiel)

Chaque entité a une table "type_*" :
```
Contacts → type_contact
Professions → type_profession
Diplômes → type_diplome
Mails → type_mail
Téléphones → type_telephone
```

**Avantage** : Cohérence référentielle, classification extensible sans migration schema.

## Génération Dynamique CRUD (megaApi.generator.js)

```javascript
// Controller/route auto-généré depuis chaque modèle Sequelize
// megaApi.generator.js → lit models/ → génère routes + controllers
// → contrôleur unifié via controllerAccessService
```

Évite le code CRUD répétitif : 50 modèles → 50 API CRUD sans code manuel.

## FHIR (HL7) avec HAPI FHIR

Configuration `hapi.application.yaml` → PostgreSQL backend.
Standard français : codifications JDV/TRE pour professions et diplômes.

```bash
# Import eSanté (professions de santé)
POST /api/admin/import    # déclenche l'import du registre national
```

## Keycloak SSO Multi-Tenant

```javascript
// config Keycloak pour express
const keycloak = new Keycloak({
  store: memoryStore
}, {
  realm: 'megadockerapi',
  'auth-server-url': 'http://keycloak:8080/auth',
  resource: 'megaapi-client'
});
```

⚠️ En dev : Keycloak middleware commenté (`start-dev`). En prod → activer + restreindre CORS.

## Docker Compose (Commandes Makefile)

```bash
make install    # Init volumes + install dépendances
make dev        # Stack complète
make devMini    # Core seulement (sans Cantaloupe, CloudBeaver)
make purgeALL   # DANGER : reset complet
```

## Liens
- [[Knowledge/patterns/nodered-n8n-architecture-hybride]] — Autres patterns Node.js/Docker
- [[git-workflow-ipcrae]] — Branches features + PR workflow
