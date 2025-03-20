/// User 클래스 정의. 도메인 모델 제공
/// 도메인 레이어는 의존성이 없음음
class User {
  final String id; // 사용자 식별자 추가
  final String email;
  final String nickname;
  final String password; 
  final String? profileImageUrl; // 명확한 이름으로 변경

  const User({ // const 생성자로 변경
    required this.id,
    required this.email,
    required this.nickname,
    required this.password,
    this.profileImageUrl,
  });
}