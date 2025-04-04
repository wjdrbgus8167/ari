import 'package:flutter/material.dart';
import 'package:ari/domain/entities/track.dart';
import 'dart:math';

class TrackListTile extends StatelessWidget {
  final Track track;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleSelection;
  final bool isPlayingIndicator;
  final bool isPausedIndicator;

  const TrackListTile({
    Key? key,
    required this.track,
    required this.isSelected,
    required this.onTap,
    required this.onToggleSelection,
    this.isPlayingIndicator = false,
    this.isPausedIndicator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 재생 중 또는 일시정지인 경우 배경색을 회색으로 설정
    final tileColor =
        (isPlayingIndicator || isPausedIndicator)
            ? Colors.grey[700]
            : Colors.transparent;

    return ListTile(
      tileColor: tileColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onToggleSelection,
            child: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              track.coverUrl ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/default_album_cover.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ],
      ),
      title: Text(
        track.trackTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artistName,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing:
          isPlayingIndicator
              ? const AudioWaveIndicator(isPlaying: true)
              : (isPausedIndicator
                  ? const Icon(
                    Icons.pause_circle_filled,
                    color: Colors.white70,
                    size: 30,
                  )
                  : null),
      onTap: onTap,
    );
  }
}

// AudioWaveIndicator
class AudioWaveIndicator extends StatefulWidget {
  final bool isPlaying;
  final Color waveColor;
  final double height;

  const AudioWaveIndicator({
    Key? key,
    required this.isPlaying,
    this.waveColor = Colors.blue,
    this.height = 20.0,
  }) : super(key: key);

  @override
  _AudioWaveIndicatorState createState() => _AudioWaveIndicatorState();
}

class _AudioWaveIndicatorState extends State<AudioWaveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _heights = [10, 15, 20, 15, 10, 5, 10, 15];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(40, widget.height),
          painter: WaveformPainter(
            heights: _heights,
            progress: _controller.value,
            isPlaying: widget.isPlaying,
            color: widget.waveColor,
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> heights;
  final double progress;
  final bool isPlaying;
  final Color color;

  WaveformPainter({
    required this.heights,
    required this.progress,
    required this.isPlaying,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..strokeWidth = 2.0;

    final barWidth = 3.0;
    final spacing = 2.0;
    final totalBars = heights.length;

    for (var i = 0; i < totalBars; i++) {
      double heightMultiplier =
          isPlaying ? 0.5 + 0.5 * sin(progress * 2 * pi + i * 0.5) : 0.3;

      final barHeight = heights[i] * heightMultiplier;
      final left = i * (barWidth + spacing);
      final top = (size.height - barHeight) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, barHeight),
          const Radius.circular(2.0),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
