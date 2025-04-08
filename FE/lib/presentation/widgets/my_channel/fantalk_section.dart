import 'package:ari/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../providers/my_channel/fantalk_providers.dart';
import '../../../data/models/my_channel/fantalk.dart';
import '../../viewmodels/my_channel/my_channel_viewmodel.dart';
import '../../../presentation/routes/app_router.dart';

/// 아티스트 채널의 팬톡 표시 (최신 1개만 표시)
/// 팬톡 전체보기 버튼 포함
class FanTalkSection extends ConsumerWidget {
  final String memberId;
  final String? fantalkChannelId;

  /// [memberId] : 채널 소유자의 회원 ID
  /// [fantalkChannelId] : 팬톡 채널 ID
  const FanTalkSection({
    super.key,
    required this.memberId,
    this.fantalkChannelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 채널 정보 상태 가져오기
    final channelState = ref.watch(myChannelProvider);
    final channelInfo = channelState.channelInfo;
    final subscriberCount = channelInfo?.subscriberCount ?? 0;
    final isArtist = channelState.isArtist; // 아티스트인지 여부 확인

    // 아티스트 이름 가져오기
    final artistName = channelInfo?.memberName ?? '아티스트';
    final displayArtistName = artistName.isNotEmpty ? artistName : '아티스트';

    // 아티스트가 아닌 경우 위젯 표시하지 않음
    if (!isArtist) {
      return const SizedBox.shrink();
    }

    // 구독자가 없는 경우 팬톡 섹션 표시하지 않음
    if (subscriberCount <= 0) {
      return const SizedBox.shrink();
    }

    // 팬톡 상태 가져오기
    final fanTalkResponse = channelState.fanTalks;
    final isLoading = channelState.fanTalksStatus == MyChannelStatus.loading;
    final hasError = channelState.fanTalksStatus == MyChannelStatus.error;

    // 구독 여부 확인
    final isSubscribed = fanTalkResponse?.subscribedYn ?? false;

    // 팬톡 개수
    final fantalkCount = fanTalkResponse?.fantalkCount ?? 0;

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더: 제목과 더보기 버튼
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 타이틀 (아티스트 이름 + 팬톡)
                Row(
                  children: [
                    Text(
                      displayArtistName,
                      style: const TextStyle(
                        color:
                            AppColors
                                .mediumPurple, // 또는 AppColors.mediumPurple 등 원하는 색상
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "님의 팬톡",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (fantalkCount > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mediumPurple.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$fantalkCount',
                          style: const TextStyle(
                            color: AppColors.mediumPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                // 더보기 버튼 (팬톡이 있을 경우에만 표시하고 구독자 또는 아티스트만 접근 가능)
                if (fantalkCount > 0 && isSubscribed)
                  GestureDetector(
                    onTap: () {
                      // 팬톡 전체 목록 페이지로 이동
                      if (fantalkChannelId != null) {
                        Navigator.of(context).pushNamed(
                          '/fantalk-list',
                          arguments: {
                            'memberId': memberId,
                            'fantalkChannelId': fantalkChannelId,
                            'isSubscribed': isSubscribed,
                          },
                        );
                      }
                    },
                    child: Text(
                      '전체보기',
                      style: TextStyle(
                        color: AppColors.mediumPurple,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 나머지 부분은 동일하게 유지
          // 로딩 중 표시
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: AppColors.mediumPurple),
              ),
            )
          // 에러 표시
          else if (hasError)
            _buildMessageBox(
              '팬톡을 불러오는데 실패했습니다.\n다시 시도해주세요.',
              textColor: Colors.red[300]!,
            )
          // 구독자가 아닌 경우 구독 안내 메시지
          else if (!isSubscribed)
            GestureDetector(
              onTap: () {
                // TODO: 구독 페이지로 라우팅
                print('구독 페이지로 이동');
              },
              child: _buildMessageBox(
                '아티스트와 구독자를 위한 팬톡입니다. \n 참여하려면 아티스트를 구독하세요!',
                icon: Icons.lock,
              ),
            )
          // 팬톡이 없는 경우 메시지 표시 (구독자에게만)
          else if (isSubscribed &&
              (fanTalkResponse == null || fanTalkResponse.fantalks.isEmpty))
            _buildMessageBox('아티스트 팬톡이 없습니다. 첫 팬톡을 작성해보세요!')
          // 팬톡 목록 표시 (최대 1개만, 구독자에게만)
          else if (isSubscribed && fanTalkResponse!.fantalks.isNotEmpty)
            _buildFanTalkItem(context, fanTalkResponse.fantalks.first),
        ],
      ),
    );
  }

  /// 메시지 박스 위젯
  Widget _buildMessageBox(
    String message, {
    IconData? icon,
    Color textColor = Colors.grey,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 팬톡 아이템 위젯
  Widget _buildFanTalkItem(BuildContext context, FanTalk fanTalk) {
    // 날짜 포맷팅
    final dateFormatter = DateFormat('yyyy.MM.dd');
    final dateTime = DateTime.parse(fanTalk.createdAt);
    final formattedDate = dateFormatter.format(dateTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자 정보, 날짜
          Row(
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    fanTalk.profileImageUrl.isNotEmpty
                        ? NetworkImage(fanTalk.profileImageUrl)
                        : null,
                child:
                    fanTalk.profileImageUrl.isEmpty
                        ? const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        )
                        : null,
              ),
              const SizedBox(width: 8),
              // 작성자 이름
              Expanded(
                child: Text(
                  fanTalk.memberName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 작성 날짜
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 팬톡 내용
          Text(
            fanTalk.content,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          // 첨부한 이미지가 있으면 표시
          if (fanTalk.fantalkImageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fanTalk.fantalkImageUrl!,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ],

          // 첨부한 트랙이 있으면 표시
          if (fanTalk.track != null) ...[
            const SizedBox(height: 12),
            _buildTrackRecommendation(fanTalk.track!),
          ],
        ],
      ),
    );
  }

  /// 트랙 첨부(추천) 위젯
  Widget _buildTrackRecommendation(FanTalkTrack track) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.mediumPurple.withValues(alpha: .3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 트랙(앨범) 커버 이미지
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: NetworkImage(track.coverImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 트랙 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 트랙 제목
                Text(
                  track.trackName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // 아티스트 이름
                Text(
                  track.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          // 재생 버튼
          IconButton(
            icon: const Icon(Icons.play_circle_outline, color: Colors.white),
            onPressed: () {
              // 트랙 재생 처리
              print('트랙 재생: ${track.trackName}');
            },
          ),
        ],
      ),
    );
  }
}
