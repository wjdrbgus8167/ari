import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';

class AudioService {
  final AudioPlayer audioPlayer = AudioPlayer();

  // 재생 위치 스트림 제공
  Stream<Duration> get onPositionChanged => audioPlayer.onPositionChanged;
  // 전체 재생 길이 스트림 제공
  Stream<Duration?> get onDurationChanged => audioPlayer.onDurationChanged;

  /// API에서 받은 URL과 트랙 정보를 사용해 음원을 처음부터 재생하고, PlaybackState를 업데이트합니다.
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
    print('[DEBUG] AudioService.play() 호출됨');
    try {
      await audioPlayer.play(UrlSource(trackFileUrl));
      print('[DEBUG] AudioService.play() 재생 시작됨');
      // 현재 재생 트랙 정보를 PlaybackState에 업데이트
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
      // 재생 상태 업데이트
      ref.read(playbackProvider.notifier).updatePlaybackState(true);
      print('[DEBUG] AudioService.play() 상태 업데이트 완료');
    } catch (e) {
      print('[ERROR] AudioService.play() 에러 발생: $e');
      rethrow;
    }
  }

  /// 일시 정지한 음원을 이어서 재생(resume), 재생 상태를 업데이트
  Future<void> resume(WidgetRef ref) async {
    print('[DEBUG] AudioService.resume() 호출됨');
    try {
      await audioPlayer.resume();
      print('[DEBUG] AudioService.resume() 이어서 재생됨');
      ref.read(playbackProvider.notifier).updatePlaybackState(true);
      print('[DEBUG] AudioService.resume() 상태 업데이트 완료');
    } catch (e) {
      print('[ERROR] AudioService.resume() 에러 발생: $e');
      rethrow;
    }
  }

  /// 현재 재생 중인 음원을 일시 정지, 재생 상태를 업데이트
  Future<void> pause(WidgetRef ref) async {
    print('[DEBUG] AudioService.pause() 호출됨');
    try {
      await audioPlayer.pause();
      print('[DEBUG] AudioService.pause() 일시 정지됨');
      ref.read(playbackProvider.notifier).updatePlaybackState(false);
      print('[DEBUG] AudioService.pause() 상태 업데이트 완료');
    } catch (e) {
      print('[ERROR] AudioService.pause() 에러 발생: $e');
      rethrow;
    }
  }

  /// 재생 상태 토글: 재생 중이면 일시 정지, 아니면 재생/이어재생
  Future<void> togglePlay(
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
    final isPlaying = ref.read(playbackProvider).isPlaying;
    print('[DEBUG] AudioService.togglePlay() 호출됨, 현재 isPlaying: $isPlaying');
    if (isPlaying) {
      await pause(ref);
    } else {
      if (ref.read(playbackProvider).currentTrackId != null) {
        await resume(ref);
      } else {
        await play(
          ref,
          trackFileUrl,
          title: title,
          artist: artist,
          coverImageUrl: coverImageUrl,
          lyrics: lyrics,
          trackId: trackId,
          albumId: albumId,
          isLiked: isLiked,
        );
      }
    }
    print(
      '[DEBUG] AudioService.togglePlay() 완료, isPlaying: ${ref.read(playbackProvider).isPlaying}',
    );
  }

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
}

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
