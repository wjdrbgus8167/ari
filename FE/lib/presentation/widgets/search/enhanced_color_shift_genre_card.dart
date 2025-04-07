import 'dart:math' as math;
import 'package:ari/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

// 색상 순환 효과 애니메이션 적용
class EnhancedColorShiftGenreCard extends StatefulWidget {
  final String title;
  final Gradient gradient;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const EnhancedColorShiftGenreCard({
    super.key,
    required this.title,
    required this.gradient,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  State<EnhancedColorShiftGenreCard> createState() =>
      _EnhancedColorShiftGenreCardState();
}

class _EnhancedColorShiftGenreCardState
    extends State<EnhancedColorShiftGenreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 각 카드별로 다른 시작점을 가지도록 랜덤 오프셋
  final double _randomOffset = math.Random().nextDouble();

  // 미세한 떠있는 효과를 위한 위치 변수
  double _translateY = 0;

  // 그라디언트 색상 가져오기
  List<Color> get _colors {
    if (widget.gradient is LinearGradient) {
      return (widget.gradient as LinearGradient).colors;
    }
    return [AppColors.mediumPurple, Colors.blue]; // 기본값
  }

  @override
  void initState() {
    super.initState();

    // 7초 주기로 무한 반복하는 애니메이션 컨트롤러
    _controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double animValue = _controller.value;

          // 사인 함수를 이용해 -1.0 ~ 1.0 사이 값 생성 (부드러운 변화)
          final double sineValue =
              math.sin((animValue + _randomOffset) * math.pi * 2) * 0.5 + 0.5;

          // 미세한 부유 효과도 추가 - 색상 변화와 함께 약간의 움직임
          _translateY =
              math.sin((animValue + _randomOffset) * math.pi * 4) *
              2; // 2픽셀 범위 내에서 움직임

          // 그라디언트 색상들의 HSV 값을 조정하여 애니메이션 효과 생성
          List<Color> animatedColors = _generateAnimatedColors(
            _colors,
            sineValue,
          );

          return Transform.translate(
            offset: Offset(0, _translateY),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: animatedColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: widget.borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: animatedColors[0].withValues(
                      alpha: .3,
                    ), // 그림자 색상도 변화
                    blurRadius: 10 + sineValue * 5, // 그림자 크기도 변화
                    spreadRadius: 1,
                    offset: Offset(0, 2 + sineValue * 2),
                  ),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    // 텍스트에 반대 방향 그라디언트 적용하여 색상 변화 강조
                    return LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: .8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black38,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 원래 색상에서 더 뚜렷하게 다른 색상으로 변화시키는 함수
  List<Color> _generateAnimatedColors(
    List<Color> originalColors,
    double factor,
  ) {
    return originalColors.map((color) {
      // HSV 색상 모델로 변환
      HSVColor hsvColor = HSVColor.fromColor(color);

      // 색상 범위 제한을 위한 변수들
      double hueShift = 15.0; // 기본 변화량 15도로 줄임
      double saturationShift = 0.15; // 기본 변화량 15%로 줄임

      // 새로운 색조값 계산
      double newHue;

      // 보라색 계열(HipHop, Jazz)의 경우 빨강/자주색 X. 안예쁨
      // 보라색 계열의 색조 값 범위: 대략 270-330
      if ((hsvColor.hue > 260 && hsvColor.hue < 340)) {
        // 보라색 계열은 파란색 방향으로만 변화하도록 제한
        // 색조값을 줄이는 방향(파란색 방향)으로만 변화
        double direction = -1.0;
        hueShift = 12.0; // 더 작은 변화량
        newHue = (hsvColor.hue + direction * hueShift * factor) % 360;
        // 만약 색조가 빨강 영역(0-30, 330-360)으로 들어가면 조정
        if (newHue < 30 || newHue > 330) {
          newHue = hsvColor.hue; // 원래 색상으로 유지
        }
      } else {
        // 다른 색상은 정상적으로 양방향 변화
        newHue = (hsvColor.hue + hueShift * factor) % 360;
      }

      // 채도(Saturation)를 조정 (최대 15% 변화로 줄임)
      double newSaturation = (hsvColor.saturation + saturationShift * factor)
          .clamp(0.0, 1.0);

      // 명도(Value)도 조정하여 빛나는 효과 (10%로 줄임)
      double newValue = (hsvColor.value + 0.1 * factor).clamp(0.0, 1.0);

      // 새 HSV 색상 생성 후 RGB로 변환하여 반환
      return HSVColor.fromAHSV(
        hsvColor.alpha,
        newHue,
        newSaturation,
        newValue,
      ).toColor();
    }).toList();
  }
}
