import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 네비게이션 히스토리 관리 provider
///
/// 사용자의 탭 이동 이력을 스택으로 관리하여 뒤로가기 기능
/// 하단 네비게이션 바의 탭 이동을 실제 페이지 이동처럼 처리
class NavigationHistoryNotifier extends StateNotifier<List<int>> {
  NavigationHistoryNotifier() : super([0]); // 초기값은 홈 화면(0)

  // 뒤로가기 버튼을 마지막으로 누른 시간
  DateTime? _lastBackPressTime;

  // 홈 화면에서 뒤로가기 버튼 누른 여부를 추적
  bool _homeBackButtonPressed = false;

  /// 뒤로가기 버튼 누른 시간 확인
  ///
  /// @return true: 빠른 연속 클릭 (1초 이내), false: 처음 클릭 또는 시간 경과
  bool isQuickSecondBackPress() {
    final now = DateTime.now();

    // 이전에 뒤로가기 버튼을 누른 적이 없거나 1초가 지난 경우
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 1)) {
      _lastBackPressTime = now;
      return false;
    }

    // 1초 이내에 다시 누른 경우
    return true;
  }

  /// 홈 화면에서 뒤로가기 버튼을 눌렀음을 표시
  void setHomeBackButtonPressed() {
    _homeBackButtonPressed = true;
  }

  /// 홈 화면에서 뒤로가기 버튼을 눌렀는지 확인
  bool isHomeBackButtonPressed() {
    // 상태 확인 후 초기화
    final wasPressed = _homeBackButtonPressed;
    _homeBackButtonPressed = false;
    return wasPressed;
  }

  /// 새 탭 추가 (중복 탭 처리 포함)
  void addTab(int tabIndex) {
    // 마지막으로 방문한 탭과 동일한 경우 히스토리에 추가하지 않음
    if (state.isNotEmpty && state.last == tabIndex) {
      return;
    }

    // 새로운 탭 인덱스를 히스토리에 추가
    state = [...state, tabIndex];
  }

  /// 이전 탭으로 이동 (뒤로가기)
  ///
  /// @return 홈 화면(0)에 있는 경우만 true, 그렇지 않으면 false
  /// 홈 화면에서는 이전 페이지 스택과 상관없이 앱 종료 처리를 위해 true 반환
  bool goBack() {
    // 현재 홈 화면(0)인지 확인
    if (state.isNotEmpty && state.last == 0) {
      // 홈 화면에서 뒤로가기 버튼을 눌렀음을 표시
      setHomeBackButtonPressed();
      return true; // 홈 화면에서는 항상 true 반환하여 앱 종료 처리
    }

    // 홈 화면이 아니면 이전 탭으로 이동
    if (state.length > 1) {
      final List<int> newState = [...state];
      newState.removeLast();
      state = newState;
    }

    return false; // 홈 화면이 아니면 false 반환
  }

  /// 현재 화면 인덱스 가져오기
  int get currentTab => state.isEmpty ? 0 : state.last;
}

/// 탭 네비게이션 히스토리 provider
final navigationHistoryProvider =
    StateNotifierProvider<NavigationHistoryNotifier, List<int>>(
      (ref) => NavigationHistoryNotifier(),
    );
