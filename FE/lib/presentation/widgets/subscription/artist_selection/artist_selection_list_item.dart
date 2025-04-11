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
    return SizedBox(
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // 이미지가 있으면 이미지 사용, 없으면 그라데이션 배경 사용
                  image: artistInfo.imageUrl != null && artistInfo.imageUrl != "https://placehold.co/100x100"
                      ? DecorationImage(
                          image: NetworkImage(artistInfo.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  // 이미지가 없을 때만 그라데이션 보여주기
                  gradient: artistInfo.imageUrl == null || artistInfo.imageUrl == "https://placehold.co/100x100"
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFD8C0FF), // 연한 보라색
                            Color(0xFFB5E0FF), // 연한 파란색
                          ],
                        )
                      : null,
                  // 이미지가 없을 때만 테두리 적용
                  border: artistInfo.imageUrl == null || artistInfo.imageUrl == "https://placehold.co/100x100"
                      ? Border.all(
                          color: Color(0xFF00A3FF), // 테두리 색상 (파란색)
                          width: 1.0,
                        )
                      : null,
                ),
                // 이미지가 없을 때만 아이콘 표시
                child: artistInfo.imageUrl == null || artistInfo.imageUrl == "https://placehold.co/100x100"
                    ? Center(
                        child: Icon(
                          Icons.person, // person 아이콘 (사용자 아이콘)
                          size: 50,
                          color: Colors.black54, // 어두운 회색
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 15),
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
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${artistInfo.followers} / ${artistInfo.subscribers}',
                      style: const TextStyle(
                        color: Color(0xFFD9D9D9),
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w300,
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
          fontSize: 15,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
        ),
      );
    }
    // 2. 구독 안 된 경우 - 체크박스 표시
    else {
      return GestureDetector(
        onTap: onToggleSubscription, // 체크 상태 변경
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
                  value: artistInfo.isChecked, // 체크 상태 표시
                  onChanged: (_) => onToggleSubscription(), // 체크박스 클릭 시 상태 변경
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
