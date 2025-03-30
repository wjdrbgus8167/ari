import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:ari/presentation/widgets/subscription/my_subscription/subscription_card_footer.dart';
import 'package:ari/presentation/widgets/subscription/my_subscription/subscription_card_header.dart';
import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscriptionModel;
  final VoidCallback onCancelPressed;

  const SubscriptionCard({
    super.key,
    required this.subscriptionModel,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: subscriptionModel.accentColor,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
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
            onCancelPressed: onCancelPressed,
          ),
        ],
      ),
    );
  }
}