import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/sign_up_request.dart';

/// 데이터를 받아오는 data부분에서 데이터소스를 동작시켜 데이터를 받아온다.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> signUp(String email, String nickname, String password) async {
    final userModel = SignUpRequest(
      email: email,
      nickname: nickname,
      password: password,
    );
    
    return await remoteDataSource.signUp(userModel);
  }
}