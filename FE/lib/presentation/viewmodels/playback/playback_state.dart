class PlaybackState {
  final bool isPlaying;
  final String trackTitle;
  final String artist;
  final String coverImageUrl;
  final String lyrics;

  PlaybackState({
    this.isPlaying = false,
    this.trackTitle = '',
    this.artist = '',
    this.coverImageUrl = '',
    this.lyrics = '',
  });

  PlaybackState copyWith({
    bool? isPlaying,
    String? trackTitle,
    String? artist,
    String? coverImageUrl,
    String? lyrics,
  }) {
    return PlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      trackTitle: trackTitle ?? this.trackTitle,
      artist: artist ?? this.artist,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      lyrics: lyrics ?? this.lyrics,
    );
  }
}
