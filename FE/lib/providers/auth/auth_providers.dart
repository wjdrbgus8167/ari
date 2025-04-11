// 인증 관련 모든 의존성 제공 및 인증상태(로그인 로그아웃) 관리
// AuthStateNotifier는 사용자 로그인 상태만을 관리
// 토큰 관리, 인증 인터셉터 설정

import 'package:ari/core/services/audio_service.dart';
import 'package:ari/core/utils/auth_interceptor.dart';
import 'package:ari/data/datasources/auth/auth_local_data_source.dart';
import 'package:ari/data/datasources/auth/auth_remote_data_source.dart';
import 'package:ari/data/repositories/auth_repository_impl.dart';
import 'package:ari/domain/repositories/auth_repository.dart';
import 'package:ari/domain/usecases/auth/auth_usecase.dart';
import 'package:ari/presentation/viewmodels/auth/login_viewmodel.dart';
import 'package:ari/presentation/viewmodels/auth/sign_up_viewmodel.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/providers/playback/playback_progress_provider.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(storage: ref.watch(secureStorageProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    refreshUrl: '/api/v1/auth/token/refresh',
    ref: ref,
  );
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
        ref: ref,
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
        ref: ref,
        loginUseCase: ref.read(loginUseCaseProvider),
        getUserProfileUseCase: ref.read(getUserProfileUseCaseProvider),
        saveTokensUseCase: ref.read(saveTokensUseCaseProvider),
        authStateNotifier: ref.read(authStateProvider.notifier),
      );
    });

// 유저 로그인 여부를 관리
class AuthStateNotifier extends StateNotifier<AsyncValue<bool>> {
  final GetAuthStatusUseCase getAuthStatusUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final Ref ref;

  AuthStateNotifier({
    required this.getAuthStatusUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.ref,
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

  Future<bool> login(String email, String password) async {
    print('[AuthStateNotifier] 로그인 시도: $email');
    try {
      await loginUseCase(email, password);
      print('[AuthStateNotifier] 로그인 성공');

      // // ✅ 오디오 서비스 및 재생 상태 초기화
      // final audioService = ref.read(audioServiceProvider);
      // final playbackNotifier = ref.read(playbackProvider.notifier);

      // await audioService.audioPlayer.stop(); // 혹시라도 백그라운드에서 재생 중이면 정지
      // playbackNotifier.reset(); // 재생 상태 초기화

      // // invalidate로 강제 상태 리셋
      // ref.invalidate(playbackProvider);
      // Future.microtask(() {
      //   ref.invalidate(listeningQueueProvider);
      // });
      // ref.invalidate(playbackPositionProvider);
      // ref.invalidate(playbackDurationProvider);

      state = const AsyncValue.data(true);
      return true; // 성공 시 true 반환
    } catch (e, stackTrace) {
      print('[AuthStateNotifier] 로그인 실패: $e');
      // 에러 상태를 설정하지 않고 기존 상태 유지
      return false; // 실패 시 false 반환
    }
  }

  Future<void> logout() async {
    print('[AuthStateNotifier] 로그아웃 시도');
    state = const AsyncValue.loading();

    try {
      // 로그아웃 시도 전에 로그를 추가
      print('[AuthStateNotifier] 로그아웃 실행 중...');
      await logoutUseCase();
      print('[AuthStateNotifier] 로그아웃 성공');

      // // 오디오 서비스 및 재생 상태 초기화
      // final audioService = ref.read(audioServiceProvider);
      // final playbackNotifier = ref.read(playbackProvider.notifier);

      // // 오디오 중단
      // await audioService.audioPlayer.stop();
      // print('[AuthStateNotifier] 오디오 중단 완료');

      // // 상태 초기화
      // playbackNotifier.reset();
      // print('[AuthStateNotifier] 재생 상태 초기화 완료');

      // // 모든 플레이백 관련 상태 강제 초기화
      // // 순환 방지 위해 invalidate는 다음 프레임으로 미룸
      // Future.microtask(() {
      //   print('[AuthStateNotifier] 상태 초기화 시작');
      //   ref.invalidate(playbackProvider);
      //   print('[AuthStateNotifier] playbackProvider 초기화 완료');

      //   ref.invalidate(listeningQueueProvider);
      //   print('[AuthStateNotifier] listeningQueueProvider 초기화 완료');

      //   ref.invalidate(playbackPositionProvider);
      //   print('[AuthStateNotifier] playbackPositionProvider 초기화 완료');

      //   ref.invalidate(playbackDurationProvider);
      //   print('[AuthStateNotifier] playbackDurationProvider 초기화 완료');
      // });

      // 로그아웃 완료
      state = const AsyncValue.data(false);
      print('[AuthStateNotifier] 로그아웃 완료');
    } catch (e, stackTrace) {
      print('[AuthStateNotifier] 로그아웃 실패: $e');
      print('[AuthStateNotifier] 스택 트레이스: $stackTrace');
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
