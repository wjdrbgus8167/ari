// lib/utils/app_lifecycle_observer.dart
import 'package:flutter/widgets.dart';
import 'dart:developer' as dev;

/// 앱 생명주기 관찰자 클래스
class AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  final VoidCallback? onInactive;
  final VoidCallback? onPaused;
  
  AppLifecycleObserver({
    required this.onResume,
    this.onInactive,
    this.onPaused,
  });
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        dev.log('[AppLifecycleObserver] 앱 상태: resumed');
        onResume();
        break;
      case AppLifecycleState.inactive:
        dev.log('[AppLifecycleObserver] 앱 상태: inactive');
        onInactive?.call();
        break;
      case AppLifecycleState.paused:
        dev.log('[AppLifecycleObserver] 앱 상태: paused');
        onPaused?.call();
        break;
      default:
        break;
    }
  }
}