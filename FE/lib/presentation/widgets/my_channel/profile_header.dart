// lib/presentation/widgets/my_channel/profile_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../data/models/my_channel/channel_info.dart';
import '../../viewmodels/my_channel/my_channel_viewmodel.dart';

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

    // 스크롤 위치에 따른 헤더 크기 조정
    final scrollOffset =
        scrollController.hasClients
            ? scrollController.offset.clamp(0, 100)
            : 0.0;
    final shrinkPercentage = scrollOffset / 100;

    // 헤더 높이 조정 (스크롤에 따라 축소)
    final headerHeight = 300 - (50 * shrinkPercentage);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: headerHeight,
      width: double.infinity,
      child:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
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
                        backgroundColor: Colors.blue,
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
      fit: StackFit.expand,
      children: [
        // 프로필 이미지 배경
        if (channelInfo.profileImageUrl != null &&
            channelInfo.profileImageUrl!.isNotEmpty)
          Image.network(channelInfo.profileImageUrl!, fit: BoxFit.cover)
        else
          Container(
            color: Colors.grey[900],
            child: const Center(
              child: Icon(Icons.person, color: Colors.white54, size: 100),
            ),
          ),

        // 이미지 위에 그라데이션 오버레이
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.5),
                Colors.black,
              ],
              stops: const [0.5, 0.8, 1.0],
            ),
          ),
        ),

        // 콘텐츠
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 여백
            const Spacer(),

            // "MY PAGE >" 텍스트 (내 프로필인 경우만)
            if (isMyProfile)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Text(
                      'MY PAGE',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ),

            // 채널명
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 8),
              child: Text(
                channelInfo.memberName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 구독자 수 & 팔로우 버튼
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 구독자 수 (있는 경우만)
                  if (channelInfo.subscriberCount > 0)
                    Text(
                      '${channelInfo.subscriberCount}명 구독중',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),

                  // 팔로우 버튼 (자신의 프로필이 아닌 경우에만 표시)
                  if (!isMyProfile)
                    _buildFollowButton(channelInfo, context, ref)
                  else
                    // "팔로우" 라벨 (오른쪽 정렬을 위한 빈 컨테이너)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '팔로잉',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 팔로우/언팔로우 버튼 - 이미지 스타일에 맞게 커스텀
  Widget _buildFollowButton(
    ChannelInfo channelInfo,
    BuildContext context,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () {
        // 팔로우 상태에 따라 적절한 액션 수행
        if (channelInfo.isFollowed) {
          // 언팔로우 처리
          if (channelInfo.followId != null) {
            ref
                .read(myChannelProvider.notifier)
                .unfollowMember(channelInfo.followId!, channelInfo.memberId);
          }
        } else {
          // 팔로우 처리
          ref
              .read(myChannelProvider.notifier)
              .followMember(channelInfo.memberId);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: channelInfo.isFollowed ? Colors.transparent : Colors.blue,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: channelInfo.isFollowed ? Colors.grey : Colors.blue,
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
