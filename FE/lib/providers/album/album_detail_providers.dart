import 'package:ari/data/repositories/album/album_repository.dart';
import 'package:ari/domain/repositories/album/album_like_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/global_providers.dart';

// Domain UseCases
import 'package:ari/domain/usecases/album_detail_usecase.dart';
import 'package:ari/domain/usecases/album_like_usecase.dart';

// ViewModel
import 'package:ari/presentation/viewmodels/album/album_detail_viewmodel.dart';

// DataSource Imports
import 'package:ari/data/datasources/album/album_remote_datasource.dart';
import 'package:ari/data/datasources/album/album_rating_remote_datasource.dart';
import 'package:ari/data/datasources/album/album_like_remote_datasource.dart';

// Repository Imports
import 'package:ari/data/repositories/album/album_rating_repository_impl.dart';
import 'package:ari/data/repositories/album/album_like_repository_impl.dart';

/// --------------------------------------------------------------------------
/// 앨범 상세 관련 Provider
/// --------------------------------------------------------------------------

/// 1. DataSource

// 앨범 상세 조회용 DataSource
final albumDataSourceProvider = Provider<AlbumDataSource>((ref) {
  return AlbumDataSourceImpl(dio: ref.read(dioProvider));
});

// 평점용 DataSource
final albumRatingDataSourceProvider = Provider<AlbumRatingDataSource>((ref) {
  return AlbumRatingDataSourceImpl(dio: ref.read(dioProvider));
});

// 좋아요 토글용 DataSource
final albumLikeRemoteDataSourceProvider = Provider<AlbumLikeRemoteDataSource>((
  ref,
) {
  return AlbumLikeRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

/// 2. Repository

// 앨범 상세 조회용 Repository
final albumRepositoryProvider = Provider((ref) {
  final dataSource = ref.read(albumDataSourceProvider);
  return AlbumRepositoryImpl(dataSource: dataSource);
});

// 평점용 Repository
final albumRatingRepositoryProvider = Provider((ref) {
  final dataSource = ref.read(albumRatingDataSourceProvider);
  return AlbumRatingRepositoryImpl(dataSource: dataSource);
});

// 좋아요용 Repository
final albumLikeRepositoryProvider = Provider<AlbumLikeRepository>((ref) {
  final remoteDataSource = ref.read(albumLikeRemoteDataSourceProvider);
  return AlbumLikeRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// 3. UseCase

// 앨범 상세 조회 UseCase
final getAlbumDetailProvider = Provider<GetAlbumDetail>((ref) {
  final repository = ref.read(albumRepositoryProvider);
  return GetAlbumDetail(repository);
});

// 평점 제출 UseCase
final rateAlbumUseCaseProvider = Provider<RateAlbum>((ref) {
  final repository = ref.read(albumRatingRepositoryProvider);
  return RateAlbum(repository);
});

// 좋아요 토글 UseCase
final toggleAlbumLikeUseCaseProvider = Provider<ToggleAlbumLike>((ref) {
  final repository = ref.read(albumLikeRepositoryProvider);
  return ToggleAlbumLike(repository);
});

/// 4. ViewModel Provider

final albumDetailViewModelProvider =
    StateNotifierProvider.family<AlbumDetailViewModel, AlbumDetailState, int>((
      ref,
      albumId,
    ) {
      final getAlbumDetail = ref.read(getAlbumDetailProvider);
      final rateAlbum = ref.read(rateAlbumUseCaseProvider);
      final toggleAlbumLike = ref.read(toggleAlbumLikeUseCaseProvider);
      return AlbumDetailViewModel(
        getAlbumDetail: getAlbumDetail,
        rateAlbumUseCase: rateAlbum,
        toggleAlbumLikeUseCase: toggleAlbumLike,
        ref: ref,
      )..loadAlbumDetail(albumId);
    });
