abstract class AlbumLikeRepository {
  /// 앨범의 좋아요 상태를 토글하는 함수 (true면 해제, false면 활성화)
  Future<bool> toggleLike(int albumId, bool currentStatus);
}
