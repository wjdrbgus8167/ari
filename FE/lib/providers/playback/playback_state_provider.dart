import 'package:ari/presentation/viewmodels/playback/playback_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/viewmodels/playback/playback_viewmodel.dart';

final playbackProvider =
    StateNotifierProvider<PlaybackViewModel, PlaybackState>(
      (ref) => PlaybackViewModel(),
    );
