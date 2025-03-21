import 'package:ari/data/datasources/album_remote_datasource.dart';
import 'package:ari/data/datasources/track_remote_datasource.dart';
import 'package:ari/data/repositories/album_repository.dart';
import 'package:ari/data/repositories/track_repository.dart';
import 'package:ari/domain/repositories/album_repository.dart';
import 'package:ari/domain/repositories/track_repository.dart';
import 'package:ari/domain/usecases/album_detail_usecase.dart';
import 'package:ari/domain/usecases/track_detail_usecase.dart';
import 'package:ari/presentation/viewmodels/album_detail_viewmodel.dart';
import 'package:ari/presentation/viewmodels/sign_up_viewmodel.dart';
import 'package:ari/presentation/viewmodels/track_detail_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/track.dart';
import '../presentation/viewmodels/home_viewmodel.dart';
import '../presentation/viewmodels/listening_queue_viewmodel.dart';

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
  final String? currentTrackId; // ✅ 기존 currentSongId → currentTrackId로 변경
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

// HomeViewModel 전역 상태
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>(
  (ref) => HomeViewModel(),
);

// ListeningQueueViewModel(재생목록) 전역 상태
final listeningQueueProvider =
    StateNotifierProvider<ListeningQueueViewModel, ListeningQueueState>(
      (ref) => ListeningQueueViewModel(),
    );

final signUpViewModelProvider =
    StateNotifierProvider<SignUpViewModel, SignUpState>(
      (ref) => SignUpViewModel(),
    );

// 데이터 소스 Provider
final albumDataSourceProvider = Provider((ref) {
  return AlbumMockDataSourceImpl(); // 필요한 경우 파라미터 전달
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







// 데이터 소스 Provider
final trackDataSourceProvider = Provider((ref) {
  return TrackMockDataSourceImpl(); // 필요한 경우 파라미터 전달
});

// 리포지토리 Provider
final trackRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(trackDataSourceProvider);
  return TrackRepositoryImpl(dataSource: dataSource);
});

// UseCase Provider
final getTrackDetailProvider = Provider((ref) {
  final repository = ref.watch(trackRepositoryProvider);
  return GetTrackDetail(repository);
});

// ViewModel Provider
final  trackDetailViewModelProvider = StateNotifierProvider<TrackDetailViewModel, TrackDetailState>((ref) {
  final getTrackDetail = ref.watch(getTrackDetailProvider);
  return TrackDetailViewModel(getTrackDetail: getTrackDetail);
});