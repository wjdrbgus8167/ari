import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';

class AudioService {
  final AudioPlayer audioPlayer = AudioPlayer();

  // 재생 위치 및 전체 길이 스트림 (just_audio 사용)
  Stream<Duration> get onPositionChanged => audioPlayer.positionStream;
  Stream<Duration?> get onDurationChanged => audioPlayer.durationStream;

  /// 단일 트랙 재생: URL로 오디오 소스를 설정하고 재생 시작
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
  }) async {
    try {
      // 단일 URL을 AudioSource.uri로 변환하여 재생 준비
      await audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(trackFileUrl)),
      );
      await audioPlayer.play();
      // PlaybackState 업데이트
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
          );
      ref.read(playbackProvider.notifier).updatePlaybackState(true);
    } catch (e) {
      print('[ERROR] AudioService.play() 에러 발생: $e');
      rethrow;
    }
  }

  /// 이어재생 (resume)
  Future<void> resume(WidgetRef ref) async {
    try {
      await audioPlayer.play();
      ref.read(playbackProvider.notifier).updatePlaybackState(true);
    } catch (e) {
      print('[ERROR] AudioService.resume() 에러 발생: $e');
      rethrow;
    }
  }

  /// 일시 정지
  Future<void> pause(WidgetRef ref) async {
    try {
      await audioPlayer.pause();
      ref.read(playbackProvider.notifier).updatePlaybackState(false);
    } catch (e) {
      print('[ERROR] AudioService.pause() 에러 발생: $e');
      rethrow;
    }
  }

  /// 지정된 위치로 이동
  Future<void> seekTo(Duration position) async {
    try {
      await audioPlayer.seek(position);
    } catch (e) {
      print('[ERROR] AudioService.seekTo() 에러 발생: $e');
      rethrow;
    }
  }

  /// 다음 트랙 재생 (ConcatenatingAudioSource를 사용하는 경우)
  Future<void> playNext() async {
    try {
      await audioPlayer.seekToNext();
    } catch (e) {
      print('[ERROR] AudioService.playNext() 에러 발생: $e');
      rethrow;
    }
  }

  /// 이전 트랙 재생 (ConcatenatingAudioSource를 사용하는 경우)
  Future<void> playPrevious() async {
    try {
      await audioPlayer.seekToPrevious();
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
