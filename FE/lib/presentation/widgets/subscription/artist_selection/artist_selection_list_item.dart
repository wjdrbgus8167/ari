// widgets/subscription_list_item.dart
import 'package:ari/presentation/viewmodels/subscription/artist_selection_viewmodel.dart';
import 'package:flutter/material.dart';

class ArtistSelectionListItem extends StatelessWidget {
  final ArtistInfo artistInfo;
  final VoidCallback onToggleSubscription;
  final VoidCallback? onToggleCheck; // 체크 상태 변경을 위한 콜백 추가

  const ArtistSelectionListItem({
    super.key,
    required this.artistInfo,
    required this.onToggleSubscription,
    this.onToggleCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 프로필 정보
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 프로필 이미지
              Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(10),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 0.50),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 이름 및 팔로워 정보
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artistInfo.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${artistInfo.followers} / ${artistInfo.subscribers}',
                      style: const TextStyle(
                        color: Color(0xFFD9D9D9),
                        fontSize: 8,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 구독 상태에 따른 3가지 표시 방식
          _buildSubscriptionWidget(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionWidget() {
    // 1. 구독 중인 경우 - 텍스트 표시 (클릭 비활성화)
    print("구독중임: ${artistInfo.name} ${artistInfo.isSubscribed}");
    if (artistInfo.isSubscribed) {
      return const Text(
        '구독 중',
        style: TextStyle(
          color: Color(0xFFDE85FC),
          fontSize: 13,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
        ),
      );
    } 
    // 2. 구독 안 된 경우 - 체크박스 표시
    else {
      return GestureDetector(
        onTap: onToggleSubscription,  // 체크 상태 변경
        child: Container(
          width: 37,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 29,
                height: 29,
                child: Checkbox(
                  value: artistInfo.isChecked,  // 체크 상태 표시
                  onChanged: (_) => onToggleSubscription(),  // 체크박스 클릭 시 상태 변경
                  activeColor: Color(0xFFDE85FC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}