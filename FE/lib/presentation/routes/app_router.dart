import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/presentation/pages/dashboard/artist_dashboard_screen.dart';
import 'package:ari/presentation/pages/dashboard/my_track_stat_list.dart';
import 'package:ari/presentation/pages/login/login_screen.dart';
import 'package:ari/presentation/pages/mypage/edit_profile_screen.dart';
import 'package:ari/presentation/pages/playlist_detail/playlist_detail_screen.dart';
import 'package:ari/presentation/pages/sign_up/sign_up_screen.dart';
import 'package:ari/presentation/pages/subscription/artist_selection_screen.dart';
import 'package:ari/presentation/pages/subscription/my_subscription_screen.dart';
import 'package:ari/presentation/pages/subscription/settlement_screen.dart';
import 'package:ari/presentation/pages/subscription/subscription_history_screen.dart';
import 'package:ari/presentation/pages/subscription/subscription_payment_screen.dart';
import 'package:ari/presentation/pages/subscription/subscription_select_screen.dart';
import 'package:ari/presentation/viewmodels/subscription/artist_selection_viewmodel.dart';
import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:ari/presentation/widgets/common/custom_dialog.dart';
import 'package:ari/presentation/widgets/common/listeningqueue_container.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:ari/presentation/pages/album/album_detail_screen.dart';
import 'package:ari/presentation/pages/track_detail/track_detail_screen.dart';
import 'package:ari/presentation/pages/home/home_screen.dart';
import 'package:ari/presentation/pages/mypage/mypage_screen.dart';
import 'package:ari/presentation/pages/listeningqueue/listening_queue_screen.dart';
import 'package:ari/presentation/pages/playlist/playlist_screen.dart';
// 나의 채널
import 'package:ari/presentation/pages/my_channel/my_channel_screen.dart';
// 음원 업로드
import 'package:ari/presentation/pages/mypage/album_upload_screen.dart';
import 'package:ari/presentation/pages/mypage/track_upload_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 장르별 페이지
import 'package:ari/core/utils/genre_utils.dart';
import 'package:ari/presentation/pages/genre/genre_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String myPage = '/mypage';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String album = '/album';
  static const String playlist = '/playlist';
  static const String playlistDetail = '/playlist-detail';
  static const String listeningqueue = '/listeningqueue';
  static const String track = '/track';
  static const String myChannel = '/mychannel';
  static const String subscription = '/subscription';
  static const String subscriptionHistory = '/subscription-history';
  static const String subscriptionPayment = '/subscription/payment';
  static const String albumUpload = '/album-upload';
  static const String trackUpload = '/album-upload/add-track';
  static const String subscriptionSelect = '/subscription/select';
  static const String artistSelection = '/subscription/select/artist';
  static const String artistDashboard = '/artist-dashboard';
  static const String myAlbumStatList = '/artist-dashboard/my-album-stats';
  static const String genre = '/genre';
  static const String editProfile = '/edit-profile';
  static const String settlement = '/settlement';

  static final Set<String> _protectedRoutes = {
    myPage,
    albumUpload,
    trackUpload,
    subscription,
    subscriptionPayment,
  };

  static bool requiresAuth(String? route) {
    return _protectedRoutes.contains(route);
  }
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings, WidgetRef ref) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );

      case AppRoutes.signUp:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignUpScreen(),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case AppRoutes.myPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyPageScreen(),
        );

      case AppRoutes.album:
        final albumId = args?['albumId'] as int? ?? 1;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AlbumDetailScreen(albumId: albumId),
        );

      // 앨범 업로드
      case AppRoutes.albumUpload:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AlbumUploadScreen(),
        );
      // 트랙 업로드
      case AppRoutes.trackUpload:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TrackUploadScreen(),
        );

      case AppRoutes.listeningqueue:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ListeningQueueScreen(),
        );

      // 재생목록 탭
      case '/listeningqueue-tab':
        return MaterialPageRoute(
          builder: (_) => const ListeningQueueTabContainer(),
        );

      case AppRoutes.track:
        final albumId = args?['albumId'] as int? ?? 1;
        final trackId = args?['trackId'] as int? ?? 1;
        final albumCoverUrl = args?['albumCoverUrl'] as String?; // 추가된 부분
        return MaterialPageRoute(
          builder:
              (_) => TrackDetailScreen(
                albumId: albumId,
                trackId: trackId,
                albumCoverUrl: albumCoverUrl, // 추가된 부분
              ),
        );

      case AppRoutes.playlist:
        return MaterialPageRoute(builder: (_) => const PlaylistScreen());

      case AppRoutes.playlistDetail:
        final playlistId = args?['playlistId'] as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => PlaylistDetailScreen(playlistId: playlistId),
        );

      case AppRoutes.myChannel:
        final memberId = args?['memberId'] as String?;
        return MaterialPageRoute(
          builder: (_) => MyChannelScreen(memberId: memberId),
        );

      case AppRoutes.subscription:
        return MaterialPageRoute(builder: (_) => const MySubscriptionScreen());

      case AppRoutes.subscriptionSelect:
        return MaterialPageRoute(
          builder: (_) => const SubscriptionSelectScreen(),
        );

      case AppRoutes.subscriptionPayment:
        final subscriptionType =
            args?['subscriptionType'] as SubscriptionType? ??
            SubscriptionType.regular;
        final artistInfo = args?['artistInfo'] as ArtistInfo?;

        // artist 구독인데 artistInfo가 없으면 예외 처리
        if (subscriptionType == SubscriptionType.artist && artistInfo == null) {
          throw ArgumentError('Artist subscription requires artist info');
        }

        return MaterialPageRoute(
          builder:
              (_) => SubscriptionPaymentScreen(
                subscriptionType: subscriptionType,
                artistInfo: artistInfo,
              ),
        );

      case AppRoutes.subscriptionHistory:
        return MaterialPageRoute(
          builder: (_) => const SubscriptionHistoryScreen(),
        );

      case AppRoutes.artistSelection:
        return MaterialPageRoute(builder: (_) => const ArtistSelectionScreen());

      case AppRoutes.artistDashboard:
        return MaterialPageRoute(builder: (_) => const ArtistDashboardScreen());

      case AppRoutes.myAlbumStatList:
        return MaterialPageRoute(builder: (_) => const MyTrackStatListScreen());

      case AppRoutes.genre:
        final genre = args?['genre'] as Genre;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => GenrePage(genre: genre),
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileEditScreen(),
        );

      case AppRoutes.settlement:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SettlementScreen(),
        );

      default:
        // 없는 경로는 홈으로 리다이렉트, 스낵바로 알림
        return MaterialPageRoute(
          builder: (context) {
            // 화면 빌드
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

  // AppRouter 클래스에 추가
  static BuildContext? currentContext;

  static Future<bool> checkAuth(BuildContext context, WidgetRef ref) async {
    AsyncValue<bool> authState = ref.watch(authStateProvider);

    while (authState.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      authState = ref.watch(authStateProvider); // 상태 다시 확인
    }

    // 로딩 중이라면 로그인 상태를 알 수 없으므로, 대기 후 다시 확인
    if (authState.hasError) {
      return false;
    }

    // 로그인 여부 확인
    final isLoggedIn = authState.value ?? false;
    if (!isLoggedIn) {
      // 로그인 안 된 경우: 다이얼로그 표시
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return CustomDialog(
            title: '로그인 필요',
            content: '로그인이 필요합니다. 로그인 화면으로 이동하시겠습니까?',
            confirmText: '로그인하기',
            cancelText: '취소',
            confirmButtonColor: Colors.blue,
            cancelButtonColor: Colors.grey,
            // onConfirm에서 로그인 화면으로 이동하지 않고, 단순히 true 반환
            onConfirm: null, // null을 전달하여 내부 동작만 실행하도록 함
            // onCancel도 null로 설정하여 내부 동작만 실행하도록 함
            onCancel: null,
          );
        },
      );

      // 다이얼로그에서 확인 버튼을 눌렀다면 로그인 화면으로 이동
      if (result == true) {
        Navigator.of(context).pushNamed(AppRoutes.login);
        return false; // 로그인 화면으로 이동했으므로 원래 의도했던 라우트로는 이동하지 않음
      }

      // 취소했다면 현재 화면에 머무름
      return false;
    }

    // 이미 로그인 된 경우
    return true;
  }

  // 앱 내에서 사용할 네비게이션 메서드
  static Future<void> navigateTo(
    BuildContext context,
    WidgetRef ref,
    String routeName, [
    Map<String, dynamic>? args,
  ]) async {
    // 현재 컨텍스트 저장
    currentContext = context;

    final bool requiresAuth = AppRoutes.requiresAuth(routeName);

    if (requiresAuth) {
      // 인증 체크 - 로그인 다이얼로그 표시 포함
      final canProceed = await checkAuth(context, ref);
      if (!canProceed) {
        // 인증 실패 또는 취소 - 현재 화면 유지
        return;
      }
    }

    // 인증 통과 또는 불필요 - 요청된 라우트로 이동
    if (args != null) {
      Navigator.of(context).pushNamed(routeName, arguments: args);
    } else {
      Navigator.of(context).pushNamed(routeName);
    }
  }
}
