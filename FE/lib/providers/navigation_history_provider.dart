import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 네비게이션 히스토리 관리 provider
///
/// 사용자의 탭 이동 이력을 스택으로 관리 -> 뒤로가기 기능 제공
/// 하단 네비게이션 바의 탭 이동을 실제 페이지 이동처럼 처리함
class NavigationHistoryNotifier extends StateNotifier<List<int>> {
  NavigationHistoryNotifier() : super([0]); // 초기값은 홈 화면(0)

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
  /// @return 홈 화면(0)이고 히스토리가 1개 남았다면 true, 그렇지 않으면 false
  bool goBack() {
    // 히스토리가 1개 이하면 더는 뒤로 못감
    if (state.length <= 1) {
      return state.last == 0; // 마지막 화면이 홈이면 true 반환
    }

    // 마지막 항목을 제거한 새 상태 생성
    final List<int> newState = [...state];
    newState.removeLast();
    state = newState;

    // 홈 화면이고 히스토리가 1개 남았으면 true
    return newState.length == 1 && newState.last == 0;
  }

  /// 현재 화면 인덱스 가져오기
  int get currentTab => state.isEmpty ? 0 : state.last;
}

/// 탭 네비게이션 히스토리 provider
final navigationHistoryProvider =
    StateNotifierProvider<NavigationHistoryNotifier, List<int>>(
      (ref) => NavigationHistoryNotifier(),
    );
