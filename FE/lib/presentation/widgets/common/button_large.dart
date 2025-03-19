import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 대형 버튼 위젯
///
/// [text] - 버튼에 표시될 텍스트
/// [onPressed] - 버튼 클릭 시 실행될 콜백
/// [backgroundColor] - 버튼 배경색 (기본값: 흰색)
/// [textColor] - 버튼 텍스트 색상 (기본값: 검정색)
/// [borderColor] - 버튼 테두리 색상 (기본값: null - 테두리 없음)
/// [borderWidth] - 버튼 테두리 두께 (기본값: 1.0)
/// [isEnabled] - 버튼 활성화 여부 (기본값: true)
/// [borderRadius] - 버튼 모서리 둥글기 (기본값: 30.0)
/// [height] - 버튼 높이 (기본값: 56.0)
/// [width] - 버튼 너비 (기본값: double.infinity)
/// [isLoading] - 로딩 상태 표시 여부 (기본값: false)

class ButtonLarge extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double borderWidth;
  final bool isEnabled;
  final double borderRadius;
  final double height;
  final double? width;
  final bool isLoading;

  const ButtonLarge({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.borderColor,
    this.borderWidth = 1.0,
    this.isEnabled = true,
    this.borderRadius = 30.0,
    this.height = 56.0,
    this.width = double.infinity,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.6),
          disabledForegroundColor: textColor.withOpacity(0.6),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side:
                borderColor != null
                    ? BorderSide(color: borderColor!, width: borderWidth)
                    : BorderSide.none,
          ),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
                : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? textColor : textColor.withOpacity(0.6),
                  ),
                ),
      ),
    );
  }
}

/// 참고
/// 버튼 변형(사용) 예시
class PrimaryButtonLarge extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final double? width;

  const PrimaryButtonLarge({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonLarge(
      text: text,
      onPressed: onPressed,
      backgroundColor:
          Colors.white, // 주 색깔을 사용하려면 Theme.of(context).primaryColor로
      textColor: Colors.black,
      isEnabled: isEnabled,
      isLoading: isLoading,
      width: width,
    );
  }
}
