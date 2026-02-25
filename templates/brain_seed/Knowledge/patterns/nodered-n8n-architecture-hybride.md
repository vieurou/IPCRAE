---
type: knowledge
tags: [nodered, n8n, architecture, realtime, async, iot, webhook, pattern, devops]
domain: devops
status: stable
sources: [project:EscapeCode/_bmad-output/architecture/system-architecture.md]
created: 2026-02-22
updated: 2026-02-22
---

# Pattern : Architecture Hybride Node-RED + n8n (Temps-Réel + Asynchrone)

## Problème résolu

Un système IoT a deux classes de besoins contradictoires :
1. **Réponse immédiate** (<100ms) : contrôle capteurs, alertes, dashboard
2. **Logique métier** (<5s acceptable) : notifications, API externes, persistance, facturation

Mettre tout dans Node-RED → trop lent pour la logique métier (single-thread).
Mettre tout dans n8n → trop lent pour le temps-réel.

## Solution : Split par latence

```
Node-RED (temps-réel)          n8n (asynchrone)
├── MQTT subscriber            ├── Business logic
├── Data parsing               ├── External APIs
├── Cache Redis writes         ├── PostgreSQL writes
├── Dashboard updates          ├── Email/notifications
└── Webhook → n8n              └── Audit logs
```

**Interface** : Node-RED envoie un HTTP webhook vers n8n pour chaque event nécessitant traitement asynchrone.

## Avantages du découplage

- **Résilience** : une panne n8n ne bloque pas les flows temps-réel
- **Scalabilité indépendante** : Node-RED et n8n scalent séparément
- **Observabilité** : chaque webhook = 1 event dans les logs n8n
- **Low-code** : les deux outils sont visuels (pas de code backend à maintenir)

## Pattern Function Node-RED (stateless)

```javascript
// Parsing + enrichissement (Node-RED function node)
const data = JSON.parse(msg.payload);
msg.payload = {
    ...data,
    timestamp: Date.now(),
    tenant_id: msg.topic.split('/')[2],
    processed_at: new Date().toISOString()
};
return msg;
```

Règle : **fonctions Node-RED = stateless** (pas de state interne). State → Redis.

## Pattern Webhook n8n

Node-RED → HTTP POST vers n8n :
```json
{
  "event": "sensor_reading",
  "tenant_id": "tenant_123",
  "sensor_id": "temp_01",
  "value": 22.5,
  "unit": "°C",
  "timestamp": 1708589000000
}
```

n8n trigger : Webhook node écoute `POST /webhook/{unique-id}`.

## Redis comme lien entre les deux

```
Node-RED → SET sensor:{tenant}:{id}:latest = {value, ts}   (cache live)
n8n     → GET sensor:{tenant}:{id}:latest                   (lecture état)
n8n     → SET processing:{event_id}:status = done           (acquittement)
```

## Quand utiliser ce pattern

✅ IoT avec logique métier non triviale
✅ Multi-tenant SaaS avec isolation requise
✅ Besoins temps-réel ET async coexistants
✅ Équipe petite (low-code = moins de maintenance)

❌ Si latence totale doit être <10ms (préférer un seul service Go/Rust)
❌ Si les flows sont très simples (Node-RED seul suffit)

## Liens
- [[mqtt-iot-multi-tenant]] — Architecture MQTT complète
- [[memoire-domaine-ipcrae]] — Décisions spécifiques projet
