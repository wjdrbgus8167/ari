import 'package:ari/core/utils/genre_utils.dart';
import 'package:ari/presentation/pages/genre/genre_page.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/core/utils/login_redirect_util.dart';
import 'package:ari/providers/navigation_history_provider.dart';
import 'package:ari/presentation/widgets/common/bottom_nav.dart';
import 'package:ari/presentation/widgets/common/playback_bar.dart';
import 'package:ari/presentation/pages/search/search_screen.dart';

// ──────────────────────────────────────────────────────────────────────────
// 네비게이션 상태 클래스
// ──────────────────────────────────────────────────────────────────────────

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

class NavigationStateNotifier extends StateNotifier<NavigationState> {
  NavigationStateNotifier()
    : super(NavigationState(currentTab: 0, history: [0]));

  // 탭 변경
  void changeTab(int tab) {
    if (state.currentTab == tab) return;

    final newHistory = [...state.history];
    // 중복되지 않으면 히스토리에 추가
    if (newHistory.isEmpty || newHistory.last != tab) {
      newHistory.add(tab);
    }
    // 오래된 히스토리 제거
    if (newHistory.length > 10) {
      newHistory.removeAt(0);
    }

    state = state.copyWith(currentTab: tab, history: newHistory);
    print('탭 변경: ${state.currentTab}, 히스토리: ${state.history}');
  }

  // 뒤로가기
  bool goBack() {
    final history = state.history;
    if (history.length <= 1) return false;

    final newHistory = [...history];
    newHistory.removeLast();
    final previousTab = newHistory.last;

    print('뒤로가기 전: 탭=${state.currentTab}, 히스토리=$history');
    state = state.copyWith(currentTab: previousTab, history: newHistory);
    print('뒤로가기 후: 탭=${state.currentTab}, 히스토리=${state.history}');
    return true;
  }

  // 현재 탭을 리셋(루트로 이동)
  void resetCurrentTab() {
    final currentTab = state.currentTab;
    final newHistory = [...state.history];

    while (newHistory.indexOf(currentTab) !=
        newHistory.lastIndexOf(currentTab)) {
      final idx = newHistory.indexOf(currentTab);
      if (idx >= 0) newHistory.removeAt(idx);
    }

    state = state.copyWith(history: newHistory);
  }
}

// ──────────────────────────────────────────────────────────────────────────
// 프로바이더
// ──────────────────────────────────────────────────────────────────────────

final navigationStateProvider =
    StateNotifierProvider<NavigationStateNotifier, NavigationState>((ref) {
      return NavigationStateNotifier();
    });

// Navigator 키
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

