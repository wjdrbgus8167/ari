import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class LyricsView extends StatefulWidget {
  final String albumCoverUrl;
  final String trackTitle; // 🎵 현재 재생 중인 트랙 제목 추가

  const LyricsView({
    Key? key,
    required this.albumCoverUrl,
    required this.trackTitle, // 🔹 필수 인자로 추가
  }) : super(key: key);

  @override
  _LyricsViewState createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  Color _dominantColor = Colors.black; // 기본값 검은색

  @override
  void initState() {
    super.initState();
    _extractDominantColor(); // 색상 추출
  }

  /// 🎨 앨범 커버에서 색상 추출
  Future<void> _extractDominantColor() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
          NetworkImage(widget.albumCoverUrl),
        );

    setState(() {
      _dominantColor = paletteGenerator.dominantColor?.color ?? Colors.black;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return _buildLyricsScreen();
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _dominantColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Text(
          "가사 보기",
          style: TextStyle(color: Colors.white70, fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 🎶 가사 모달 화면
  Widget _buildLyricsScreen() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: _dominantColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // 🔹 가사창 상단 타이틀 & 닫기 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔹 ⬇️ 스와이프 버튼
                      IconButton(
                        icon: Image.asset(
                          'assets/images/down_btn.png',
                          width: 40,
                          height: 40,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      // 🔹 현재 재생 중인 `trackTitle` 적용
                      Expanded(
                        child: Text(
                          widget.trackTitle, // 현재 재생 중인 트랙 제목 표시
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis, // 긴 제목 줄임 처리
                        ),
                      ),
                      const SizedBox(width: 50), // 오른쪽 균형 맞추기
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 🔹 가사 내용
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Text(
                        "가사 줄 1\n"
                        "가사 줄 2\n"
                        "가사 줄 3\n"
                        "가사 줄 4\n"
                        "가사 줄 5\n"
                        "가사 줄 6\n"
                        "가사 줄 7\n"
                        "가사 줄 8\n"
                        "가사 줄 9\n"
                        "가사 줄 10",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 🔹 재생 슬라이더 & 버튼
                _buildPlaybackControls(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 재생 인터페이스 (슬라이더 + 버튼)
  Widget _buildPlaybackControls() {
    return Column(
      children: [
        // 🔵 진행 바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Slider(
                value: 0.3, // 예시 값
                onChanged: (value) {},
                activeColor: Colors.white,
                inactiveColor: Colors.white38,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("0:38", style: TextStyle(color: Colors.white70)),
                  Text("-1:18", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 🔵 컨트롤 버튼 (이전, 재생/일시정지, 다음)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 36,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 64,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
