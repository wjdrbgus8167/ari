import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class PlaybackState {
  final int? currentTrackId;
  final String trackUrl;
  final String trackTitle;
  final String artist;
  final String coverImageUrl;
  final String lyrics;
  final bool isPlaying;

  PlaybackState({
    this.currentTrackId,
    this.trackUrl = '',
    this.trackTitle = '',
    this.artist = '',
    this.coverImageUrl = '',
    this.lyrics = '',
    this.isPlaying = false,
  });

  PlaybackState copyWith({
    int? currentTrackId,
    String? trackUrl,
    String? trackTitle,
    String? artist,
    String? coverImageUrl,
    String? lyrics,
    bool? isPlaying,
  }) {
    return PlaybackState(
      currentTrackId: currentTrackId ?? this.currentTrackId,
      trackUrl: trackUrl ?? this.trackUrl,
      trackTitle: trackTitle ?? this.trackTitle,
      artist: artist ?? this.artist,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      lyrics: lyrics ?? this.lyrics,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  PlaybackNotifier() : super(PlaybackState());

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

final coverImageProvider = Provider<ImageProvider<Object>>((ref) {
  final playbackState = ref.watch(playbackProvider);
  if (playbackState.coverImageUrl.isNotEmpty) {
    return NetworkImage(playbackState.coverImageUrl);
  } else {
    return const AssetImage('assets/images/default_album_cover.png');
  }
});
