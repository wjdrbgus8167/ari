import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/common/custom_dialog.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'package:ari/providers/user_provider.dart';

/// 로그인 상태를 확인하고 로그인이 필요한 경우 다이얼로그를 표시한 후
/// 로그인 화면으로 이동시키는 유틸리티 함수
///
/// [context] : 현재 BuildContext
/// [ref] : Riverpod의 WidgetRef
/// [onLoginSuccess] : 로그인 성공 후 실행할 콜백 함수
/// [returns] : 로그인 상태 여부 (true: 이미 로그인됨, false: 로그인 필요)
Future<bool> checkLoginAndRedirect(
  BuildContext context,
  WidgetRef ref, {
  VoidCallback? onLoginSuccess,
}) async {
  // 현재 로그인 상태 확인
  final authState = ref.read(authStateProvider);

  // 로그인 되어 있는 경우
  final isLoggedIn = authState.maybeWhen(
    data: (isAuthenticated) => isAuthenticated,
    orElse: () => false,
  );

  if (isLoggedIn) {
    // 이미 로그인된 경우 콜백 실행 후 true 반환
    if (onLoginSuccess != null) {
      onLoginSuccess();
    }
    return true;
  }

  // 로그인 필요한 경우 다이얼로그 표시
  final result = await context.showCustomDialog(
    title: '로그인 필요',
    content: '이 기능을 사용하려면 로그인이 필요합니다.',
    confirmText: '로그인',
    cancelText: '취소',
    confirmButtonColor: Colors.blue,
  );

  // 로그인 버튼 클릭 시 로그인 화면으로 이동
  if (result == true) {
    if (context.mounted) {
      // 로그인 화면으로 이동
      final loggedIn = await Navigator.of(context).pushNamed(AppRoutes.login);

      // 로그인 성공 후 돌아온 경우
      if (loggedIn == true && context.mounted) {
        // 사용자 정보 새로고침 (토큰 변경 반영)
        await ref.read(userProvider.notifier).refreshUserInfo();

        // 콜백 실행
        if (onLoginSuccess != null) {
          onLoginSuccess();
        }
        return true;
      }
    }
  }

  return false;
}
