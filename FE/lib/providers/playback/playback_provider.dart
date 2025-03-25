import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/models/track.dart';
import 'package:ari/core/services/playback_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';

// 재생 상태 전역 관리
class PlaybackState {
  final String? currentTrackId;
  final String trackTitle;
  final bool isPlaying;

  PlaybackState({
    this.currentTrackId,
    required this.trackTitle,
    this.isPlaying = false,
  });

  PlaybackState copyWith({String? currentTrackId, bool? isPlaying}) {
    return PlaybackState(
      currentTrackId: currentTrackId ?? this.currentTrackId,
      trackTitle: trackTitle,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

// PlaybackNotifier
class PlaybackNotifier extends StateNotifier<PlaybackState> {
  PlaybackNotifier() : super(PlaybackState(trackTitle: ''));

  void play(String songId) {
    state = state.copyWith(currentTrackId: songId, isPlaying: true);
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  void togglePlayback() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }
}

// Provide list of tracks (if needed)
final playlistProvider = StateProvider<List<Track>>((ref) => []);

// Provide Dio, AudioPlayer, PlaybackService
final dioProvider = Provider<Dio>((ref) => Dio());

final audioPlayerProvider = Provider<AudioPlayer>((ref) => AudioPlayer());

final playbackServiceProvider = Provider<PlaybackService>((ref) {
  return PlaybackService(
    dio: ref.watch(dioProvider),
    audioPlayer: ref.watch(audioPlayerProvider),
  );
});

// Provide the PlaybackNotifier
final playbackNotifierProvider =
    StateNotifierProvider<PlaybackNotifier, PlaybackState>(
      (ref) => PlaybackNotifier(),
    );
