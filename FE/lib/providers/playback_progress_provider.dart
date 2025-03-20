// providers/playback_progress_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/audio_service.dart';

final playbackPositionProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.onPositionChanged;
});

final playbackDurationProvider = StreamProvider<Duration?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.onDurationChanged;
});
