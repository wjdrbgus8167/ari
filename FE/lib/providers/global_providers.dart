import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final String? currentSongId;
  final bool isPlaying;

  PlaybackState({this.currentSongId, this.isPlaying = false});

  PlaybackState copyWith({String? currentSongId, bool? isPlaying}) {
    return PlaybackState(
      currentSongId: currentSongId ?? this.currentSongId,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  PlaybackNotifier() : super(PlaybackState());

  void play(String songId) {
    state = state.copyWith(currentSongId: songId, isPlaying: true);
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
