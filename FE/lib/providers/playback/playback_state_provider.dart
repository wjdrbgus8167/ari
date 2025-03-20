import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/viewmodels/playback_viewmodel.dart';

final playbackProvider =
    StateNotifierProvider<PlaybackViewModel, PlaybackState>(
      (ref) => PlaybackViewModel(),
    );
