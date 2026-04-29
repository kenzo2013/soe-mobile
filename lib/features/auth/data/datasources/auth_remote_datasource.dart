import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dtos/auth_response_dto.dart';

class AuthRemoteDatasource {
  const AuthRemoteDatasource(this._dio);
  final Dio _dio;

  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'user': {'email': email, 'password': password},
      },
    );
    return AuthResponseDto.fromJson(r.data!);
  }

  Future<AuthResponseDto> register(RegisterParams p) async {
    final body = <String, dynamic>{
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
    return AuthResponseDto.fromJson(r.data!);
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _dio.post<void>(
      ApiEndpoints.passwordReset,
      data: {
        'user': {'email': email},
      },
    );
  }

  Future<void> logout() async {
    await _dio.delete<void>(ApiEndpoints.logout);
  }

  bool _hasAddress(RegisterParams p) =>
      p.neighborhood != null ||
      p.city != null ||
      p.country != null ||
      p.countryCode != null;
}
