import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/album/album_remote_datasource.dart';
import 'package:ari/data/models/album_detail.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/repositories/album_repository.dart';
import 'package:dartz/dartz.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumDataSource dataSource;

  AlbumRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, Album>> getAlbumDetail(int albumId) async {
    try {
      final response = await dataSource.getAlbumDetail(albumId);

      if (response.data == null) {
        return Left(Failure(message: "Response data is null"));
      }
      return Right(response.data as AlbumDetailModel);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}