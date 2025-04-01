import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../data/models/my_channel/channel_info.dart';
import '../../../presentation/viewmodels/my_channel_viewmodel.dart';

/// 나의 채널 프로필 헤더 위젯
/// 사용자 이름, 프로필 이미지, 팔로우 버튼 등
class ProfileHeader extends ConsumerWidget {
  final String memberId;
  final bool isMyProfile; // 내 프로필인지 여부
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

    // 스크롤 위치에 따른 헤더 크기 조정
    final scrollOffset =
        scrollController.hasClients
            ? scrollController.offset.clamp(0, 100)
            : 0.0;
    final shrinkPercentage = scrollOffset / 100;

    // 프로필 이미지 크기 조정 (스크롤에 따라 축소)
    final profileSize = 100 - (30 * shrinkPercentage);

    // 헤더 높이 조정 (스크롤에 따라 축소)
    final headerHeight = 220 - (50 * shrinkPercentage);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
              : (channelInfo == null
                  ? const Center(
                    child: Text(
                      '채널 정보를 불러올 수 없습니다.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                  : _buildProfileContent(
                    context,
                    channelInfo,
                    channelNotifier,
                    profileSize,
                  )),
    );
  }

  /// 프로필 콘텐츠 구성 (프로필 이미지, 이름, 팔로우 버튼 등)
  Widget _buildProfileContent(
    BuildContext context,
    ChannelInfo channelInfo,
    MyChannelNotifier channelNotifier,
    double profileSize,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 프로필 이미지
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: profileSize,
                height: profileSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                  image: DecorationImage(
                    image: NetworkImage(channelInfo.profileImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child:
                    channelInfo.profileImageUrl.isEmpty
                        ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: profileSize * 0.6,
                        )
                        : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 채널명
                    Text(
                      channelInfo.memberName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // 구독자 수
                    Text(
                      '${channelInfo.subscriberCount}명 구독중',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    // 팔로우 버튼 (자신의 프로필이 아닌 경우에만 표시)
                    if (!isMyProfile)
                      _buildFollowButton(channelInfo, channelNotifier),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 팔로우/언팔로우 버튼
  Widget _buildFollowButton(
    ChannelInfo channelInfo,
    MyChannelNotifier channelNotifier,
  ) {
    return ElevatedButton(
      onPressed: () {
        if (channelInfo.isFollowed) {
          // 이미 팔로우 중이면 언팔로우
          // TODO: followId 가져오기 로직 구현 필요!!
          // 임시로 빈 문자열 사용
          channelNotifier.unfollowMember('', memberId);
        } else {
          // 팔로우하지 않은 경우 팔로우
          channelNotifier.followMember(memberId);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: channelInfo.isFollowed ? Colors.grey : Colors.blue,
        minimumSize: const Size(120, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        channelInfo.isFollowed ? '팔로우 중' : '팔로우',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
