import 'package:ari/data/datasources/music_drawer/subscribed_artists_remote_datasource.dart';
import 'package:ari/data/models/music_drawer/subscribed_artist_model.dart';
import 'package:ari/data/models/subscription/artist_subscription_models.dart';
import 'package:ari/domain/repositories/music_drawer/subscribed_artists_repository.dart';
import 'package:ari/core/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

class SubscribedArtistsRepositoryImpl implements SubscribedArtistsRepository {
  final SubscribedArtistsRemoteDataSource _dataSource;

  SubscribedArtistsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ArtistsResponse>> getSubscribedArtists() async {
    try {
      final response = await _dataSource.getSubscribedArtists();
      return Right(response);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }  
  }
}
