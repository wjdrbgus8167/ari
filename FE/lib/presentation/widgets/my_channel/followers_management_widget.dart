import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../providers/user_provider.dart';
import '../../../core/constants/app_colors.dart';

/// 팔로우/언팔로우 관리
/// 프로필 헤더 등에 표시되는 팔로우 버튼과 관련 기능 처리
class FollowersManagementWidget extends ConsumerStatefulWidget {
  final String targetMemberId; // 팔로우/언팔로우 대상 사용자 ID
  final bool isFollowing; // 현재 팔로우 중인지 여부
  final VoidCallback? onFollowChanged; // 팔로우 변경 후 콜백

  const FollowersManagementWidget({
    super.key,
    required this.targetMemberId,
    required this.isFollowing,
    this.onFollowChanged,
  });

  @override
  ConsumerState<FollowersManagementWidget> createState() =>
      _FollowersManagementWidgetState();
}

class _FollowersManagementWidgetState
    extends ConsumerState<FollowersManagementWidget> {
  // 로컬 상태
  late bool _isFollowing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 초기 팔로우 상태
    _isFollowing = widget.isFollowing;
  }

  @override
  void didUpdateWidget(FollowersManagementWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 외부에서 isFollowing이 변경되면 로컬 상태 업데이트
    if (oldWidget.isFollowing != widget.isFollowing && !_isLoading) {
      setState(() {
        _isFollowing = widget.isFollowing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 나의 ID 확인 (본인 채널이면 팔로우 버튼 표시 안 함)
    final myUserId = ref.read(userIdProvider);
    final isMySelf = myUserId == widget.targetMemberId;

    // 본인 채널이면 버튼 표시 안 함
    if (isMySelf) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: _isLoading ? null : _handleFollowAction,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isFollowing ? Colors.grey[800] : AppColors.mediumPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child:
          _isLoading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
              : Text(
                _isFollowing ? '팔로잉' : '팔로우',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }

  /// 팔로우/언팔로우 처리
  Future<void> _handleFollowAction() async {
    final channelNotifier = ref.read(myChannelProvider.notifier);

    // 로딩 상태 시작
    setState(() {
      _isLoading = true;
    });

    try {
      bool success;

      if (_isFollowing) {
        // 이미 팔로우 중이면 언팔로우
        success = await channelNotifier.unfollowMember(widget.targetMemberId);
      } else {
        // 언팔로우 중이면 팔로우
        success = await channelNotifier.followMember(widget.targetMemberId);
      }

      // 성공하면 로컬 상태 업데이트 (실패 시 viewModel에서 원래 상태로 복원)
      if (success && mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
        });

        // 팔로우 변경 후 콜백 호출
        if (mounted && widget.onFollowChanged != null) {
          widget.onFollowChanged!();
        }
      }
    } finally {
      // 작업 완료 후 로딩 상태 종료
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
