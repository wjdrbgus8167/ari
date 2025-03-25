import 'package:ari/providers/playback/playback_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/playback/playback_state_provider.dart';
import 'playback_info.dart';
import 'playback_controls.dart';
import '../lyrics/lyrics_view.dart';

class ExpandedPlaybackScreen extends ConsumerWidget {
  const ExpandedPlaybackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    // playbackServiceProvider에서 playbackService 인스턴스를 읽어옴.
    final playbackService = ref.read(playbackServiceProvider);

    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 1.0,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/default_album_cover.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              ),
            ),
            const Positioned(top: 40, left: 16, child: PlaybackInfo()),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: PlaybackControls(
                onToggle: () async {
                  print('[DEBUG] PlaybackControls onToggle 호출됨');
                  if (playbackState.isPlaying) {
                    await playbackService.audioPlayer.pause();
                    ref
                        .read(playbackProvider.notifier)
                        .updatePlaybackState(false);
                  } else {
                    await playbackService.playTrack(albumId: 1, trackId: 1);
                    ref
                        .read(playbackProvider.notifier)
                        .updatePlaybackState(true);
                  }
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LyricsView(
                albumCoverUrl: 'assets/images/default_album_cover.png',
                trackTitle: playbackState.trackTitle,
                onToggle: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
