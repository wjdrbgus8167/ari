import '../../domain/entities/user.dart';

/// data/models : 데이터 전송 객체 정의
/// 
class UserModel extends User {
  UserModel({
    required super.email,
    required super.nickname,
    required super.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      nickname: json['nickname'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nickname': nickname,
      'password': password,
    };
  }
}