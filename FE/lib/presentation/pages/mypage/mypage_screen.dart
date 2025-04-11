import 'package:ari/domain/usecases/dashboard/get_dashboard_data_usecase.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/mypage/mypage_viewmodel.dart';
import 'package:ari/presentation/widgets/common/custom_dialog.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/mypage/mypage_menu_item.dart';
import 'package:ari/presentation/widgets/mypage/mypage_profile.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// MyPageViewModel Provider 정의 - StateNotifierProvider로 변경
final myPageProvider = StateNotifierProvider<MyPageViewModel, MyPageState>((ref) {
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
      ref.read(myPageProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 상태와 노티파이어를 각각 가져옴
    final myPageState = ref.watch(myPageProvider);
    final viewModel = ref.read(myPageProvider.notifier);
    
    // 로그인 상태 확인
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );
    print("로그인 여부 :$isLoggedIn");
    
    // 프로필 정보
    final userProfile = myPageState.userProfile;

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
            if (myPageState.isLoading)
              const LinearProgressIndicator(),
            
            // 에러 메시지가 있는 경우 표시
            if (myPageState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  myPageState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            
            // 컨텐츠 부분 (스크롤 가능)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 위젯
                    MypageProfile(
                      name: userProfile.nickname,
                      instagramId: userProfile.instagram ?? "",
                      bio: userProfile.bio,
                      followers: userProfile.followerCount,
                      following: userProfile.followingCount,
                      profileImage: userProfile.profileImageUrl,
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
                      routeName: AppRoutes.subscriptionHistory,
                      onTap: () => viewModel.onMenuItemClicked(context, AppRoutes.subscriptionHistory),
                    ),
                    MypageMenuItem(
                      title: '앨범 업로드',
                      routeName: AppRoutes.albumUpload,
                      onTap: () async {
                        if (!(await viewModel.hasWallet())) {
                          if (!mounted) return;
                          final shouldRegisterArtist = await context.showConfirmDialog(
                            title: "아티스트 등록",
                            content: "정산 지갑 등록 후 이용 가능합니다.",
                            confirmText: "등록하기",
                            cancelText: "취소",
                          );
                          // 사용자가 확인(true)을 선택한 경우에만 로그아웃 실행
                          if (shouldRegisterArtist == true) {
                            if (!mounted) return;
                            viewModel.onMenuItemClicked(context, AppRoutes.artistDashboard);
                            return;
                          }
                        } else {
                          if (!mounted) return;
                          viewModel.onMenuItemClicked(context, AppRoutes.albumUpload);
                          return;
                        }
                      },
                    ),
                    MypageMenuItem(
                      title: '아티스트 대시보드',
                      routeName: AppRoutes.artistDashboard,
                      onTap: () => viewModel.onMenuItemClicked(context, AppRoutes.artistDashboard),
                    ),
                    MypageMenuItem(
                      title: '정산 내역',
                      routeName: AppRoutes.settlement,
                      onTap: () async {
                        if (!(await viewModel.hasWallet())) {
                          if (!mounted) return;
                          final shouldRegisterArtist = await context.showConfirmDialog(
                            title: "아티스트 등록",
                            content: "정산 지갑 등록 후 이용 가능합니다.",
                            confirmText: "등록하기",
                            cancelText: "취소",
                          );
                          // 사용자가 확인(true)을 선택한 경우에만 로그아웃 실행
                          if (shouldRegisterArtist == true) {
                            if (!mounted) return;
                            viewModel.onMenuItemClicked(context, AppRoutes.artistDashboard);
                            return;
                          }
                        } else {
                          if (!mounted) return;
                          viewModel.onMenuItemClicked(context, AppRoutes.settlement);
                          return;
                        }
                      },
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