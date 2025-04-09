import 'package:ari/presentation/viewmodels/playback/playback_state.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/providers/playback/playback_progress_provider.dart';
import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/presentation/widgets/playback/expanded_playbackscreen.dart';
import 'package:ari/core/services/playback_service.dart' as playbackServiceLib;
import 'package:ari/core/services/audio_service.dart';
import 'package:ari/core/utils/login_helper.dart';

class PlaybackBar extends ConsumerWidget {
  const PlaybackBar({super.key});

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
      onTap: () async {
        final ok = await checkLoginAndNavigateIfNeeded(
          context: context,
          ref: ref,
        );
        if (!ok) return;
        try {
          // 프레임 딜레이를 줘서 build 중 상태 변화에 의한 재빌드와 충돌을 피함
          await Future.delayed(Duration.zero);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const ExpandedPlaybackScreen(),
          );
        } catch (e, stack) {
          debugPrint('❌ 에러 발생: $e');
          debugPrint('🧱 스택: $stack');
        }
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
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.music_note,
                          size: 40,
                          color: Colors.white70,
                        );
                      },
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
                            final ok = await checkLoginAndNavigateIfNeeded(
                              context: context,
                              ref: ref,
                            );
                            if (!ok) return;
                            if (playbackState.isPlaying) {
                              await audioService.pause(ref);
                            } else {
                              if (playbackState.currentTrackId != null) {
                                try {
                                  await audioService.resume(ref);
                                } on DioException catch (e) {
                                  final code =
                                      e.response?.data['error']?['code'];
                                  if (code == 'S001') {
                                    context.showToast(
                                      '🔒 구독권이 없습니다. 구독 후 이용해 주세요.',
                                    );
                                  } else if (code == 'S002') {
                                    context.showToast(
                                      '🚫 현재 구독권으로는 재생할 수 없는 곡입니다.',
                                    );
                                  } else if (code == 'S003') {
                                    context.showToast('⚠️ 로그인 후 이용해 주세요.');
                                  } else {
                                    context.showToast('❌ 알 수 없는 오류가 발생했습니다.');
                                  }
                                } catch (_) {
                                  context.showToast('❗예상치 못한 오류가 발생했습니다.');
                                }
                              } else {
                                final queue = queueState.filteredPlaylist;
                                if (queue.isEmpty) {
                                  context.showToast('재생 가능한 곡이 없습니다.');
                                } else {
                                  final shuffledQueue = List.from(queue);
                                  shuffledQueue.shuffle();
                                  final listeningQueueItem =
                                      shuffledQueue.first;

                                  try {
                                    await playbackService.playTrack(
                                      albumId: listeningQueueItem.track.albumId,
                                      trackId: listeningQueueItem.track.trackId,
                                      ref: ref,
                                      context: context,
                                    );
                                  } on DioException catch (e) {
                                    final code =
                                        e.response?.data['error']?['code'];
                                    if (code == 'S001') {
                                      context.showToast(
                                        '🔒 구독권이 없습니다. 구독 후 이용해 주세요.',
                                      );
                                    } else if (code == 'S002') {
                                      context.showToast(
                                        '🚫 현재 구독권으로는 재생할 수 없는 곡입니다.',
                                      );
                                    } else if (code == 'S003') {
                                      context.showToast('⚠️ 로그인 후 이용해 주세요.');
                                    } else {
                                      context.showToast('❌ 알 수 없는 오류가 발생했습니다.');
                                    }
                                  } catch (_) {
                                    context.showToast('❗예상치 못한 오류가 발생했습니다.');
                                  }
                                }
                              }
                            }
                          },
                ),
                IconButton(
                  icon: const Icon(Icons.queue_music, color: Colors.white),
                  onPressed: () async {
                    final ok = await checkLoginAndNavigateIfNeeded(
                      context: context,
                      ref: ref,
                    );
                    if (!ok) return;

                    Navigator.pushNamed(context, '/listeningqueue-tab');
                  },
                ),
              ],
            ),
          ),
          // 음악 재생 진행바
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final positionAsync = ref.watch(playbackPositionProvider);
              final durationAsync = ref.watch(playbackDurationProvider);

              final position = positionAsync.asData?.value ?? Duration.zero;
              final duration = durationAsync.asData?.value ?? Duration.zero;

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
