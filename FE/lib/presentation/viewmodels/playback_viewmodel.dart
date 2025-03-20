import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaybackState {
  final String currentTrackId;
  final String trackTitle;
  final bool isPlaying;

  PlaybackState({
    required this.currentTrackId,
    required this.trackTitle,
    required this.isPlaying,
  });

  PlaybackState copyWith({
    String? currentTrackId,
    String? trackTitle,
    bool? isPlaying,
  }) {
    return PlaybackState(
      currentTrackId: currentTrackId ?? this.currentTrackId,
      trackTitle: trackTitle ?? this.trackTitle,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class PlaybackViewModel extends StateNotifier<PlaybackState> {
  PlaybackViewModel()
    : super(
        PlaybackState(
          currentTrackId: "노래 제목",
          trackTitle: "노래 제목",
          isPlaying: false,
        ),
      );

  void updatePlaybackState(bool isPlaying) {
    state = state.copyWith(isPlaying: isPlaying);
  }
}

final playbackProvider =
    StateNotifierProvider<PlaybackViewModel, PlaybackState>(
      (ref) => PlaybackViewModel(),
    );
