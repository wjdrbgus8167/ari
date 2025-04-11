import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:ari/presentation/widgets/subscription/my_subscription/subscription_card.dart';
import 'package:flutter/material.dart';

// 정기 구독 섹션
class RegularSubscriptionSection extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;
  final Function(int)? onCancelPressed;

  const RegularSubscriptionSection({
    super.key,
    required this.subscriptions,
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '정기 구독',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // 정기 구독 카드 목록
          if (subscriptions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  '정기 구독 내역이 없습니다',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ),
            )
          else
            ...subscriptions.map(
              (subscription) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SubscriptionCard(
                    subscriptionModel: subscription,
                    onCancelPressed: onCancelPressed != null 
                    ? () => onCancelPressed!(subscription.id)
                    : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 아티스트 구독 섹션
class ArtistSubscriptionSection extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;
  final Function(int)? onCancelPressed;

  const ArtistSubscriptionSection({
    super.key,
    required this.subscriptions,
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '아티스트 구독',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // 아티스트 구독 카드 목록
          if (subscriptions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  '아티스트 구독 내역이 없습니다',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ),
            )
          else
            ...subscriptions.map(
              (subscription) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SubscriptionCard(
                  subscriptionModel: subscription,
                  onCancelPressed: onCancelPressed != null 
                  ? () => onCancelPressed!(subscription.id)
                  : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
