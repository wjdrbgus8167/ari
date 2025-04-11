import 'package:flutter/material.dart';

/// 장르 카테고리 카드 위젯
/// 그라데이션 배경, 장르 이름 표시
class GenreCard extends StatelessWidget {
  final String title;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const GenreCard({
    super.key,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // 장르 이름
            Positioned(
              left: 16,
              top: 16,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
