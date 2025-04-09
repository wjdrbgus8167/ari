import 'package:ari/data/datasources/api_client.dart';
import 'package:ari/data/models/music_drawer/subscribed_artist_model.dart';

/// 나의 음악 서랍 - 구독 중인 아티스트 관련 원격 데이터소스 인터페이스
abstract class SubscribedArtistsRemoteDataSource {
  /// 구독 중인 아티스트 목록 조회
  Future<SubscribedArtistsResponse> getSubscribedArtists();
}

class SubscribedArtistsRemoteDataSourceImpl
    implements SubscribedArtistsRemoteDataSource {
  final ApiClient _apiClient;

  SubscribedArtistsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<SubscribedArtistsResponse> getSubscribedArtists() async {
    try {
      // API 호출
      final response = await _apiClient.get(
        '/api/v1/mypages/subscriptions/artists/list',
      );

      // 응답 파싱
      // 디버깅을 위해 응답 로깅
      print('API 응답: $response');

      return SubscribedArtistsResponse.fromJson(response);
    } catch (e) {
      print('구독 아티스트 데이터 로드 에러: $e');
      // 에러 처리
      rethrow;
    }
  }
}
