// lib/core/services/audio_service.dart
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/domain/entities/track.dart';

class AudioService {
  // 오디오 플레이어 인스턴스
  final AudioPlayer audioPlayer = AudioPlayer();

  // 재생목록 큐를 구성할 수 있는 소스
  final ConcatenatingAudioSource _playlistSource = ConcatenatingAudioSource(
    children: [],
  );

  // 재생 위치 스트림
  Stream<Duration> get onPositionChanged => audioPlayer.positionStream;

  // 총 길이 스트림
  Stream<Duration?> get onDurationChanged => audioPlayer.durationStream;

  // 기본 설정: 자동 다음곡, 루프, 셔플 적용
  AudioService() {
    _initializePlayer();
  }

  void _initializePlayer() {
    // 트랙이 끝났을 때 자동 다음곡 재생
    audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await audioPlayer.seekToNext();
        await audioPlayer.play();
      }
    });
  }

  // 단일 트랙 재생 (예: 처음 재생)
  Future<void> playSingleTrack(WidgetRef ref, Track track) async {
    final source = AudioSource.uri(Uri.parse(track.trackFileUrl ?? ''));
    await audioPlayer.setAudioSource(source);
    await audioPlayer.play();

    final uniqueId = "track_\${track.trackId}";
    ref
        .read(playbackProvider.notifier)
        .updateTrackInfo(
          trackTitle: track.trackTitle,
          artist: track.artistName,
          coverImageUrl: track.coverUrl ?? '',
          lyrics: track.lyric ?? '',
          currentTrackId: track.trackId,
          albumId: track.albumId,
          trackUrl: track.trackFileUrl ?? '',
          isLiked: false,
          currentQueueItemId: uniqueId,
        );
    ref.read(playbackProvider.notifier).updatePlaybackState(true);
  }

  // 전체 큐에서 특정 트랙부터 재생
  Future<void> playPlaylistFromTrack(
    WidgetRef ref,
    List<Track> playlist,
    Track startTrack,
  ) async {
    _playlistSource.clear();

    for (final track in playlist) {
      _playlistSource.add(AudioSource.uri(Uri.parse(track.trackFileUrl ?? '')));
    }

    final initialIndex = playlist.indexWhere(
      (t) => t.trackId == startTrack.trackId,
    );
    await audioPlayer.setAudioSource(
      _playlistSource,
      initialIndex: initialIndex,
    );
    await audioPlayer.play();

    final uniqueId = "track_\${startTrack.trackId}";
    ref
        .read(playbackProvider.notifier)
        .updateTrackInfo(
          trackTitle: startTrack.trackTitle,
          artist: startTrack.artistName,
          coverImageUrl: startTrack.coverUrl ?? '',
          lyrics: startTrack.lyric ?? '',
          currentTrackId: startTrack.trackId,
          albumId: startTrack.albumId,
          trackUrl: startTrack.trackFileUrl ?? '',
          isLiked: false,
          currentQueueItemId: uniqueId,
        );
    ref.read(playbackProvider.notifier).updatePlaybackState(true);
  }

  // 선택된 트랙부터 큐 끝까지 재생 (차트, 플레이리스트 전용)
  Future<void> playFromQueueSubset(
    WidgetRef ref,
    List<Track> fullQueue,
    Track selectedTrack,
  ) async {
    _playlistSource.clear();

    for (final track in fullQueue) {
      _playlistSource.add(AudioSource.uri(Uri.parse(track.trackFileUrl ?? '')));
    }

    final initialIndex = fullQueue.indexWhere(
      (t) => t.trackId == selectedTrack.trackId,
    );

    await audioPlayer.setAudioSource(
      _playlistSource,
      initialIndex: initialIndex,
    );
    await audioPlayer.play();

    final uniqueId = "track_${selectedTrack.trackId}";
    ref
        .read(playbackProvider.notifier)
        .updateTrackInfo(
          trackTitle: selectedTrack.trackTitle,
          artist: selectedTrack.artistName,
          coverImageUrl: selectedTrack.coverUrl ?? '',
          lyrics: selectedTrack.lyric ?? '',
          currentTrackId: selectedTrack.trackId,
          albumId: selectedTrack.albumId,
          trackUrl: selectedTrack.trackFileUrl ?? '',
          isLiked: false,
          currentQueueItemId: uniqueId,
        );
    ref.read(playbackProvider.notifier).updatePlaybackState(true);
  }

  // 다음에 재생할 트랙을 큐에 추가하고 즉시 재생
  Future<void> addAndPlayNext(WidgetRef ref, Track newTrack) async {
    final source = AudioSource.uri(Uri.parse(newTrack.trackFileUrl ?? ''));
    await _playlistSource.insert(0, source);
    await audioPlayer.setAudioSource(_playlistSource, initialIndex: 0);
    await audioPlayer.play();

    final uniqueId = "track_\${newTrack.trackId}";
    ref
        .read(playbackProvider.notifier)
        .updateTrackInfo(
          trackTitle: newTrack.trackTitle,
          artist: newTrack.artistName,
          coverImageUrl: newTrack.coverUrl ?? '',
          lyrics: newTrack.lyric ?? '',
          currentTrackId: newTrack.trackId,
          albumId: newTrack.albumId,
          trackUrl: newTrack.trackFileUrl ?? '',
          isLiked: false,
          currentQueueItemId: uniqueId,
        );
    ref.read(playbackProvider.notifier).updatePlaybackState(true);
  }

  // 재생 재개
  Future<void> resume(WidgetRef ref) async {
    await audioPlayer.play();
    ref.read(playbackProvider.notifier).updatePlaybackState(true);
  }

  // 일시정지
  Future<void> pause(WidgetRef ref) async {
    await audioPlayer.pause();
    ref.read(playbackProvider.notifier).updatePlaybackState(false);
  }

  // 특정 위치로 이동
  Future<void> seekTo(Duration position) async {
    await audioPlayer.seek(position);
  }

  // 다음 곡 재생
  Future<void> playNext() async {
    await audioPlayer.seekToNext();
    await audioPlayer.play();
  }

  // 이전 곡 재생
  Future<void> playPrevious() async {
    await audioPlayer.seekToPrevious();
    await audioPlayer.play();
  }

  // 셔플 모드 토글
  Future<void> toggleShuffle() async {
    final enabled = audioPlayer.shuffleModeEnabled;
    await audioPlayer.setShuffleModeEnabled(!enabled);
  }

  // 반복 모드 설정
  Future<void> setLoopMode(LoopMode loopMode) async {
    await audioPlayer.setLoopMode(loopMode);
  }
}

// 전역 Provider 등록
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
