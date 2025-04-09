import 'package:ari/domain/repositories/music_drawer/subscribed_artists_repository.dart';
import 'package:ari/data/models/music_drawer/subscribed_artist_model.dart';

/// 구독 중인 아티스트 목록 조회 유스케이스
class GetSubscribedArtistsUseCase {
  final SubscribedArtistsRepository _repository;

  GetSubscribedArtistsUseCase(this._repository);

  Future<List<SubscribedArtistModel>> execute() {
    return _repository.getSubscribedArtists();
  }
}

/// 구독 중인 아티스트 수 조회 유스케이스
class GetSubscribedArtistsCountUseCase {
  final SubscribedArtistsRepository _repository;

  GetSubscribedArtistsCountUseCase(this._repository);

  Future<int> execute() {
    return _repository.getSubscribedArtistsCount();
  }
}