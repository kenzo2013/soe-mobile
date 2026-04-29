import 'package:dio/dio.dart';

/// Stub : la conversion en Failure est faite dans le Repository.
/// Cet interceptor sert si on veut centraliser un événement (ex. analytics).
class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();
}
