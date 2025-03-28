import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/mypage/mypage_menu_item.dart';
import 'package:ari/presentation/widgets/mypage/mypage_profile.dart';
import 'package:flutter/material.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
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
            
            // 컨텐츠 부분 (스크롤 가능)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 위젯
                    MypageProfile(
                      name: '진우석',
                      instagramId: '인스타그램ID',
                      bio: '안녕하세요~',
                      followers: 0,
                      following: 0,
                      profileImage: "https://placehold.co/100x100",
                      secondaryImage: "https://placehold.co/100x100",
                      onEditPressed: () {
                        // 프로필 수정 페이지로 이동하는 로직
                        print('프로필 수정 버튼 클릭');
                      },
                    ),
                    
                    // 메뉴 아이템들
                    MypageMenuItem(
                      title: '나의 구독',
                      routeName: AppRoutes.subscribe,
                    ),
                    MypageMenuItem(
                      title: '구독 내역',
                      routeName: AppRoutes.subscribe,
                    ),
                    MypageMenuItem(
                      title: '앨범 업로드',
                      routeName: AppRoutes.subscribe,
                    ),
                    MypageMenuItem(
                      title: '아티스트 대시보드',
                      routeName: AppRoutes.subscribe,
                    ),
                    MypageMenuItem(
                      title: '정산 내역',
                      routeName: AppRoutes.subscribe,
                    ),
                    MypageMenuItem(
                      title: '로그아웃',
                      routeName: AppRoutes.login,
                    ),
                    
                    // 하단 여백
                    SizedBox(height: 20),
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