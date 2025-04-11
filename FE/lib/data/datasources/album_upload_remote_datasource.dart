import 'dart:io';
import '../models/upload_album_request.dart';

abstract class AlbumUploadRemoteDataSource {
  /// [albumRequest] 메타데이터
  /// [coverImageFile] 커버 이미지
  /// [trackFiles] 트랙 파일들
  /// 성공 실패

  Future<String> uploadAlbum({
    required UploadAlbumRequest albumRequest,
    required File coverImageFile,
    required Map<String, File> trackFiles,
    Function(double progress)? onProgress, // 진행률 콜백 추가
  });
}