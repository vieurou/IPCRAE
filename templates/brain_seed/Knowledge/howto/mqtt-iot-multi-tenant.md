---
type: knowledge
tags: [mqtt, iot, multi-tenant, mosquitto, nodered, architecture, devops, escapecode]
domain: devops
status: stable
sources: [project:EscapeCode/_bmad-output/architecture, project:EscapeCode/escapecode-poc]
created: 2026-02-22
updated: 2026-02-22
---

# MQTT IoT Multi-Tenant — Architecture et Patterns

## Architecture Hybride Temps-Réel + Asynchrone

Pattern validé sur EscapeCode (POC 2026-01-18) :

```
IoT Devices (ESP32/Sensors)
    ↓ MQTT Pub
Mosquitto 2.0 (Broker)
    ↓ MQTT Sub
Node-RED (temps-réel, <100ms)
    ├→ Redis (cache état + pub/sub)
    ├→ Dashboard monitoring
    └→ HTTP Webhook
        ↓
n8n (async, <5s)
    ├→ PostgreSQL (persistence)
    ├→ External APIs (Stripe, Email)
    └→ Redis (cache update)
```

**Règle de split** : Node-RED pour réponse immédiate (<100ms), n8n pour logique métier (<5s).

## Structure Topics MQTT Multi-Tenant

```
{app}/sensor/{tenant_id}/{location}/{sensor_type}/{id}/data
{app}/control/{tenant_id}/{room_id}/{device_id}/cmd
{app}/status/{tenant_id}/{resource_type}/{resource_id}
{app}/system/{component}/health
```

**QoS par criticité** :
- `sensor/data` : QoS 0 (best effort, haute fréquence tolère pertes)
- `control/cmd` : QoS 2 (exactly-once, actions critiques)
- `status` : QoS 1 (at-least-once, état important)

**Pattern wildcard Node-RED** :
```
Topic: {app}/sensor/+/data     ← couvre tous les tenants/capteurs
→ 1 flow = tous les appareils (scalable sans code changes)
```

## Isolation Multi-Tenant

**ACL Mosquitto** (par tenant) :
```conf
# Dans mosquitto.conf
pattern read {app}/sensor/%u/#
pattern write {app}/control/%u/#
```

**Isolation BDD** (schéma par tenant) :
```sql
CREATE SCHEMA tenant_{tenant_id};
-- Tables par tenant : sensors, readings, configs, rooms
-- Avantage : backup/restore par tenant, isolation complète
```

## Stack POC Validée

| Service | Image | Port | Usage |
|---------|-------|------|-------|
| Mosquitto | eclipse-mosquitto:2.0 | 1883, 9001 (WS) | MQTT broker |
| Node-RED | nodered/node-red | 1880 | Real-time flows |
| n8n | n8nio/n8n:1.0.0 | 5678 | Async workflows |
| Redis | redis:7-alpine | 6379 | Cache + Pub/Sub |

## Métriques POC EscapeCode (référence)

| Métrique | Cible | Résultat |
|----------|-------|----------|
| Messages traités | 1000+ | 1032 (100%) |
| Latence end-to-end | <100ms | <50ms |
| Débit | >1 msg/s | 2.9 msg/s |
| CPU | - | <1% |
| RAM | <500MB | 102MB |

## Lancement POC

```bash
cd /home/eric/DEV/EscapeCode/escapecode-poc
docker-compose up -d
# Node-RED UI : http://localhost:1880
# Simulation capteurs : python3 mqtt-publisher.py
```

## Liens
- [[Knowledge/patterns/nodered-n8n-architecture-hybride]] — Pattern détaillé
- [[Knowledge/howto/docker-compose-multi-services]] — Orchestration Docker
