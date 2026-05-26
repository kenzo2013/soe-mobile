# TODO

## Setup Google Places (à faire avant un vrai run device)

La clé doit être passée au build :

```bash
flutter run --dart-define=GOOGLE_PLACES_API_KEY=
```

ou via un fichier `env/dev.env` :

```
GOOGLE_PLACES_API_KEY=
```

puis `flutter run --dart-define-from-file=env/dev.env`.

### Restrictions Google Cloud à autoriser

- **Places API (New)**
- **Maps SDK for Android** (package `cm.soe.mobile` + SHA-1 du keystore)
- **Maps SDK for iOS** (bundle id `cm.soe.mobile`)

## Reste à valider en runtime

- Login : vérifier que le JWT arrive bien dans le header `Authorization` côté
  API (sinon adapter `_extractBearer` dans `auth_remote_datasource.dart`).
- Tester le flow complet : inscription → OTP reçu → confirmation → login.
- Tester reset password avec OTP de bout en bout.
- Vérifier l'autocomplete Places sur device réel.
