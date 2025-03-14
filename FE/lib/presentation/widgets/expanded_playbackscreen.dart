import 'package:flutter/material.dart';
import '../../providers/global_providers.dart';

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
      // 전체 화면 꽉 채우기
      initialChildSize: 1.0,
      minChildSize: 1.0,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/default_album_cover.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Stack(
            children: [
              // 상단 오버레이: 좌측에 노래 제목-아티스트, 우측에 빈 하트 아이콘
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 노래 제목과 아티스트
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playbackState.currentSongId ?? "노래 제목",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "아티스트 이름",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    // 빈 하트 아이콘 (좋아요)
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        // 좋아요 로직 추가
                      },
                    ),
                  ],
                ),
              ),
              // 하단 재생 인터페이스
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  color: Colors.black.withOpacity(0.5), // 반투명 오버레이
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 재생 슬라이더
                      Slider(
                        value: 0.3, // 예시 값
                        onChanged: (value) {
                          // 슬라이더 값 변경 로직
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white38,
                      ),
                      // 재생 컨트롤 버튼 (이전, 재생/정지, 다음)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              // 이전 곡 로직 추가
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              playbackState.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 64,
                            ),
                            onPressed: onToggle,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              // 다음 곡 로직 추가
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
