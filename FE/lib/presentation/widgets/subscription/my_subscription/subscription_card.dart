import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:ari/presentation/widgets/subscription/my_subscription/subscription_card_footer.dart';
import 'package:ari/presentation/widgets/subscription/my_subscription/subscription_card_header.dart';
import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscriptionModel;
  final VoidCallback? onCancelPressed;

  const SubscriptionCard({
    super.key,
    required this.subscriptionModel,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: subscriptionModel.accentColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        margin: const EdgeInsets.all(2), // 테두리 두께
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),// 배경색, 앱의 배경색에 맞게 변경하세요
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 상단 부분 (제목, 이름)
            CardHeader(subscriptionModel: subscriptionModel),
            
            // 하단 부분 (기간, 코인, 해지 버튼)
            CardFooter(
              subscriptionModel: subscriptionModel,
              // onCancelPressed: onCancelPressed,
            ),
          ],
        ),
      ),
    );
  }
}