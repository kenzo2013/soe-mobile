import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/failure_message.dart';
import 'package:soe/i18n/translations.g.dart';

void main() {
  final tr = AppLocale.fr.buildSync();

  test('asFailure keeps a Failure and turns anything else into UnknownFailure',
      () {
    expect(asFailure(const NetworkFailure()), isA<NetworkFailure>());
    expect(asFailure(const FormatException('bad json')), isA<UnknownFailure>());
    expect(asFailure(StateError('oops')), isA<UnknownFailure>());
  });

  test(
      'a Failure can be thrown (AsyncNotifier.build) and caught as an Exception',
      () {
    expect(() => throw const NotFoundFailure(), throwsA(isA<Exception>()));
  });

  test('failureMessage uses the server message for conflicts and validation',
      () {
    expect(failureMessage(const ConflictFailure('Devis déjà accepté'), tr),
        'Devis déjà accepté');
    expect(
        failureMessage(const ValidationFailure({}), tr), tr.errors.validation);
    expect(failureMessage(const NetworkFailure(), tr), tr.errors.network);
  });
}
