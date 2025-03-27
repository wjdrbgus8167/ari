import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'comment_overlay.dart';

class PlaybackCommentWidget extends ConsumerStatefulWidget {
  const PlaybackCommentWidget({Key? key}) : super(key: key);

  @override
  _PlaybackCommentWidgetState createState() => _PlaybackCommentWidgetState();
}

class _PlaybackCommentWidgetState extends ConsumerState<PlaybackCommentWidget> {
  bool _showCommentOverlay = false;

  String getCurrentPlaybackTime() => "0:32";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_showCommentOverlay) {
          setState(() => _showCommentOverlay = true);
        }
      },
      child: Stack(
        children: [
          if (_showCommentOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: CommentOverlay(
                      timestamp: getCurrentPlaybackTime(),
                      onClose:
                          () => setState(() => _showCommentOverlay = false),
                      trackTitle: "현재 트랙 제목",
                      artist: "아티스트 이름",
                      coverImageUrl: 'assets/images/default_album_cover.png',
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
