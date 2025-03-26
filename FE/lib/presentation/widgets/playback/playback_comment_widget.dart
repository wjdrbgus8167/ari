import 'dart:ui';
import 'package:ari/providers/playback/playback_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'playback_info.dart';
import 'playback_controls.dart';
import 'package:ari/presentation/widgets/lyrics/lyrics_view.dart';

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

// 댓글 오버레이 헤더를 별도의 위젯으로 분리합니다.
class CommentOverlayHeader extends StatelessWidget {
  final VoidCallback onClose;

  const CommentOverlayHeader({Key? key, required this.onClose})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 왼쪽 여백 (텍스트 중앙 정렬을 위한 공간)
            const SizedBox(width: 48),
            Expanded(
              child: Center(
                child: const Text(
                  "댓글",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset('assets/images/down_btn.png'),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

// 댓글 오버레이를 StatefulWidget으로 변경하여 스와이프 제스처로 닫히게 처리합니다.
class CommentOverlay extends StatefulWidget {
  final String timestamp;
  final VoidCallback onClose;

  const CommentOverlay({
    Key? key,
    required this.timestamp,
    required this.onClose,
  }) : super(key: key);

  @override
  _CommentOverlayState createState() => _CommentOverlayState();
}

class _CommentOverlayState extends State<CommentOverlay> {
  double _dragOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 세로 드래그 제스처로 오버레이를 닫습니다.
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dy;
        });
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset > 100) {
          // 충분히 아래로 드래그한 경우 오버레이 닫기
          widget.onClose();
        }
        setState(() {
          _dragOffset = 0.0;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 헤더 영역: 별도의 CommentOverlayHeader 위젯 사용
              CommentOverlayHeader(onClose: widget.onClose),
              const Divider(),
              // 트랙 정보 영역: 앨범 커버, 노래 제목, 아티스트
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/default_album_cover.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Track Title",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Artist Name",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 댓글 갯수
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "댓글 31개",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 8),
              // 댓글 목록 (더미 데이터)
              Expanded(
                child: ListView.builder(
                  itemCount: 5, // 예시: 5개의 댓글
                  itemBuilder: (context, index) {
                    return const CommentItem();
                  },
                ),
              ),
              // 댓글 입력창
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "댓글을 남겨보세요...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        // 댓글 전송 로직 추가
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  const CommentItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 각 댓글 항목: 작성자 사진, 닉네임, 타임스탬프, 작성일, 댓글 내용
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자 사진
          CircleAvatar(
            backgroundImage: NetworkImage("https://placehold.co/40x40"),
          ),
          const SizedBox(width: 8),
          // 댓글 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임, 타임스탬프, 작성일
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "닉네임",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          "0:32",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          "2025-03-25",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 댓글 내용
                const Text(
                  "이것은 댓글 내용입니다. 매우 좋은 곡입니다.",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
