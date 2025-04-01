import 'package:ari/core/utils/auth_interceptor.dart';
import 'package:ari/data/datasources/playlist/playlist_remote_datasource.dart';
import 'package:ari/data/datasources/playlist/playlist_remote_datasource_impl.dart';
import 'package:ari/data/repositories/playlist_repository_impl.dart';
import 'package:ari/domain/repositories/playlist_repository.dart';
import 'package:ari/presentation/viewmodels/playlist/playlist_state.dart';
import 'package:ari/presentation/viewmodels/playlist/playlist_viewmodel.dart';

import 'package:ari/providers/auth/auth_providers.dart';
import 'package:ari/providers/user_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:ari/presentation/viewmodels/home_viewmodel.dart';
import 'package:ari/presentation/viewmodels/listening_queue_viewmodel.dart';

import 'package:ari/data/models/track.dart';
import 'package:ari/data/repositories/chart_repository_impl.dart';
import 'package:ari/data/datasources/chart_remote_data_source.dart';

import 'package:ari/domain/repositories/chart_repository.dart';
import 'package:ari/domain/usecases/get_charts_usecase.dart';

import 'package:ari/core/services/playback_service.dart';
import 'package:ari/core/constants/app_constants.dart';

// final dioProvider = Provider<Dio>((ref) => Dio());

// Bottom Navigation 전역 상태
class BottomNavState extends StateNotifier<int> {
  BottomNavState() : super(0);
  void setIndex(int index) {
    state = index;
  }
}

final bottomNavProvider = StateNotifierProvider<BottomNavState, int>((ref) {
  return BottomNavState();
});

// 재생 상태 전역 관리
class PlaybackState {
  final String? currentTrackId;
  final String trackTitle;
  final bool isPlaying;

  PlaybackState({
    this.currentTrackId,
    required this.trackTitle,
    this.isPlaying = false,
  });

  PlaybackState copyWith({String? currentTrackId, bool? isPlaying}) {
    return PlaybackState(
      currentTrackId: currentTrackId ?? this.currentTrackId,
      trackTitle: this.trackTitle,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  PlaybackNotifier() : super(PlaybackState(trackTitle: ''));

  void play(String songId) {
    state = state.copyWith(currentTrackId: songId, isPlaying: true);
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  void togglePlayback() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }
}

final playlistProvider = StateProvider<List<Track>>((ref) => []);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));

  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('DIO LOG: $obj'),
    ),
  );

  final refreshTokensUseCase = ref.read(refreshTokensUseCaseProvider);
  final getAuthStatusUseCase = ref.read(getAuthStatusUseCaseProvider);
  final getTokensUseCase = ref.read(getTokensUseCaseProvider);

  // Add auth interceptor with the required dependencies
  dio.interceptors.add(
    AuthInterceptor(
      refreshTokensUseCase: refreshTokensUseCase,
      getAuthStatusUseCase: getAuthStatusUseCase,
      getTokensUseCase: getTokensUseCase,
      dio: dio,
    ),
  );

  return dio;
});

// AudioPlayer 인스턴스를 전역에서 제공하는 Provider 추가
final audioPlayerProvider = Provider<AudioPlayer>((ref) => AudioPlayer());

final playbackServiceProvider = Provider<PlaybackService>((ref) {
  return PlaybackService(
    dio: ref.watch(dioProvider),
    audioPlayer: ref.watch(audioPlayerProvider),
  );
});
final chartRemoteDataSourceProvider = Provider<ChartRemoteDataSource>((ref) {
  return ChartRemoteDataSource(dio: ref.watch(dioProvider));
});

final chartRepositoryProvider = Provider<IChartRepository>((ref) {
  return ChartRepositoryImpl(
    remoteDataSource: ref.watch(chartRemoteDataSourceProvider),
    baseUrl: const String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://ari-music.duckdns.org',
    ),
  );
});

final getChartsUseCaseProvider = Provider<GetChartsUseCase>((ref) {
  return GetChartsUseCase(ref.watch(chartRepositoryProvider));
});

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  return HomeViewModel(
    getChartsUseCase: ref.watch(getChartsUseCaseProvider),
    playlistRemoteDataSource: ref.watch(playlistRemoteDataSourceProvider),
  );
});

final playlistRemoteDataSourceProvider = Provider<IPlaylistRemoteDataSource>((
  ref,
) {
  return PlaylistRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final playlistRepositoryProvider = Provider<IPlaylistRepository>((ref) {
  return PlaylistRepositoryImpl(
    remoteDataSource: ref.watch(playlistRemoteDataSourceProvider),
  );
});

final playlistViewModelProvider =
    StateNotifierProvider<PlaylistViewModel, PlaylistState>((ref) {
      return PlaylistViewModel(
        playlistRepository: ref.watch(playlistRepositoryProvider),
      );
    });

// ListeningQueueViewModel(재생목록) 전역 상태
final listeningQueueProvider =
    StateNotifierProvider<ListeningQueueViewModel, ListeningQueueState>((ref) {
      final userId = ref.watch(authUserIdProvider);
      final playlistRepository = ref.watch(playlistRepositoryProvider);
      return ListeningQueueViewModel(
        userId: userId,
        playlistRepository: playlistRepository,
      );
    });
