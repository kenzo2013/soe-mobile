import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';

/// Garde commune des repositories tuteur : exécute `body`, convertit les
/// `DioException` en `Failure` typées (utile dès le branchement API réel) et
/// rattrape toute autre erreur en `UnknownFailure` (sécurité côté mock).
Future<Result<T, Failure>> tutorGuard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on DioException catch (e) {
    return Err(ExceptionMapper.fromDio(e));
  } catch (_) {
    return const Err(UnknownFailure());
  }
}
