import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/music_drawer/likey_albums_model.dart';
import 'package:ari/data/models/music_drawer/likey_tracks_model.dart';
import 'package:ari/domain/repositories/music_drawer/likey_repository.dart';
import 'package:dartz/dartz.dart';

class GetLikeyAlbumsUseCase {
  final LikeyRepository _repository;

  GetLikeyAlbumsUseCase(this._repository);

  Future<Either<Failure, LikeyAlbumsResponse>> call() {
    return _repository.getLikeyAlbums();
  }
}

class GetLikeyTracksUseCase {
  final LikeyRepository _repository;

  GetLikeyTracksUseCase(this._repository);

  Future<Either<Failure, LikeyTracksResponse>> call() {
    return _repository.getLikeyTracks();
  }
}