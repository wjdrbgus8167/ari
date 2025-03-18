/// User 클래스 정의. 도메인 모델 제공
/// 도메인 레이어는 의존성이 없음음
class User {
  final String email;
  final String nickname;
  final String password;

  User({
    required this.email,
    required this.nickname,
    required this.password,
  });
}