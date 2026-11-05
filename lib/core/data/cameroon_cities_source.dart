import 'package:dio/dio.dart';

import '../error/exception_mapper.dart';
import '../network/api_endpoints_v2.dart';
import 'cameroon_city.dart';

/// Every city of Cameroon, main ones first (`GET /auth/cities`, public: the sign-up calls it
/// before the account exists, the address after). A Dio error becomes a Failure.
class CameroonCitiesSource {
  const CameroonCitiesSource(this._dio);
  final Dio _dio;

  Future<List<CameroonCity>> fetch() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.cities);
      return ((response.data?['data'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CameroonCity.fromJson)
          .where((city) => city.name.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw ExceptionMapper.fromDio(e);
    }
  }
}
