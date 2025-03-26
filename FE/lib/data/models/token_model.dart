import 'package:ari/domain/entities/token.dart';

class TokenModel extends Token {
  TokenModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  factory TokenModel.fromEntity(Token entity) {
    return TokenModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
    );
  }
}