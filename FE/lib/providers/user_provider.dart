import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ari/core/utils/jwt_utils.dart';
import 'package:ari/data/models/user_model.dart';
import 'package:ari/domain/entities/user.dart';
import 'package:ari/domain/usecases/auth_usecase.dart';
import 'package:ari/providers/auth/auth_providers.dart';

/// 사용자 정보 저장 키
const String _userStorageKey = 'current_user_info';

/// JWT 토큰에서 사용자 정보를 추출, 관리
class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final GetTokensUseCase getTokensUseCase;
  final FlutterSecureStorage secureStorage;
  final AsyncValue<bool> authState;

  @override
  bool get mounted => !_disposed;
  bool _disposed = false;

  UserNotifier({
    required this.getTokensUseCase,
    required this.secureStorage,
    required this.authState,
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
        extractUserFromToken();
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
        await extractUserFromToken();
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

      // 추출한 정보 저장
      await _saveUserToStorage(user);

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

    await extractUserFromToken();
  }
}

/// 앱 전체에서 현재 로그인된 사용자 정보에 접근 가능
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((
  ref,
) {
  return UserNotifier(
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

/// 사용자 로그인 상태 확인
final isUserLoggedInProvider = Provider<bool>((ref) {
  final userState = ref.watch(userProvider);
  return userState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});
