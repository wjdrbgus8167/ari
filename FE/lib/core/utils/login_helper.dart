import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/common/custom_dialog.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> checkLoginAndNavigateIfNeeded({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final isLoggedIn = ref.read(isUserLoggedInProvider);

  if (!isLoggedIn) {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return CustomDialog(
          title: '로그인 필요',
          content: '로그인이 필요합니다. 로그인 화면으로 이동하시겠습니까?',
          confirmText: '로그인하기',
          cancelText: '취소',
          confirmButtonColor: Colors.blue,
          cancelButtonColor: Colors.grey,
          // onConfirm에서 로그인 화면으로 이동하지 않고, 단순히 true 반환
          onConfirm: null, // null을 전달하여 내부 동작만 실행하도록 함
          // onCancel도 null로 설정하여 내부 동작만 실행하도록 함
          onCancel: null,
        );
      },
    );

    if (result == true) {
      Navigator.pushNamed(context, AppRoutes.login);
    }

    return false; // 로그인 상태가 아니므로 false 반환
  }

  return true; // 로그인 되어있음
}
