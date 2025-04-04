import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/repositories/album/album_detail_repository.dart';
import 'package:dartz/dartz.dart';

class GetAlbumDetail {
  final AlbumRepository repository;

  GetAlbumDetail(this.repository);

  /// 앨범 상세 정보를 가져오는 유스케이스
  /// [albumId]: 조회할 앨범의 ID
  Future<Either<Failure, Album>> execute(int albumId) async {
    return await repository.getAlbumDetail(albumId);
  }
}
