import 'package:ari/presentation/pages/home/home_screen.dart';
import 'package:ari/presentation/pages/login/login_screen.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/core/utils/login_redirect_util.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/providers/navigation_history_provider.dart';
import 'package:ari/presentation/widgets/common/bottom_nav.dart';
import 'package:ari/presentation/widgets/common/playback_bar.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:ari/presentation/pages/search/search_screen.dart';
import '../../pages/my_channel/my_channel_screen.dart';

// 네비게이션 상태를 관리하는 클래스
class NavigationState {
  final int currentTab;
  final List<int> history;

  NavigationState({required this.currentTab, required this.history});

  NavigationState copyWith({int? currentTab, List<int>? history}) {
    return NavigationState(
      currentTab: currentTab ?? this.currentTab,
      history: history ?? this.history,
    );
  }
}

// 네비게이션 상태 노티파이어
class NavigationStateNotifier extends StateNotifier<NavigationState> {
  NavigationStateNotifier()
    : super(NavigationState(currentTab: 0, history: [0]));

  // 탭 변경
  void changeTab(int tab) {
    if (state.currentTab == tab) return;

    // 히스토리에 추가
    final newHistory = [...state.history];
    if (newHistory.isNotEmpty && newHistory.last != tab) {
      newHistory.add(tab);
    } else if (newHistory.isEmpty) {
      newHistory.add(tab);
    }

    // 히스토리가 10개를 넘으면 잘라내기
    if (newHistory.length > 10) {
      newHistory.removeAt(0);
    }

    // 상태 업데이트
    state = state.copyWith(currentTab: tab, history: newHistory);
    print('탭 변경: ${state.currentTab}, 히스토리: ${state.history}');
  }

  // 뒤로가기
  bool goBack() {
    final history = state.history;

    // 히스토리가 1개 이하면 뒤로 갈 수 없음
    if (history.length <= 1) return false;

    // 히스토리에서 현재 탭 제거하고 이전 탭으로 이동
    final newHistory = [...history];
    newHistory.removeLast();
    final previousTab = newHistory.last;

    // 상태 업데이트 전 로그
    print('뒤로가기 전: ${state.currentTab}, 히스토리: ${state.history}');

    // 상태 업데이트
    state = state.copyWith(currentTab: previousTab, history: newHistory);

    // 상태 업데이트 후 로그
    print('뒤로가기 후: ${state.currentTab}, 히스토리: ${state.history}');

    return true;
  }

  // 현재 탭의 히스토리 모두 제거하고 루트로 이동
  void resetCurrentTab() {
    final currentTab = state.currentTab;
    final history = [...state.history];

    // 현재 탭이 여러 번 추가되었다면 마지막 하나만 남기고 제거
    while (history.indexOf(currentTab) != history.lastIndexOf(currentTab)) {
      final index = history.indexOf(currentTab);
      if (index >= 0) {
        history.removeAt(index);
      }
    }

    state = state.copyWith(history: history);
  }
}

// 통합된 네비게이션 상태 제공자
final navigationStateProvider =
    StateNotifierProvider<NavigationStateNotifier, NavigationState>((ref) {
      return NavigationStateNotifier();
    });

// 네비게이션 키를 관리하는 프로바이더
final navigatorKeysProvider = Provider<Map<int, GlobalKey<NavigatorState>>>((
  ref,
) {
  return {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
  };
});

/// 전역 네비게이션 컨테이너 - 모든 탭과 내부 스택을 관리
class GlobalNavigationContainer extends ConsumerStatefulWidget {
  const GlobalNavigationContainer({super.key});

  @override
  ConsumerState<GlobalNavigationContainer> createState() =>
      _GlobalNavigationContainerState();
}

