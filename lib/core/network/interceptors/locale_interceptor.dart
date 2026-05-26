import 'package:dio/dio.dart';

import '../../../i18n/translations.g.dart';

/// Injecte `Accept-Language` à chaque requête, basé sur la locale slang
/// courante. Permet à l'API SOE de renvoyer ses messages d'erreur dans la
/// langue de l'utilisateur (fr / en).
class LocaleInterceptor extends Interceptor {
  const LocaleInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] =
        LocaleSettings.instance.currentLocale.languageCode;
    handler.next(options);
  }
}
