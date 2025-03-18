import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'lyrics_header.dart';
import 'lyrics_content.dart';
import '../playback/playback_controls.dart';

class LyricsView extends StatefulWidget {
  final String albumCoverUrl;
  final String trackTitle;
  final VoidCallback onToggle; // ✅ 추가

  const LyricsView({
    Key? key,
    required this.albumCoverUrl,
    required this.trackTitle,
    required this.onToggle, // ✅ 추가
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
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: _dominantColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          LyricsHeader(trackTitle: widget.trackTitle),
          const SizedBox(height: 20),
          LyricsContent(lyrics: "가사 줄 1\n가사 줄 2\n가사 줄 3\n"),
          const SizedBox(height: 20),
          PlaybackControls(
            onToggle: widget.onToggle, // ✅ onToggle 전달
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
