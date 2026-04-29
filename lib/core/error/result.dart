/// Type Result<S, F> : succès ou échec, sans throw.
///
/// Pattern-matching Dart 3 :
/// ```dart
/// switch (result) {
///   Ok(:final value) => ...,
///   Err(:final failure) => ...,
/// }
/// ```
sealed class Result<S, F> {
  const Result();

  bool get isOk => this is Ok<S, F>;
  bool get isErr => this is Err<S, F>;

  S? get valueOrNull => switch (this) {
        Ok(:final value) => value,
        Err() => null,
      };

  F? get failureOrNull => switch (this) {
        Ok() => null,
        Err(:final failure) => failure,
      };
}

final class Ok<S, F> extends Result<S, F> {
  final S value;
  const Ok(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<S, F> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

final class Err<S, F> extends Result<S, F> {
  final F failure;
  const Err(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Err<S, F> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;
}
