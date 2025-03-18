import 'package:ari/domain/repositories/auth_repository.dart';

/// usecase의 역할
/// 하나의 특정 비즈니스 작업을 담당
/// 비즈니스 로직 캡슐화 : UI와 데이터 소스와 독립적인 비즈니스 로직 처리
/// 비즈니스 로직을 독립적으로 테스트 가능 
/// 
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<void> execute(String email, String nickname, String password) async {
    return await repository.signUp(email, nickname, password);
  }
}