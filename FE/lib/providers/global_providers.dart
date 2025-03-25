import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';

import '../presentation/viewmodels/sign_up_viewmodel.dart';
import '../presentation/viewmodels/home_viewmodel.dart';
import '../presentation/viewmodels/listening_queue_viewmodel.dart';
import '../presentation/viewmodels/my_channel_viewmodel.dart';

import '../data/models/track.dart';
import '../data/repositories/chart_repository_impl.dart';
import '../data/datasources/chart_remote_data_source.dart';
import '../data/datasources/my_channel_remote_datasource.dart';
import '../data/datasources/my_channel_remote_datasource_impl.dart';
import '../data/repositories/my_channel_repository_impl.dart';

import '../domain/repositories/chart_repository.dart';
import '../domain/repositories/my_channel_repository.dart';
import '../domain/usecases/get_charts_usecase.dart';
import '../domain/usecases/my_channel_usecases.dart';

import '../core/services/playback_service.dart';
import '../core/constants/app_constants.dart';

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
      trackTitle: trackTitle,
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

final dioProvider = Provider<Dio>((ref) => Dio());

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
    baseUrl: baseUrl,
  );
});

final getChartsUseCaseProvider = Provider<GetChartsUseCase>((ref) {
  return GetChartsUseCase(ref.watch(chartRepositoryProvider));
});

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  return HomeViewModel(getChartsUseCase: ref.watch(getChartsUseCaseProvider));
});

// ListeningQueueViewModel(재생목록) 전역 상태
final listeningQueueProvider =
    StateNotifierProvider<ListeningQueueViewModel, ListeningQueueState>(
      (ref) => ListeningQueueViewModel(),
    );

final signUpViewModelProvider =
    StateNotifierProvider<SignUpViewModel, SignUpState>(
      (ref) => SignUpViewModel(),
    );

// ========== 나의 채널 관련 Provider 추가 ==========

/// 인증 토큰 제공자
/// 로그인 상태에 따라 실제 토큰 반환
final authTokenProvider = Provider<String>((ref) {
  // 실제 구현에서는 토큰 저장소에서 가져옵니다
  // 예: SharedPreferences, Secure Storage 등
  return 'dummy-token';
});

/// 나의 채널 원격 데이터 소스 제공자
final myChannelRemoteDataSourceProvider = Provider<MyChannelRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  final token = ref.watch(authTokenProvider);

  return MyChannelRemoteDataSourceImpl(dio: dio, token: token);
});

/// 나의 채널 리포지토리 제공자
final myChannelRepositoryProvider = Provider<MyChannelRepository>((ref) {
  final remoteDataSource = ref.watch(myChannelRemoteDataSourceProvider);

  return MyChannelRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// UseCase 제공자들
final getChannelInfoUseCaseProvider = Provider<GetChannelInfoUseCase>((ref) {
  return GetChannelInfoUseCase(ref.watch(myChannelRepositoryProvider));
});

final followMemberUseCaseProvider = Provider<FollowMemberUseCase>((ref) {
  return FollowMemberUseCase(ref.watch(myChannelRepositoryProvider));
});

final unfollowMemberUseCaseProvider = Provider<UnfollowMemberUseCase>((ref) {
  return UnfollowMemberUseCase(ref.watch(myChannelRepositoryProvider));
});

final getArtistAlbumsUseCaseProvider = Provider<GetArtistAlbumsUseCase>((ref) {
  return GetArtistAlbumsUseCase(ref.watch(myChannelRepositoryProvider));
});

final getArtistNoticesUseCaseProvider = Provider<GetArtistNoticesUseCase>((
  ref,
) {
  return GetArtistNoticesUseCase(ref.watch(myChannelRepositoryProvider));
});

final getFanTalksUseCaseProvider = Provider<GetFanTalksUseCase>((ref) {
  return GetFanTalksUseCase(ref.watch(myChannelRepositoryProvider));
});

final getPublicPlaylistsUseCaseProvider = Provider<GetPublicPlaylistsUseCase>((
  ref,
) {
  return GetPublicPlaylistsUseCase(ref.watch(myChannelRepositoryProvider));
});

final getFollowersUseCaseProvider = Provider<GetFollowersUseCase>((ref) {
  return GetFollowersUseCase(ref.watch(myChannelRepositoryProvider));
});

final getFollowingsUseCaseProvider = Provider<GetFollowingsUseCase>((ref) {
  return GetFollowingsUseCase(ref.watch(myChannelRepositoryProvider));
});

/// 나의 채널 뷰모델 제공자
final myChannelProvider =
    StateNotifierProvider<MyChannelNotifier, MyChannelState>((ref) {
      return MyChannelNotifier(
        getChannelInfoUseCase: ref.watch(getChannelInfoUseCaseProvider),
        followMemberUseCase: ref.watch(followMemberUseCaseProvider),
        unfollowMemberUseCase: ref.watch(unfollowMemberUseCaseProvider),
        getArtistAlbumsUseCase: ref.watch(getArtistAlbumsUseCaseProvider),
        getArtistNoticesUseCase: ref.watch(getArtistNoticesUseCaseProvider),
        getFanTalksUseCase: ref.watch(getFanTalksUseCaseProvider),
        getPublicPlaylistsUseCase: ref.watch(getPublicPlaylistsUseCaseProvider),
        getFollowersUseCase: ref.watch(getFollowersUseCaseProvider),
        getFollowingsUseCase: ref.watch(getFollowingsUseCaseProvider),
      );
    });
