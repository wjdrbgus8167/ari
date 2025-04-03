import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/mypage/mypage_viewmodel.dart';
import 'package:ari/presentation/widgets/common/custom_dialog.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/mypage/mypage_menu_item.dart';
import 'package:ari/presentation/widgets/mypage/mypage_profile.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// MyPageViewModel Provider 정의
final myPageViewModelProvider = Provider.autoDispose<MyPageViewModel>((ref) {
  return MyPageViewModel(ref);
});

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  @override
  void initState() {
    super.initState();
    // 뷰모델 초기화 (화면이 렌더링된 후)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myPageViewModelProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(myPageViewModelProvider);
    
    // 로그인 상태 확인
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );
    print("로그인 여부 :$isLoggedIn");
    

    return Scaffold(
      body: Container(
        height: double.infinity,
        color: Colors.black,
        child: Column(
          children: [
            // 헤더 위젯
            HeaderWidget(
              type: HeaderType.backWithTitle,
              title: "마이페이지",
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            
            // 로딩 표시
            if (viewModel.isLoading)
              const LinearProgressIndicator(),
            
            // 컨텐츠 부분 (스크롤 가능)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 위젯
                    MypageProfile(
                      name: viewModel.name,
                      instagramId: viewModel.instagramId,
                      bio: viewModel.bio,
                      followers: viewModel.followers,
                      following: viewModel.following,
                      profileImage: viewModel.profileImage,
                      secondaryImage: viewModel.secondaryImage,
                      onEditPressed: () => viewModel.navigateToEditProfile(context),
                    ),
                    
                    // 메뉴 아이템들
                    MypageMenuItem(
                      title: '나의 구독',
                      routeName: AppRoutes.subscription,
                      onTap: () => viewModel.onMenuItemClicked(context, AppRoutes.subscription),
                    ),
                    MypageMenuItem(
                      title: '구독 내역',
                      routeName: AppRoutes.subscription,
                      onTap: () => viewModel.onMenuItemClicked(context, AppRoutes.subscription),
                    ),
                    MypageMenuItem(
                      title: '앨범 업로드',
                      routeName: AppRoutes.albumUpload,
                      onTap: () => viewModel.onMenuItemClicked(context, AppRoutes.albumUpload),
                    ),
                    MypageMenuItem(
                      title: '아티스트 대시보드',
                      routeName: AppRoutes.artistDashboard,
                      onTap: () => viewModel.onMenuItemClicked(context, AppRoutes.artistDashboard),
                    ),
                    MypageMenuItem(
                      title: '정산 내역',
                      routeName: AppRoutes.subscription,
                      onTap: () => viewModel.onMenuItemClicked(context, AppRoutes.subscription),
                    ),
                    MypageMenuItem(
                      title: '로그아웃',
                      routeName: AppRoutes.home,
                      onTap: () async {
                        final shouldLogout = await context.showConfirmDialog(
                          title: "로그아웃",
                          content: "로그아웃하시겠습니까?",
                          confirmText: "확인",
                          cancelText: "취소",
                        );
                        
                        // 사용자가 확인(true)을 선택한 경우에만 로그아웃 실행
                        if (shouldLogout == true) {
                          await viewModel.logout(context);
                        }
                      }
                    ),
                    // 하단 여백
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}