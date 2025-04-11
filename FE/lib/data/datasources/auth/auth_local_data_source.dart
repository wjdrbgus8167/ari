import 'package:ari/data/models/token_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<TokenModel?> getTokens();
  Future<void> saveTokens(TokenModel tokens);
  Future<void> clearTokens();
  Future<bool> hasTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';

  AuthLocalDataSourceImpl({required this.storage});

  @override
  Future<TokenModel?> getTokens() async {
    final accessToken = await storage.read(key: accessTokenKey);
    final refreshToken = await storage.read(key: refreshTokenKey);

    if (accessToken != null && refreshToken != null) {
      return TokenModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
    return null;
  }

  @override
  Future<void> saveTokens(TokenModel tokens) async {
    await storage.write(key: accessTokenKey, value: tokens.accessToken);
    await storage.write(key: refreshTokenKey, value: tokens.refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await storage.delete(key: accessTokenKey);
    await storage.delete(key: refreshTokenKey);
  }

  @override
  Future<bool> hasTokens() async {
    final accessToken = await storage.read(key: accessTokenKey);
    return accessToken != null;
  }
}