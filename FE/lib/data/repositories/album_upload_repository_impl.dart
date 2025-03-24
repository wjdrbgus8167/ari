import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/exceptions/failure.dart';
import '../../domain/repositories/album_upload_repository.dart';
import '../datasources/album_upload_remote_datasource.dart';
import '../models/upload_album_request.dart';

class AlbumUploadRepositoryImpl implements AlbumUploadRepository {
  final AlbumUploadRemoteDataSource dataSource;

  AlbumUploadRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, String>> uploadAlbum({
    required UploadAlbumRequest albumRequest,
    required File coverImageFile,
    required Map<String, File> trackFiles,
  }) async {
    try {
      final result = await dataSource.uploadAlbum(
        albumRequest: albumRequest,
        coverImageFile: coverImageFile,
        trackFiles: trackFiles,
      );
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}

/// 공부하면서 하느라.. 주석을 조금 적어놓을게요ㅠ
// 1. AlbumUploadRepositoryImpl 클래스는 AlbumUploadRepository를 구현하는 클래스
// - 데이터 소스 계층과 도메인 계층(AlbumUploadRepository) 사이의 중간자 역할
// 2. 기능
// - dartz의 Either 사용해서 성공, 실패 분리
// - 데이터 소스의 예외를 잡아서 도메인 계층이 이해할 수 있는 형태로 변환
// - 앨범 업로드 요청을 데이터 소스로 위임
// 3. 오류 처리
// - Failure 타입 예외는 그대로 left로 반환, 기타는 Failure로 감싸서 left로 반환
// - 성공 시 결과 메시지를 right로 반환