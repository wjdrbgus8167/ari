// lib/data/datasources/comment_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:ari/data/models/comment.dart';
import 'package:ari/providers/global_providers.dart';

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
    final data = response.data['data'];
    return Comment.fromJson(data);
  }
}
