import 'package:flutter/material.dart';
import '../../providers/global_providers.dart';
import './expanded_playbackscreen.dart';

class PlaybackBar extends StatelessWidget {
  final PlaybackState playbackState;
  final VoidCallback onToggle;

  const PlaybackBar({
    Key? key,
    required this.playbackState,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 재생바 탭 시 확장된 재생창 모달 띄우기
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // 전체 화면 모달
          backgroundColor: Colors.transparent,
          builder:
              (context) =>
                  const SizedBox.expand(child: ExpandedPlaybackScreenWrapper()),
        );
      },
      child: Container(
        color: Colors.grey[850],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // 앨범 커버 왼쪽 패딩 포함
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
            // 노래 제목과 아티스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playbackState.currentSongId ?? "노래 제목",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "아티스트 이름",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 재생 버튼
            IconButton(
              icon: Icon(
                playbackState.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: onToggle,
            ),
            // 재생목록 아이콘
            IconButton(
              icon: const Icon(Icons.queue_music, color: Colors.white),
              onPressed: () {
                // 재생목록 보기 로직 추가
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 래퍼 위젯: ExpandedPlaybackScreen을 Scaffold가 없는 상태로 감싸줌
class ExpandedPlaybackScreenWrapper extends StatelessWidget {
  const ExpandedPlaybackScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // PlaybackState, onToggle 등은 실제 앱에서는 전역 상태로 전달해야 함.
    // 여기서는 예시로 placeholder 값을 사용함.
    final playbackState = PlaybackState(
      currentSongId: "노래 제목",
      isPlaying: true,
    );

    return ExpandedPlaybackScreen(
      playbackState: playbackState,
      onToggle: () {
        // 토글 로직 예시
        Navigator.pop(context);
      },
    );
  }
}
