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
    String? trackTitle,
    String? artist,
    bool? isPlaying,
  }) {
    return PlaybackState(
      trackTitle: trackTitle ?? this.trackTitle,
      artist: artist ?? this.artist,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}
