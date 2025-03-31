import 'package:dio/dio.dart';
import 'package:ari/core/constants/app_constants.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:ari/core/utils/jwt_utils.dart';

class PlaybackRemoteDatasource {
  final Dio dio;

  PlaybackRemoteDatasource({required this.dio});

  /// 앨범의 특정 트랙 정보를 가져옵니다.
  /// JWT 토큰이 만료되었으면 예외를 던지고, 그렇지 않으면 Authorization 헤더에 토큰을 추가하여 API를 호출합니다.
  Future<ApiResponse<Map<String, dynamic>>> fetchTrackInfo({
    required int albumId,
    required int trackId,
    required String jwt,
  }) async {
    // 토큰 만료 여부 검증 (만료되었다면 예외 발생)
    if (JwtUtils.isTokenExpired(jwt)) {
      throw Exception('JWT token is expired');
    }

    final url = '$baseUrl/api/v1/albums/$albumId/tracks/$trackId';
    final response = await dio.post(
      url,
      options: Options(headers: {'Authorization': 'Bearer $jwt'}),
    );

    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }
}
