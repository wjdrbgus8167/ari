import 'package:dio/dio.dart';

/// 앨범 좋아요 토글을 위한 Remote DataSource 추상 클래스
abstract class AlbumLikeRemoteDataSource {
  Future<Response> toggleLike(int albumId, bool currentStatus);
}

/// 실제 구현체: Dio를 이용하여 API 요청
class AlbumLikeRemoteDataSourceImpl implements AlbumLikeRemoteDataSource {
  final Dio dio;

  AlbumLikeRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> toggleLike(int albumId, bool currentStatus) async {
    final payload = {'activateYn': !currentStatus};
    return await dio.post('/api/v1/albums/$albumId/likes', data: payload);
  }
}
