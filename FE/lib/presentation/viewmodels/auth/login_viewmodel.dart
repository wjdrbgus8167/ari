import 'package:ari/domain/entities/token.dart';
import 'package:ari/domain/usecases/auth/auth_usecase.dart';
import 'package:ari/domain/usecases/user/user_usecase.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// 로그인 상태 관리 클래스
class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;

  LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 로그인 뷰모델
class LoginViewModel extends StateNotifier<LoginState> {
  final Ref ref;
  final LoginUseCase loginUseCase;
  final SaveTokensUseCase saveTokensUseCase;
  final AuthStateNotifier authStateNotifier;
  final GetUserProfileUseCase getUserProfileUseCase;

  LoginViewModel({
    required this.ref,
    required this.loginUseCase,
    required this.saveTokensUseCase,
    required this.getUserProfileUseCase,
    required this.authStateNotifier,
  }) : super(LoginState());

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  bool validateInputs() {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessage: '이메일과 비밀번호를 입력해주세요');
      return false;
    }
    return true;
  }

  Future<bool> login() async {

    state = state.copyWith(isLoading: true, errorMessage: null);
    await authStateNotifier.login(state.email, state.password);
    state = state.copyWith(isLoading: false);
    await authStateNotifier.refreshAuthState(); 
    await ref.read(userProvider.notifier).refreshUserInfo();

    return true;
  }

  // 소셜 로그인 시작 (구글)
  Future<void> startGoogleLogin() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 백엔드 엔드포인트 URL
      const googleAuthUrl = 'api/v1/oauth2/authorization/google';
      
      // URL 열기
      if (await canLaunchUrl(Uri.parse(googleAuthUrl))) {
        await launchUrl(
          Uri.parse(googleAuthUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('구글 로그인을 시작할 수 없습니다');
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '구글 로그인을 시작하는 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  // 리다이렉트 처리
  Future<bool> handleSocialLoginCallback(Token token) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 백엔드가 제공한 토큰 처리
      await saveTokensUseCase(token);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '소셜 로그인 처리 중 오류가 발생했습니다: ${e.toString()}',
      );
      return false;
    }
  }
}