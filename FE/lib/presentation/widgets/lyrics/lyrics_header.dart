import 'package:flutter/material.dart';

class LyricsHeader extends StatelessWidget {
  final String trackTitle;

  const LyricsHeader({super.key, required this.trackTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Image.asset(
              'assets/images/down_btn.png',
              width: 40,
              height: 40,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              trackTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 50), // 오른쪽 균형 맞추기
        ],
      ),
    );
  }
}
