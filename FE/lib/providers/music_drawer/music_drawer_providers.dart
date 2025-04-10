import 'package:ari/data/datasources/music_drawer/likey_remote_datasources.dart';
import 'package:ari/data/repositories/music_drawer/likey_repository.dart';
import 'package:ari/domain/repositories/music_drawer/likey_repository.dart';
import 'package:ari/domain/usecases/music_drawer/likey_usecases.dart';
import 'package:ari/presentation/viewmodels/music_drawer/likey_album_viewmodel.dart';
import 'package:ari/presentation/viewmodels/music_drawer/likey_track_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/datasources/music_drawer/subscribed_artists_remote_datasource.dart';
import 'package:ari/data/repositories/music_drawer/subscribed_artists_repository_impl.dart';
import 'package:ari/domain/repositories/music_drawer/subscribed_artists_repository.dart';
import 'package:ari/domain/usecases/music_drawer/subscribed_artists_usecases.dart';
import 'package:ari/presentation/viewmodels/music_drawer/subscribed_artists_viewmodel.dart';
import 'package:ari/providers/global_providers.dart';

/// 구독 중인 아티스트 데이터소스 프로바이더
final subscribedArtistsDataSourceProvider =
    Provider<SubscribedArtistsRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return SubscribedArtistsRemoteDataSourceImpl(apiClient);
    });

/// 구독 중인 아티스트 레포지토리 프로바이더
final subscribedArtistsRepositoryProvider =
    Provider<SubscribedArtistsRepository>((ref) {
      final dataSource = ref.watch(subscribedArtistsDataSourceProvider);
      return SubscribedArtistsRepositoryImpl(dataSource);
    });

/// 구독 중인 아티스트 목록 조회 유스케이스 프로바이더
final getSubscribedArtistsUseCaseProvider =
    Provider<GetSubscribedArtistsUseCase>((ref) {
      final repository = ref.watch(subscribedArtistsRepositoryProvider);
      return GetSubscribedArtistsUseCase(repository);
    });

/// 구독 중인 아티스트 뷰모델 프로바이더
final subscribedArtistsViewModelProvider = StateNotifierProvider<
  SubscribedArtistsViewModel,
  SubscribedArtistsState
>((ref) {
  final getArtistsUseCase = ref.watch(getSubscribedArtistsUseCaseProvider);
  return SubscribedArtistsViewModel(getArtistsUseCase);
});

/// 구독 중인 아티스트 수 프로바이더
final subscribedArtistsCountProvider = FutureProvider<int>((ref) async {
  final viewModel = ref.watch(subscribedArtistsViewModelProvider.notifier);
  return await viewModel.getSubscribedArtistsCount();
});

/// 구독 중인 아티스트 데이터소스 프로바이더
final likeyDataSourceProvider =
    Provider<LikeyRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return LikeyRemoteDataSourceImpl(apiClient);
    });

/// 구독 중인 아티스트 레포지토리 프로바이더
final likeyRepositoryProvider =
    Provider<LikeyRepository>((ref) {
      final dataSource = ref.watch(likeyDataSourceProvider);
      return LikeyRepositoryImpl(dataSource);
    });

/// 좋아요 누른 앨범 프로바이더
final getLikeyAlbumsUseCaseProvider =
    Provider<GetLikeyAlbumsUseCase>((ref) {
      final repository = ref.watch(likeyRepositoryProvider);
      return GetLikeyAlbumsUseCase(repository);
    });

/// 좋아요 누른 트랙 프로바이더
final getLikeyTracksUseCaseProvider =
    Provider<GetLikeyTracksUseCase>((ref) {
      final repository = ref.watch(likeyRepositoryProvider);
      return GetLikeyTracksUseCase(repository);
    });

final likeyAlbumsViewModelProvider = StateNotifierProvider<
  LikeyAlbumViewmodel,
  LikeyAlbumsState
>((ref) {
  final getAlbumsUseCase = ref.watch(getLikeyAlbumsUseCaseProvider);
  return LikeyAlbumViewmodel(getAlbumsUseCase);
});

final likeyTracksViewModelProvider = StateNotifierProvider<
  LikeyTrackViewmodel,
  LikeyTracksState
>((ref) {
  final getTracksUseCase = ref.watch(getLikeyTracksUseCaseProvider);
  return LikeyTrackViewmodel(getTracksUseCase);
});