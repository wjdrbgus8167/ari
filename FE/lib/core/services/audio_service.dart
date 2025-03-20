import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/playback/playback_state_provider.dart';

/// 오디오 재생 관련 기능을 제공하는 싱글톤 클래스입니다.
class AudioService {
  // 싱글톤 인스턴스 생성 (애플리케이션 전역에서 하나의 인스턴스만 사용)
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // 실제 오디오 재생을 담당하는 AudioPlayer 인스턴스
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 현재 재생 위치(시간)를 스트림으로 제공
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  // 전체 재생 길이(시간)를 스트림으로 제공
  Stream<Duration?> get onDurationChanged => _audioPlayer.onDurationChanged;

  /// 오디오 재생 메서드
  /// 재생 후 상태를 업데이트하여 UI에 반영
  Future<void> play(WidgetRef ref) async {
    await _audioPlayer.play(AssetSource('music/sample.mp3'));
    // 재생 상태를 true로 업데이트 (재생 중임을 표시)
    ref.read(playbackProvider.notifier).updatePlaybackState(true);
  }

  /// 오디오를 일시 정지하는 메서드
  /// 일시 정지 후 상태를 업데이트하여 UI에 반영
  Future<void> pause(WidgetRef ref) async {
    await _audioPlayer.pause();
    // 재생 상태를 false로 업데이트 (일시 정지됨을 표시)
    ref.read(playbackProvider.notifier).updatePlaybackState(false);
  }

  /// 오디오 재생 상태를 토글하는 메서드
  /// 현재 재생 중이면 일시 정지, 아니면 재생
  Future<void> togglePlay(WidgetRef ref) async {
    final isPlaying = ref.read(playbackProvider).isPlaying;
    if (isPlaying) {
      await pause(ref);
    } else {
      await play(ref);
    }
  }

  /// 슬라이더 등을 이용해 특정 위치로 이동
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }
}

// Riverpod Provider 등록: 앱 내에서 AudioService 인스턴스를 전역적으로 사용하기 위해 등록합니다.
final audioServiceProvider = Provider((ref) => AudioService());
