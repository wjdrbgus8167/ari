import 'package:ari/presentation/pages/login/login_screen.dart';
import 'package:ari/presentation/pages/sign_up/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:ari/presentation/pages/album/album_detail_screen.dart';
import 'package:ari/presentation/pages/track_detail/track_detail_screen.dart';
import 'package:ari/presentation/pages/home/home_screen.dart';
import 'package:ari/presentation/pages/mypage/mypage_screen.dart';
import 'package:ari/presentation/pages/listeningqueue/listening_queue_screen.dart';
import 'package:ari/presentation/pages/playlist/playlist_screen.dart';
import 'package:ari/presentation/pages/my_channel/my_channel_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String myPage = '/mypage';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String album = '/album';
  static const String playlist = '/playlist';
  static const String listeningqueue = '/listeningqueue';
  static const String track = '/track';
  static const String myChannel = '/mychannel';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.myPage:
        return MaterialPageRoute(builder: (_) => const MyPageScreen());

      case AppRoutes.album:
        return MaterialPageRoute(builder: (_) => AlbumDetailScreen(albumId: 1));

      case AppRoutes.listeningqueue:
        return MaterialPageRoute(builder: (_) => const ListeningQueueScreen());

      case AppRoutes.track:
        return MaterialPageRoute(
          builder: (_) => const TrackDetailScreen(albumId: 1, trackId: 1),
        );

      case AppRoutes.playlist:
        return MaterialPageRoute(builder: (_) => const PlaylistScreen());

      case AppRoutes.myChannel:
        final args = settings.arguments as Map<String, dynamic>?;
        final memberId = args?['memberId'] as String?;
        return MaterialPageRoute(
          builder: (_) => MyChannelScreen(memberId: memberId),
        );

      default:
        // 없는 경로는 홈으로 리다이렉트, 스낵바로 알림
        return MaterialPageRoute(
          builder: (context) {
            // 화면 빌드 후 SnackBar 표시
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '😞 경로 "${settings.name}"를 찾을 수 없어 홈 화면으로 이동했습니다.',
                  ),
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
            // 홈 화면 반환
            return const HomeScreen();
          },
        );
    }
  }
}
