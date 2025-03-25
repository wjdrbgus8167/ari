// lib/presentation/viewmodels/playback/playback_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'playback_state.dart';

class PlaybackViewModel extends StateNotifier<PlaybackState> {
  PlaybackViewModel()
    : super(
        PlaybackState(trackTitle: "노래 제목", artist: "가수 이름", isPlaying: false),
      );

  void updatePlaybackState(bool isPlaying) {
    state = state.copyWith(isPlaying: isPlaying);
  }

  void updateTrack(String title, String artist) {
    state = state.copyWith(trackTitle: title, artist: artist);
  }
}

// Provider 등록
final playbackViewModelProvider =
    StateNotifierProvider<PlaybackViewModel, PlaybackState>(
      (ref) => PlaybackViewModel(),
    );
