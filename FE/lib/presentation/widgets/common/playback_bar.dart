import 'package:ari/presentation/viewmodels/playback/playback_state.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/providers/playback/playback_progress_provider.dart';
import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/presentation/widgets/playback/expanded_playbackscreen.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/core/services/playback_service.dart' as playbackServiceLib;
import 'package:ari/core/services/audio_service.dart';

class PlaybackBar extends ConsumerWidget {
  const PlaybackBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    final playbackService = ref.read(
      playbackServiceLib.playbackServiceProvider,
    );
    final audioService = ref.read(audioServiceProvider);
    final coverImage = ref.watch(coverImageProvider);

    // listeningQueueProvider의 상태를 가져옵니다.
    final queueState = ref.watch(listeningQueueProvider);

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
                    child: Image(
                      image: coverImage,
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
                // 재생 버튼: 로딩 중이면 CircularProgressIndicator를 표시하고, onPressed를 null로 설정합니다.
                IconButton(
                  icon:
                      queueState.isLoading
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Icon(
                            playbackState.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                  onPressed:
                      queueState.isLoading
                          ? null
                          : () async {
                            if (playbackState.isPlaying) {
                              await audioService.pause(ref);
                            } else {
                              // 현재 재생 중인 트랙이 있다면 이어서 재생(resume)
                              if (playbackState.currentTrackId != null) {
                                await audioService.resume(ref);
                              } else {
                                // 현재 재생 중인 트랙이 없으면 재생목록(리슨잉 큐)에서 셔플하여 재생
                                final queue = queueState.filteredPlaylist;
                                if (queue.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('재생 가능한 곡이 없습니다.'),
                                    ),
                                  );
                                } else {
                                  final shuffledQueue = List.from(queue);
                                  shuffledQueue.shuffle();
                                  final listeningQueueItem =
                                      shuffledQueue.first;
                                  await playbackService.playTrack(
                                    albumId: listeningQueueItem.track.albumId,
                                    trackId: listeningQueueItem.track.trackId,
                                    ref: ref,
                                  );
                                }
                              }
                            }
                          },
                ),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
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
