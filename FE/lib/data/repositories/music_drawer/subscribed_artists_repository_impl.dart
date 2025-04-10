import 'package:ari/data/datasources/music_drawer/subscribed_artists_remote_datasource.dart';
import 'package:ari/data/models/music_drawer/subscribed_artist_model.dart';
import 'package:ari/domain/repositories/music_drawer/subscribed_artists_repository.dart';
import 'package:ari/core/exceptions/failure.dart';

class SubscribedArtistsRepositoryImpl implements SubscribedArtistsRepository {
  final SubscribedArtistsRemoteDataSource _dataSource;

  SubscribedArtistsRepositoryImpl(this._dataSource);

  @override
  Future<List<SubscribedArtistModel>> getSubscribedArtists() async {
    try {
      final response = await _dataSource.getSubscribedArtists();

      if (response.status == 200) {
        // 빈 배열이어도 성공으로 처리
        return response.artists; // 빈 배열일 수 있음
      } else {
        throw Failure(message: response.message);
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '구독 중인 아티스트 목록을 불러오는데 실패했습니다');
    }
  }

  @override
  Future<int> getSubscribedArtistsCount() async {
    try {
      final response = await _dataSource.getSubscribedArtists();

      if (response.status == 200) {
        return response.artists.length;
      } else {
        throw Failure(message: response.message);
      }
    } catch (e) {
      throw Failure(message: '구독 중인 아티스트 수를 불러오는데 실패했습니다');
    }
  }
}
