// lib/data/datasources/comment_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:ari/data/models/comment.dart';

class CommentRemoteDatasource {
  final Dio dio;

  CommentRemoteDatasource({required this.dio});

  Future<List<Comment>> fetchComments(int trackId) async {
    final response = await dio.get('/api/v1/albums/tracks/$trackId/comments');
    // 응답 구조: { status, message, data: { comments: [...], commentCount: ... }, error }
    final data = response.data['data'];
    if (data == null || data['comments'] == null) return [];
    final List<dynamic> commentsJson = data['comments'];
    return commentsJson.map((json) => Comment.fromJson(json)).toList();
  }

  Future<Comment> postComment({
    required int albumId,
    required int trackId,
    required String content,
    required String contentTimestamp,
  }) async {
    final response = await dio.post(
      '/api/v1/albums/$albumId/tracks/$trackId/comments',
      data: {"content": content, "contentTimestamp": contentTimestamp},
    );

    final data = response.data['data']; // ← null
    if (data == null) {
      // 그냥 댓글이 성공적으로 등록되었다고 보고,
      // 곧바로 GET 요청으로 목록을 갱신하면 됨.
      // 여기는 "빈" Comment를 임시로 반환하거나
      // 에러 대신 "등록 완료" 정도로 간주하는 로직을 작성
      return Comment(
        commentId: 0,
        nickname: '',
        content: '',
        createdAt: DateTime.now(),
        timestamp: null,
        profileImageUrl: null,
        memberId: 0,
      );
    }

    return Comment.fromJson(data);
  }
}
