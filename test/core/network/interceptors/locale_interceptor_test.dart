import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/network/interceptors/locale_interceptor.dart';
import 'package:soe/i18n/translations.g.dart';

class _MockReqHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  late _MockReqHandler handler;
  const interceptor = LocaleInterceptor();

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  setUp(() {
    handler = _MockReqHandler();
  });

  test('injecte Accept-Language avec la locale fr', () {
    LocaleSettings.setLocaleSync(AppLocale.fr);
    final options = RequestOptions(path: '/foo');

    interceptor.onRequest(options, handler);

    expect(options.headers['Accept-Language'], 'fr');
    verify(() => handler.next(options)).called(1);
  });

  // NB: AppLocale.en utilise une "deferred library" (loadLibrary async) qui
  // ne peut pas être chargée via setLocaleSync sous flutter_test ("Deferred
  // library l_en was not loaded"). On ne teste donc que la locale fr (par
  // défaut, buildSync direct). Le code de l'intercepteur lit simplement
  // currentLocale.languageCode, indépendant de la locale concrète.

  test('appelle toujours handler.next', () {
    LocaleSettings.setLocaleSync(AppLocale.fr);
    final options = RequestOptions(path: '/foo');

    interceptor.onRequest(options, handler);

    verify(() => handler.next(options)).called(1);
  });
}
