import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/common/button_large.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // 로그인 상태 감시
    final loginState = ref.watch(loginViewModelProvider);
    final viewModel = ref.read(loginViewModelProvider.notifier);

    // 상태 변화 리스너 추가
    ref.listen(loginViewModelProvider, (previous, next) {
      // 오류 메시지가 있을 때 토스트 표시
      if (next.errorMessage != null) {
        context.showToast(next.errorMessage!);
      }
    });


    return Scaffold(
      // 배경색 검정
      backgroundColor: Colors.black,
      // 앱바: HomeScreen과 동일한 스타일 + 커스텀 뒤로가기 버튼
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        // 뒤로가기 버튼: 클릭 시 이전 화면으로 이동
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset(
            'assets/images/prev_btn.png',
            width: 40,
            height: 40,
          ),
        ),
        title: Image.asset('assets/images/logo.png', height: 40),
        elevation: 0,
      ),
      // 로그인 폼 포함
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 화면 상단 로그인 텍스트
            const Text(
              '로그인',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // 이메일 입력 필드
            TextField(
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelText: '이메일',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => viewModel.setEmail(value),
            ),
            const SizedBox(height: 16),
            // 비밀번호 입력 필드
            TextField(
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => viewModel.setPassword(value),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 16),

            // 로그인 버튼
            ButtonLarge(
              text: loginState.isLoading ? '로그인 중...' : '로그인하기',
              onPressed:
                  loginState.isLoading
                      ? null // 로딩 중일 때는 버튼 비활성화
                      : () async {
                          // 입력 유효성 검사
                          if (!viewModel.validateInputs()) {
                            return; // 유효성 검사 실패 시 진행하지 않음 (에러 메시지는 이미 설정됨)
                          }
                          
                          // 로그인 시도
                          final success = await viewModel.login();
                          print('success: $success'); // 로그인 성공 여부 출력
                          if (success) {
                            // 로그인 성공 시 홈 화면으로 이동
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.home, 
                                (route) => false, // 이전 화면들을 모두 제거
                              );
                            }
                          }
                        },
            ),
            const SizedBox(height: 16),
            // 구글 계정으로 로그인 버튼
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  width: 24,
                  height: 24,
                ),
                onPressed:
                    loginState.isLoading
                        ? null // 로딩 중일 때는 버튼 비활성화
                        : () async {
                            // 구글 로그인 로직 구현
                            await viewModel.startGoogleLogin();
                            // 결과는 리다이렉트와 콜백으로 처리되므로 여기서 추가 로직 필요 없음
                          },
                label: const Text(
                  '구글 계정으로 로그인하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '아직 회원이 아니신가요? ',
                  style: TextStyle(color: Colors.white),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.signUp);
                  },
                  child: const Text(
                    '회원가입 하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}