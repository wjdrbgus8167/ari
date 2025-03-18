// SignUpState 정의
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpState {
  final String email;
  final String nickname;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final String? errorMessage;

  SignUpState({
    this.email = '',
    this.nickname = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.errorMessage,
  });

  SignUpState copyWith({
    String? email,
    String? nickname,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SignUpState(
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// StateNotifier로 변경된 ViewModel
class SignUpViewModel extends StateNotifier<SignUpState> {
  // final SignUpUseCase signUpUseCase;
  
  SignUpViewModel() : super(SignUpState());
  
  void setEmail(String value) {
    state = state.copyWith(email: value);
  }
  
  void setNickname(String value) {
    state = state.copyWith(nickname: value);
  }
  
  void setPassword(String value) {
    state = state.copyWith(password: value);
  }
  
  void setConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value);
  }
  
  bool validateInputs() {
    if (state.email.isEmpty || state.nickname.isEmpty || state.password.isEmpty || state.confirmPassword.isEmpty) {
      state = state.copyWith(errorMessage: '모든 필드를 입력해주세요');
      return false;
    }
    
    if (state.password != state.confirmPassword) {
      state = state.copyWith(errorMessage: '비밀번호가 일치하지 않습니다');
      return false;
    }
    
    return true;
  }
  
  Future<bool> signUp() async {
    if (!validateInputs()) {
      return false;
    }
    return true;
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // await signUpUseCase.execute(state.email, state.nickname, state.password);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '회원가입 중 오류가 발생했습니다: ${e.toString()}'
      );
      return false;
    }
  }
}