import 'package:ari/domain/entities/profile.dart';
import 'package:ari/domain/entities/user.dart';

/// JWT 토큰에서 파싱한 정보를 저장, 관리
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.nickname,
    super.password = '', // 비밀번호는 토큰에서 오지 않음
    super.profileImageUrl,
  });

  /// JSON 데이터에서 UserModel 객체 생성
  /// [json] 사용자 데이터를 담은 맵
  /// 반환: UserModel 인스턴스
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['memberId'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      password: '', // JSON에서는 비밀번호를 포함하지 않음
      profileImageUrl: json['profileImageUrl'],
    );
  }

  /// JWT 토큰 페이로드에서 UserModel 객체 생성
  /// [payload] JWT 토큰의 페이로드 부분 (userId와 email만 포함)
  factory UserModel.fromJwtPayload(Map<String, dynamic> payload) {
    return UserModel(
      id: payload['userId']?.toString() ?? '',
      // email 필드가 있으면 사용, 없으면 sub 필드에서 이메일 추출
      email: payload['email']?.toString() ?? payload['sub']?.toString() ?? '',
      nickname: '', // 토큰에 닉네임이 없으므로 빈 문자열 설정
      password: '', // JWT에서는 비밀번호를 포함하지 않음
      profileImageUrl: null, // 토큰에 프로필 이미지 URL이 없음
    );
  }

  /// User 객체를 JSON으로 변환
  /// 반환: 사용자 정보를 담은 Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }

  /// User 엔티티에서 UserModel 생성
  /// [user] User 엔티티 인스턴스
  /// 반환: 엔티티로부터 생성된 UserModel 인스턴스
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      nickname: user.nickname,
      password: user.password,
      profileImageUrl: user.profileImageUrl,
    );
  }

  factory UserModel.fromProfileAndEmail(Profile profile, String email) {
    return UserModel(
      id: profile.memberId.toString(),
      email: email,
      nickname: profile.nickname,
      password: '',
      profileImageUrl: profile.profileImageUrl,
    );
  }

  /// UserModel 복사본 생성 (정보 업데이트 시 사용)
  /// 변경할 필드만 인자로 전달하면 나머지는 기존 값 유지
  /// 반환: 새로운 UserModel 인스턴스
  UserModel copyWith({
    String? id,
    String? email,
    String? nickname,
    String? password,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      password: password ?? this.password,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
