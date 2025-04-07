import 'package:ari/presentation/routes/app_router.dart';
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
        return AlertDialog(
          title: const Text("로그인이 필요합니다"),
          content: const Text("이 기능을 이용하려면 로그인해야 합니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text("로그인하기"),
            ),
          ],
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
