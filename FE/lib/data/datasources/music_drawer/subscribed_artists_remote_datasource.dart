import 'package:ari/data/datasources/api_client.dart';
import 'package:ari/data/models/music_drawer/subscribed_artist_model.dart';
import 'package:ari/data/models/subscription/artist_subscription_models.dart';

/// 나의 음악 서랍 - 구독 중인 아티스트 관련 원격 데이터소스 인터페이스
abstract class SubscribedArtistsRemoteDataSource {
  /// 구독 중인 아티스트 목록 조회
  Future<ArtistsResponse> getSubscribedArtists();
}

class SubscribedArtistsRemoteDataSourceImpl
    implements SubscribedArtistsRemoteDataSource {
  final ApiClient _apiClient;

  SubscribedArtistsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ArtistsResponse> getSubscribedArtists() async {
    return _apiClient.request<ArtistsResponse>(
      url: '/api/v1/mypages/subscriptions/artists/list',
      method: 'GET',
      fromJson: (artist) => ArtistsResponse.fromJson(artist),
    );
  }
}
