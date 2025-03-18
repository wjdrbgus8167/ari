import 'package:ari/presentation/viewmodels/album_detail_viewmodel.dart';
import 'package:ari/presentation/viewmodels/sign_up_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/track.dart';
import '../presentation/viewmodels/home_viewmodel.dart';

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

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>(
  (ref) {
    return PlaybackNotifier();
  },
);

final playlistProvider = StateProvider<List<Track>>((ref) => []);

/// ✅ **Provider 설정 (Riverpod)**
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>(
  (ref) => HomeViewModel(),
);

final signUpViewModelProvider = StateNotifierProvider<SignUpViewModel, SignUpState>(
  (ref) => SignUpViewModel(),
);

final albumDetailViewModelProvider = StateNotifierProvider<AlbumDetailViewModel, AlbumDetailState>(
  (ref) => AlbumDetailViewModel(),
);