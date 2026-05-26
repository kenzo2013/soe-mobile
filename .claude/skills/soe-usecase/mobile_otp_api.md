# API Mobile — Codes OTP (Confirmation & Reset Password)

> **Base URL** : `https://api.jeteste.site/api/v1`
> Tous les endpoints sont en `application/json`.

---

## Paramètre `client_type`

Pour activer le mode **code à 6 chiffres** (au lieu d'un lien web), passer `client_type: "mobile"` dans les requêtes d'inscription et de reset password.

---

## Configuration OTP

| Paramètre | Valeur |
|---|---|
| Longueur du code | 6 chiffres |
| Expiration | 15 minutes |
| Tentatives max | 5 (le code est invalidé après) |
| Hashage | SHA256 (le code n'est jamais stocké en clair) |

---

## 1. Inscription

### `POST /users/register`

Crée un nouveau compte. Si `client_type: "mobile"` est passé, un code à 6 chiffres est envoyé par email au lieu du lien de confirmation classique.

**Request :**
```json
{
  "client_type": "mobile",
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "first_name": "John",
    "last_name": "Doe",
    "civility": "male",
    "phone": "+237650000001",
    "role": "parent",
    "accept_cgu": true,
    "lang": "fr",
    "address_attributes": {
      "address": "247 rue Mandessi Bell",
      "city": "Douala",
      "neighborhood": "Akwa",
      "country": "Cameroun",
      "country_code": "CM"
    }
  }
}
```

**Réponse succès (200) :**
```json
{
  "status": { "code": 200, "message": "Inscription réussie." },
  "data": {
    "id": "abc123",
    "type": "user",
    "attributes": {
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "role": "parent",
      "status": "active",
      "full_name": "Doe John",
      "avatar_url": null
    }
  }
}
```

> L'utilisateur reçoit un email avec un code à 6 chiffres.
> Le compte n'est **pas encore confirmé** — il faut appeler `/users/confirmation/verify_code`.

**Réponse erreur (422) :**
```json
{
  "status": { "code": 422, "message": "Email a déjà été pris, Phone est trop court" }
}
```

---

## 2. Confirmation de compte

### 2a. Renvoyer le code de confirmation

### `POST /users/confirmation`

Renvoie un email de confirmation. Si `client_type: "mobile"`, envoie un code à 6 chiffres.

**Request :**
```json
{
  "email": "user@example.com",
  "client_type": "mobile"
}
```

**Réponse succès (200) :**
```json
{
  "status": { "code": 200, "message": "Instructions de confirmation envoyées à votre email." }
}
```

**Erreurs possibles (422) :**

| Message | Cause |
|---|---|
| `"Aucun compte trouvé avec cet email."` | Email inconnu |
| `"Le compte est déjà confirmé."` | Compte déjà activé |

---

### 2b. Vérifier le code de confirmation

### `POST /users/confirmation/verify_code`

Vérifie le code à 6 chiffres et confirme le compte si valide.

**Request :**
```json
{
  "email": "user@example.com",
  "code": "482910"
}
```

**Réponse succès (200) :**
```json
{
  "status": { "code": 200, "message": "Compte confirmé avec succès." },
  "data": {
    "id": "abc123",
    "type": "user",
    "attributes": {
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "role": "parent"
    }
  }
}
```

**Erreurs possibles (422) :**

| Message | Cause |
|---|---|
| `"Code de confirmation invalide ou expiré."` | Mauvais code, expiré (>15 min), ou 5 tentatives dépassées |
| `"Aucun compte trouvé avec cet email."` | Email inconnu |
| `"Le compte est déjà confirmé."` | Compte déjà activé |

---

## 3. Réinitialisation du mot de passe

### 3a. Demander un code de reset

### `POST /users/password`

Envoie un code de réinitialisation par email. Passer `client_type: "mobile"` pour recevoir un code au lieu d'un lien.

**Request :**
```json
{
  "email": "user@example.com",
  "client_type": "mobile"
}
```

**Réponse succès (200) :**
```json
{
  "status": { "code": 200, "message": "Code de réinitialisation envoyé à votre email." }
}
```

**Erreur (422) :**
```json
{
  "status": { "code": 422, "message": "Aucun compte trouvé avec cet email." }
}
```

---

### 3b. Vérifier le code de reset

### `POST /users/password/verify_code`

Vérifie que le code est valide **sans le consommer**. Permet d'afficher un écran "code valide" avant de demander le nouveau mot de passe.

**Request :**
```json
{
  "email": "user@example.com",
  "code": "739201"
}
```

**Réponse succès (200) :**
```json
{
  "status": { "code": 200, "message": "Le code est valide." }
}
```

**Erreur (422) :**
```json
{
  "status": { "code": 422, "message": "Code de réinitialisation invalide ou expiré." }
}
```

---

### 3c. Réinitialiser le mot de passe avec le code

### `PATCH /users/password/reset_with_code`

Change le mot de passe en utilisant le code vérifié. Le code est consommé après succès.

**Request :**
```json
{
  "email": "user@example.com",
  "code": "739201",
  "password": "nouveauMotDePasse123",
  "password_confirmation": "nouveauMotDePasse123"
}
```

**Réponse succès (200) :**
```json
{
  "status": { "code": 200, "message": "Mot de passe réinitialisé avec succès." }
}
```

**Erreurs possibles (422) :**

| Message | Cause |
|---|---|
| `"Code de réinitialisation invalide ou expiré."` | Mauvais code, expiré, ou tentatives dépassées |
| `"Mot de passe est trop court (6 caractères minimum)"` | Validation mot de passe |
| `"Confirmation du mot de passe ne correspond pas"` | password != password_confirmation |
| `"Aucun compte trouvé avec cet email."` | Email inconnu |

---

## Flows complets

### Flow 1 : Inscription mobile

```
1. POST /users/register        (client_type: "mobile")
   → 200 + user data
   → Email envoyé avec code 6 chiffres

2. POST /users/confirmation/verify_code   (email + code)
   → 200 + user data (compte confirmé)

3. POST /users/login            (email + password)
   → 200 + JWT token
```

### Flow 2 : Renvoi de confirmation (si email non reçu)

```
1. POST /users/confirmation     (email, client_type: "mobile")
   → 200 (nouveau code envoyé)

2. POST /users/confirmation/verify_code   (email + code)
   → 200 (compte confirmé)
```

### Flow 3 : Reset mot de passe mobile

```
1. POST /users/password              (email, client_type: "mobile")
   → 200 (code envoyé par email)

2. POST /users/password/verify_code  (email + code)
   → 200 (code valide, afficher écran nouveau mot de passe)

3. PATCH /users/password/reset_with_code  (email + code + password + password_confirmation)
   → 200 (mot de passe changé)

4. POST /users/login                 (email + nouveau password)
   → 200 + JWT token
```

---

## Gestion des erreurs

Toutes les erreurs suivent le même format :

```json
{
  "status": {
    "code": 422,
    "message": "Description de l'erreur"
  }
}
```

### Cas limites

| Situation | Comportement |
|---|---|
| Code expiré (>15 min) | Retourne `422` — demander un nouveau code |
| 5 tentatives échouées | Code invalidé — demander un nouveau code |
| Email inconnu | Retourne `422` avec message explicite |
| Compte déjà confirmé | Retourne `422` — rediriger vers login |
| `client_type` absent | Comportement web par défaut (lien au lieu de code) |

---

## Endpoints existants (rappel)

| Endpoint | Méthode | Auth | Description |
|---|---|---|---|
| `/users/login` | POST | Non | Connexion (retourne JWT) |
| `/users/logout` | DELETE | Oui | Déconnexion |
| `/users/register` | POST | Non | Inscription |
| `/current_user` | GET | Oui | Profil utilisateur |
| `/current_user` | PATCH | Oui | Modifier profil |
| `/current_user/update_password` | PATCH | Oui | Changer mot de passe (connecté) |
| `/user_devices` | POST | Oui | Enregistrer device push |
| `/user_devices/activity` | PATCH | Oui | Mettre à jour activité device |
