import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaybackState {
  final String trackTitle;
  final String artist;
  final bool isPlaying;

  PlaybackState({
    required this.trackTitle,
    required this.artist,
    required this.isPlaying,
  });

  PlaybackState copyWith({
    String? currentTrackId,
    String? trackTitle,
    bool? isPlaying,
  }) {
    return PlaybackState(
      trackTitle: trackTitle ?? this.trackTitle,
      artist: artist ?? this.artist,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class PlaybackViewModel extends StateNotifier<PlaybackState> {
  PlaybackViewModel()
    : super(
        PlaybackState(trackTitle: "노래 제목", artist: "가수 이름", isPlaying: false),
      );

  void updatePlaybackState(bool isPlaying) {
    state = state.copyWith(isPlaying: isPlaying);
  }
}
