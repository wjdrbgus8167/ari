import 'dart:ui';
import 'package:ari/presentation/viewmodels/playback/playback_state.dart';
import 'package:ari/presentation/widgets/playback_comment/comment_overlay.dart';
import 'package:ari/providers/playback/playback_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'playback_info.dart';
import 'playback_controls.dart';
import 'package:ari/presentation/widgets/lyrics/lyrics_view.dart';
import 'package:ari/providers/playback/playback_progress_provider.dart';

class ExpandedPlaybackScreen extends ConsumerStatefulWidget {
  const ExpandedPlaybackScreen({Key? key}) : super(key: key);

  @override
  _ExpandedPlaybackScreenState createState() => _ExpandedPlaybackScreenState();
}

class _ExpandedPlaybackScreenState
    extends ConsumerState<ExpandedPlaybackScreen> {
  bool _showCommentOverlay = false;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackProvider);
    final playbackService = ref.read(playbackServiceProvider);
    final coverImage = ref.watch(coverImageProvider);

    final positionAsyncValue = ref.watch(playbackPositionProvider);
    final Duration currentPosition = positionAsyncValue.when(
      data: (duration) => duration,
      loading: () => Duration.zero,
      error: (_, __) => Duration.zero,
    );
    final String currentTimestamp = _formatDuration(currentPosition);

    return GestureDetector(
      onTap: () {
        if (!_showCommentOverlay) {
          setState(() {
            _showCommentOverlay = true;
          });
        }
      },
      child: Stack(
        children: [
          DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 1.0,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Stack(
                children: [
                  // 배경: API의 coverImageUrl 사용 (없으면 기본 asset)
                  Positioned.fill(
                    child: Image(image: coverImage, fit: BoxFit.cover),
                  ),
                  // 우측 상단 즐겨찾기 버튼
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
                  // 좌측 상단 PlaybackInfo
                  Positioned(
                    top: 40,
                    left: 16,
                    child: PlaybackInfo(
                      trackTitle: playbackState.trackTitle,
                      artist: playbackState.artist,
                    ),
                  ),
                  // 하단 재생 컨트롤 영역
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
                          await playbackService.playTrack(
                            albumId: 1,
                            trackId: 1,
                            ref: ref,
                          );
                          ref
                              .read(playbackProvider.notifier)
                              .updatePlaybackState(true);
                        }
                      },
                    ),
                  ),
                  // 하단 가사 보기 영역
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LyricsView(
                      albumCoverUrl:
                          playbackState.coverImageUrl.isNotEmpty
                              ? playbackState.coverImageUrl
                              : 'assets/images/default_album_cover.png',
                      trackTitle: playbackState.trackTitle,
                      lyrics: playbackState.lyrics,
                      onToggle: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          // 댓글 오버레이
          if (_showCommentOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: CommentOverlay(
                      trackTitle: playbackState.trackTitle,
                      artist: playbackState.artist,
                      coverImageUrl: playbackState.coverImageUrl,
                      timestamp: currentTimestamp,
                      onClose: () {
                        setState(() {
                          _showCommentOverlay = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
