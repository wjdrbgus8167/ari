// 데이터 소스 Provider
import 'package:ari/data/datasources/album_remote_datasource.dart';
import 'package:ari/data/repositories/album_repository.dart';
import 'package:ari/domain/usecases/album_detail_usecase.dart';
import 'package:ari/presentation/viewmodels/album_detail_viewmodel.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final albumDataSourceProvider = Provider((ref) {
  return AlbumMockDataSourceImpl(
    dio: ref.watch(dioProvider), 
    baseUrl: const String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://ari-music.duckdns.org',
    ),
  );
});

// 리포지토리 Provider
final albumRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(albumDataSourceProvider);
  return AlbumRepositoryImpl(dataSource: dataSource);
});

// UseCase Provider
final getAlbumDetailProvider = Provider((ref) {
  final repository = ref.watch(albumRepositoryProvider);
  return GetAlbumDetail(repository);
});

// ViewModel Provider
final albumDetailViewModelProvider = StateNotifierProvider<AlbumDetailViewModel, AlbumDetailState>((ref) {
  final getAlbumDetail = ref.watch(getAlbumDetailProvider);
  return AlbumDetailViewModel(getAlbumDetail: getAlbumDetail);
});