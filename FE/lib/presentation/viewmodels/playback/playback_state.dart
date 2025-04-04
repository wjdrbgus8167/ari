import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class PlaybackState {
  final int? currentTrackId;
  final String? currentQueueItemId;
  final int? albumId;
  final String trackUrl;
  final String trackTitle;
  final String artist;
  final String coverImageUrl;
  final String lyrics;
  final bool isPlaying;
  final bool isLiked;

  PlaybackState({
    this.currentTrackId,
    this.currentQueueItemId,
    this.albumId,
    this.trackUrl = '',
    this.trackTitle = '',
    this.artist = '',
    this.coverImageUrl = '',
    this.lyrics = '',
    this.isPlaying = false,
    this.isLiked = false,
  });

  PlaybackState copyWith({
    int? currentTrackId,
    String? currentQueueItemId,
    int? albumId,
    String? trackUrl,
    String? trackTitle,
    String? artist,
    String? coverImageUrl,
    String? lyrics,
    bool? isPlaying,
    bool? isLiked,
  }) {
    return PlaybackState(
      currentTrackId: currentTrackId ?? this.currentTrackId,
      currentQueueItemId: currentQueueItemId ?? this.currentQueueItemId,
      albumId: albumId ?? this.albumId,
      trackUrl: trackUrl ?? this.trackUrl,
      trackTitle: trackTitle ?? this.trackTitle,
      artist: artist ?? this.artist,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      lyrics: lyrics ?? this.lyrics,
      isPlaying: isPlaying ?? this.isPlaying,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  PlaybackNotifier() : super(PlaybackState());

  void updatePlaybackState(bool isPlaying) {
    state = state.copyWith(isPlaying: isPlaying);
  }

  void updateLikeStatus(bool isLiked) {
    state = state.copyWith(isLiked: isLiked);
  }

  void updateTrackInfo({
    required String trackTitle,
    required String artist,
    required String coverImageUrl,
    required String lyrics,
    required int currentTrackId,
    required int albumId,
    required String trackUrl,
    required bool isLiked,
    required String currentQueueItemId,
  }) {
    state = state.copyWith(
      trackTitle: trackTitle,
      artist: artist,
      coverImageUrl: coverImageUrl,
      lyrics: lyrics,
      currentTrackId: currentTrackId,
      albumId: albumId,
      trackUrl: trackUrl,
      isLiked: isLiked,
      currentQueueItemId: currentQueueItemId,
    );
    print('[DEBUG] PlaybackState 업데이트 완료: ${state.toString()}');
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
