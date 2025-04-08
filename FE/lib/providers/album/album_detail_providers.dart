import 'package:ari/data/datasources/album/album_rating_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/datasources/album/album_remote_datasource.dart';
import 'package:ari/data/repositories/album/album_repository.dart';
import 'package:ari/domain/repositories/album/album_detail_repository.dart';
import 'package:ari/domain/repositories/album/album_rating_repository.dart';
import 'package:ari/domain/usecases/album_detail_usecase.dart';
import 'package:ari/presentation/viewmodels/album/album_detail_viewmodel.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/data/repositories/album/album_rating_repository_impl.dart';

/// 📦 DataSource
final albumDataSourceProvider = Provider<AlbumDataSource>((ref) {
  return AlbumDataSourceImpl(dio: ref.read(dioProvider));
});

/// 📦 Repository
final albumRepositoryProvider = Provider<AlbumRepository>((ref) {
  final dataSource = ref.read(albumDataSourceProvider);
  return AlbumRepositoryImpl(dataSource: dataSource);
});

// 평점용 DataSource
final albumRatingDataSourceProvider = Provider<AlbumRatingDataSource>((ref) {
  return AlbumRatingDataSourceImpl(dio: ref.read(dioProvider));
});

// 평점용 Repository
final albumRatingRepositoryProvider = Provider<AlbumRatingRepository>((ref) {
  final dataSource = ref.read(albumRatingDataSourceProvider);
  return AlbumRatingRepositoryImpl(dataSource: dataSource);
});

/// 💡 UseCase: 앨범 상세 조회
final getAlbumDetailProvider = Provider<GetAlbumDetail>((ref) {
  final repository = ref.read(albumRepositoryProvider);
  return GetAlbumDetail(repository);
});

// 평점 UseCase
final rateAlbumUseCaseProvider = Provider<RateAlbum>((ref) {
  final repository = ref.read(albumRatingRepositoryProvider);
  return RateAlbum(repository);
});

/// 📌 ViewModel
final albumDetailViewModelProvider =
    StateNotifierProvider.family<AlbumDetailViewModel, AlbumDetailState, int>((
      ref,
      albumId,
    ) {
      final getAlbumDetail = ref.read(getAlbumDetailProvider);
      final rateAlbum = ref.read(rateAlbumUseCaseProvider);

      return AlbumDetailViewModel(
        getAlbumDetail: getAlbumDetail,
        rateAlbumUseCase: rateAlbum,
      )..loadAlbumDetail(albumId); // 초기 로딩
    });
