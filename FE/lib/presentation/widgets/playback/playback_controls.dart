import 'package:flutter/material.dart';

class PlaybackControls extends StatelessWidget {
  final VoidCallback onToggle;

  const PlaybackControls({Key? key, required this.onToggle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      color: Colors.black.withOpacity(0.6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔵 재생 진행 바
          Slider(
            value: 0.3,
            onChanged: (value) {},
            activeColor: Colors.white,
            inactiveColor: Colors.white38,
          ),

          // 🔵 현재 시간 / 전체 시간 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "1:12",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  "3:45",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 🔵 재생 컨트롤 (셔플, 이전, 재생/정지, 다음, 반복)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shuffle,
                  color: Colors.white70,
                  size: 28,
                ),
                onPressed: () {},
              ),
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
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 64,
                ),
                onPressed: onToggle,
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.repeat, color: Colors.white70, size: 28),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
