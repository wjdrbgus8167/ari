import 'package:ari/data/datasources/api_client.dart';
import 'package:ari/data/models/music_drawer/likey_albums_model.dart';
import 'package:ari/data/models/music_drawer/likey_tracks_model.dart';

/// 나의 음악 서랍 - 구독 중인 아티스트 관련 원격 데이터소스 인터페이스
abstract class LikeyRemoteDataSource {
  /// 구독 중인 아티스트 목록 조회
  Future<LikeyAlbumsResponse> getLikeyAlbums();
  Future<LikeyTracksResponse> getLikeyTracks();
}

class LikeyRemoteDataSourceImpl implements LikeyRemoteDataSource {
  final ApiClient _apiClient;

  LikeyRemoteDataSourceImpl(this._apiClient);

  @override
  Future<LikeyAlbumsResponse> getLikeyAlbums() async {
    return _apiClient.request<LikeyAlbumsResponse>(
      url: '/api/v1/likes/albums',
      method: 'GET',
      fromJson: (albums) => LikeyAlbumsResponse.fromJson(albums),
    );
  }

  @override
  Future<LikeyTracksResponse> getLikeyTracks() async {
    return _apiClient.request<LikeyTracksResponse>(
      url: '/api/v1/likes/tracks',
      method: 'GET',
      fromJson: (tracks) => LikeyTracksResponse.fromJson(tracks),
    );
  }
}
