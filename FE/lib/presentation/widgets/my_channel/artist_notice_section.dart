import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../providers/user_provider.dart';
import '../../../data/models/my_channel/artist_notice.dart';
import '../../viewmodels/my_channel/my_channel_viewmodel.dart';
import '../../pages/my_channel/artist_notice_detail_screen.dart';
import '../../pages/my_channel/create_notice_screen.dart';

/// 아티스트 공지사항 섹션 위젯: 아티스트가 작성한 공지사항 표시
/// 최근 1개의 공지사항만 표시, 클릭 시 공지사항 상세 페이지로 이동
/// 본인의 채널인 경우 공지사항 작성 버튼 표시
class ArtistNoticeSection extends ConsumerWidget {
  final String memberId;

  /// [memberId] : 채널 소유자 ID
  const ArtistNoticeSection({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 아티스트 공지사항 상태 가져오기
    final channelState = ref.watch(myChannelProvider);
    final noticeResponse = channelState.artistNotices;
    final isLoading =
        channelState.artistNoticesStatus == MyChannelStatus.loading;
    final hasError = channelState.artistNoticesStatus == MyChannelStatus.error;
    final isArtist = true;

    // 현재 로그인한 사용자 ID 가져오기 (내 채널 여부 확인용)
    final currentUserId = ref.read(userIdProvider);
    final isMyChannel = currentUserId != null && currentUserId == memberId;

    // 채널 아티스트 이름 가져오기 (상세화면 타이틀용)
    final channelInfo = channelState.channelInfo;
    final artistName = channelInfo?.memberName ?? '아티스트';

    // 아티스트 이름 여부 확인 (없으면 기본값 사용)
    final displayArtistName = artistName.isNotEmpty ? artistName : '아티스트';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 섹션 제목 영역
                Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          artistName,
                          style: const TextStyle(
                            color: AppColors.mediumPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "님의 공지",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // 공지사항 개수 표시
                    if (noticeResponse != null &&
                        noticeResponse.notices.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${noticeResponse.noticeCount})',
                        style: TextStyle(
                          color: AppColors.mediumPurple,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),

                // 내 채널일 경우 공지 작성 버튼 추가 (공백으로 버튼 간격 조정)
                if (isMyChannel)
                  GestureDetector(
                    onTap: () => _navigateToCreateNotice(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mediumPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.mediumPurple.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: AppColors.mediumPurple,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '작성',
                            style: TextStyle(
                              color: AppColors.mediumPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
                child: CircularProgressIndicator(color: AppColors.mediumPurple),
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Text(
                '작성한 공지사항이 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          // 공지사항 표시 (최근 1개만)
          else
            _buildNoticeItem(
              context,
              noticeResponse.notices[0],
              noticeResponse,
              artistName,
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
    String artistName,
  ) {
    // 날짜 포맷팅
    final dateFormatter = DateFormat('yyyy.MM.dd');
    final dateTime = DateTime.parse(notice.createdAt);
    final formattedDate = dateFormatter.format(dateTime);

    return GestureDetector(
      onTap: () {
        // 공지사항 상세 페이지로 이동
        _navigateToNoticeDetail(context, notice.noticeId, artistName);
      },

      // 나의 앨범 섹션처럼 카드 내부 배경을 테두리 색깔(보라색)로
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightPurple.withValues(alpha: 0.15), // 배경색 수정
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.mediumPurple.withValues(alpha: 0.3), // 테두리 투명도 수정
            width: 1,
          ),
        ),

        // 기존: 위와 다르게 그냥 검정st 배경
        // child: Container(
        //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //   decoration: BoxDecoration(
        //     color: Colors.grey[900],
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(
        //       color: AppColors.mediumPurple.withValues(alpha: 0.3),
        //       width: 1,
        //     ),
        //   ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 제목 영역에 공지사항 표시
                const Text(
                  '최근 공지',
                  style: TextStyle(
                    color: AppColors.mediumPurple,
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
              Hero(
                tag: 'notice_image_${notice.noticeId}', // Hero 태그 추가 (상세화면과 연결)
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    notice.noticeImageUrl!,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.fitHeight,
                    loadingBuilder: (ctx, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[800],
                        child: Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                            color: AppColors.mediumPurple,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 공지사항 상세 페이지로 이동
  void _navigateToNoticeDetail(
    BuildContext context,
    int noticeId,
    String artistName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ArtistNoticeDetailScreen(
              noticeId: noticeId,
              artistName: artistName,
            ),
      ),
    );
  }

  /// 공지사항 작성 페이지로 이동
  void _navigateToCreateNotice(BuildContext context, WidgetRef ref) async {
    // 공지사항 작성 페이지로 이동
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNoticeScreen(memberId: memberId),
      ),
    );

    // 공지사항 작성 성공 시 목록 새로고침
    if (result == true) {
      ref.read(myChannelProvider.notifier).loadArtistNotices(memberId);
    }
  }
}
