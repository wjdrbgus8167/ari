// domain/repositories/album_repository.dart

import 'package:ari/domain/entities/album.dart';

abstract class AlbumRepository {
  /// 앨범 상세 정보를 가져오는 메서드
  Future<AlbumDetail> getAlbumDetail(int albumId);
}