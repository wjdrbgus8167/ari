import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/playback_state_provider.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<Duration?> get onDurationChanged => _audioPlayer.onDurationChanged;

  Future<void> play(WidgetRef ref) async {
    await _audioPlayer.play(AssetSource('music/sample.mp3'));
    ref.read(playbackProvider.notifier).updatePlaybackState(true);
  }

  Future<void> pause(WidgetRef ref) async {
    await _audioPlayer.pause();
    ref.read(playbackProvider.notifier).updatePlaybackState(false);
  }

  Future<void> togglePlay(WidgetRef ref) async {
    final isPlaying = ref.read(playbackProvider).isPlaying;
    if (isPlaying) {
      await pause(ref);
    } else {
      await play(ref);
    }
  }

  // 재생창 재생바 슬라이더 조작
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }
}

// Riverpod Provider 등록
final audioServiceProvider = Provider((ref) => AudioService());

//만약 백엔드에서 HLS를 통해 스트리밍으로 보내줄경우 아래처럼 수정
// import 'package:just_audio/just_audio.dart';

// class AudioService {
//   final AudioPlayer _player = AudioPlayer();

//   Future<void> setUrl(String hlsUrl) async {
//     await _player.setUrl(hlsUrl); // HLS URL (.m3u8)
//   }

//   Future<void> play() => _player.play();

//   Future<void> pause() => _player.pause();

//   void togglePlay() {
//     if (_player.playing) {
//       pause();
//     } else {
//       play();
//     }
//   }

//   void dispose() => _player.dispose();
// }
