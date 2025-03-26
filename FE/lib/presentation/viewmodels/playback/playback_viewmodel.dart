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
    required int currentTrackId,
    required String trackUrl,
  }) {
    state = state.copyWith(
      trackTitle: trackTitle,
      artist: artist,
      coverImageUrl: coverImageUrl,
      lyrics: lyrics,
      currentTrackId: currentTrackId,
      trackUrl: trackUrl,
    );
  }
}

// Provider 등록
final playbackViewModelProvider =
    StateNotifierProvider<PlaybackViewModel, PlaybackState>(
      (ref) => PlaybackViewModel(),
    );
