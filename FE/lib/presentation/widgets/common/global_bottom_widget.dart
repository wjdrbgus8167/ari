import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/presentation/widgets/common/bottom_nav.dart';
import 'package:ari/presentation/widgets/common/playback_bar.dart';

class GlobalBottomWidget extends ConsumerWidget {
  final Widget child; // 각 페이지 콘텐츠 영역

  const GlobalBottomWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomIndex = ref.watch(bottomNavProvider);

    Widget currentScreen = child;

    // 하단 탭 인덱스가 변경될 때 해당 화면으로 교체
    if (bottomIndex != 0) {
      switch (bottomIndex) {
        case 1:
          // TODO: 검색 화면
          currentScreen = const Center(
            child: Text(
              '검색 화면',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          );
          break;
        case 2:
          // TODO: 음악 서랍 화면
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
      body: currentScreen,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlaybackBar(),
          CommonBottomNav(
            currentIndex: bottomIndex,
            onTap: (index) {
              // 현재 인덱스와 선택한 인덱스가 같으면 해당 화면을 맨 위로 스크롤
              if (index == bottomIndex) {
                // TODO: 현재 화면 맨 위로 스크롤 처리
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
