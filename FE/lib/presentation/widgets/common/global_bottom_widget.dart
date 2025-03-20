import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/global_providers.dart';
import '../../../providers/playback_state_provider.dart'; // ✅ playbackStateProvider 추가
import 'bottom_nav.dart';
import 'playback_bar.dart';

class GlobalBottomWidget extends ConsumerWidget {
  final Widget child; // 각 페이지 콘텐츠 영역

  const GlobalBottomWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomIndex = ref.watch(bottomNavProvider);
    final playbackState = ref.watch(playbackProvider); // ✅ 변경
    final playbackNotifier = ref.read(playbackProvider.notifier); // ✅ 변경

    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlaybackBar(), // ✅ playbackState 전달할 필요 없음 (내부에서 관리)
          CommonBottomNav(
            currentIndex: bottomIndex,
            onTap: (index) {
              ref.read(bottomNavProvider.notifier).setIndex(index);
            },
          ),
        ],
      ),
    );
  }
}
