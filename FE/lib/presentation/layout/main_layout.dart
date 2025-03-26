import 'package:flutter/material.dart';
import '../routes/app_router.dart';
import '../widgets/common/bottom_nav.dart';

/// 메인 앱 레이아웃
/// 하단 내비게이션 바와 각 화면(페이지)을 연결
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const Navigator(
      key: Key('home'),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
    ),
    const Center(
      child: Text('검색', style: TextStyle(color: Colors.white)),
    ), // TODO: 임시 검색 화면
    const Center(
      child: Text('음악 서랍', style: TextStyle(color: Colors.white)),
    ), // TODO: 임시 음악 서랍 화면
    const Navigator(
      key: Key('mychannel'),
      initialRoute: AppRoutes.myChannel,
      onGenerateRoute: AppRouter.generateRoute,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CommonBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
