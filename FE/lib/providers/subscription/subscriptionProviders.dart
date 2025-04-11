// 프로바이더 정의
import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:ari/presentation/viewmodels/subscription/subscription_select_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ViewModel Provider
final subscriptionSelectViewModelProvider = 
    StateNotifierProvider<SubscriptionSelectViewModel, List<SubscriptionPlan>>((ref) {
  return SubscriptionSelectViewModel();
});

// 선택된 구독 플랜 Provider
final selectedSubscriptionPlanProvider = StateProvider<SubscriptionType?>((ref) {
  return null;
});