import 'package:flutter/material.dart';
import '../../providers/global_providers.dart';
import 'playback_info.dart';
import 'playback_controls.dart';
import 'lyrics_view.dart';

class ExpandedPlaybackScreen extends StatelessWidget {
  final PlaybackState playbackState;
  final VoidCallback onToggle;

  const ExpandedPlaybackScreen({
    Key? key,
    required this.playbackState,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 1.0,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Stack(
          children: [
            // 🔹 배경 이미지 (앨범 커버)
            Positioned.fill(
              child: Image.asset(
                'assets/images/default_album_cover.png',
                fit: BoxFit.cover,
              ),
            ),

            // 🔹 좋아요 버튼 (오른쪽 상단)
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

            // 🔹 노래 정보 (제목 & 아티스트)
            const Positioned(top: 40, left: 16, child: PlaybackInfo()),

            // 🔹 재생 인터페이스
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: PlaybackControls(onToggle: onToggle),
            ),

            // 🔹 가사 보기 버튼
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LyricsView(
                albumCoverUrl: 'assets/images/default_album_cover.png',
                trackTitle: playbackState.trackTitle,
              ),
            ),
          ],
        );
      },
    );
  }
}
