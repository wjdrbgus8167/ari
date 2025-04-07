// lib/presentation/viewmodels/subscription/subscription_viewmodel.dart
import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 구독 모델 클래스
class SubscriptionPlan {
  final SubscriptionType type;
  final String title;
  final String subtitle;
  final String description;
  final double price;
  final Color borderColor;

  SubscriptionPlan({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.borderColor,
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

// 구독 관련 ViewModel
class SubscriptionSelectViewModel extends StateNotifier<List<SubscriptionPlan>> {
  SubscriptionSelectViewModel() : super([
    // 무제한 듣기 구독
    SubscriptionPlan(
      type: SubscriptionType.regular,
      title: '무제한 듣기',
      subtitle: '정기 결제',
      description: '아리와 함께 힙한 하루를 보내보세요',
      price: 1,
      borderColor: const Color(0xFF2B9FFF),
    ),
    // 아티스트 구독
    SubscriptionPlan(
      type: SubscriptionType.artist,
      title: '아티스트 구독',
      subtitle: '아티스트 정기 결제',
      description: '좋아하는 아티스트와 함께라면 뭐든 할 수 있죠',
      price: 1,
      borderColor: const Color(0xFFDE85FC),
    ),
  ]);

  // 새 구독 추가 메서드
  Future<void> navigateToSubscriptionScreen(BuildContext context, SubscriptionType type) async {
    switch (type) {
    case SubscriptionType.regular:
      // 정기 구독은 바로 구독 페이지로 이동
      Navigator.pushNamed(context, AppRoutes.subscriptionPayment);
      break;
    
    case SubscriptionType.artist:
      // 아티스트 구독은 아티스트 선택 페이지로 먼저 이동
      Navigator.pushNamed(context, AppRoutes.artistSelection);
      break;
  }
  }
}