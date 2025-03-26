import 'dart:ui';
import 'package:ari/providers/playback/playback_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'playback_info.dart';
import 'playback_controls.dart';
import 'package:ari/presentation/widgets/lyrics/lyrics_view.dart';
import 'package:ari/presentation/widgets/playback/playback_comment_widget.dart';

class ExpandedPlaybackScreen extends ConsumerStatefulWidget {
  const ExpandedPlaybackScreen({Key? key}) : super(key: key);

  @override
  _ExpandedPlaybackScreenState createState() => _ExpandedPlaybackScreenState();
}

class _ExpandedPlaybackScreenState
    extends ConsumerState<ExpandedPlaybackScreen> {
  bool _showCommentOverlay = false;

  // 실제 재생시간을 가져오는 로직으로 대체 가능 (예시값)
  String getCurrentPlaybackTime() {
    return "0:32";
  }

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackProvider);
    final playbackService = ref.read(playbackServiceProvider);

    return GestureDetector(
      // 재생 화면 터치 시 댓글 오버레이가 나타납니다.
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
                  // 배경 앨범 커버 (재생 화면 배경)
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/default_album_cover.png',
                      fit: BoxFit.cover,
                    ),
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
                  // 왼쪽 상단 PlaybackInfo (예: 곡 제목, 아티스트 등)
                  const Positioned(top: 40, left: 16, child: PlaybackInfo()),
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
                      albumCoverUrl: 'assets/images/default_album_cover.png',
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
          // 댓글 오버레이: 배경은 재생 화면을 블러 처리한 모습
          if (_showCommentOverlay)
            Positioned.fill(
              child: GestureDetector(
                // 배경 터치 시 오버레이 닫힘 없이 제스처가 CommentOverlay로 전달되게 함.
                onTap: () {},
                child: Container(
                  // 재생 화면 위에 블러 효과와 어둡게 처리된 오버레이 배경
                  color: Colors.black.withOpacity(0.4),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: CommentOverlay(
                      timestamp: getCurrentPlaybackTime(),
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
