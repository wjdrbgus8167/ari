import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/audio_service.dart';

// 오디오 재생 위치 스트림 제공함
final playbackPositionProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.onPositionChanged;
});

// 오디오 전체 길이(시간) 스트림 제공함
final playbackDurationProvider = StreamProvider<Duration?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.onDurationChanged;
});
