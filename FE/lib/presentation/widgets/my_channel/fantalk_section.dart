import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/my_channel_providers.dart';
import '../../../data/models/my_channel/fantalk.dart';
import '../../viewmodels/my_channel_viewmodel.dart';

/// 팬톡 섹션 위젯
/// 아티스트 채널의 팬톡 표시
class FanTalkSection extends ConsumerWidget {
  final String memberId;

  /// 생성자
  /// [memberId] : 채널 소유자의 회원 ID
  const FanTalkSection({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 팬톡 상태 가져오기
    final channelState = ref.watch(myChannelProvider);
    final fanTalkResponse = channelState.fanTalks;
    final isLoading = channelState.fanTalksStatus == MyChannelStatus.loading;
    final hasError = channelState.fanTalksStatus == MyChannelStatus.error;
    final isArtist = channelState.isArtist; // 아티스트인지 여부 확인

    // 아티스트가 아닌 경우 위젯 표시x
    if (!isArtist) {
      return const SizedBox.shrink();
    }

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
                Text(
                  '아티스트 팬톡 ${fanTalkResponse?.fantalkCount ?? 0}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (fanTalkResponse != null &&
                    fanTalkResponse.fantalks.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      // TODO: 팬톡 전체 목록 페이지로 이동
                      print('팬톡 더보기 클릭');
                    },
                    child: Text(
                      '더 보기',
                      style: TextStyle(color: Colors.blue[300], fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),

          // 로딩 중 표시
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            )

          // 에러 표시
          else if (hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '팬톡을 불러오는데 실패했습니다.\n다시 시도해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[300], fontSize: 14),
                ),
              ),
            )

          // 팬톡이 없는 경우 메시지 표시
          else if (fanTalkResponse == null || fanTalkResponse.fantalks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '아티스트 팬톡이 없습니다. 첫 팬톡을 작성해보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
            )

          // 팬톡 목록 표시 (최대 2개)
          else
            ...fanTalkResponse.fantalks
                .take(2)
                .map((fanTalk) => _buildFanTalkItem(context, fanTalk))
                .toList(),

          // 팬톡 작성 버튼 (항상 표시)
          if (!isLoading && !hasError)
            _buildWriteFanTalkButton(context),
        ],
      ),
    );
  }

  /// 섹션 헤더 위젯 (제목과 더보기 버튼)
  Widget _buildSectionHeader(FanTalkResponse? fanTalkResponse) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 팬톡 제목과 개수
          Text(
            '아티스트 팬톡 ${fanTalkResponse?.fantalkCount ?? 0}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // 더보기 버튼 (팬톡이 있을 경우에만 표시)
          if (fanTalkResponse != null && fanTalkResponse.fantalks.isNotEmpty)
            GestureDetector(
              onTap: () {
                // TODO: 팬톡 전체 목록 페이지로 이동
                print('팬톡 더보기');
              },
              child: Text(
                '더 보기',
                style: TextStyle(color: Colors.blue[300], fontSize: 14),
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
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
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
          Text(fanTalk.content, style: const TextStyle(color: Colors.white)),

          // 첨부한 이미지가 있으면 표시
          if (fanTalk.fantalkImageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fanTalk.fantalkImageUrl!,
                width: double.infinity,
                height: 150,
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
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1),
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
              // TODO: 트랙 재생 처리
              print('트랙 재생: ${track.trackName}');
            },
          ),
        ],
      ),
    );
  }

  /// 팬톡 작성 버튼 위젯
  Widget _buildWriteFanTalkButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: OutlinedButton(
        onPressed: () {
          // TODO: 팬톡 작성 페이지로 이동
          print('팬톡 작성 버튼 클릭');
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue, width: 1),
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
        ),
        child: const Text(
          '팬톡 작성하기',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
