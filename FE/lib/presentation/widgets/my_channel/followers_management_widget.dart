import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../providers/user_provider.dart';
import '../../../presentation/viewmodels/my_channel/my_channel_viewmodel.dart';

/// 팔로우/언팔로우 관리
/// 프로필 헤더 등에 표시되는 팔로우 버튼과 관련 기능 처리
class FollowersManagementWidget extends ConsumerWidget {
  final String targetMemberId; // 팔로우/언팔로우 대상 사용자 ID
  final bool isFollowing; // 현재 팔로우 중인지 여부
  final String? followId; // 팔로우 관계 ID (언팔로우 시 필요)
  final VoidCallback? onFollowChanged; // 팔로우 변경 후 콜백

  /// [targetMemberId] : 팔로우/언팔로우 대상 사용자 ID
  /// [isFollowing] : 현재 팔로우 중인지 여부
  /// [followId] : 팔로우 관계 ID (언팔로우 시 필요)
  /// [onFollowChanged] : 팔로우 변경 후 콜백
  const FollowersManagementWidget({
    super.key,
    required this.targetMemberId,
    required this.isFollowing,
    this.followId,
    this.onFollowChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 나의 ID 확인 (본인 채널이면 팔로우 버튼 표시 안 함)
    final myUserId = ref.watch(userIdProvider);
    final isMySelf = myUserId == targetMemberId;

    // 로딩 상태 감지
    final channelState = ref.watch(myChannelProvider);
    final isChannelInfoLoading = channelState.channelInfoStatus == MyChannelStatus.loading;

    // 본인 채널이면 버튼 표시 안 함
    if (isMySelf) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: isChannelInfoLoading
          ? null // 로딩 중이면 버튼 비활성화
          : () => _handleFollowAction(ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.grey[800] : Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: isChannelInfoLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              isFollowing ? '팔로잉' : '팔로우',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  /// 팔로우/언팔로우 처리
  Future<void> _handleFollowAction(WidgetRef ref) async {
    final channelNotifier = ref.read(myChannelProvider.notifier);

    if (isFollowing) {
      // 이미 팔로우 중이면 언팔로우
      if (followId != null) {
        await channelNotifier.unfollowMember(followId!, targetMemberId);
      } else {
        // followId가 없으면 오류 (UI에서는 발생하지 않도록 처리)
        debugPrint('언팔로우 시도 중 오류: followId가 null입니다.');
      }
    } else {
      // 언팔로우 중이면 팔로우
      await channelNotifier.followMember(targetMemberId);
    }

    // 팔로우 변경 후 콜백 호출
    if (onFollowChanged != null) {
      onFollowChanged!();
    }
  }
}