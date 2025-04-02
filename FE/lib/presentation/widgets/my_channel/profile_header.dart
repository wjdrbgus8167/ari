import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../presentation/viewmodels/my_channel/my_channel_viewmodel.dart';
import 'followers_management_widget.dart';

/// 사용자 프로필 헤더
/// 채널 주인의 프로필 이미지, 이름, 팔로우 정보 등 표시
class ProfileHeader extends ConsumerWidget {
  final String memberId;
  final bool isMyProfile;
  final ScrollController scrollController;

  /// [memberId] : 채널 주인 회원 ID
  /// [isMyProfile] : 내 프로필인지 여부
  /// [scrollController] : 스크롤 컨트롤러 (헤더 애니메이션용)
  const ProfileHeader({
    super.key,
    required this.memberId,
    required this.isMyProfile,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 채널 상태 조회
    final channelState = ref.watch(myChannelProvider);
    final channelInfo = channelState.channelInfo;
    final isLoading = channelState.channelInfoStatus == MyChannelStatus.loading;
    final hasError = channelState.channelInfoStatus == MyChannelStatus.error;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.black,
      child:
          isLoading
              ? _buildLoadingState()
              : hasError
              ? _buildErrorState()
              : channelInfo != null
              ? _buildProfileContent(context, ref, channelInfo)
              : _buildEmptyState(),
    );
  }

  /// 프로필 구성
  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    channelInfo,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 프로필 이미지
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  channelInfo.profileImageUrl.isNotEmpty
                      ? NetworkImage(channelInfo.profileImageUrl)
                      : null,
              child:
                  channelInfo.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
            ),
            const SizedBox(width: 16),

            // 프로필 정보 (이름, 계정)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channelInfo.memberName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${channelInfo.memberId}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),

                  // 팔로워/팔로잉 정보
                  Row(
                    children: [
                      Text(
                        '팔로워 ${channelInfo.followerCount}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '팔로잉 ${channelInfo.followingCount}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 팔로우/언팔로우 버튼
            if (!isMyProfile) // 내 프로필이 아닌 경우에만
              FollowersManagementWidget(
                targetMemberId: memberId,
                isFollowing: channelInfo.isFollowing,
                followId: channelInfo.followId,
                onFollowChanged: () {
                  // 팔로우 상태 변경 후 채널 정보 다시 로드
                  ref
                      .read(myChannelProvider.notifier)
                      .loadChannelInfo(memberId);
                },
              ),
          ],
        ),

        // 소개
        if (channelInfo.introduction.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            channelInfo.introduction,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ],
    );
  }

  /// 로딩 상태 UI
  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: CircularProgressIndicator(color: Colors.blue),
      ),
    );
  }

  /// 오류 상태 UI
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              '프로필 정보를 불러오는데 실패했습니다.\n다시 시도해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[300], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Text(
          '프로필 정보가 없습니다.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ),
    );
  }
}
