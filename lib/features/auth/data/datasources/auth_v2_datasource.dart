import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints_v2.dart';
import '../../domain/entities/sign_up_answers.dart';

/// Calls of the API v2 authentication endpoints. Returns the `data` of the envelope.
class AuthV2Datasource {
  const AuthV2Datasource(this._dio);
  final Dio _dio;

  Future<({int status, Map<String, dynamic> data})> signIn(
      String login, String password) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiEndpointsV2.session,
      data: {'login': login, 'password': password},
    );
    return (status: r.statusCode ?? 0, data: _data(r));
  }

  Future<void> validateSignUpStep(SignUpStep step, SignUpAnswers answers) =>
      _dio.post<void>(
        ApiEndpointsV2.signUpValidate,
        data: {'step': step.name, 'sign_up': answers.toJson()},
      );

  Future<Map<String, dynamic>> signUp(SignUpAnswers answers) async => _data(
        await _dio.post<Map<String, dynamic>>(ApiEndpointsV2.signUp,
            data: {'sign_up': answers.toJson()}),
      );

  Future<Map<String, dynamic>> confirmEmail(
          String pendingToken, String code) async =>
      _data(
        await _dio.post<Map<String, dynamic>>(
          ApiEndpointsV2.confirmation,
          data: {'pending_token': pendingToken, 'code': code},
        ),
      );

  Future<Map<String, dynamic>> resendConfirmation(String pendingToken) async =>
      _data(
        await _dio.post<Map<String, dynamic>>(
          ApiEndpointsV2.confirmationResend,
          data: {'pending_token': pendingToken},
        ),
      );

  Future<Map<String, dynamic>> requestPasswordReset(String login) async =>
      _data(
        await _dio.post<Map<String, dynamic>>(ApiEndpointsV2.passwordReset,
            data: {'login': login}),
      );

  Future<Map<String, dynamic>> verifyResetCode(
          String resetToken, String code) async =>
      _data(
        await _dio.post<Map<String, dynamic>>(
          ApiEndpointsV2.passwordResetVerify,
          data: {'reset_token': resetToken, 'code': code},
        ),
      );

  Future<Map<String, dynamic>> resendPasswordReset(String resetToken) async =>
      _data(
        await _dio.post<Map<String, dynamic>>(
          ApiEndpointsV2.passwordResetResend,
          data: {'reset_token': resetToken},
        ),
      );

  Future<Map<String, dynamic>> resetPassword(
          String verifiedToken, String password, String confirmation) async =>
      _data(
        await _dio.put<Map<String, dynamic>>(
          ApiEndpointsV2.passwordReset,
          data: {
            'verified_token': verifiedToken,
            'password': password,
            'password_confirmation': confirmation
          },
        ),
      );

  Future<void> signOut() => _dio.delete<void>(ApiEndpointsV2.session);

  Future<Map<String, dynamic>> me() async =>
      _data(await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.me));

  Map<String, dynamic> _data(Response<Map<String, dynamic>> r) =>
      (r.data?['data'] as Map<String, dynamic>?) ?? const {};
}
