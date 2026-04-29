---
name: soe-repository
description: Crée l'interface Domain Repository + son implémentation Data + DTO freezed + Mapper + tests round-trip et propagation des Failures. À utiliser pour exposer une nouvelle ressource API.
---

# soe-repository

Génère interface Domain + impl Data + DataSource + DTO + Mapper + tests.

## Fichiers à créer

### 1. Interface (Domain)
```dart
// lib/features/<feature>/domain/repositories/<feature>_repository.dart
abstract class <Feature>Repository {
  Future<Result<<Entity>, Failure>> get<X>(...);
  Future<Result<void, Failure>> <action>(...);
}
```

### 2. Entity (Domain) — freezed, pas de json
```dart
// lib/features/<feature>/domain/entities/<entity>.dart
@freezed
class <Entity> with _$<Entity> {
  const factory <Entity>({required String id, /* ... */}) = _<Entity>;
}
```

### 3. DTO (Data) — freezed + json_serializable
```dart
// lib/features/<feature>/data/dtos/<entity>_dto.dart
@freezed
class <Entity>Dto with _$<Entity>Dto {
  const factory <Entity>Dto({
    required String id,
    @JsonKey(name: 'first_name') required String firstName,
  }) = _<Entity>Dto;

  factory <Entity>Dto.fromJson(Map<String, dynamic> j) => _$<Entity>DtoFromJson(j);
}
```

### 4. Mapper (Data)
```dart
// lib/features/<feature>/data/mappers/<entity>_mapper.dart
extension <Entity>DtoX on <Entity>Dto {
  <Entity> toEntity() => <Entity>(id: id, /* ... */);
}
```

### 5. Remote DataSource (Data)
```dart
// lib/features/<feature>/data/datasources/<feature>_remote_datasource.dart
class <Feature>RemoteDatasource {
  const <Feature>RemoteDatasource(this._dio);
  final Dio _dio;

  Future<<Entity>Dto> fetch<X>() async {
    final r = await _dio.get<Map<String, dynamic>>('/parents/...');
    return <Entity>Dto.fromJson(r.data!['data'] as Map<String, dynamic>);
  }
}
```

### 6. Repository Impl (Data)
```dart
// lib/features/<feature>/data/repositories/<feature>_repository_impl.dart
class <Feature>RepositoryImpl implements <Feature>Repository {
  const <Feature>RepositoryImpl(this._remote);
  final <Feature>RemoteDatasource _remote;

  @override
  Future<Result<<Entity>, Failure>> get<X>(...) async {
    try {
      final dto = await _remote.fetch<X>();
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
```

## Règles dures
- **Le DataSource throw** des `DioException`. **Le Repository convertit** via `ExceptionMapper.fromDio`.
- **Aucun `Result` dans le DataSource** — il manipule des DTO et des exceptions Dio.
- **Aucun `try/catch` dans Domain** ni dans Presentation.
- **DTO ≠ Entity** : Domain ne connaît jamais `*_dto.dart`.
- Endpoints **jamais en dur** dans le code : centraliser dans `core/network/api_endpoints.dart`.
- Multipart : utiliser `FormData.fromMap({...})` côté DataSource. Compresser images (qualité 80%, max 1920px) en amont.

## Tests obligatoires

### Mapper (round-trip 100 %)
```dart
test('round-trip DTO -> Entity preserves fields', () {
  final dto = <Entity>Dto(id: '1', firstName: 'Jean');
  final e = dto.toEntity();
  expect(e.id, '1');
  expect(e.firstName, 'Jean');
});
```

### Repository Impl (≥ 80 %)
```dart
class _MockDS extends Mock implements <Feature>RemoteDatasource {}

test('returns Ok on success', () async {
  when(() => ds.fetch<X>()).thenAnswer((_) async => _dto());
  expect(await repo.get<X>(), isA<Ok>());
});

test('maps DioException 401 -> UnauthorizedFailure', () async {
  when(() => ds.fetch<X>()).thenThrow(DioException(
    requestOptions: RequestOptions(),
    response: Response(requestOptions: RequestOptions(), statusCode: 401),
  ));
  final r = await repo.get<X>();
  expect(r, isA<Err>());
  expect((r as Err).failure, isA<UnauthorizedFailure>());
});
```

Couvrir au minimum les codes : 400, 401, 403, 404, 409, 422, 5xx, network timeout.
