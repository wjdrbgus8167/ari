import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/album/album_rating_remote_datasource.dart';
import 'package:ari/domain/repositories/album/album_rating_repository.dart';
import 'package:dartz/dartz.dart';

class AlbumRatingRepositoryImpl implements AlbumRatingRepository {
  final AlbumRatingDataSource dataSource;

  AlbumRatingRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, void>> rateAlbum(int albumId, double rating) async {
    try {
      final response = await dataSource.rateAlbum(albumId, rating);
      if (response.status == 200) {
        return const Right(null);
      } else {
        return Left(Failure(message: response.message ?? '평점 등록 실패'));
      }
    } catch (e) {
      return Left(Failure(message: '에러 발생: $e'));
    }
  }
}
