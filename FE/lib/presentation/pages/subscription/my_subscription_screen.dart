import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/subscription/my_subscription/subscription_process_button.dart';
import 'package:ari/presentation/widgets/subscription/my_subscription/subscription_section.dart';
import 'package:ari/providers/subscription/subscriptionProviders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MySubscriptionScreen extends ConsumerStatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  MySubscriptionScreenState createState() => MySubscriptionScreenState();
}

class MySubscriptionScreenState extends ConsumerState<MySubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 구독 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mySubscriptionViewModelProvider.notifier).loadSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(mySubscriptionViewModelProvider);
    print("구독 데이터: ${viewModel.getAllSubscriptionsAsModel()}");
    return Scaffold(
      backgroundColor: Colors.black,
      body: viewModel.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.black),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 헤더 섹션
              HeaderWidget(
                type: HeaderType.backWithTitle,
                title: "나의 구독",
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
              // 구독 프로세스 버튼
              SubscriptionProcessButton(
                onPressed: () {
                  ref.read(mySubscriptionViewModelProvider.notifier).navigateToSubscriptionPage(context);
                },
              ),
              const SizedBox(height: 20),
              // 구독 목록 영역
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 정기 구독 섹션
                      RegularSubscriptionSection(
                        subscriptions: viewModel.getMonthlySubscriptionsAsModel(),
                        onCancelPressed: (id) => ref.read(mySubscriptionViewModelProvider.notifier).cancelMonthlySubscription(),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // 아티스트 구독 섹션
                      ArtistSubscriptionSection(
                        subscriptions: viewModel.getArtistSubscriptionsAsModel(),
                        onCancelPressed: (id) => ref.read(mySubscriptionViewModelProvider.notifier).cancelArtistSubscription('1'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}