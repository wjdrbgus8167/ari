// 데이터 소스 Provider
import 'package:ari/data/datasources/album/album_remote_datasource.dart';
import 'package:ari/data/repositories/album_repository.dart';
import 'package:ari/domain/usecases/album_detail_usecase.dart';
import 'package:ari/presentation/viewmodels/album/album_detail_viewmodel.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final albumDataSourceProvider = Provider((ref) {
  return AlbumDataSourceImpl(
    dio: ref.read(dioProvider),
  );
});

// 리포지토리 Provider
final albumRepositoryProvider = Provider((ref) {
  final dataSource = ref.read(albumDataSourceProvider);
  return AlbumRepositoryImpl(dataSource: dataSource);
});

// UseCase Provider
final getAlbumDetailProvider = Provider((ref) {
  final repository = ref.read(albumRepositoryProvider);
  return GetAlbumDetail(repository);
});

// ViewModel Provider
final albumDetailViewModelProvider = StateNotifierProvider<AlbumDetailViewModel, AlbumDetailState>((ref) {
  final getAlbumDetail = ref.read(getAlbumDetailProvider);
  return AlbumDetailViewModel(getAlbumDetail: getAlbumDetail);
});