# Feature `tutor` — Workflow Tuteur

Flux **Tuteur** (22 écrans · 8 sections) d'après le design Claude Design
(`Tutor.html`), **branché sur l'API REST SOE** (CDC §5 et §7.6). Architecture
Clean / MVVM Riverpod, conforme à `REBUILD_SPEC.md` (§5, §13).

## Sections & écrans

| # | Section | Écrans | Route racine |
|---|---------|--------|--------------|
| 1 | Tableau de bord | Dashboard (séances du jour + 4 stats + actions) | `/tutor` |
| 2 | Mon profil | Hub · Bio · Formations · Expériences · Pièces d'identité · Matières/niveau · Disponibilités | `/tutor/profile` |
| 3 | Offres d'emploi | Liste · Détail · Postuler | `/tutor/jobs` |
| 4 | Mes cours | Cours actifs · Détail élève + EDT · Gérer horaires | `/tutor/courses` |
| 5 | Séances | Liste groupée · Détail (flags) · Modifier · Rapport + signature | `/tutor/sessions` |
| 6 | Rémunérations | Hero earnings + historique | `/tutor/remunerations` |
| 7 | Infos de paiement | Méthodes (MoMo/Orange/banque) · Ajouter compte bancaire | `/tutor/payment` |
| 8 | Contrats | À signer / signés + avenants | `/tutor/contracts` |

## Endpoints branchés (CDC §7.6)

**Lecture** : `GET /tutors` · `/tutors/jobs(/:id)` · `/tutors/tutoring_courses` ·
`/tutors/students/:id?reservation_id=` · `/tutors/sessions(/:id/details)` ·
`/tutors/remunerations` · `/tutors/descriptions` · `/tutors/trainings` ·
`/tutors/works` · `/tutors/identities` · `/tutors/tutor_courses` ·
`/tutors/availabilities` · `/tutors/payment_informations` · `/common/contracts` ·
`/current_user` (identité du profil).

**Écriture** : `POST /tutors/candidacies` · `POST|PATCH /tutors/descriptions` ·
CRUD `trainings` / `works` / `identities` (multipart) / `tutor_courses` /
`availabilities` · `POST /tutors/sessions/:id/session_reports` (multipart
signature) · `PATCH /tutors/sessions/:id` · `POST
/tutors/tutoring_courses/manage_schedules` · `POST /tutors/payment_informations`
+ `PATCH .../:id/mark_as_default` · `PATCH /common/contracts/:id` (signature).

## Conventions data (alignées sur la feature `parent`)

- **Envelope** `{ status, data, pagination }` → `TutorApi.dataObject/dataList`.
- **JSON:API** : aplatissement récursif des `{ id, attributes }` à tous les
  niveaux via `TutorApi.deepFlat`.
- **DTOs tolérants** (`data/dtos/*`) : `@Default`, champs nullables, `readValue`
  acceptant plusieurs alias de champ, normalisation des listes hétérogènes
  (`TutorApi.names`). Les **dates ISO** sont parsées puis **formatées dans
  `toEntity()`** (`TutorApi.timeRange/dateLine/shortDate/relative`) → les entités
  portent des chaînes d'affichage, **les pages restent inchangées**.
- **Payloads Rails** wrappés (`{ training: {...} }`) ; **multipart**
  (`identity[images][]`, `session_report[signature]`, `contract[signature]`) via
  `TutorApi.multipart`.
- **Erreurs** : `tutorGuard` convertit les `DioException` en `Failure` typées
  (`ExceptionMapper.fromDio`) — 401/403/404/409/422 (CDC §7.4).

> ⚠️ La forme exacte des réponses tuteur n'étant pas détaillée champ par champ
> dans le CDC, les DTOs sont **défensifs** : les noms de champ probables sont
> mappés avec des alias et des défauts, de sorte qu'un écart de nommage dégrade
> proprement (valeur vide) plutôt que de planter. À confronter au Swagger
> (`https://api.jeteste.site/api-docs`) pour ajuster les alias si besoin.

## Structure

```
domain/
  entities/        + tutor_form_params.dart (params des mutations)
  repositories/    tutor_repositories.dart (8 interfaces, lecture + écriture)
  usecases/        tutor_usecases.dart (lecture + écriture, 1 action = 1 classe)
data/
  dtos/            *_dto.dart (freezed + json_serializable, tolérants + toEntity)
  datasources/     *_remote_datasource.dart (Dio) + tutor_remote_base.dart (helpers)
  repositories/    tutor_repositories_impl.dart + tutor_repo_guard.dart
presentation/
  viewmodels/      tutor_async_state.dart (AsyncList/Item/Object + TutorActionState)
                   tutor_viewmodels.dart (16 VM lecture)
  providers.dart   datasource → repository → usecase → viewModel (+ usecases écriture)
  pages/           22 ConsumerWidget (state.when)
  widgets/         tutor_drawer, tutor_app_bar, tutor_ui,
                   tutor_action (runTutorAction + tutorFailureMessage),
                   tutor_signature (canvas → PNG → fichier temp),
                   tutor_form_sheets (sheets CRUD + signature contrat)
  routes.dart      tutorRoutes()
```

### Mutations (écriture)

`TutorActionViewModel` (`idle/submitting/success/error`) pilote les
formulaires ; la View réagit via `runTutorAction(...)` (toast succès/erreur,
pop, refresh de la liste concernée). Aucun `BuildContext` dans les VM.

La signature (rapport de séance, contrat) est capturée par
`TutorSignatureController` puis exportée en **PNG transparent** (`PictureRecorder`)
écrit dans un fichier temporaire, uploadé en multipart.

## Limites connues (gaps API du CDC §7.7)

- **Matières (`subjects`)** : pas d'endpoint dédié → l'ajout de matières par
  classe (`tutor_courses`) est partiel (suppression OK ; la création nécessite
  `GET /references/subjects` à créer côté back). Picker de classe via la feature
  `references` (`/common/school_classes`).
- **Profil** : pas d'endpoint agrégé — composé de `/current_user` + bio
  (`/tutors/descriptions`). Note/avis du tuteur non exposés côté tuteur (0 par
  défaut).
- Le détail d'un cours utilise `GET /tutors/students/:id` (studentId) ; le
  `reservation_id` est passé en query quand disponible.

## Tests

```bash
flutter test test/features/tutor      # 28 tests
flutter analyze lib/features/tutor    # No issues found
```

- `…/viewmodels/tutor_viewmodels_test.dart` — 4 états des 16 ViewModels de
  lecture + `TutorActionViewModel` (idle/submitting/success/error + concurrence).
- `…/data/tutor_mappers_test.dart` — `deepFlat` JSON:API, mapping DTO→Entity
  tolérant (alias, dates, sous-objets), agrégations `groupSessionsByDay` /
  `buildRemunerations`.

## Reste à faire

- Confronter les DTOs au Swagger et ajuster les alias de champs réels.
- Endpoint `references/subjects` pour finaliser le CRUD matières.
- Téléchargement des reçus PDF (rémunérations / contrats) et pickers
  date/heure natifs sur l'édition de séance.
- Couverture tests widget par page + seuil 80 % (DoD §7.5).
```
