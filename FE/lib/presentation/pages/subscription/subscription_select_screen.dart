import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/subscription/subscription_select/subscription_plan_card.dart';
import 'package:ari/providers/subscription/subscriptionProviders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionSelectScreen extends ConsumerStatefulWidget {
  const SubscriptionSelectScreen({super.key});

  @override
  SubscriptionSelectScreenState createState() => SubscriptionSelectScreenState();
}

class SubscriptionSelectScreenState extends ConsumerState<SubscriptionSelectScreen> {
  bool isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    // ViewModel에서 구독 플랜 목록 가져오기
    final subscriptionPlans = ref.watch(subscriptionSelectViewModelProvider);
    final viewModel = ref.read(subscriptionSelectViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 헤더 부분
              HeaderWidget(
                type: HeaderType.backWithTitle,
                title: "구독하기",
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              // 구독 플랜 목록
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // 구독 플랜 카드들
                      ...subscriptionPlans.map((plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SubscriptionPlanCard(
                          plan: plan,
                          isLoading: isLoading,
                          onTap: (type) => viewModel.navigateToSubscriptionScreen(context, type),
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}