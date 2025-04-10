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

/// 구독 중인 아티스트 수 조회 유스케이스 프로바이더
final getSubscribedArtistsCountUseCaseProvider =
    Provider<GetSubscribedArtistsCountUseCase>((ref) {
      final repository = ref.watch(subscribedArtistsRepositoryProvider);
      return GetSubscribedArtistsCountUseCase(repository);
    });

/// 구독 중인 아티스트 뷰모델 프로바이더
final subscribedArtistsViewModelProvider = StateNotifierProvider<
  SubscribedArtistsViewModel,
  SubscribedArtistsState
>((ref) {
  final getArtistsUseCase = ref.watch(getSubscribedArtistsUseCaseProvider);
  final getArtistsCountUseCase = ref.watch(
    getSubscribedArtistsCountUseCaseProvider,
  );
  return SubscribedArtistsViewModel(getArtistsUseCase, getArtistsCountUseCase);
});

/// 구독 중인 아티스트 수 프로바이더
final subscribedArtistsCountProvider = FutureProvider<int>((ref) async {
  final viewModel = ref.watch(subscribedArtistsViewModelProvider.notifier);
  return await viewModel.getSubscribedArtistsCount();
});