class _GlobalNavigationContainerState
    extends ConsumerState<GlobalNavigationContainer>
    with WidgetsBindingObserver {
  DateTime? _lastBackPressTime;
  int _backPressCount = 0;

  // 캐시된 페이지들을 저장 (각 탭마다 새로 구성하지 않도록)
  final Map<int, Widget> _cachedPages = {};

  // 백 버튼 이벤트 처리를 위한 잠금 메커니즘
  bool _backLock = false;
  final _lockDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 홈 탭(0)의 페이지를 캐시에 추가
    _cachedPages[0] = _buildNavigator(0);

    // 검색 탭(1)의 페이지도 미리 캐시에 추가
    _cachedPages[1] = _buildSearchNavigator();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 통합된 네비게이션 상태 사용
    final navState = ref.watch(navigationStateProvider);
    final selectedTab = navState.currentTab;

    // 선택된 탭의 페이지가 없으면 생성하여 캐시에 추가
    if (!_cachedPages.containsKey(selectedTab)) {
      // 특수 케이스: 탭 1은 검색 스크린
      if (selectedTab == 1) {
        _cachedPages[selectedTab] = _buildSearchNavigator();
      } else {
        _cachedPages[selectedTab] = _buildNavigator(selectedTab);
      }
    }

    // 이중 방어를 위한 접근법
    return WillPopScope(
      onWillPop: () async {
        // 홈 탭이면 항상 처리 허용 (앱 종료를 위한 더블 클릭 감지를 위해)
        if (ref.read(navigationStateProvider).currentTab == 0) {
          return true;
        }

        // 홈이 아닌 탭에서 잠겨있으면 처리 중지
        if (_backLock) {
          print('WillPopScope에서 백 이벤트 차단');
          return false;
        }
        return true; // PopScope에서 처리하도록 허용
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          // 이미 처리된 경우 무시
          if (didPop) return;

          // 단일 진입점으로 모든 백 버튼 이벤트 처리
          _handleBackNavigation();
        },
        child: Scaffold(
          key: ValueKey<int>(navState.currentTab), // 탭이 변경될 때마다 새 키 부여
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: KeyedSubtree(
              key: ValueKey<String>('tab-${navState.currentTab}'),
              child: _cachedPages[navState.currentTab]!,
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PlaybackBar(),
              CommonBottomNav(
                currentIndex: navState.currentTab,
                onTap: (index) async {
                  if (index == navState.currentTab) {
                    // 이미 루트 화면이면 아무 작업도 하지 않음
                    return;
                  }

                  // 검색 탭은 특별한 로그인 확인 없이 바로 이동
                  if (index == 1) {
                    _navigateToTab(index);
                    return;
                  }

                  if (index == 2 || index == 3) {
                    final isLoggedIn = await _checkLoginStatus(context, index);
                    if (!isLoggedIn) return;
                  }

                  _navigateToTab(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 문제 1번 수정: _handleBackNavigation 메서드 수정
  Future<void> _handleBackNavigation() async {
    final navState = ref.read(navigationStateProvider);
    final selectedTab = navState.currentTab;
    final navigatorKeys = ref.read(navigatorKeysProvider);
    final currentNavigatorKey = navigatorKeys[selectedTab];
    final canPopInCurrentTab =
        currentNavigatorKey?.currentState?.canPop() ?? false;

    // 검색 탭(1)에서의 특별 처리
    if (selectedTab == 1) {
      // 검색 탭에서 뒤로가기는 항상 홈 탭으로 이동
      print('검색 탭에서 홈 탭으로 이동');
      _navigateToTab(0);
      return;
    }

    // 홈 탭(0)에서의 처리
    if (selectedTab == 0) {
      // 홈 탭 내에서 뒤로갈 수 있는 경우 (네비게이션 스택이 있음)
      if (canPopInCurrentTab) {
        print('홈 탭 내부 뒤로가기 실행');
        await currentNavigatorKey?.currentState?.maybePop();
        return;
      }

      // 홈 탭의 루트에 있는 경우 (앱 종료)
      _handleHomeTabBack();
      return;
    }

    // 여기서부터는 홈 탭이 아닌 경우의 처리

    // 잠금 상태 확인 - 중복 호출 방지
    if (_backLock) {
      print('백 이벤트 잠금 상태 - 무시됨');
      return;
    }

    // 즉시 잠금 활성화
    _backLock = true;

    try {
      final navNotifier = ref.read(navigationStateProvider.notifier);

      // 중요 수정: 탭 내 뒤로가기가 가능한 경우, 먼저 시도하고 실제로 뒤로 갔는지 확인
      if (canPopInCurrentTab) {
        final didPop =
            await currentNavigatorKey?.currentState?.maybePop() ?? false;

        // 탭 내에서 뒤로가기 성공한 경우 탭 전환하지 않고 종료
        if (didPop && currentNavigatorKey?.currentState?.canPop() == true) {
          print('탭 내부 뒤로가기 성공');
          return;
        }
      }

      // 탭 내 뒤로가기가 불가능한 경우만 탭 전환 시도
      print('탭 내부 뒤로가기 불가능, 다른 탭으로 이동');

      // 이전 탭 미리 계산
      final previousTab =
          navState.history.length > 1
              ? navState.history[navState.history.length - 2]
              : 0;

      // 이전 탭으로 이동
      final success = navNotifier.goBack();

      if (success) {
        // UI 즉시 업데이트
        setState(() {
          // 이전 탭 UI 캐시 확인
          if (!_cachedPages.containsKey(previousTab)) {
            if (previousTab == 1) {
              _cachedPages[previousTab] = _buildSearchNavigator();
            } else {
              _cachedPages[previousTab] = _buildNavigator(previousTab);
            }
          }
        });
      } else {
        // 이동할 곳이 없으면 홈으로
        setState(() {
          navNotifier.changeTab(0);
        });
      }
    } finally {
      // 잠금 해제는 지연시킴
      Future.delayed(_lockDuration, () {
        if (mounted) {
          _backLock = false;
          print('백 이벤트 잠금 해제됨');
        }
      });
    }
  }

  // 홈 탭에서의 뒤로가기 처리 (앱 종료)
  void _handleHomeTabBack() {
    final now = DateTime.now();

    // 2초 이내에 두 번째 뒤로가기가 발생했는지 확인
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      // 첫 번째 뒤로가기
      _backPressCount = 1;
      _lastBackPressTime = now;

      print('첫 번째 뒤로가기 감지 - 앱 종료 안내');
      // SnackBar 대신 Toast 사용하도록 수정
      context.showToast("'뒤로' 버튼을 한 번 더 누르면 종료됩니다");
    } else {
      // 2초 이내의 두 번째 뒤로가기
      _backPressCount++;
      print('두 번째 뒤로가기 감지 - 앱 종료 진행');
      SystemNavigator.pop();
    }
  }

  // 현재 탭을 초기화 (스택을 루트로 복원)
  void _resetCurrentTab() {
    final selectedTab = ref.read(navigationStateProvider).currentTab;
    final navigatorKeys = ref.read(navigatorKeysProvider);

    // 히스토리 리셋
    ref.read(navigationStateProvider.notifier).resetCurrentTab();

    final canPop = navigatorKeys[selectedTab]?.currentState?.canPop() ?? false;
    if (canPop) {
      navigatorKeys[selectedTab]?.currentState?.popUntil(
        (route) => route.isFirst,
      );
    }
  }

  // 새 탭으로 이동
  void _navigateToTab(int index) {
    // 한 번에 탭과 히스토리 업데이트
    ref.read(navigationStateProvider.notifier).changeTab(index);

    // 기존 탐색 이력에도 추가
    ref.read(navigationHistoryProvider.notifier).addTab(index);
  }

  // 검색 탭용 특별한 네비게이터 구성
  Widget _buildSearchNavigator() {
    return const SafeArea(child: SearchScreen());
  }

  // 네비게이터 위젯 생성
  Widget _buildNavigator(int index) {
    final navigatorKeys = ref.read(navigatorKeysProvider);

    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: Navigator(
        key: navigatorKeys[index],
        onGenerateRoute: (settings) => AppRouter.generateRoute(settings, ref),
        initialRoute: _getInitialRouteForTab(index),
        observers: [
          HeroController(),
          // 3번 탭의 경우 추가 옵저버 등록 (1번 탭은 SearchScreen으로 처리되므로 제외)
          if (index == 3) NavigatorObserver(), // 네비게이션 모니터링을 위한 옵저버 추가
        ],
      ),
    );
  }

  // 각 탭의 초기 경로 반환
  String _getInitialRouteForTab(int index) {
    switch (index) {
      case 0:
        return AppRoutes.home;
      // case 1은 SearchScreen을 직접 사용하므로 여기서는 처리하지 않음
      case 2:
        return '/'; // 음악 서랍 경로
      case 3:
        return AppRoutes.myChannel;
      default:
        return AppRoutes.home;
    }
  }

  // 로그인 상태 확인 및 로그인 화면으로 리다이렉트
  Future<bool> _checkLoginStatus(BuildContext context, int index) async {
    final isLoggedIn = await checkLoginAndRedirect(
      context,
      ref,
      onLoginSuccess: () {
        // 로그인 성공 시 지연 후 탭 이동
        Future.delayed(const Duration(milliseconds: 100), () {
          _navigateToTab(index);
        });
      },
    );

    return isLoggedIn;
  }
}
