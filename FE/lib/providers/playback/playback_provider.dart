import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/models/track.dart';
import 'package:ari/core/services/playback_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ari/providers/global_providers.dart';

// 재생 상태 전역 관리
class PlaybackState {
  final int? currentTrackId;
  final String trackTitle;
  final bool isPlaying;
  final String trackUrl;

  PlaybackState({
    this.currentTrackId,
    this.trackUrl = '',
    this.trackTitle = '',
    this.isPlaying = false,
  });

  // PlaybackState의 새로운 상태 생성
  //PlaybackState 객체를 직접 수정하는 대신, copyWith 메서드를 사용해 새로운 객체를 생성
  // 이렇게 하면 상태 변경을 추적하기 쉽고, 불변성을 유지할 수 있음(이게 riverpod 권장방식)
  PlaybackState copyWith({
    int? currentTrackId,
    String? trackTitle,
    bool? isPlaying,
    String? trackUrl,
  }) {
    return PlaybackState(
      currentTrackId: currentTrackId ?? this.currentTrackId,
      trackTitle: trackTitle ?? this.trackTitle,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

// 전역 재생상태 업데이트 하는 Notifier
class PlaybackNotifier extends StateNotifier<PlaybackState> {
  PlaybackNotifier() : super(PlaybackState(trackTitle: ''));

  void play(int songId, String trackUrl) {
    state = state.copyWith(
      currentTrackId: songId,
      isPlaying: true,
      trackUrl: trackUrl,
    );
  }

  // 일시 정지 시 상태 업데이트
  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  // 재생 상태 토글(스위치)
  void togglePlayback() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  // 트랙 정보를 업데이트 (트랙 제목, URL, 트랙 ID)
  void updateTrackInfo({
    required String trackTitle,
    required String trackUrl,
    required int currentTrackId,
  }) {
    state = state.copyWith(
      trackTitle: trackTitle,
      trackUrl: trackUrl,
      currentTrackId: currentTrackId,
    );
  }
}

// 재생 목록 제공
final playlistProvider = StateProvider<List<Track>>((ref) => []);

// AudioPlayer 인스턴스 제공
final audioPlayerProvider = Provider<AudioPlayer>((ref) => AudioPlayer());

// PlaybackService 인스턴스를 제공 (API 호출 및 오디오 재생)
final playbackServiceProvider = Provider<PlaybackService>((ref) {
  return PlaybackService(
    dio: ref.watch(dioProvider),
    audioPlayer: ref.watch(audioPlayerProvider),
  );
});

// PlaybackNotifier를 전역상태로 제공
final playbackNotifierProvider =
    StateNotifierProvider<PlaybackNotifier, PlaybackState>(
      (ref) => PlaybackNotifier(),
    );
