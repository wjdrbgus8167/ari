import 'package:ari/data/models/login_request.dart';
import 'package:ari/domain/entities/token.dart';
import 'package:ari/domain/repositories/auth_repository.dart';
import 'package:ari/data/datasources/auth_local_data_source.dart';
import 'package:ari/data/datasources/auth_remote_data_source.dart';
import 'package:ari/data/models/token_model.dart';
import 'package:ari/data/models/sign_up_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<bool> isAuthenticated() async {
    return await localDataSource.hasTokens();
  }

  @override
  Future<Token?> getTokens() async {
    return await localDataSource.getTokens();
  }

  @override
  Future<void> saveTokens(Token tokens) async {
    final tokenModel = TokenModel.fromEntity(tokens);
    await localDataSource.saveTokens(tokenModel);
  }

  @override
  Future<void> clearTokens() async {
    await localDataSource.clearTokens();
  }

  @override
  Future<Token?> refreshTokens() async {
    //토큰을 가져온다.
    final currentTokens = await localDataSource.getTokens();
    if (currentTokens == null) {
      return null;
    }

    // refresh dataSource를 구현하여 새로운 토큰을 받는다.
    final newTokens = await remoteDataSource.refreshTokens(currentTokens.refreshToken);
    if (newTokens != null) {
      // 그 토큰을 저장한다.
      await localDataSource.saveTokens(newTokens);
      return newTokens;
    }
    return null;
  }
  
  @override
  Future<void> signUp(String email, String nickname, String password) async {
    final userModel = SignUpRequest(
      email: email,
      nickname: nickname,
      password: password,
    );
    
    return await remoteDataSource.signUp(userModel);
  }

  @override
  Future<Token?> login(String email, String password) async {
    // refresh dataSource를 구현하여 새로운 토큰을 받는다.
    final newTokens = await remoteDataSource.login(LoginRequest(email: email, password: password));
    if (newTokens != null) {
      // 그 토큰을 저장한다.
      await localDataSource.saveTokens(newTokens);
      return newTokens;
    }
    return null;
  }
}
