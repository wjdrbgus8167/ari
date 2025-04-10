import 'package:ari/data/models/music_drawer/subscribed_artist_model.dart';

abstract class SubscribedArtistsRepository {
  /// 구독 중인 아티스트 목록 조회
  Future<List<SubscribedArtistModel>> getSubscribedArtists();

  /// 구독 중인 아티스트 수 조회
  Future<int> getSubscribedArtistsCount();
}
