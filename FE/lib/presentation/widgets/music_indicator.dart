import 'dart:math';
import 'package:flutter/material.dart';

class AudioWaveIndicator extends StatefulWidget {
  final bool isPlaying;
  final Color waveColor;
  final double height;

  const AudioWaveIndicator({
    super.key,
    required this.isPlaying,
    this.waveColor = Colors.blue,
    this.height = 20.0,
  });

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
      // 애니메이션 효과를 위한 높이 변화
      double heightMultiplier =
          isPlaying
              ? 0.5 + 0.5 * sin(progress * 2 * pi + i * 0.5)
              : 0.3; // 재생 중이 아닐 때는 작은 파형

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
