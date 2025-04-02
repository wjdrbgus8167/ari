import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 구독 상태를 관리할 StateNotifier
class SubscriptionViewModel extends StateNotifier<SubscriptionState> {
  SubscriptionViewModel() : super(SubscriptionState.initial());

  // 구독 데이터 로드 메서드
  Future<void> loadSubscriptions() async {
    state = state.copyWith(isLoading: true);
    
    // 이 부분에서 실제로는 API 호출 등을 통해 데이터를 가져옵니다.
    // 예시를 위해 더미 데이터 사용
    await Future.delayed(const Duration(milliseconds: 500));
    
    final regularSubscriptions = [
      SubscriptionModel(
        id: 1,
        title: '월간 구독 with',
        name: 'Ari',
        period: '2025.03.08 ~ 2025.04.07',
        coins: '0.24',
        monthsSubscribed: 1,
        type: SubscriptionType.regular,
      ),
    ];

    final artistSubscriptions = [
      SubscriptionModel(
        id: 2,
        title: '아티스트 구독 with',
        name: 'Weekend',
        period: '2025.03.08 ~ 2025.04.07',
        coins: '0.24',
        monthsSubscribed: 1,
        type: SubscriptionType.artist,
      ),
      SubscriptionModel(
        id: 3,
        title: '아티스트 구독 with',
        name: 'Weekend',
        period: '2025.03.08 ~ 2025.04.07',
        coins: '0.24',
        monthsSubscribed: 1,
        type: SubscriptionType.artist,
      ),
    ];
    
    state = state.copyWith(
      regularSubscriptions: regularSubscriptions, 
      artistSubscriptions: artistSubscriptions,
      isLoading: false
    );
  }

  // 구독 취소 메서드
  Future<void> cancelSubscription(int id) async {
    state = state.copyWith(isLoading: true);
    
    // 서버 API 호출 등을 통해 구독 취소 처리
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 로컬 데이터에서 해당 구독 삭제
    final updatedRegularSubscriptions = state.regularSubscriptions
        .where((subscription) => subscription.id != id)
        .toList();
        
    final updatedArtistSubscriptions = state.artistSubscriptions
        .where((subscription) => subscription.id != id)
        .toList();
    
    state = state.copyWith(
      regularSubscriptions: updatedRegularSubscriptions,
      artistSubscriptions: updatedArtistSubscriptions,
      isLoading: false
    );
  }

  // 새 구독 추가 메서드
  Future<void> navigateToSubscriptionPage(BuildContext context) async {
    Navigator.pushNamed(context, AppRoutes.subscriptionSelect);
  }
}

// 구독 상태 클래스
class SubscriptionState {
  final List<SubscriptionModel> regularSubscriptions;
  final List<SubscriptionModel> artistSubscriptions;
  final bool isLoading;

  SubscriptionState({
    required this.regularSubscriptions,
    required this.artistSubscriptions,
    required this.isLoading,
  });

  // 초기 상태 생성
  factory SubscriptionState.initial() {
    return SubscriptionState(
      regularSubscriptions: [],
      artistSubscriptions: [],
      isLoading: false,
    );
  }

  // 상태 복사 메서드
  SubscriptionState copyWith({
    List<SubscriptionModel>? regularSubscriptions,
    List<SubscriptionModel>? artistSubscriptions,
    bool? isLoading,
  }) {
    return SubscriptionState(
      regularSubscriptions: regularSubscriptions ?? this.regularSubscriptions,
      artistSubscriptions: artistSubscriptions ?? this.artistSubscriptions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 구독 타입 열거형
enum SubscriptionType {
  regular,
  artist,
}

// 구독 데이터 모델
class SubscriptionModel {
  final int id;
  final String title;
  final String name;
  final String period;
  final String coins;
  final int monthsSubscribed;
  final SubscriptionType type;

  SubscriptionModel({
    required this.id,
    required this.title,
    required this.name,
    required this.period,
    required this.coins,
    required this.monthsSubscribed,
    required this.type,
  });

  LinearGradient get accentColor {
    switch (type) {
      case SubscriptionType.regular:
        return AppColors.blueToMintGradient;
      case SubscriptionType.artist:
        return AppColors.purpleGradient;
    }
  }
}
