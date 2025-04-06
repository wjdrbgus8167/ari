import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../data/models/my_channel/channel_info.dart';
import '../../viewmodels/my_channel/my_channel_viewmodel.dart';
import '../../routes/app_router.dart';
import '../../../core/constants/app_colors.dart';

/// 나의 채널 프로필 헤더 위젯
/// 사용자 프로필 이미지(배경), 이름, 구독자 수, 팔로우 버튼 등
class ProfileHeader extends ConsumerWidget {
  final String memberId;
  final bool isMyProfile; // 내 프로필인지
  final ScrollController scrollController;

  const ProfileHeader({
    super.key,
    required this.memberId,
    required this.isMyProfile,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 채널 정보 가져오기
    final channelState = ref.watch(myChannelProvider);
    final channelNotifier = ref.read(myChannelProvider.notifier);
    final channelInfo = channelState.channelInfo;
    final isLoading = channelState.channelInfoStatus == MyChannelStatus.loading;
    final hasError = channelState.channelInfoStatus == MyChannelStatus.error;

    // 고정 높이
    const double headerHeight = 300;

    return Container(
      height: headerHeight,
      width: double.infinity,
      color: Colors.black,
      child:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.mediumGreen),
              )
              : hasError
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '채널 정보를 불러올 수 없습니다.',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed:
                          () => channelNotifier.loadChannelInfo(memberId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mediumGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              )
              : (channelInfo == null
                  ? const Center(
                    child: Text(
                      '채널 정보를 불러올 수 없습니다.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                  : _buildProfileContent(context, channelInfo, ref)),
    );
  }

  /// 프로필 콘텐츠 구성 (프로필 이미지 배경, 이름, 구독자 수, 팔로우 버튼 등)
  Widget _buildProfileContent(
    BuildContext context,
    ChannelInfo channelInfo,
    WidgetRef ref,
  ) {
    return Stack(
      children: [
        // 프로필 이미지 배경 (전체 영역 차지)
        if (channelInfo.profileImageUrl != null &&
            channelInfo.profileImageUrl!.isNotEmpty)
          Positioned.fill(
            child: Image.network(
              channelInfo.profileImageUrl!,
              fit: BoxFit.cover,
            ),
          )
        else
          Positioned.fill(
            child: Container(
              color: Colors.grey[900],
              child: const Center(
                child: Icon(Icons.person, color: Colors.white54, size: 100),
              ),
            ),
          ),

        // 이미지 위에 그라데이션 오버레이
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black,
                ],
                stops: const [0.4, 0.8, 1.0],
              ),
            ),
          ),
        ),

        // 내용 배치 - 하단부 위주
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "MY PAGE >" 텍스트 (내 프로필인 경우만)
              if (isMyProfile)
                Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      // 마이페이지로 이동
                      AppRouter.navigateTo(context, ref, AppRoutes.myPage);
                    },
                    child: Row(
                      children: [
                        Text(
                          'MY PAGE',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[300],
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

              // 채널명
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 왼쪽 - 채널명
                    Text(
                      channelInfo.memberName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // 오른쪽 - 팔로우 버튼 (자신의 프로필이 아닌 경우에만)
                    if (!isMyProfile) _buildFollowButton(channelInfo, ref),
                  ],
                ),
              ),

              // 구독자 수 (있는 경우만)
              if (channelInfo.subscriberCount > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 24, top: 8),
                  child: Text(
                    '${channelInfo.subscriberCount}명 구독중',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                )
              else
                // 하단 여백
                const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  /// 팔로우/언팔로우 버튼
  Widget _buildFollowButton(ChannelInfo channelInfo, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // 팔로우 상태에 따라
        // 관련 부분만 수정
        if (channelInfo.isFollowed) {
          // 언팔로우 처리 - memberId
          ref
              .read(myChannelProvider.notifier)
              .unfollowMember(channelInfo.memberId);
        } else {
          // 팔로우 처리
          ref
              .read(myChannelProvider.notifier)
              .followMember(channelInfo.memberId);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              channelInfo.isFollowed
                  ? Colors.transparent
                  : AppColors.mediumPurple,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color:
                channelInfo.isFollowed ? Colors.grey : AppColors.mediumPurple,
            width: 1,
          ),
        ),
        child: Text(
          channelInfo.isFollowed ? '팔로잉' : '팔로우',
          style: TextStyle(
            color: channelInfo.isFollowed ? Colors.grey : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
