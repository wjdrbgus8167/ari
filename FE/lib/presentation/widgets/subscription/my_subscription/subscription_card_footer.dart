import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:ari/presentation/widgets/subscription/my_subscription/cancel_button.dart';
import 'package:ari/presentation/widgets/subscription/my_subscription/coin_display.dart';
import 'package:flutter/material.dart';

class CardFooter extends StatelessWidget {
  final SubscriptionModel subscriptionModel;
  final VoidCallback onCancelPressed;

  const CardFooter({
    super.key,
    required this.subscriptionModel,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                subscriptionModel.period,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 7),
              CoinDisplay(coins: subscriptionModel.coins),
            ],
          ),
          CancelButton(onPressed: onCancelPressed),
        ],
      ),
    );
  }
}
