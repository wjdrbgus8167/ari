// 프로바이더 정의
import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionViewModelProvider = StateNotifierProvider<SubscriptionViewModel, SubscriptionState>((ref) {
  return SubscriptionViewModel();
});