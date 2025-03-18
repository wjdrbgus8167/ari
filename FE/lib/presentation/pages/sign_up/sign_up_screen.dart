import 'package:ari/presentation/widgets/sign_up/sign_up_button.dart';
import 'package:ari/presentation/widgets/sign_up/sign_up_text_field.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/pages/home/home_screen.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({Key? key}) : super(key: key);

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
                  SignUpButton(
                    text: '회원가입 완료하기',
                    onTap: () async {
                      if (await viewModel.signUp()) {
                        // 회원가입 성공, 다음 화면으로 이동
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const HomeScreen())
                        );
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