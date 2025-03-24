import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/album_remote_datasource.dart';
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

      // 응답 데이터 구조 확인
      if (response.data == null) {
        return Left(Failure(message: "Response data is null"));
      }
      // 안전한 타입 체크 및 변환
      if (response.data is Map<String, dynamic>) {
        final dataMap = response.data as Map<String, dynamic>;
        return Right(AlbumDetailModel.fromJson(dataMap));
      } else {
        return Left(Failure(message: "Response data is not a map: ${response.data.runtimeType}"));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}