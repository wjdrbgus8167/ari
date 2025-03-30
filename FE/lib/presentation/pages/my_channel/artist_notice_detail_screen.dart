// lib\presentation\pages\my_channel\artist_notice_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/my_channel_providers.dart';
import '../../viewmodels/my_channel_viewmodel.dart';
import '../../widgets/common/custom_toast.dart';

/// 아티스트 공지사항 상세 화면
/// 공지사항의 전체 내용과 이미지(있는 경우)를 표시
class ArtistNoticeDetailScreen extends ConsumerStatefulWidget {
  final int noticeId;
  final String artistName; // 아티스트 이름 매개변수 추가

  /// [noticeId] : 표시할 공지사항 ID
  /// [artistName] : 아티스트 이름 (AppBar 타이틀 표시용)
  const ArtistNoticeDetailScreen({
    super.key,
    required this.noticeId,
    required this.artistName, // 필수 매개변수로 추가
  });

  @override
  ConsumerState<ArtistNoticeDetailScreen> createState() =>
      _ArtistNoticeDetailScreenState();
}

class _ArtistNoticeDetailScreenState
    extends ConsumerState<ArtistNoticeDetailScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 화면 렌더링 후 공지사항 상세 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNoticeDetail();
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
          .loadArtistNoticeDetail(widget.noticeId);
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

  @override
  Widget build(BuildContext context) {
    // 공지사항 상세 정보와 상태 구독
    final channelState = ref.watch(myChannelProvider);
    final notice = channelState.artistNoticeDetail;
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
          '${widget.artistName}의 공지사항', // 아티스트 이름 표시
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
              : _buildNoticeDetailView(notice),
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

  /// 공지사항 상세 화면
  Widget _buildNoticeDetailView(notice) {
    // 날짜 포맷팅
    final dateFormatter = DateFormat('yyyy.MM.dd HH:mm');
    final dateTime = DateTime.parse(notice.createdAt);
    final formattedDate = dateFormatter.format(dateTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 공지사항 메타 정보 (날짜)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              formattedDate,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),

          // 이미지가 있는 경우 표시
          if (notice.noticeImageUrl != null) ...[
            Hero(
              tag: 'notice_image_${notice.noticeId}', // Hero 태그 추가 (목록과 연결)
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    notice.noticeImageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 공지사항 내용
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
            child: Text(
              notice.noticeContent,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),

          // 하단 공간
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
