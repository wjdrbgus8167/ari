// 구독 내역 상태 클래스
import 'dart:ui';

import 'package:ari/data/models/subscription_history_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionHistoryState {
  final bool isLoading;
  final String selectedTab; // 'regular' 또는 'artist'
  final List<SubscriptionHistory> subscriptions;
  final List<Artist> artists;
  final String? currentSubscriptionPeriod;
  final String? selectedArtist;
  final String? errorMessage;
  
  SubscriptionHistoryState({
    this.isLoading = false,
    this.selectedTab = 'regular',
    this.subscriptions = const [],
    this.artists = const [],
    this.currentSubscriptionPeriod,
    this.selectedArtist,
    this.errorMessage,
  });
  
  SubscriptionHistoryState copyWith({
    bool? isLoading,
    String? selectedTab,
    List<SubscriptionHistory>? subscriptions,
    List<Artist>? artists,
    String? currentSubscriptionPeriod,
    String? selectedArtist,
    String? errorMessage,
  }) {
    return SubscriptionHistoryState(
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
      subscriptions: subscriptions ?? this.subscriptions,
      artists: artists ?? this.artists,
      currentSubscriptionPeriod: currentSubscriptionPeriod ?? this.currentSubscriptionPeriod,
      selectedArtist: selectedArtist ?? this.selectedArtist,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ViewModel
class SubscriptionHistoryViewModel extends StateNotifier<SubscriptionHistoryState> {
  // 실제 프로젝트에서는 여기에 Repository 주입
  SubscriptionHistoryViewModel() : super(SubscriptionHistoryState()) {
    _loadDummyData();
  }
  
  // 탭 변경
  void changeTab(String tab) {
    if (tab != state.selectedTab) {
      state = state.copyWith(selectedTab: tab);
    }
  }
  
  // 구독 기간 변경
  void changeSubscriptionPeriod(String period) {
    state = state.copyWith(currentSubscriptionPeriod: period);
  }
  
  // 아티스트 선택
  void selectArtist(String artistName) {
    state = state.copyWith(selectedArtist: artistName);
  }
  
  // 더미 데이터 로드 (실제로는 API 호출)
  void _loadDummyData() {
    state = state.copyWith(isLoading: true);
    
    // 지연 시뮬레이션
    Future.delayed(Duration(milliseconds: 500), () {
      // 더미 데이터
      final subscriptions = [
        SubscriptionHistory(
          period: '2025.01.12 ~ 2025.02.11',
          type: 'regular',
          amount: 0.213,
          streamingCount: 208,
        ),
        SubscriptionHistory(
          period: '2025.01.12 ~ 2025.02.11',
          type: 'artist',
          amount: 1,
          streamingCount: 20,
        ),
      ];
      
      final artists = [
        Artist(
          name: 'artist 1',
          imageUrl: 'https://placehold.co/30x30',
          allocation: 60,
          streamingCount: 20,
          color: const Color(0xFFC084FC),
        ),
        Artist(
          name: 'artist 2',
          imageUrl: 'https://placehold.co/30x30',
          allocation: 40,
          streamingCount: 17,
          color: const Color(0xFF2563EB),
        ),
        Artist(
          name: 'Weeknd',
          imageUrl: 'https://placehold.co/30x30',
          allocation: 80,
          streamingCount: 208,
          color: const Color(0xFFDE85FC),
        ),
      ];
      
      state = state.copyWith(
        isLoading: false,
        subscriptions: subscriptions,
        artists: artists,
        currentSubscriptionPeriod: '2025.01.12 ~ 2025.02.11',
        selectedArtist: 'Weeknd'
      );
    });
  }
}

final subscriptionHistoryViewModelProvider = StateNotifierProvider<SubscriptionHistoryViewModel, SubscriptionHistoryState>((ref) {
  return SubscriptionHistoryViewModel();
});