import 'package:ari/core/utils/auth_interceptor.dart';
import 'package:ari/data/datasources/auth_local_data_source.dart';
import 'package:ari/data/datasources/auth_remote_data_source.dart';
import 'package:ari/data/repositories/auth_repository_impl.dart';
import 'package:ari/domain/repositories/auth_repository.dart';
import 'package:ari/domain/usecases/auth_usecase.dart';
import 'package:ari/presentation/viewmodels/auth/login_viewmodel.dart';
import 'package:ari/presentation/viewmodels/auth/sign_up_viewmodel.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(storage: ref.watch(secureStorageProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(refreshUrl: '/api/v1/auth/refresh', ref: ref);
});

final getAuthStatusUseCaseProvider = Provider<GetAuthStatusUseCase>((ref) {
  return GetAuthStatusUseCase(ref.watch(authRepositoryProvider));
});

final getTokensUseCaseProvider = Provider<GetTokensUseCase>((ref) {
  return GetTokensUseCase(ref.watch(authRepositoryProvider));
});

final saveTokensUseCaseProvider = Provider<SaveTokensUseCase>((ref) {
  return SaveTokensUseCase(ref.watch(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final refreshTokensUseCaseProvider = Provider<RefreshTokensUseCase>((ref) {
  return RefreshTokensUseCase(ref.watch(authRepositoryProvider));
});

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<bool>>((ref) {
      return AuthStateNotifier(
        getAuthStatusUseCase: ref.watch(getAuthStatusUseCaseProvider),
        loginUseCase: ref.watch(loginUseCaseProvider),
        logoutUseCase: ref.watch(logoutUseCaseProvider),
      );
    });

// 인증 인터셉터 제공자. 인증 인터셉터는 request시 자동으로 authorization 삽입하는 역할을 함
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(
    refreshTokensUseCase: ref.watch(refreshTokensUseCaseProvider),
    getAuthStatusUseCase: ref.watch(getAuthStatusUseCaseProvider),
    getTokensUseCase: ref.watch(getTokensUseCaseProvider),
    dio: ref.watch(dioProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

final signUpViewModelProvider =
    StateNotifierProvider<SignUpViewModel, SignUpState>((ref) {
      return SignUpViewModel(signUpUseCase: ref.watch(signUpUseCaseProvider));
    });

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
      return LoginViewModel(
        loginUseCase: ref.read(loginUseCaseProvider),
        saveTokensUseCase: ref.read(saveTokensUseCaseProvider),
        authStateNotifier: ref.read(authStateProvider.notifier),
      );
    });

// 유저 로그인 여부를 관리
class AuthStateNotifier extends StateNotifier<AsyncValue<bool>> {
  final GetAuthStatusUseCase getAuthStatusUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthStateNotifier({
    required this.getAuthStatusUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(const AsyncValue.loading()) {
    print('[AuthStateNotifier] 초기화 시작');
    _initialize();
  }

  Future<void> _initialize() async {
    print('[AuthStateNotifier] _initialize 호출됨');
    state = const AsyncValue.loading();
    try {
      print('[AuthStateNotifier] 인증 상태 확인 중...');
      final isAuthenticated = await getAuthStatusUseCase();
      print('[AuthStateNotifier] 인증 상태 확인 결과: $isAuthenticated');
      state = AsyncValue.data(isAuthenticated);
    } catch (e, stackTrace) {
      print('[AuthStateNotifier] 인증 상태 확인 오류: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 인증 상태 재확인 메서드 추가 (public으로 외부에서 호출 가능)
  Future<void> refreshAuthState() async {
    print('[AuthStateNotifier] refreshAuthState 호출됨');
    await _initialize();
  }

  Future<void> login(String email, String password) async {
    print('[AuthStateNotifier] 로그인 시도: $email');
    try {
      await loginUseCase(email, password);
      print('[AuthStateNotifier] 로그인 성공');
      state = const AsyncValue.data(true);
    } catch (e, stackTrace) {
      print('[AuthStateNotifier] 로그인 실패: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> logout() async {
    print('[AuthStateNotifier] 로그아웃 시도');
    state = const AsyncValue.loading();
    try {
      await logoutUseCase();
      print('[AuthStateNotifier] 로그아웃 성공');
      state = const AsyncValue.data(false);
    } catch (e, stackTrace) {
      print('[AuthStateNotifier] 로그아웃 실패: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 현재 상태를 로그로 출력하는 도우미 메서드
  void logCurrentState() {
    print('[AuthStateNotifier] 현재 상태: $state');
    state.when(
      data: (isLoggedIn) => print('[AuthStateNotifier] 로그인 상태: $isLoggedIn'),
      loading: () => print('[AuthStateNotifier] 상태: 로딩 중'),
      error: (e, _) => print('[AuthStateNotifier] 상태: 오류 - $e'),
    );
  }
}
