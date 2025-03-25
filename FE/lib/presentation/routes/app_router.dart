import 'package:flutter/material.dart';
import 'package:ari/presentation/pages/album/album_detail_screen.dart';
import 'package:ari/presentation/pages/track_detail/track_detail_screen.dart';
import 'package:ari/presentation/pages/home/home_screen.dart';
import 'package:ari/presentation/pages/mypage/mypage_screen.dart';
import 'package:ari/presentation/pages/listeningqueue/listening_queue_screen.dart';
import 'package:ari/presentation/pages/playlist/playlist_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String myPage = '/mypage';

  // 여기에 경로 더 추가하십시옹
  static const String login = '/login';
  static const String album = '/album';
  static const String playlist = '/playlist';
  static const String listeningqueue = '/listeningqueue';
  static const String track = '/track';
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
      case AppRoutes.listeningqueue:
        return MaterialPageRoute(builder: (_) => const ListeningQueueScreen());
      case AppRoutes.track:
        return MaterialPageRoute(
          builder: (_) => const TrackDetailScreen(albumId: 1, trackId: 1),
        );
      case AppRoutes.playlist:
        return MaterialPageRoute(builder: (_) => const PlaylistScreen());
      default:
        // 없는 경로는 홈으로 리다이렉트
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text('Route ${settings.name} not found')),
              ),
        );
    }
  }
}
