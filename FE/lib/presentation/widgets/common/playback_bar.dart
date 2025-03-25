import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/playback/playback_state_provider.dart';
import '../../../providers/playback/playback_progress_provider.dart';
import '../../../providers/global_providers.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/playback_service.dart';
import '../../../core/constants/app_colors.dart';
import '../playback/expanded_playbackscreen.dart';
import '../../routes/app_router.dart';

class PlaybackBar extends ConsumerWidget {
  const PlaybackBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    // playbackServiceProvider에서 playbackService 인스턴스를 읽어옴.
    final playbackService = ref.read(playbackServiceProvider);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const ExpandedPlaybackScreen(),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'assets/images/default_album_cover.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playbackState.trackTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        playbackState.artist,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    playbackState.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    if (playbackState.isPlaying) {
                      // 재생 중이면 일시정지 처리
                      await playbackService.audioPlayer.pause();
                    } else {
                      // 재생 중이 아니면 API 호출로 트랙 재생 (여기선 albumId와 trackId를 1로 고정)
                      await playbackService.playTrack(albumId: 1, trackId: 1);
                    }
                  },
                ),
                // 재생목록 아이콘
                IconButton(
                  icon: const Icon(Icons.queue_music, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.listeningqueue);
                  },
                ),
              ],
            ),
          ),
          // 음악 재생 진행바
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final position = ref
                  .watch(playbackPositionProvider)
                  .maybeWhen(data: (pos) => pos, orElse: () => Duration.zero);
              final duration = ref
                  .watch(playbackDurationProvider)
                  .maybeWhen(
                    data: (dur) => dur ?? Duration.zero,
                    orElse: () => Duration.zero,
                  );
              double progressFraction = 0;
              if (duration.inMilliseconds > 0) {
                progressFraction =
                    position.inMilliseconds / duration.inMilliseconds;
                if (progressFraction > 1) progressFraction = 1;
              }
              return Container(
                width: maxWidth,
                height: 2,
                decoration: const BoxDecoration(color: Colors.white24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: maxWidth * progressFraction,
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: AppColors.purpleGradientHorizontal,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
