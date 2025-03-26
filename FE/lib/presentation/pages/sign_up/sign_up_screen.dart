import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/common/button_large.dart';
import 'package:ari/presentation/widgets/sign_up/sign_up_text_field.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상태 관찰
    final signUpState = ref.watch(signUpViewModelProvider);
    // ViewModel 인스턴스에 접근
    final viewModel = ref.read(signUpViewModelProvider.notifier);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 회원가입 제목
                  const Text(
                    '회원가입',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 58),
                  
                  // 이메일 입력 필드
                  SignUpTextField(
                    hintText: '이메일',
                    onChanged: viewModel.setEmail,
                  ),
                  const SizedBox(height: 14),
                  
                  // 닉네임 입력 필드
                  SignUpTextField(
                    hintText: '닉네임',
                    onChanged: viewModel.setNickname,
                  ),
                  const SizedBox(height: 14),
                  
                  // 비밀번호 입력 필드
                  SignUpTextField(
                    hintText: '비밀번호',
                    obscureText: true,
                    onChanged: viewModel.setPassword,
                  ),
                  const SizedBox(height: 14),
                  
                  // 비밀번호 확인 필드
                  SignUpTextField(
                    hintText: '비밀번호 확인',
                    obscureText: true,
                    onChanged: viewModel.setConfirmPassword,
                  ),
                  const SizedBox(height: 14),
                  
                  // 에러 메시지 표시
                  if (signUpState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        signUpState.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // 회원가입 버튼
                  ButtonLarge(
                    text: '회원가입 완료하기',
                    onPressed: () async {
                      if (await viewModel.signUp()) {
                        // 잠시 후 로그인 화면으로 이동
                        Navigator.of(context).pushNamed(AppRoutes.login);
                      }
                    },
                    isLoading: signUpState.isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}