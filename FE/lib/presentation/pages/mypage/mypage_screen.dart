import 'package:ari/presentation/routes/app_router.dart';
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
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 여기에 MypageWidget 추가
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
                  // Menu items
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
                  
                  // 섹션 제목
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 18),
                    child: const Text(
                      '아티스트 대시보드',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  
                  MypageMenuItem(
                    title: '로그아웃',
                    routeName: AppRoutes.login,
                  ),
                  
                  // 하단 플레이어를 위한 여백
                  const SizedBox(height: 100),
                ],
              ),
            ),
            
          ],
        ),
      )
    );
  }
}