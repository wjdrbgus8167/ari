import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/global_providers.dart';
import '../../../providers/playback/playback_state_provider.dart'; // ✅ playbackStateProvider 추가
import 'bottom_nav.dart';
import 'playback_bar.dart';
import '../../pages/my_channel/my_channel_screen.dart';

// 인덱스 0: 홈 화면 (전달된 child)
// 인덱스 1: 검색 화면 (임시 텍스트 표시)
// 인덱스 2: 음악 서랍 화면 (임시 텍스트 표시)
// 인덱스 3: 나의 채널 화면 (MyChannelScreen)

class GlobalBottomWidget extends ConsumerWidget {
  final Widget child; // 각 페이지 콘텐츠 영역

  const GlobalBottomWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomIndex = ref.watch(bottomNavProvider);
    final playbackState = ref.watch(playbackProvider); // ✅ 변경
    final playbackNotifier = ref.read(playbackProvider.notifier); // ✅ 변경

    Widget currentScreen = child;

    // 하단 탭 인덱스가 변경될 때 해당 화면으로 교체
    if (bottomIndex != 0) {
      switch (bottomIndex) {
        case 1:
          // 검색 화면 (추후 구현)
          currentScreen = const Center(
            child: Text(
              '검색 화면',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          );
          break;
        case 2:
          // 음악 서랍 화면 (추후 구현)
          currentScreen = const Center(
            child: Text(
              '음악 서랍 화면',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          );
          break;
        case 3:
          // 나의 채널 화면
          currentScreen = const MyChannelScreen();
          break;
        default:
          // 기본값은 전달된 child (일반적으로 HomeScreen)
          currentScreen = child;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlaybackBar(), // ✅ playbackState 전달할 필요 없음 (내부에서 관리)
          CommonBottomNav(
            currentIndex: bottomIndex,
            onTap: (index) {
              // 인덱스가 0이고 현재도 0이면 홈 화면을 맨 위로 스크롤
              if (index == 0 && bottomIndex == 0) {
                // TODO: 홈 화면 맨 위로 스크롤 처리
                // 예: _homeScrollController.animateTo(0.0, ...);
              }
              // 하단 네비게이션 인덱스 업데이트
              ref.read(bottomNavProvider.notifier).setIndex(index);
            },
          ),
        ],
      ),
    );
  }
}

