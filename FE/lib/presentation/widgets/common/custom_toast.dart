import 'package:flutter/material.dart';
import 'package:ari/core/constants/app_colors.dart';

class CustomToast {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      _removeToast();

      final overlay = Overlay.of(context, rootOverlay: true);
      if (overlay == null) return;

      final overlayEntry = OverlayEntry(
        builder: (context) => _ToastOverlay(message: message, onDismiss: _removeToast),
      );

      _currentToast = overlayEntry;
      overlay.insert(overlayEntry);

      Future.delayed(duration, () {
        _removeToast();
      });
    });
  }

  static void _removeToast() {
    _currentToast?.remove();
    _currentToast = null;
  }

  static OverlayEntry? _currentToast;
}

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
  late double _keyboardHeight;
  late double _screenWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    
    // 키보드 높이 계산 (viewInsets 사용)
    _keyboardHeight = mediaQuery.viewInsets.bottom;
    _screenWidth = mediaQuery.size.width;
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );

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
      // 키보드 높이 위로 토스트 배치
      bottom: _keyboardHeight + 16, 
      left: _screenWidth * 0.125,
      right: _screenWidth * 0.125,
      child: GestureDetector(
        onTap: () {
          _animationController.reverse().then((_) {
            widget.onDismiss();
          });
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightPurple.withAlpha(180),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
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
}

extension ToastExtension on BuildContext {
  void showToast(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    CustomToast.show(context: this, message: message, duration: duration);
  }
}