// ──────────────────────────────────────────────────────────────────────────
// GlobalNavigationContainer
// ──────────────────────────────────────────────────────────────────────────

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

  // 탭별 페이지 캐시
  final Map<int, Widget> _cachedPages = {};

  bool _backLock = false;
  final _lockDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 0번(홈) 캐시
    _cachedPages[0] = _buildNavigator(0);
    // 1번(검색) 캐시
    _cachedPages[1] = _buildSearchNavigator();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationStateProvider);
    final selectedTab = navState.currentTab;

    if (!_cachedPages.containsKey(selectedTab)) {
      if (selectedTab == 1) {
        _cachedPages[selectedTab] = _buildSearchNavigator();
      } else {
        _cachedPages[selectedTab] = _buildNavigator(selectedTab);
      }
    }

    return WillPopScope(
      onWillPop: () async {
        // 홈 탭(0)이면 "두 번 눌러 종료" 로직을 위해 true 반환
        if (selectedTab == 0) return true;

        // 홈 외 탭에서 백 이벤트 잠금 중이면 막음
        if (_backLock) {
          print('WillPopScope 백 이벤트 잠금 중');
          return false;
        }
        return true;
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) _handleBackNavigation();
        },
        child: Scaffold(
          key: ValueKey<int>(selectedTab),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder:
                (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey<String>('tab-$selectedTab'),
              child: _cachedPages[selectedTab]!,
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PlaybackBar(),
              CommonBottomNav(
                currentIndex: selectedTab,
                onTap: (index) async {
                  if (index == selectedTab) return;

                  // 탭 1(검색)은 로그인 체크 불필요
                  if (index == 1) {
                    _navigateToTab(index);
                    return;
                  }

                  // 탭 2,3은 로그인 체크
                  if (index == 2 || index == 3) {
                    final ok = await _checkLoginStatus(context, index);
                    if (!ok) return;
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

  // ────────────────────────────────────────────────────────────────────────
  // 뒤로가기 핸들러
  // ────────────────────────────────────────────────────────────────────────
  Future<void> _handleBackNavigation() async {
    final navState = ref.read(navigationStateProvider);
    final selectedTab = navState.currentTab;
    final navKeys = ref.read(navigatorKeysProvider);
    final currentKey = navKeys[selectedTab];
    final canPopInCurrentTab = currentKey?.currentState?.canPop() ?? false;

    // (1) 검색 탭(1)에서는 뒤로가면 홈(0)으로
    if (selectedTab == 1) {
      print('검색 탭 → 홈 탭');
      _navigateToTab(0);
      return;
    }

    // (2) 홈 탭(0) 처리: 스택이 있으면 pop, 없으면 앱 종료
    if (selectedTab == 0) {
      if (canPopInCurrentTab) {
        print('홈 탭 내부 뒤로가기');
        await currentKey?.currentState?.maybePop();
        return;
      }
      _handleHomeTabBack(); // 앱 종료 로직
      return;
    }

    // (3) 그 외 탭(2,3 등)
    if (_backLock) {
      print('백 이벤트 잠금 중 - 무시됨');
      return;
    }
    _backLock = true;

    try {
      final navNotifier = ref.read(navigationStateProvider.notifier);

      // 탭 내 pop 가능 여부
      if (canPopInCurrentTab) {
        final didPop = await currentKey?.currentState?.maybePop() ?? false;
        if (didPop && currentKey?.currentState?.canPop() == true) {
          print('탭 내부 뒤로가기 성공');
          return;
        }
      }

      print('탭 내부 뒤로 불가능 → 이전 탭으로');
      final success = navNotifier.goBack();
      if (!success) {
        // 실패 시 홈으로
        navNotifier.changeTab(0);
      } else {
        final prevTab = navNotifier.state.currentTab;
        setState(() {
          if (!_cachedPages.containsKey(prevTab)) {
            if (prevTab == 1) {
              _cachedPages[prevTab] = _buildSearchNavigator();
            } else {
              _cachedPages[prevTab] = _buildNavigator(prevTab);
            }
          }
        });
      }
    } finally {
      Future.delayed(_lockDuration, () {
        if (mounted) {
          _backLock = false;
          print('백 이벤트 잠금 해제');
        }
      });
    }
  }

  // 홈 탭 → 두 번 누르면 종료
  void _handleHomeTabBack() {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      _backPressCount = 1;
      print('첫 뒤로 → 안내');
      context.showToast("'뒤로' 버튼을 한 번 더 누르면 종료됩니다");
    } else {
      _backPressCount++;
      print('두 번째 뒤로 → 종료');
      SystemNavigator.pop();
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 탭 전환
  // ────────────────────────────────────────────────────────────────────────
  void _navigateToTab(int index) {
    ref.read(navigationStateProvider.notifier).changeTab(index);
    ref.read(navigationHistoryProvider.notifier).addTab(index);
  }

  void _resetCurrentTab() {
    final state = ref.read(navigationStateProvider);
    final key = ref.read(navigatorKeysProvider)[state.currentTab];
    ref.read(navigationStateProvider.notifier).resetCurrentTab();

    if (key?.currentState?.canPop() == true) {
      key?.currentState?.popUntil((route) => route.isFirst);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 로그인 체크
  // ────────────────────────────────────────────────────────────────────────
  Future<bool> _checkLoginStatus(BuildContext context, int index) async {
    final isLoggedIn = await checkLoginAndRedirect(
      context,
      ref,
      onLoginSuccess:
          () => Future.delayed(const Duration(milliseconds: 100), () {
            _navigateToTab(index);
          }),
    );
    return isLoggedIn;
  }

  // ────────────────────────────────────────────────────────────────────────
  // (탭 1) 검색 전용 Navigator
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildSearchNavigator() {
    final navKeys = ref.read(navigatorKeysProvider);
    return Navigator(
      key: navKeys[1],
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/search':
            return MaterialPageRoute(builder: (_) => const SearchScreen());

          case '/genre':
            // 장르 페이지: 탭 1 Navigator에서 라우트 처리
            final args = settings.arguments as Map<String, dynamic>?;
            final genreParam = args?['genre'] as Genre? ?? Genre.all;
            return MaterialPageRoute(
              builder: (_) => GenrePage(genre: genreParam),
            );

          default:
            return MaterialPageRoute(builder: (_) => const SearchScreen());
        }
      },
      initialRoute: '/search',
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // (탭 0,2,3) Navigator
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildNavigator(int index) {
    final navKeys = ref.read(navigatorKeysProvider);
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: Navigator(
        key: navKeys[index],
        onGenerateRoute: (settings) => AppRouter.generateRoute(settings, ref),
        initialRoute: _getInitialRouteForTab(index),
        observers: [HeroController(), if (index == 3) NavigatorObserver()],
      ),
    );
  }

  String _getInitialRouteForTab(int index) {
    switch (index) {
      case 0:
        return AppRoutes.home; // 홈
      // case 1 → 위 _buildSearchNavigator()에서 처리(/search)
      case 2:
        return AppRoutes.musicDrawer;
      case 3:
        return AppRoutes.myChannel;
      default:
        return AppRoutes.home;
    }
  }
}
