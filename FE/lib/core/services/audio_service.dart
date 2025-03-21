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
    // 음원 재생 (AssetSource 대신 네트워크 URL도 사용 가능)
    await audioPlayer.play(AssetSource('music/sample.mp3'));
    // 재생 상태 업데이트: 재생 중임을 표시
    ref.read(playbackProvider.notifier).updatePlaybackState(true);
  }

  /// 현재 재생 중인 음원을 일시 정지하고, 재생 상태를 업데이트함.
  Future<void> pause(WidgetRef ref) async {
    await audioPlayer.pause();
    ref.read(playbackProvider.notifier).updatePlaybackState(false);
  }

  /// 재생 상태를 토글함.
  /// 재생 중이면 일시정지, 아니면 재생.
  Future<void> togglePlay(WidgetRef ref) async {
    final isPlaying = ref.read(playbackProvider).isPlaying;
    if (isPlaying) {
      await pause(ref);
    } else {
      await play(ref);
    }
  }

  /// 슬라이더 등에서 특정 위치로 이동할 때 호출.
  Future<void> seekTo(Duration position) async {
    await audioPlayer.seek(position);
  }
}

// AudioService 인스턴스를 전역적으로 제공하는 Provider
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
