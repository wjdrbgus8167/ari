// album upload repository 인터페이스
// Repository 패턴 - 데이터 소스(서버 등)에 접근하는 로직 분리

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/exceptions/failure.dart';
import '../../data/models/upload_album_request.dart';

abstract class AlbumUploadRepository {
  /// [albumRequest] 앨범 메타 데이터
  /// [coverImageFile] 커버 이미지
  /// [trackFiles] 업로드할 트랙 파일
  /// 성공 실패 반환
  Future<Either<Failure, String>> uploadAlbum({
    required UploadAlbumRequest albumRequest,
    required File coverImageFile,
    required Map<String, File> trackFiles,
    Function(double progress)? onProgress, // 콜백 파라미터
  });
}