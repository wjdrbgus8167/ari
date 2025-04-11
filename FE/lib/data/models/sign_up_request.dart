/// data/models : 데이터 전송 객체 정의
/// 
class SignUpRequest {
  final String email;
  final String nickname;
  final String password;

  SignUpRequest({
    required this.email,
    required this.nickname,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nickname': nickname,
      'password': password,
    };
  }
}