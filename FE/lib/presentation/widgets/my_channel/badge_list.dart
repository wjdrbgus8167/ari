import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TODO: 배지 모델 클래스 (임시)
/// TODO: API 연결하기
class BadgeModel {
  final String id;
  final String imageUrl;
  final String name;
  final String description;

  BadgeModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.description,
  });
}

/// 뱃지 목록 위젯
/// 사용자가 획득한 배지 표시
class BadgeList extends ConsumerWidget {
  final String memberId;

  const BadgeList({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 실제 배지 데이터 연동하기
    // 임시 데이터 사용
    final badges = _getDummyBadges();

    // 배지가 없는 경우 위젯 표시 X
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Text(
              '${badges.length}개 배지',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final badge = badges[index];
                return _buildBadgeItem(context, badge);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 배지 아이템 위젯
  Widget _buildBadgeItem(BuildContext context, BadgeModel badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(context, badge),
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
                image: DecorationImage(
                  image: NetworkImage(badge.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 배지 상세 정보 다이얼로그
  void _showBadgeDetails(BuildContext context, BadgeModel badge) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              badge.name,
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(badge.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  badge.description,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
    );
  }

  /// 임시 배지 데이터
  List<BadgeModel> _getDummyBadges() {
    return [
      BadgeModel(
        id: '1',
        imageUrl: 'https://via.placeholder.com/50',
        name: '첫 앨범',
        description: '첫 앨범을 구매한 팬에게 주어지는 배지',
      ),
      BadgeModel(
        id: '2',
        imageUrl: 'https://via.placeholder.com/50',
        name: '30번째 팬',
        description: '아티스트의 30번째 팬에게 주어지는 배지',
      ),
    ];
  }
}
