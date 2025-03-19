import 'package:flutter/material.dart';

class CommonBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CommonBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        currentIndex: currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false, // 라벨 표시 x
        showUnselectedLabels: false, // 라벨 표시 x
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_outlined),
            activeIcon: Icon(Icons.library_music),
            label: '음악 서랍',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recent_actors_outlined),
            activeIcon: Icon(Icons.recent_actors),
            label: '나의 채널',
          ),
        ],
        // items: const [
        //   BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        //   BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
        //   BottomNavigationBarItem(icon: Icon(Icons.menu), label: '서랍'),
        //   BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        // ],
      ),
    );
  }
}
