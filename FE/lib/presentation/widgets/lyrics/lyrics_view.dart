import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'lyrics_header.dart';
import 'lyrics_content.dart';
import '../playback/playback_controls.dart';

class LyricsView extends StatefulWidget {
  final String albumCoverUrl;
  final String trackTitle;
  final VoidCallback onToggle; // 창 닫기 기능 유지

  const LyricsView({
    Key? key,
    required this.albumCoverUrl,
    required this.trackTitle,
    required this.onToggle,
  }) : super(key: key);

  @override
  _LyricsViewState createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  Color _dominantColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _extractDominantColor();
  }

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
        // 모달 하단 시트를 전체 화면에 가깝게 표시하여 배경의 재생 인터페이스가 보이지 않도록 함
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

  Widget _buildLyricsScreen() {
    return Container(
      width: double.infinity,
      // 높이를 전체 화면으로 설정하여 재생 인터페이스가 보이지 않도록 함
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: _dominantColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          LyricsHeader(trackTitle: widget.trackTitle),
          const SizedBox(height: 20),
          Expanded(child: LyricsContent(lyrics: "가사 줄 1\n가사 줄 2\n가사 줄 3\n")),
          const SizedBox(height: 20),
          PlaybackControls(onToggle: widget.onToggle),
          const SizedBox(height: 10),
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 36,
              color: Colors.white70,
            ),
            onPressed: widget.onToggle,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
