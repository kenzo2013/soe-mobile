import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dtos/auth_response_dto.dart';
import '../dtos/user_dto.dart';

class AuthRemoteDatasource {
  const AuthRemoteDatasource(this._dio);
  final Dio _dio;

  static const String _clientTypeMobile = 'mobile';

  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'user': {'email': email, 'password': password},
      },
    );
    final token = _extractBearer(r.headers);
    final body = r.data!;
    final userJson = body['data'] as Map<String, dynamic>;
    return LoginResponseDto(
      data: UserDto.fromJson(userJson),
      accessToken: token,
    );
  }

  Future<RegisterResponseDto> register(RegisterParams p) async {
    final body = <String, dynamic>{
      'client_type': _clientTypeMobile,
      'user': {
        'email': p.email,
        'password': p.password,
        'password_confirmation': p.passwordConfirmation,
        'first_name': p.firstName,
        'last_name': p.lastName,
        'role': p.role.apiValue,
        'accept_cgu': p.acceptCgu,
        'lang': p.lang,
        if (p.civility != null) 'civility': p.civility,
        if (p.phone != null) 'phone': p.phone,
        if (_hasAddress(p))
          'address_attributes': {
            if (p.address != null) 'address': p.address,
            if (p.neighborhood != null) 'neighborhood': p.neighborhood,
            if (p.city != null) 'city': p.city,
            if (p.country != null) 'country': p.country,
            if (p.countryCode != null) 'country_code': p.countryCode,
          },
      },
    };
    final r = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: body,
    );
    return RegisterResponseDto.fromJson(r.data!);
  }

  Future<void> resendConfirmation({required String email}) async {
    await _dio.post<void>(
      ApiEndpoints.confirmation,
      data: {
        'email': email,
        'client_type': _clientTypeMobile,
      },
    );
  }

  Future<ConfirmationResponseDto> verifyConfirmationCode({
    required String email,
    required String code,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.confirmationVerifyCode,
      data: {'email': email, 'code': code},
    );
    return ConfirmationResponseDto.fromJson(r.data!);
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _dio.post<void>(
      ApiEndpoints.passwordReset,
      data: {
        'email': email,
        'client_type': _clientTypeMobile,
      },
    );
  }

  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    await _dio.post<void>(
      ApiEndpoints.passwordVerifyCode,
      data: {'email': email, 'code': code},
    );
  }

  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _dio.patch<void>(
      ApiEndpoints.passwordResetWithCode,
      data: {
        'email': email,
        'code': code,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<void> logout() async {
    await _dio.delete<void>(ApiEndpoints.logout);
  }

  bool _hasAddress(RegisterParams p) =>
      p.address != null ||
      p.neighborhood != null ||
      p.city != null ||
      p.country != null ||
      p.countryCode != null;

  /// Devise-JWT renvoie le token via l'en-tête `Authorization: Bearer <jwt>`.
  String _extractBearer(Headers headers) {
    final raw = headers.value('authorization') ?? headers.value('Authorization');
    if (raw == null || raw.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        type: DioExceptionType.badResponse,
        message: 'Missing Authorization header on login response',
      );
    }
    return raw.toLowerCase().startsWith('bearer ') ? raw.substring(7) : raw;
  }
}
