# Concept : [Nom du Concept - Ex: Authentication]

**Statut** : 🟡 En Réflexion | 🔵 Prêt pour Dev | 🟢 Terminé
**Date** : YYYY-MM-DD
**Dépend de** : [Liens éventuels, ex: 00_base_de_donnees.md]

- **Effort estimé** : 
- **Tests requis** : 

## 1. User Story et Intentions
*En tant que [rôle], je veux [action] afin de [bénéfice/but].*
- **Description** : [Explication claire du besoin sans technique]

## 2. Périmètre (V1 vs Future)
L'agent IA ne doit coder QUE la section `V1 (Requis)`. Les sections `V2+` et `Rejeté` sont listées pour éviter à l'IA de faire de mauvaises suggestions futures.

- [x] **V1 (Requis)** : [Ex: Connexion par email/mot de passe]
- [ ] **Prochaine Version (V2+)** : [Ex: Social Login Google/Github]
- [x] **Rejeté** : [Ex: 2FA par SMS, trop complexe et couteux, écarté définitivement]

## 3. Moyens Techniques et Logique Métier
- **Choix technique spécifique** : [Ex: Utilisation de JsonWebToken, validité 24h]
- **Base de données impactée** : [Ex: Table Users (id, email, password_hash)]
- **Algorithme / Logique** :
  1. Le user soumet le form.
  2. L'API vérifie le hash (argon2).
  3. Retourne token dans une res HTTPOnly Cookie.

## 4. Spécifications du Code (Prompt IA)
*Directives directes que l'IA exécutante doit accomplir pour terminer ce concept.*
- **Fichiers impactés** :
  - `src/api/auth.js` -> Implémenter POST /login
  - `src/ui/login.html` -> Créer le formulaire
- **Interfaces / Mockups** :
  ```javascript
  // L'interface attendue :
  interface AuthResponse {
     token: string;
     user: { id: number, email: string }
  }
  ```

## 5. Obstacles Rencontrés & Hacks
*À remplir par le Développeur ou l'IA Gérante durant le développement pour documenter les problèmes imprévus.*
- **Problème** : [Ex: L'API refuse les CORS en local]
- **Solution / Hack** : [Ex: Ajout d'un proxy dans Vite]
