import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../data/models/my_channel/artist_notice.dart';
import '../../../presentation/widgets/my_channel/notice_comment_section.dart';
import '../../viewmodels/my_channel/my_channel_viewmodel.dart';
import '../../../presentation/widgets/common/custom_toast.dart';

/// 아티스트 공지사항 상세 화면
/// 공지사항 전체 내용, 이미지 표시, 댓글과 이전 공지사항 목록 표시
class ArtistNoticeDetailScreen extends ConsumerStatefulWidget {
  final int noticeId;
  final String artistName;

  /// [noticeId] : 표시할 공지사항 ID
  /// [artistName] : 아티스트 이름 (AppBar 타이틀 표시용)
  const ArtistNoticeDetailScreen({
    super.key,
    required this.noticeId,
    required this.artistName,
  });

  @override
  ConsumerState<ArtistNoticeDetailScreen> createState() =>
      _ArtistNoticeDetailScreenState();
}

class _ArtistNoticeDetailScreenState
    extends ConsumerState<ArtistNoticeDetailScreen> {
  bool _isLoading = true;
  late int _currentNoticeId;

  @override
  void initState() {
    super.initState();
    _currentNoticeId = widget.noticeId;

    // 화면 렌더링 후 공지사항 상세 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNoticeDetail();
      _loadNoticesList();
    });
  }

  /// 공지사항 상세 정보 로드
  Future<void> _loadNoticeDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 공지사항 상세 정보 요청
      await ref
          .read(myChannelProvider.notifier)
          .loadArtistNoticeDetail(_currentNoticeId);
    } catch (e) {
      if (mounted) {
        context.showToast('공지사항을 불러오는데 실패했습니다');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 공지사항 목록 로드 (이미 로드되어 있지 않은 경우)
  Future<void> _loadNoticesList() async {
    final noticeResponse = ref.read(myChannelProvider).artistNotices;
    if (noticeResponse == null || noticeResponse.notices.isEmpty) {
      // 공지사항 정보가 없으면 아티스트 ID를 통해 목록 로드 해야됨
      // 여기서는 아티스트 ID를 얻을 수 없음
      // P3 TODO: 아티스트 ID를 상세화면 진입 시 전달하도록 수정
    }
  }

  /// 다른 공지사항으로 전환
  void _switchToNotice(int noticeId) {
    setState(() {
      _currentNoticeId = noticeId;
    });
    _loadNoticeDetail();
  }

  @override
  Widget build(BuildContext context) {
    // 공지사항 상세 정보와 상태 구독
    final channelState = ref.watch(myChannelProvider);
    final notice = channelState.artistNoticeDetail;
    final noticesList = channelState.artistNotices?.notices ?? [];

    final isLoading =
        _isLoading ||
        channelState.artistNoticeDetailStatus == MyChannelStatus.loading;
    final hasError =
        channelState.artistNoticeDetailStatus == MyChannelStatus.error;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          '${widget.artistName}의 공지사항',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.mediumPurple),
              )
              : hasError
              ? _buildErrorView()
              : notice == null
              ? _buildEmptyView()
              : _buildDetailPageContent(notice, noticesList),
    );
  }

  /// 에러 화면
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 48),
          const SizedBox(height: 16),
          Text(
            '공지사항을 불러오는데 실패했습니다',
            style: TextStyle(color: Colors.red[300], fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadNoticeDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mediumPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 공지사항이 없는 경우 화면
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, color: Colors.grey[500], size: 48),
          const SizedBox(height: 16),
          Text(
            '공지사항을 찾을 수 없습니다',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// 공지사항 상세 페이지
  Widget _buildDetailPageContent(
    ArtistNotice notice,
    List<ArtistNotice> noticesList,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 공지사항 상세 영역
          _buildCurrentNotice(notice),

          // 구분선
          // const SizedBox(height: 32),
          // const Divider(color: Colors.grey, height: 1),
          // const SizedBox(height: 24),

          // 댓글 섹션
          NoticeCommentSection(noticeId: _currentNoticeId),

          // 구분선
          const SizedBox(height: 32),
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 24),

          // 이전 공지사항 목록
          _buildPreviousNotices(noticesList),

          // 하단 여백
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 현재 선택된 공지사항 상세 정보
  Widget _buildCurrentNotice(ArtistNotice notice) {
    // 날짜 포맷팅
    final dateFormatter = DateFormat('yyyy.MM.dd');
    final dateTime = DateTime.parse(notice.createdAt);
    final formattedDate = dateFormatter.format(dateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 공지사항 헤더 (제목 + 날짜)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '현재 공지',
              style: TextStyle(
                color: AppColors.mediumPurple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formattedDate, // 날짜 우측 배치
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.mediumPurple.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 공지사항 내용
              Text(
                notice.noticeContent,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),

              // 텍스트 밑에 이미지
              if (notice.noticeImageUrl != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Hero(
                    tag: 'notice_image_${notice.noticeId}',
                    child: Image.network(
                      notice.noticeImageUrl!,
                      width: double.infinity,
                      height: 300, // 이미지 높이 제한
                      fit: BoxFit.cover, // 이미지 비율 유지하면서 크기 조절
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150, // 에러 시 컨테이너 높이
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 36,
                            ),
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
      ],
    );
  }

  /// 이전 공지사항 목록
  Widget _buildPreviousNotices(List<ArtistNotice> noticesList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          ' 공지 목록',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // 이전 공지사항 목록이 비어있는 경우
        if (noticesList.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '이전 공지사항이 없습니다.',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          )
        // 이전 공지사항 목록 표시
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: noticesList.length,
            itemBuilder: (context, index) {
              final notice = noticesList[index];
              return _buildPreviousNoticeItem(notice);
            },
          ),
      ],
    );
  }

  /// 이전 공지사항 아이템
  Widget _buildPreviousNoticeItem(ArtistNotice notice) {
    // 날짜 포맷팅
    final dateFormatter = DateFormat('yyyy.MM.dd');
    final dateTime = DateTime.parse(notice.createdAt);
    final formattedDate = dateFormatter.format(dateTime);

    // 현재 선택된 공지사항인지 확인
    final isSelected = notice.noticeId == _currentNoticeId;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          _switchToNotice(notice.noticeId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.mediumPurple.withValues(alpha: 0.15)
                  : Colors.transparent,
          border: Border.all(
            color:
                isSelected
                    ? AppColors.mediumPurple
                    : Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    color:
                        isSelected ? AppColors.mediumPurple : Colors.grey[400],
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mediumPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '현재 공지',
                      style: TextStyle(
                        color: AppColors.mediumPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice.noticeContent,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),

            // 이미지 미리보기 (있는 경우)
            if (notice.noticeImageUrl != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.image, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '이미지 첨부됨',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
