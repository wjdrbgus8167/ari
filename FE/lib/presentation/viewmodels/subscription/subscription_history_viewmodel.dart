// 통합 구독 내역 상태 클래스
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionHistoryState {
  final String selectedTab;
  
  SubscriptionHistoryState({
    this.selectedTab = 'regular',
  });
  
  SubscriptionHistoryState copyWith({
    String? selectedTab,
  }) {
    return SubscriptionHistoryState(
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

// 통합 ViewModel 클래스
class SubscriptionHistoryViewModel extends StateNotifier<SubscriptionHistoryState> {
  SubscriptionHistoryViewModel() 
      : super(SubscriptionHistoryState());
  
  void changeTab(String tabId) {
    state = state.copyWith(selectedTab: tabId);
  }
}

// Provider 정의
final subscriptionHistoryViewModelProvider =
    StateNotifierProvider<SubscriptionHistoryViewModel, SubscriptionHistoryState>((ref) {
  return SubscriptionHistoryViewModel();
});