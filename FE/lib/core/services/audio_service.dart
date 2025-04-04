import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/data/models/track.dart'; // Hive에 저장된 Track 모델 (또는 API 모델)

class AudioService {
  final AudioPlayer audioPlayer = AudioPlayer();

  // 재생 위치 및 전체 길이 스트림 (just_audio 사용)
  Stream<Duration> get onPositionChanged => audioPlayer.positionStream;
  Stream<Duration?> get onDurationChanged => audioPlayer.durationStream;

  /// 단일 트랙 재생 (기존 방식)
  Future<void> play(
    WidgetRef ref,
    String trackFileUrl, {
    required String title,
    required String artist,
    required String coverImageUrl,
    required String lyrics,
    required int trackId,
    required int albumId,
    required bool isLiked,
    required String currentQueueItemId,
  }) async {
    print('[DEBUG] AudioService.play() 호출됨');
    try {
      // 먼저 트랙 정보를 업데이트하여 UI에 바로 반영
      ref
          .read(playbackProvider.notifier)
          .updateTrackInfo(
            trackTitle: title,
            artist: artist,
            coverImageUrl: coverImageUrl,
            lyrics: lyrics,
            currentTrackId: trackId,
            albumId: albumId,
            trackUrl: trackFileUrl,
            isLiked: isLiked,
            currentQueueItemId: currentQueueItemId,
          );
      // 오디오 소스를 설정하고 재생 시작
      await audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(trackFileUrl)),
      );
      await audioPlayer.play();
      // 재생 상태 업데이트 (이 값은 PlaybackNotifier의 스트림 구독으로도 보완 가능)
      ref.read(playbackProvider.notifier).updatePlaybackState(true);
      print('[DEBUG] AudioService.play() 상태 업데이트 완료');
    } catch (e) {
      print('[ERROR] AudioService.play() 에러 발생: $e');
      rethrow;
    }
  }

  /// 재생목록(플레이리스트) 재생: ConcatenatingAudioSource를 사용하여 트랙 목록 전체를 재생
  Future<void> playPlaylist(
    WidgetRef ref,
    List<Track> tracks, {
    int initialIndex = 0,
  }) async {
    print('[DEBUG] AudioService.playPlaylist() 호출됨');
    try {
      // 각 트랙의 trackFileUrl을 이용해 AudioSource 목록 생성
      final sources =
          tracks.map((track) {
            return AudioSource.uri(Uri.parse(track.trackFileUrl));
          }).toList();

      // ConcatenatingAudioSource를 생성
      final playlistSource = ConcatenatingAudioSource(children: sources);

      // 플레이리스트를 세팅하며, initialIndex를 지정
      await audioPlayer.setAudioSource(
        playlistSource,
        initialIndex: initialIndex,
      );
      await audioPlayer.play();

      // 초기 재생 트랙의 정보를 PlaybackState에 업데이트
      final currentTrack = tracks[initialIndex];
      ref
          .read(playbackProvider.notifier)
          .updateTrackInfo(
            trackTitle: currentTrack.trackTitle,
            artist: currentTrack.artist,
            coverImageUrl: currentTrack.coverUrl ?? '',
            lyrics: currentTrack.lyrics,
            currentTrackId: currentTrack.id,
            albumId: currentTrack.albumId,
            trackUrl: currentTrack.trackFileUrl,
            isLiked: false,
            currentQueueItemId: currentTrack.id.toString(),
          );
      ref.read(playbackProvider.notifier).updatePlaybackState(true);
      print('[DEBUG] AudioService.playPlaylist() 재생 시작됨');
    } catch (e) {
      print('[ERROR] AudioService.playPlaylist() 에러 발생: $e');
      rethrow;
    }
  }

  /// 이어재생 (resume)
  Future<void> resume(WidgetRef ref) async {
    print('[DEBUG] AudioService.resume() 호출됨');
    try {
      await audioPlayer.play();
      ref.read(playbackProvider.notifier).updatePlaybackState(true);
      print('[DEBUG] AudioService.resume() 이어서 재생됨');
    } catch (e) {
      print('[ERROR] AudioService.resume() 에러 발생: $e');
      rethrow;
    }
  }

  /// 일시 정지
  Future<void> pause(WidgetRef ref) async {
    print('[DEBUG] AudioService.pause() 호출됨');
    try {
      await audioPlayer.pause();
      ref.read(playbackProvider.notifier).updatePlaybackState(false);
      print('[DEBUG] AudioService.pause() 일시 정지됨');
    } catch (e) {
      print('[ERROR] AudioService.pause() 에러 발생: $e');
      rethrow;
    }
  }

  /// 지정된 위치로 이동
  Future<void> seekTo(Duration position) async {
    print('[DEBUG] AudioService.seekTo() 호출됨, 이동할 위치: ${position.inSeconds}s');
    try {
      await audioPlayer.seek(position);
      print('[DEBUG] AudioService.seekTo() 완료');
    } catch (e) {
      print('[ERROR] AudioService.seekTo() 에러 발생: $e');
      rethrow;
    }
  }

  /// 다음 트랙 재생
  Future<void> playNext() async {
    print('[DEBUG] AudioService.playNext() 호출됨');
    try {
      await audioPlayer.seekToNext();
      print('[DEBUG] AudioService.playNext() 완료');
    } catch (e) {
      print('[ERROR] AudioService.playNext() 에러 발생: $e');
      rethrow;
    }
  }

  /// 이전 트랙 재생
  Future<void> playPrevious() async {
    print('[DEBUG] AudioService.playPrevious() 호출됨');
    try {
      await audioPlayer.seekToPrevious();
      print('[DEBUG] AudioService.playPrevious() 완료');
    } catch (e) {
      print('[ERROR] AudioService.playPrevious() 에러 발생: $e');
      rethrow;
    }
  }

  /// 셔플 모드 토글
  Future<void> toggleShuffle() async {
    try {
      final enabled = audioPlayer.shuffleModeEnabled;
      await audioPlayer.setShuffleModeEnabled(!enabled);
    } catch (e) {
      print('[ERROR] AudioService.toggleShuffle() 에러 발생: $e');
      rethrow;
    }
  }

  /// 루프 모드 설정: LoopMode.off, LoopMode.one, LoopMode.all
  Future<void> setLoopMode(LoopMode loopMode) async {
    try {
      await audioPlayer.setLoopMode(loopMode);
    } catch (e) {
      print('[ERROR] AudioService.setLoopMode() 에러 발생: $e');
      rethrow;
    }
  }
}

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
