import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // 날짜/숫자 포맷팅과 파싱
import '../../../providers/my_channel_providers.dart';
import '../../../data/models/my_channel/artist_notice.dart';
import '../../viewmodels/my_channel_viewmodel.dart';

/// 아티스트 공지사항 섹션 위젯: 아티스트가 작성한 공지사항 표시
/// 최근 1개의 공지사항만 표시하고, 클릭 시 공지사항 상세 페이지로 이동
class ArtistNoticeSection extends ConsumerWidget {
  final String memberId;
  const ArtistNoticeSection({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 아티스트 공지사항 상태 가져오기
    final channelState = ref.watch(myChannelProvider);
    final noticeResponse = channelState.artistNotices;
    final isLoading =
        channelState.artistNoticesStatus == MyChannelStatus.loading;
    final hasError = channelState.artistNoticesStatus == MyChannelStatus.error;
    final isArtist = channelState.isArtist; // 아티스트 회원인지 여부 확인

    // 아티스트가 아닌 경우 위젯을 표시하지 않음
    if (!isArtist) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '아티스트 공지',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (noticeResponse != null && noticeResponse.notices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 공지사항 상세 페이지(공지 댓글, 이전 공지 확인)로 이동
                        print('공지사항 더보기 클릭');
                      },
                      child: Text(
                        '더 보기',
                        style: TextStyle(color: Colors.blue[300], fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 로딩 중 표시시
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
                  '공지사항을 불러오는데 실패했습니다.\n다시 시도해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[300], fontSize: 14),
                ),
              ),
            )

          // 공지사항이 없는 경우 메시지 표시
          else if (noticeResponse == null || noticeResponse.notices.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '아티스트가 작성한 공지사항이 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
            )

          // 공지사항 표시 (최근 1개만)
          else
            _buildNoticeItem(
              context,
              noticeResponse.notices[0],
              noticeResponse,
            ),
        ],
      ),
    );
  }

  /// 개별 공지사항 아이템 위젯
  Widget _buildNoticeItem(
    BuildContext context,
    ArtistNotice notice,
    ArtistNoticeResponse noticeResponse,
  ) {
    // 날짜 포맷팅
    final dateFormatter = DateFormat('yyyy.MM.dd');
    final dateTime = DateTime.parse(notice.createdAt);
    final formattedDate = dateFormatter.format(dateTime);

    return GestureDetector(
      onTap: () {
        // TODO: 공지사항 상세 페이지로 이동하는 네비게이션 로직
        print('공지사항 클릭: ${notice.noticeId}');

      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 제목 영역에 공지사항 개수 표시 추가
                Text(
                  '공지사항 (${noticeResponse.noticeCount})',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice.noticeContent,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            if (notice.noticeImageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  notice.noticeImageUrl!,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 8),
            // 공지사항이 더 있음을 알리는 '더보기' 링크
            if (noticeResponse.noticeCount > 1)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '더보기 ›',
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
