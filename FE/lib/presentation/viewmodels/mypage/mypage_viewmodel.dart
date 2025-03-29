import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPageViewModel extends ChangeNotifier {
  // 사용자 정보
  final String _name = '진우석';
  final String _instagramId = '인스타그램ID';
  final String _bio = '안녕하세요~';
  final int _followers = 0;
  final int _following = 0;
  final String _profileImage = "https://placehold.co/100x100";
  final String _secondaryImage = "https://placehold.co/100x100";
  
  // 로딩 상태
  bool _isLoading = false;
  
  // 데이터 노출용 getters
  String get name => _name;
  String get instagramId => _instagramId;
  String get bio => _bio;
  int get followers => _followers;
  int get following => _following;
  String get profileImage => _profileImage;
  String get secondaryImage => _secondaryImage;
  bool get isLoading => _isLoading;

  final Ref ref; // Riverpod ref 추가
  MyPageViewModel(this.ref);
  
  // 초기화 메서드
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 여기에 사용자 정보를 가져오는 API 호출을 구현합니다.
      // 예: final userInfo = await _userRepository.getUserProfile();
      
      // 임시로 딜레이를 줘서 로딩 상태를 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));
      
      // 데이터 업데이트 (실제 구현에서는 API 응답으로 업데이트)
      // _name = userInfo.name;
      // _instagramId = userInfo.instagramId;
      // ...
    } catch (e) {
      // 에러 처리
      debugPrint('사용자 정보 로딩 오류: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 프로필 편집 처리
  void navigateToEditProfile(BuildContext context) {
    // 프로필 수정 페이지로 이동하는 로직
    debugPrint('프로필 수정 버튼 클릭');
    
    // 예: Navigator.pushNamed(context, AppRoutes.editProfile);
  }
  
  // 로그아웃 처리
  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
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
          // 로그 기록
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
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 메뉴 아이템 클릭 처리
  void onMenuItemClicked(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }
}