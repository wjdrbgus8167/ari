import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/music_drawer/likey_albums_model.dart';
import 'package:ari/data/models/music_drawer/likey_tracks_model.dart';
import 'package:dartz/dartz.dart';

abstract class LikeyRepository {
  /// 구독 중인 아티스트 목록 조회
  Future<Either<Failure, LikeyAlbumsResponse>> getLikeyAlbums();
  Future<Either<Failure, LikeyTracksResponse>> getLikeyTracks();
}