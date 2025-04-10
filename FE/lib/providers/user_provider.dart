// 로그인한 사용자의 상세 정보 관리
// UserNotifier: JWT 토큰에서 사용자 정보(IX, 이메일 등) 추출 및 관리
// 로컬 스토리지에 사용자 정보 저장, 로드, 삭제
// 사용자 ID, 이메일 등 편리한 접근 제공
// auth_providers.dart가 변경되면(로그인/로그아웃) user_provider가 반응
// 인증 상태가 변경될 때 사용자 정보도 자동으로 업데이트/삭제

import 'dart:convert';
import 'package:ari/data/datasources/user/profile_remote_data_source.dart';
import 'package:ari/data/repositories/user_repository.dart';
import 'package:ari/domain/entities/profile.dart';
import 'package:ari/domain/repositories/user/user_repository.dart';
import 'package:ari/domain/usecases/dashboard/get_dashboard_data_usecase.dart';
import 'package:ari/domain/usecases/user/user_usecase.dart';
import 'package:ari/presentation/viewmodels/dashboard/artist_dashboard_viewmodel.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ari/core/utils/jwt_utils.dart';
import 'package:ari/data/models/user_model.dart';
import 'package:ari/domain/entities/user.dart';
import 'package:ari/domain/usecases/auth/auth_usecase.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'dart:developer' as dev;

/// 사용자 정보 저장 키
const String _userStorageKey = 'current_user_info';

