import 'package:ari/domain/entities/profile.dart';
import 'package:ari/domain/usecases/user/user_usecase.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 사용자 프로필 모델 클래스
class UserProfile extends Profile {
  UserProfile({
    required super.memberId,
    required super.nickname,
    required super.instagram,
    required super.bio,
    required super.followerCount,
    required super.followingCount,
    required super.profileImageUrl,
  });
  
  // 기본 생성자
  factory UserProfile.empty() {
    return UserProfile(
      memberId: 1,
      nickname: '',
      instagram: '',
      bio: '',
      followerCount: 0,
      followingCount: 0,
      profileImageUrl: 'https://placehold.co/100x100',
    );
  }
}

// 마이페이지 상태 클래스
class MyPageState {
  final Profile userProfile;
  final bool isLoading;
  final String? errorMessage;
  
  MyPageState({
    required this.userProfile,
    this.isLoading = false,
    this.errorMessage,
  });
  
  // 초기 상태
  factory MyPageState.initial() {
    return MyPageState(
      userProfile: UserProfile.empty(),
      isLoading: false,
    );
  }
  // copyWith 메서드
  MyPageState copyWith({
    Profile? userProfile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MyPageState(
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// NotifierProvider 정의
// StateNotifierProvider 정의
class MyPageViewModel extends StateNotifier<MyPageState> {
  final Ref ref;
  
  MyPageViewModel(this.ref) : super(MyPageState.initial()) {
    // 초기 상태 설정은 super 호출로 처리됨
  }
  
  // 유저 프로필 유스케이스 접근자
  GetUserProfileUseCase get getUserProfileUseCase => ref.read(getUserProfileUseCaseProvider);
  
  // 초기화 메서드
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // 사용자 프로필 가져오기
      await getUserProfile();
      
    } catch (e) {
      // 에러 처리
      debugPrint('사용자 정보 로딩 오류: $e');
      state = state.copyWith(
        errorMessage: '사용자 정보를 불러오는 중 오류가 발생했습니다.',
        isLoading: false
      );
    }
  }
  
  // 프로필 편집 페이지로 이동
  void navigateToEditProfile(BuildContext context) {
    debugPrint('프로필 수정 버튼 클릭');
    // 예: Navigator.pushNamed(context, AppRoutes.editProfile);
  }
  
  // 로그아웃 처리
  Future<void> logout(BuildContext context) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isLoggedIn = ref.read(authStateProvider).when(
        data: (value) => value,
        loading: () => false,
        error: (_, __) => false,
      );
      
      debugPrint(isLoggedIn.toString());
      
      if (isLoggedIn) {
        // 로그아웃 수행
        await ref.read(authStateProvider.notifier).logout();
        
        // mounted 체크
        if (!context.mounted) {
          debugPrint('위젯이 이미 dispose되어 네비게이션 실행 불가');
          return;
        }
        
        // 홈 화면으로 이동
        Navigator.pushNamedAndRemoveUntil(
          context, 
          AppRoutes.home, 
          (route) => false
        );

        // 토스트 표시
        context.showToast('성공적으로 로그아웃되었습니다.');
      }
    } catch (e) {
      // 에러 처리
      debugPrint('로그아웃 중 오류: $e');
      
      // mounted 체크
      if (!context.mounted) return;
      context.showToast('로그아웃 중 오류가 발생했습니다.');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 사용자 프로필 가져오기
  Future<bool> getUserProfile() async {
    try {
      final result = await getUserProfileUseCase();
      
      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
          );
          return false;
        },
        (profile) {
          state = state.copyWith(
            userProfile: profile,
            isLoading: false,
          );
          return true;
        }
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: '프로필을 가져오는 중 오류가 발생했습니다: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }
  
  // 메뉴 아이템 클릭 처리
  void onMenuItemClicked(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }
}


// Provider 정의
final myPageProvider = StateNotifierProvider<MyPageViewModel, MyPageState>((ref) {
  return MyPageViewModel(ref);
});