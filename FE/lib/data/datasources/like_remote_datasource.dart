import 'package:dio/dio.dart';

class LikeRemoteDatasource {
  final Dio dio;

  LikeRemoteDatasource({required this.dio});

  /// 사용자가 이 트랙에 좋아요했는지 확인하는 API
  Future<bool> fetchLikeStatus(int trackId) async {
    final response = await dio.get(
      '/api/v1/albums/tracks/$trackId/likes/status',
    );
    // 응답 예시: { "status": 200, "data": { "liked": true }, "error": null }
    final data = response.data['data'];
    return data != null && data['liked'] == true;
  }

  /// 좋아요/좋아요 취소 요청을 보내는 API
  Future<void> toggleLikeStatus({
    required int albumId,
    required int trackId,
  }) async {
    final currentStatus = await fetchLikeStatus(trackId); // 현재 좋아요 상태 확인
    await dio.post(
      '/api/v1/albums/$albumId/tracks/$trackId/likes',
      data: {"activateYn": !currentStatus},
    );
  }
}
