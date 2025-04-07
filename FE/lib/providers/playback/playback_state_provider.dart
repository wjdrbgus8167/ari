import 'dart:async';
import 'package:ari/core/services/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaybackState {
  final int? currentTrackId;
  final String currentQueueItemId;
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
    this.albumId,
    this.trackUrl = '',
    this.trackTitle = '',
    this.artist = '',
    this.coverImageUrl = '',
    this.lyrics = '',
    this.isPlaying = false,
    this.isLiked = false,
    this.currentQueueItemId = '',
  });

  PlaybackState copyWith({
    int? currentTrackId,
    int? albumId,
    String? trackUrl,
    String? trackTitle,
    String? artist,
    String? coverImageUrl,
    String? lyrics,
    bool? isPlaying,
    bool? isLiked,
    String? currentQueueItemId,
  }) {
    return PlaybackState(
      currentTrackId: currentTrackId ?? this.currentTrackId,
      albumId: albumId ?? this.albumId,
      trackUrl: trackUrl ?? this.trackUrl,
      trackTitle: trackTitle ?? this.trackTitle,
      artist: artist ?? this.artist,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      lyrics: lyrics ?? this.lyrics,
      isPlaying: isPlaying ?? this.isPlaying,
      isLiked: isLiked ?? this.isLiked,
      currentQueueItemId: currentQueueItemId ?? this.currentQueueItemId,
    );
  }

  @override
  String toString() {
    return 'PlaybackState(currentTrackId: $currentTrackId, albumId: $albumId, trackTitle: $trackTitle, artist: $artist, coverImageUrl: $coverImageUrl, trackUrl: $trackUrl, isPlaying: $isPlaying, isLiked: $isLiked)';
  }
}

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final AudioPlayer audioPlayer;
  late final StreamSubscription<PlayerState> _playerStateSubscription;

  PlaybackNotifier({required this.audioPlayer}) : super(PlaybackState()) {
    // just_audio의 playerStateStream을 구독하여 자동 업데이트
    _playerStateSubscription = audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      state = state.copyWith(isPlaying: playerState.playing);
    });
  }
  void reset() {
    state = PlaybackState(); // 초기 상태로 되돌림
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    super.dispose();
  }

  void updatePlaybackState(bool isPlaying) {
    state = state.copyWith(isPlaying: isPlaying);
  }

  void updateLikeStatus(bool isLiked) {
    state = state.copyWith(isLiked: isLiked);
  }

  /// 현재 재생되는 트랙의 정보를 업데이트합니다.
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
    );
    print('[DEBUG] PlaybackState 업데이트 완료: ${state.toString()}');
  }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>(
  (ref) {
    // audioServiceProvider를 통해 AudioPlayer 인스턴스를 받아옵니다.
    final audioService = ref.watch(audioServiceProvider);
    return PlaybackNotifier(audioPlayer: audioService.audioPlayer);
  },
);
