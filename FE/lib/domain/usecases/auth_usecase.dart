import 'package:ari/domain/entities/token.dart';
import 'package:ari/domain/repositories/auth_repository.dart';

// 인증 상태를 받을 수 있음음
class GetAuthStatusUseCase {
  final AuthRepository repository;

  GetAuthStatusUseCase(this.repository);

  Future<bool> call() => repository.isAuthenticated();
}

// 토큰 저장 로직 작동동
class SaveTokensUseCase {
  final AuthRepository repository;

  SaveTokensUseCase(this.repository);

  Future<void> call(Token tokens) => repository.saveTokens(tokens);
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<void> call(Token tokens) => repository.login(tokens);
}

// 로그아웃 유스케이스. 토큰 제거 로직 작동
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() => repository.clearTokens();
}

// refreshToken 로직 작동동
class RefreshTokensUseCase {
  final AuthRepository repository;

  RefreshTokensUseCase(this.repository);

  Future<Token?> call() => repository.refreshTokens();
}

// 토큰 조회 로직
class GetTokensUseCase {
  final AuthRepository repository;

  GetTokensUseCase(this.repository);

  Future<Token?> call() => repository.getTokens();
}