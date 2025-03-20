import 'package:ari/presentation/pages/album/album_detail_screen.dart';
import 'package:flutter/material.dart';
import '../pages/home/home_screen.dart';
import '../pages/mypage/mypage_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String myPage = '/mypage';
  
  // 여기에 경로 더 추가하십시옹
  static const String login = '/login';
  static const String album = '/album';
  static const String playlist = '/playlist';
} 

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case AppRoutes.myPage:
        return MaterialPageRoute(builder: (_) => const MyPageScreen());

      case AppRoutes.album:
        return MaterialPageRoute(builder: (_) => AlbumDetailScreen(albumId: 1));
      // 여기에 경로 더 추가하십시오잉
      
      default:
        // 없는 경로는 홈으로 리다이렉트
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}