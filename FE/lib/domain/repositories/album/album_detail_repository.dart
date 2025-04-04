// domain/repositories/album_repository.dart

import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:dartz/dartz.dart';

abstract class AlbumRepository {
  /// 앨범 상세 정보를 가져오는 메서드
  Future<Either<Failure, Album>> getAlbumDetail(int albumId);
}