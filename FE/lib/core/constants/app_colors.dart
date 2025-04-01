import 'package:flutter/material.dart';

class AppColors {
  static const Color lightGreen = Color(0xFFCAFFF5);
  static const Color mediumGreen = Color(0xFF36DFBF);
  static const Color darkGreen = Color(0xFF1FBAA2);
  static const Color lightPurple = Color(0xFFE5BCFF);
  static const Color mediumPurple = Color(0xFFC76BFF);
  static const Color darkPurple = Color(0xFF8A4FFF);

  // 보라 그라데이션 - 가로
  static const LinearGradient purpleGradientHorizontal = LinearGradient(
    colors: [lightPurple, mediumPurple, darkPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // 보라 그라데이션 - 세로
  static const LinearGradient purpleGradientVertical = LinearGradient(
    colors: [lightPurple, mediumPurple, darkPurple],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 초록 그라데이션 - 가로
  static const LinearGradient greenGradientHorizontal = LinearGradient(
    colors: [lightGreen, mediumGreen, darkGreen],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  // 초록 그라데이션 - 세로
  static const LinearGradient greenGradientVertical = LinearGradient(
    colors: [lightGreen, mediumGreen, darkGreen],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient blueToMintGradient = LinearGradient(
    colors: [
      Color(0xFF2CA0FF),  // 밝은 파란색
      Color(0xFF7DDCFF),  // 하늘색
      Color(0xFF5DEDFA),  // 청록색
      Color(0xFFCAFFFB),  // 밝은 민트색
    ],
    stops: [0.0, 0.33, 0.65, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [
      Color(0xFFDE85FC),  // 연한 보라색
      Color(0xFFC78BF9),  // 중간 보라색
      Color(0xFFC78BF9),  // 중간 보라색 (반복)
      Color(0xFF8A4FFF),  // 진한 보라색
    ],
    stops: [0.0, 0.44, 0.44, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
