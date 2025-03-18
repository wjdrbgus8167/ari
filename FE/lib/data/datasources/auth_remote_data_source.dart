import '../models/user_model.dart';
/// datasources는 데이터의 입출력(api 호출과 처리)을을 담당합니다.
/// 클린 아키텍처의 장점은 의존과 구분이 명확하기 때문에 테스트가 편함. 이런 식으로 api 연결 부분을 최소화하는 것도 가능함.
abstract class AuthRemoteDataSource {
  Future<void> signUp(UserModel userModel);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> signUp(UserModel userModel) async {
    // API 호출 구현
    
    // 임시 구현 (나중에 실제 API 호출로 대체)
    await Future.delayed(const Duration(seconds: 1));
    return;
  }
}
