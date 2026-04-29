# Feature `auth`

Authentification SOE — login, register, mot de passe oublié, logout.

## Endpoints API consommés
| Méthode | Endpoint | Description |
|---|---|---|
| POST | `/users/login` | Connexion |
| POST | `/users/register` | Inscription parent ou tuteur |
| POST | `/users/password` | Demande de réinitialisation |
| DELETE | `/users/logout` | Déconnexion |

## UseCases

### `Login`
```dart
Future<Result<AuthSession, Failure>> call({
  required String email,
  required String password,
})
```
Valide email et mot de passe non vide. En cas de succès, persiste token et rôle dans `SecureStorage`.

### `Register`
```dart
Future<Result<AuthSession, Failure>> call({required RegisterParams params})
```
Valide email, mot de passe ≥ 8 chars, confirmation, prénom/nom non vides, CGU acceptées. Persiste la session.

### `RequestPasswordReset`
```dart
Future<Result<void, Failure>> call({required String email})
```

### `Logout`
```dart
Future<Result<void, Failure>> call()
```
Efface toujours le token local, même si l'appel serveur échoue.

## State
`AuthState` (sealed freezed) : `initial | loading | authenticated(session) | passwordResetSent(email) | error(failure)`.

## Persistance
Tokens et rôle dans `flutter_secure_storage` (clés : `StorageKeys.authToken`, `StorageKeys.currentRole`).
JAMAIS dans `SharedPreferences`.

## Sécurité
- Mot de passe jamais loggé.
- Aucun secret en dur.
- Token purgé au 401 par `AuthInterceptor`.
