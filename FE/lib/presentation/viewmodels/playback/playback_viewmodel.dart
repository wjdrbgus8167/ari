import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'playback_state.dart';

class PlaybackViewModel extends StateNotifier<PlaybackState> {
  PlaybackViewModel() : super(PlaybackState());

  void updatePlaybackState(bool isPlaying) {
    state = state.copyWith(isPlaying: isPlaying);
  }

  void updateTrackInfo({
    required String trackTitle,
    required String artist,
    required String coverImageUrl,
    required String lyrics,
  }) {
    state = state.copyWith(
      trackTitle: trackTitle,
      artist: artist,
      coverImageUrl: coverImageUrl,
      lyrics: lyrics,
    );
  }
}

// Provider 등록
final playbackViewModelProvider =
    StateNotifierProvider<PlaybackViewModel, PlaybackState>(
      (ref) => PlaybackViewModel(),
    );
