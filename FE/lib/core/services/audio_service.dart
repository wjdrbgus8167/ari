import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/playback/playback_state_provider.dart';

class AudioService {
  // AudioPlayer 인스턴스 생성
  final AudioPlayer audioPlayer = AudioPlayer();

  // 재생 위치 스트림
  Stream<Duration> get onPositionChanged => audioPlayer.onPositionChanged;
  // 전체 재생 길이 스트림
  Stream<Duration?> get onDurationChanged => audioPlayer.onDurationChanged;

  /// 지정된 음원을 재생하고, 재생 상태를 업데이트함.
  Future<void> play(WidgetRef ref) async {
    print('[DEBUG] AudioService.play() 호출됨');
    try {
      // 음원 재생 (AssetSource 대신 네트워크 URL도 사용 가능)
      await audioPlayer.play(AssetSource('music/sample.mp3'));
      print('[DEBUG] AudioService.play() 재생 시작됨');
      // 재생 상태 업데이트: 재생 중임을 표시
      ref.read(playbackProvider.notifier).updatePlaybackState(true);
      print('[DEBUG] AudioService.play() 상태 업데이트 완료');
    } catch (e) {
      print('[ERROR] AudioService.play() 에러 발생: $e');
      rethrow;
    }
  }

  /// 현재 재생 중인 음원을 일시 정지하고, 재생 상태를 업데이트함.
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

  /// 재생 상태를 토글함.
  /// 재생 중이면 일시 정지, 아니면 재생.
  Future<void> togglePlay(WidgetRef ref) async {
    final isPlaying = ref.read(playbackProvider).isPlaying;
    print('[DEBUG] AudioService.togglePlay() 호출됨, 현재 isPlaying: $isPlaying');
    if (isPlaying) {
      await pause(ref);
    } else {
      await play(ref);
    }
    print(
      '[DEBUG] AudioService.togglePlay() 완료, isPlaying: ${ref.read(playbackProvider).isPlaying}',
    );
  }

  /// 슬라이더 등에서 특정 위치로 이동할 때 호출.
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

// AudioService 인스턴스를 전역적으로 제공하는 Provider
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
