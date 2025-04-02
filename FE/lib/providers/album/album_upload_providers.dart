import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/album_upload_remote_datasource.dart';
import '../../data/datasources/album_upload_remote_datasource_impl.dart';
import '../../data/repositories/album_upload_repository_impl.dart';
import '../../domain/repositories/album_upload_repository.dart';
import '../../domain/usecases/upload_album_usecase.dart';
import '../../presentation/viewmodels/mypage/album_upload_viewmodel.dart';
import '../global_providers.dart';

// DataSource Provider: datasource 계층 의존성 주입
// - Dio 인스턴스를 주입받아 원격 데이터 소스 구현
final albumUploadDataSourceProvider = Provider<AlbumUploadRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  
  return AlbumUploadRemoteDataSourceImpl(
    dio: dio,
    baseUrl: const String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://ari-music.duckdns.org',
    ),
  );
});

// Repository Provider: repository 계층 의존성 주입
// - 데이터 소스 구현체 주입받아 리포지토리 구현 
final albumUploadRepositoryProvider = Provider<AlbumUploadRepository>((ref) {
  final dataSource = ref.watch(albumUploadDataSourceProvider);
  return AlbumUploadRepositoryImpl(dataSource: dataSource);
});

// UseCase Provider: usecase 계층 의존성 주입
// - 리포지토리 구현체 주입받아 유스케이스 구현
final uploadAlbumUseCaseProvider = Provider<UploadAlbumUseCase>((ref) {
  final repository = ref.watch(albumUploadRepositoryProvider);
  return UploadAlbumUseCase(repository: repository);
});

// ViewModel Provider: presentation 계층 의존성 주입
// - 유스케이스 구현체 주입받아 뷰모델 구현
// - UI 컴포넌트가 이 provider 통해 ViewModel에 접근
final albumUploadViewModelProvider = StateNotifierProvider<AlbumUploadViewModel, AlbumUploadState>((ref) {
  final uploadAlbumUseCase = ref.watch(uploadAlbumUseCaseProvider);
  return AlbumUploadViewModel(uploadAlbumUseCase: uploadAlbumUseCase);
});