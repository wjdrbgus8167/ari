import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/my_channel/fantalk.dart';
import '../../viewmodels/my_channel/fantalk_viewmodel.dart';
import '../../../providers/my_channel/fantalk_providers.dart';
import '../../../providers/user_provider.dart';
import '../../routes/app_router.dart';

/// 팬톡 전체 목록 화면
/// 아티스트와 구독자만 조회 및 등록 가능
class FantalkListScreen extends ConsumerStatefulWidget {
  final String memberId;
  final String fantalkChannelId;
  final bool isSubscribed;

  const FantalkListScreen({
    super.key,
    required this.memberId,
    required this.fantalkChannelId,
    required this.isSubscribed,
  });

  @override
  ConsumerState<FantalkListScreen> createState() => _FantalkListScreenState();
}

class _FantalkListScreenState extends ConsumerState<FantalkListScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 팬톡 목록 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFantalks();
      // 현재 팬톡 채널 ID 설정
      ref.read(currentFantalkChannelIdProvider.notifier).state =
          widget.fantalkChannelId;
    });
  }

  // 팬톡 로딩 메서드 추가
  Future<void> _loadFantalks() async {
    try {
      await ref
          .read(fantalkProvider.notifier)
          .loadFanTalks(widget.fantalkChannelId);
    } catch (e) {
      print('팬톡 로딩 오류: $e');
      // 오류 발생 시 처리 (예: 스낵바 표시)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('팬톡 로딩 중 오류가 발생했습니다: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 팬톡 상태 가져오기
    final fantalkState = ref.watch(fantalkProvider);
    final isLoading = fantalkState.fanTalksStatus == FantalkStatus.loading;
    final hasError = fantalkState.fanTalksStatus == FantalkStatus.error;
    final fanTalks = fantalkState.fanTalks?.fantalks ?? [];
    final fantalkCount = fantalkState.fanTalks?.fantalkCount ?? 0;
    final errorMessage = fantalkState.error?.message;

    // 현재 로그인한 사용자 정보
    final userState = ref.watch(userProvider);
    final isLoggedIn = userState.maybeWhen(
      data: (user) => user != null,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '아티스트 팬톡 $fantalkCount',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      // 팬톡 작성 버튼 (FAB)
      // 구독자이거나 채널 주인(아티스트)인 경우에만 표시
      floatingActionButton:
          widget.isSubscribed && isLoggedIn
              ? FloatingActionButton(
                onPressed: () {
                  // 팬톡 작성 화면으로 이동
                  Navigator.of(context).pushNamed(
                    '/create-fantalk',
                    arguments: {'fantalkChannelId': widget.fantalkChannelId},
                  );
                },
                backgroundColor: AppColors.mediumGreen,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
      body: RefreshIndicator(
        onRefresh: () async {
          // 당겨서 새로고침
          await ref
              .read(fantalkProvider.notifier)
              .loadFanTalks(widget.fantalkChannelId);
        },
        child: _buildContent(
          context,
          isLoading: isLoading,
          hasError: hasError,
          fanTalks: fanTalks,
          isSubscribed: widget.isSubscribed,
          errorMessage: errorMessage,
          fanTalksStatus: fantalkState.fanTalksStatus,
        ),
      ),
    );
  }

  /// 화면 컨텐츠 빌드
  Widget _buildContent(
    BuildContext context, {
    required bool isLoading,
    required bool hasError,
    required List<FanTalk> fanTalks,
    required bool isSubscribed,
    required FantalkStatus fanTalksStatus,
    String? errorMessage,
  }) {
    // 데이터가 있으면 데이터 표시
    if (fanTalks.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fanTalks.length,
        itemBuilder: (context, index) {
          return _buildFanTalkItem(context, fanTalks[index]);
        },
      );
    }

    // 로딩 중이고 데이터가 없는 경우
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mediumGreen),
      );
    }

    // 에러 발생했고 데이터가 없는 경우
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? '팬톡을 불러오는데 실패했습니다.\n아래로 당겨서 다시 시도해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[300]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFantalks,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('다시 시도', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    // 팬톡이 없는 경우 (로딩 완료 상태)
    if (fanTalksStatus == FantalkStatus.success && fanTalks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: Colors.grey[400],
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                isSubscribed ? '아직 팬톡이 없습니다.\n첫 팬톡을 작성해보세요!' : '아직 팬톡이 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // 기본 로딩 표시
    return const Center(
      child: CircularProgressIndicator(color: AppColors.mediumGreen),
    );
  }

  /// 개별 팬톡 아이템 위젯
  Widget _buildFanTalkItem(BuildContext context, FanTalk fanTalk) {
    // 날짜 포맷팅
    final dateFormatter = DateFormat('yyyy.MM.dd');
    final dateTime = DateTime.parse(fanTalk.createdAt);
    final formattedDate = dateFormatter.format(dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Text(fanTalk.content, style: const TextStyle(color: Colors.white)),

          // 첨부한 이미지가 있으면 표시
          if (fanTalk.fantalkImageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fanTalk.fantalkImageUrl!,
                width: double.infinity,
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
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
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
              // TODO: 트랙 재생 로직 구현
            },
          ),
        ],
      ),
    );
  }
}
