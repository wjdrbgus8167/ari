import 'package:ari/domain/repositories/album/album_like_repository.dart';
import 'package:ari/data/datasources/album/album_like_remote_datasource.dart';

class AlbumLikeRepositoryImpl implements AlbumLikeRepository {
  final AlbumLikeRemoteDataSource remoteDataSource;

  AlbumLikeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> toggleLike(int albumId, bool currentStatus) async {
    try {
      final response = await remoteDataSource.toggleLike(
        albumId,
        currentStatus,
      );
      print('[DEBUG] Remote response: ${response.statusCode} ${response.data}');

      // response가 null이 아니고, statusCode가 200인 경우에만 true 반환
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (error) {
      // 이 경우 예외를 던지므로, 호출하는 쪽에서 catch해야 합니다.
      throw Exception("좋아요 토글 실패: $error");
    }
  }
}
