import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/exceptions/failure.dart';
import '../../data/models/upload_album_request.dart';
import '../repositories/album_upload_repository.dart';

class UploadAlbumUseCase {
  final AlbumUploadRepository repository;

  UploadAlbumUseCase({required this.repository});

  Future<Either<Failure, String>> call({
    required UploadAlbumRequest albumRequest,
    required File coverImageFile,
    required Map<String, File> trackFiles,
    Function(double progress)? onProgress, // 콜백 파라미터
  }) async {
    return await repository.uploadAlbum(
      albumRequest: albumRequest,
      coverImageFile: coverImageFile,
      trackFiles: trackFiles,
      onProgress: onProgress, // 콜백 전달
    );
  }
}


// 공부를 위한 주석
// 1. 앨범 업로드라는 특정 비즈니스 로직(유스케이스)을 담당하는 클래스로
// Repository를 통해 데이터를 가져오거나 저장
// - 앱의 비즈니스 로직과 데이터 계층 분리
// 2. call 메서드 -> 유스케이스 객체를 함수처럼 호출 가능
// 3. 역할: 비즈니스 로직이 복잡해질 경우 여기에 로직 추가
// - presentation, data, domain 계층 간의 의존성을 낮추기 위해 사용
// (presentation 계층에서 직접 데이터를 가져오거나 저장하지 않도록 함)
// 4. repository.uploadAlbum 메서드를 호출하여 앨범 업로드 요청을 수행
// - 앨범 업로드 요청에 필요한 데이터를 인자로 전달