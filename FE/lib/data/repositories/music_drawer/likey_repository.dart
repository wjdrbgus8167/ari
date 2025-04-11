import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/music_drawer/likey_remote_datasources.dart';
import 'package:ari/data/models/music_drawer/likey_albums_model.dart';
import 'package:ari/data/models/music_drawer/likey_tracks_model.dart';
import 'package:ari/domain/repositories/music_drawer/likey_repository.dart';
import 'package:dartz/dartz.dart';

class LikeyRepositoryImpl implements LikeyRepository {
  final LikeyRemoteDataSource _dataSource;

  LikeyRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, LikeyAlbumsResponse>> getLikeyAlbums() async {
    try {
      final response = await _dataSource.getLikeyAlbums();
      return Right(response);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }  
  }

  @override
  Future<Either<Failure, LikeyTracksResponse>> getLikeyTracks() async {
    try {
      final response = await _dataSource.getLikeyTracks();
      return Right(response);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }  
  }
}
