import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'lyrics_header.dart';
import 'lyrics_content.dart';
import '../playback/playback_controls.dart';

class LyricsView extends StatefulWidget {
  final String albumCoverUrl;
  final String trackTitle;
  final String lyrics;
  final VoidCallback onToggle; // 창 닫기 기능 유지

  const LyricsView({
    Key? key,
    required this.albumCoverUrl,
    required this.trackTitle,
    required this.lyrics,
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
      height: MediaQuery.of(context).size.height,
      // Stack을 사용하여 배경 이미지와 블러 효과, 그리고 콘텐츠를 겹쳐서 표시합니다.
      child: Stack(
        children: [
          // 배경 이미지: albumCoverUrl이 있으면 네트워크 이미지, 없으면 기본 asset 이미지 사용
          Positioned.fill(
            child:
                widget.albumCoverUrl.isNotEmpty
                    ? Image.network(widget.albumCoverUrl, fit: BoxFit.cover)
                    : Image.asset(
                      'assets/images/default_album_cover.png',
                      fit: BoxFit.cover,
                    ),
          ),
          // 배경에 블러 효과와 어두운 오버레이 적용
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),
          // 콘텐츠 영역
          Column(
            children: [
              const SizedBox(height: 20),
              LyricsHeader(trackTitle: widget.trackTitle),
              const SizedBox(height: 20),
              Expanded(child: LyricsContent(lyrics: widget.lyrics)),
              const SizedBox(height: 20),
              PlaybackControls(onToggle: widget.onToggle),
            ],
          ),
        ],
      ),
    );
  }
}
