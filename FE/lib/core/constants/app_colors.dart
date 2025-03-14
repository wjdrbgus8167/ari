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
}
