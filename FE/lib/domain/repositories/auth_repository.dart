import 'package:ari/domain/entities/token.dart';

/// Future 객체 : 플러터의 비동기 작업 처리. 미래의 결과값을 표현해줌.(UI 차단을 막기 위함함)
/// 레포지토리 인터페이스. 데이터 접근 로직을 담고 있음
/// Repository 패턴의 주요 특징
/// 데이터의 출처를 숨김 (데이터의 출처가 중요하지 않아짐)
/// 데이터 작업만 관리
abstract class AuthRepository {
  // 회원가입
  Future<void> signUp(String email, String nickname, String password);

  // 인증
  Future<bool> isAuthenticated();
  Future<Token?> getTokens();
  Future<void> saveTokens(Token tokens);
  Future<void> clearTokens();
  Future<Token?> refreshTokens();
  Future<Token?> login();
}