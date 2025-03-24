import 'package:flutter/material.dart';

class CustomToast {
  /// [context] - 토스트 표시할 컨텍스트
  /// [message] - 메시지
  /// [type] - 토스트 종류 (성공 경고)
  /// [duration] - 토스트가 표시되는 시간 (기본 2초)
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    // 이전 토스트 제거
    _removeToast();

    // Overlay 위에 토스트 표시
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => _ToastOverlay(
            message: message,
            onDismiss: _removeToast,
          ),
    );

    // 전역 변수에 현재 토스트 저장
    _currentToast = overlayEntry;

    // 토스트 표시
    overlay.insert(overlayEntry);

    // n분 후 토스트 자동 없어짐
    Future.delayed(duration, () {
      _removeToast();
    });
  }

  /// 현재 토스트 제거
  static void _removeToast() {
    _currentToast?.remove();
    _currentToast = null;
  }

  // 현재 토스트 저장용 변수
  static OverlayEntry? _currentToast;
}

/// 토스트 오버레이 위젯
class _ToastOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ToastOverlay({required this.message, required this.onDismiss});

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // fade 애니메이션
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );

    // 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).viewPadding.bottom + 50,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: () {
          // 터치하면 토스트 없어짐
          _animationController.reverse().then((_) {
            widget.onDismiss();
          });
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 배경색
  Color _getBackgroundColor() {
    return Colors.black;
  }
}


// 확장 메서드(다이얼로그 쉽게 호출 가능)
// 원본 클래스 수정하지 않아도 기능 확장 가능
extension ToastExtension on BuildContext {
  // 토스트 표시
  void showToast(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    CustomToast.show(
      context: this,
      message: message,
      duration: duration,
    );
  }
}