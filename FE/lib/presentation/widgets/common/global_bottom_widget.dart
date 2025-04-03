import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/providers/navigation_history_provider.dart';
import 'package:ari/presentation/widgets/common/bottom_nav.dart';
import 'package:ari/presentation/widgets/common/playback_bar.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import '../../pages/my_channel/my_channel_screen.dart';

// 인덱스 0: 홈 화면 (전달된 child)
// 인덱스 1: 검색 화면 (임시 텍스트 표시)
// 인덱스 2: 음악 서랍 화면 (임시 텍스트 표시)
// 인덱스 3: 나의 채널 화면 (MyChannelScreen)

/// 글로벌 하단 위젯과 탭별 화면 관리
///
/// 전체 앱의 공통 골격 제공, 하단 네비게이션 바와 재생 바를 포함
class GlobalBottomWidget extends ConsumerWidget {
  final Widget child; // 각 페이지 콘텐츠 영역

  const GlobalBottomWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 탭 인덱스
    final bottomIndex = ref.watch(bottomNavProvider);

    // 탭 히스토리 변경 감지
    ref.listen(navigationHistoryProvider, (previous, current) {
      // 히스토리가 변경되면 UI도 함께 업데이트하기 위해
      // 선택된 탭 인덱스를 현재 히스토리의 마지막 항목으로 설정
      if (current.isNotEmpty && current.last != bottomIndex) {
        ref.read(bottomNavProvider.notifier).setIndex(current.last);
      }
    });

    Widget currentScreen = child;

    // 하단 탭 인덱스가 변경될 때 그 화면으로 변경
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
          // 기본값은 전달된 child (보통 HomeScreen)
          currentScreen = child;
      }
    }

    // PopScope로 뒤로가기 이벤트 처리
    return PopScope(
      canPop: false, // 기본 뒤로가기 동작 비활성화
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // 뒤로가기 처리를 위해 히스토리 확인
        final historyNotifier = ref.read(navigationHistoryProvider.notifier);
        final isAtHome = historyNotifier.goBack();

        // 홈화면인 경우 토스트 표시 또는 앱 종료
        if (isAtHome) {
          // 실제 뒤로가기 버튼을 눌렀는지 확인
          if (historyNotifier.isHomeBackButtonPressed()) {
            final isQuickSecondPress = historyNotifier.isQuickSecondBackPress();

            if (isQuickSecondPress) {
              // 1초 이내에 뒤로가기를 두 번 누른 경우: 앱 종료
              SystemNavigator.pop();
            } else {
              // 처음 뒤로가기 누른 경우: 토스트 메시지 표시
              context.showToast('뒤로가기 버튼을 한 번 더 누르면 종료됩니다');
            }
          }
        }
      },
      child: Scaffold(
        body: currentScreen,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PlaybackBar(),
            CommonBottomNav(
              currentIndex: bottomIndex,
              onTap: (index) {
                // 현재 인덱스와 선택한 인덱스가 같으면 해당 화면을 맨 위로 스크롤
                if (index == bottomIndex) {
                  // TODO: 현재 화면 맨 위로 스크롤 처리
                } else {
                  // 탭 변경 시 히스토리에 추가
                  ref.read(navigationHistoryProvider.notifier).addTab(index);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
