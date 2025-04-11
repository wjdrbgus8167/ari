import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:ari/presentation/viewmodels/subscription/subscription_select_viewmodel.dart';
import 'package:ari/presentation/widgets/subscription/subscription_select/subscription_plan_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionPlanCard extends ConsumerWidget {
  final SubscriptionPlan plan;
  final bool isLoading;
  final Function(SubscriptionType) onTap;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 플랜 헤더
        SubscriptionPlanHeader(plan: plan),
        const SizedBox(height: 10),
        
        // 플랜 카드
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: ShapeDecoration(
            color: const Color(0xFF161616),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 2,
                color: plan.borderColor,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 플랜 제목과 설명
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _getSubtitleText(plan.type),
                ],
              ),
              const SizedBox(height: 10),
              // 하단 설명과 가격
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    plan.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      // 가격 표시
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            plan.price.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/coin_icon.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      
                      // 구매 버튼
                      InkWell(
                        onTap: () => onTap(plan.type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                          decoration: ShapeDecoration(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 0.50,
                                color: Color(0xFF989595),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 14,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  '구매',
                                  style: TextStyle(
                                    color: Color(0xFFD9D9D9),
                                    fontSize: 14,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getSubtitleText(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.regular:
        return const Text(
          '무제한 듣기',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w300,
          ),
        );
      case SubscriptionType.artist:
        return const Text(
          '무제한 듣기 + 아티스트 팬 혜택',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w300,
          ),
        );
    }
  }
}