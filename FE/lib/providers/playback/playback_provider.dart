import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/models/track.dart';
import 'package:ari/core/services/playback_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ari/providers/global_providers.dart';

// 재생 상태 전역 관리
class PlaybackState {
  final int? currentTrackId;
  final int? albumId;
  final String trackUrl;
  final String trackTitle;
  final String artist;
  final String coverImageUrl;
  final String lyrics;
  final bool isPlaying;
  final bool isLiked;
  final String currentQueueItemId;

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

  // PlaybackState의 새로운 상태 생성
  //PlaybackState 객체를 직접 수정하는 대신, copyWith 메서드를 사용해 새로운 객체를 생성
  // 이렇게 하면 상태 변경을 추적하기 쉽고, 불변성을 유지할 수 있음(이게 riverpod 권장방식)
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
      currentQueueItemId: currentQueueItemId ?? this.currentQueueItemId, // 업데이트
    );
  }

  @override
  String toString() {
    return 'PlaybackState(currentTrackId: $currentTrackId, albumId: $albumId, trackTitle: $trackTitle, artist: $artist, coverImageUrl: $coverImageUrl, trackUrl: $trackUrl, isPlaying: $isPlaying, isLiked: $isLiked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlaybackState &&
            runtimeType == other.runtimeType &&
            currentTrackId == other.currentTrackId &&
            albumId == other.albumId &&
            trackUrl == other.trackUrl &&
            trackTitle == other.trackTitle &&
            artist == other.artist &&
            coverImageUrl == other.coverImageUrl &&
            lyrics == other.lyrics &&
            isPlaying == other.isPlaying &&
            isLiked == other.isLiked &&
            currentQueueItemId == other.currentQueueItemId;
  }

  @override
  int get hashCode => Object.hash(
    currentTrackId,
    albumId,
    trackUrl,
    trackTitle,
    artist,
    coverImageUrl,
    lyrics,
    isPlaying,
    isLiked,
    currentQueueItemId,
  );
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
      currentQueueItemId: currentQueueItemId, // ✅ 이 줄 추가!
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

// // PlaybackNotifier를 전역상태로 제공
// final playbackNotifierProvider =
//     StateNotifierProvider<PlaybackNotifier, PlaybackState>(
//       (ref) => PlaybackNotifier(),
//     );