/// JWT 토큰에서 사용자 정보를 추출, 관리
class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final GetTokensUseCase getTokensUseCase;
  final FlutterSecureStorage secureStorage;
  final AsyncValue<bool> authState;
  final Ref ref;

  @override
  bool get mounted => !_disposed;
  bool _disposed = false;

  UserNotifier({
    required this.getTokensUseCase,
    required this.secureStorage,
    required this.authState,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    // 초기화 시 사용자 정보 로드
    _loadUserInfo();

    // 인증 상태에 따라 사용자 정보 관리
    _handleAuthStateChange(authState);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// 인증 상태 변경 처리
  void _handleAuthStateChange(AsyncValue<bool> authState) {
    authState.whenData((isAuthenticated) {
      if (!isAuthenticated) {
        // 로그아웃 시 사용자 정보 삭제
        clearUserInfo();
      } else {
        // 로그인 시 사용자 정보 추출
        refreshUserInfo();
      }
    });
  }

  /// 시작시 저장된 사용자 정보 or 토큰에서 추출한 정보 로드
  Future<void> _loadUserInfo() async {
    try {
      // 먼저 로컬 스토리지에서 사용자 정보 확인
      final userJson = await secureStorage.read(key: _userStorageKey);

      // mounted 체크 (상태 업데이트 전)
      if (!mounted) return;

      if (userJson != null) {
        // 저장된 사용자 정보가 있으면 로드
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        state = AsyncValue.data(UserModel.fromJson(userMap));
      } else {
        // 저장된 정보가 없으면 토큰에서 추출 시도
        await refreshUserInfo();
      }
    } catch (e, stackTrace) {
      print('사용자 정보 로드 오류: $e');
      // mounted 체크 (오류 상태 업데이트 전)
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  /// JWT 토큰에서 사용자 정보 추출
  Future<User?> extractUserFromToken() async {
    try {
      // mounted 체크 (상태 업데이트 전)
      if (!mounted) return null;

      state = const AsyncValue.loading();

      // 토큰 가져오기
      final tokens = await getTokensUseCase();

      // mounted 체크 (비동기 작업 후)
      if (!mounted) return null;

      if (tokens == null || tokens.accessToken.isEmpty) {
        state = const AsyncValue.data(null);
        return null;
      }

      // 토큰에서 페이로드 추출
      final payload = JwtUtils.parseJwtPayload(tokens.accessToken);

      // UserModel 생성
      final user = UserModel.fromJwtPayload(payload);

      // mounted 체크 (최종 상태 업데이트 전)
      if (!mounted) return user;

      state = AsyncValue.data(user);
      return user;
    } catch (e, stackTrace) {
      print('토큰에서 사용자 정보 추출 오류: $e');
      // mounted 체크 (오류 상태 업데이트 전)
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
      return null;
    }
  }

  /// JWT 토큰에서 사용자 정보 추출
  Future<User?> saveUserFromProfile(Profile profile, String email) async {
    try {
      // mounted 체크 (상태 업데이트 전)
      if (!mounted) return null;

      state = const AsyncValue.loading();

      // mounted 체크 (비동기 작업 후)
      if (!mounted) return null;

      // UserModel 생성
      final user = UserModel.fromProfileAndEmail(profile, email);

      // 추출한 정보 저장
      await _saveUserToStorage(user);

      // mounted 체크 (최종 상태 업데이트 전)
      if (!mounted) return user;

      state = AsyncValue.data(user);
      return user;
    } catch (e, stackTrace) {
      print('사용자 정보 추출 오류: $e');
      // mounted 체크 (오류 상태 업데이트 전)
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
      return null;
    }
  }

  /// 사용자 정보를 로컬 스토리지에 저장
  Future<void> _saveUserToStorage(User user) async {
    try {
      final userModel = user is UserModel ? user : UserModel.fromEntity(user);
      final userJson = json.encode(userModel.toJson());
      await secureStorage.write(key: _userStorageKey, value: userJson);
    } catch (e) {
      print('사용자 정보 저장 오류: $e');
    }
  }

  /// 저장된 사용자 정보 삭제 (로그아웃 시 호출)
  Future<void> clearUserInfo() async {
    try {
      await secureStorage.delete(key: _userStorageKey);

      // mounted 체크 (상태 업데이트 전)
      if (!mounted) return;

      state = const AsyncValue.data(null);
    } catch (e) {
      print('사용자 정보 삭제 오류: $e');
    }
  }

  /// 사용자 정보 수동 새로고침
  Future<void> refreshUserInfo() async {
    // mounted 체크 (비동기 작업 시작 전)
    if (!mounted) return;

    try {
      final userProfileUseCase = ref.read(getUserProfileUseCaseProvider);
      final profileResult = await userProfileUseCase();
      User? user = await extractUserFromToken();
      // mounted 체크 (비동기 작업 이후)
      if (!mounted) return;

      profileResult.fold(
        (failure) {
          // 프로필 정보 가져오기 실패 시 로그와 스낵바 표시
          dev.log('사용자 프로필 정보 가져오기 실패: ${failure.message}');
        },
        (profile) {
          saveUserFromProfile(profile, user?.email ?? '');
          dev.log('사용자 프로필 정보 갱싱싱 성공');
        },
      );
    } catch (e) {
      dev.log('사용자 정보 새로고침 중 오류 발생: $e');
    }
  }
}

/// 앱 전체에서 현재 로그인된 사용자 정보에 접근 가능
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((
  ref,
) {
  return UserNotifier(
    ref: ref,
    getTokensUseCase: ref.watch(getTokensUseCaseProvider),
    secureStorage: ref.watch(secureStorageProvider),
    authState: ref.watch(authStateProvider),
  );
});

/// 사용자 ID 간편 접근
final userIdProvider = Provider<String?>((ref) {
  final userState = ref.watch(userProvider);
  return userState.when(
    data: (user) => user?.id,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// 사용자 이메일 간편 접근
final userEmailProvider = Provider<String?>((ref) {
  final userState = ref.watch(userProvider);
  return userState.when(
    data: (user) => user?.email,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// 사용자 닉네임 간편 접근
final userNicknameProvider = Provider<String?>((ref) {
  final userState = ref.watch(userProvider);
  return userState.when(
    data: (user) => user?.nickname,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// 사용자 로그인 상태 확인
final isUserLoggedInProvider = Provider<bool>((ref) {
  // authStateProvider의 상태를 우선 확인
  final authState = ref.watch(authStateProvider);
  final isAuthenticatedFromAuth = authState.when(
    data: (isAuth) => isAuth,
    loading: () => false,
    error: (_, __) => false,
  );

  // 인증 상태가 false면 즉시 false 반환
  if (!isAuthenticatedFromAuth) {
    return false;
  }

  // 인증 상태가 true인 경우에만 사용자 정보 확인
  final userState = ref.watch(userProvider);
  return userState.when(
    data: (user) => user != null,
    loading: () => true, // 인증 상태가 true라면 로딩 중에도 true로 간주
    error: (_, __) => false,
  );
});

/// 현재 로그인한 사용자의 ID를 반환하는 Provider
final authUserIdProvider = Provider<String>((ref) {
  final userState = ref.watch(userProvider);
  return userState.when(
    data: (user) => user?.id ?? "",
    loading: () => "",
    error: (_, __) => "",
  );
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>(
  (ref) => UserRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider)),
);
final userRepositoryProvider = Provider<UserRepository>(
  (ref) =>
      UserRepositoryImpl(dataSource: ref.read(userRemoteDataSourceProvider)),
);
final getUserProfileUseCaseProvider = Provider(
  (ref) => GetUserProfileUseCase(ref.read(userRepositoryProvider)),
);

final hasWalletUseCaseProvider = Provider(
  (ref) => HasWalletUseCase(ref.read(dashboardRepositoryProvider)),
);
