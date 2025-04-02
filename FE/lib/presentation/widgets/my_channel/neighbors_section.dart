import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../data/models/my_channel/neighbor.dart';
import '../../viewmodels/my_channel/my_channel_viewmodel.dart';

/// 이웃(팔로워/팔로잉) 섹션 탭 인덱스
enum NeighborTab { followers, followings }

/// 이웃(팔로워/팔로잉) 섹션 위젯
/// 팔로워, 팔로잉 목록을 탭으로 전환
class NeighborsSection extends ConsumerStatefulWidget {
  final String memberId;

  /// [memberId] : 채널 소유자의 회원 ID
  const NeighborsSection({super.key, required this.memberId});

  @override
  ConsumerState<NeighborsSection> createState() => _NeighborsSectionState();
}

class _NeighborsSectionState extends ConsumerState<NeighborsSection> {
  // 현재 선택된 탭
  NeighborTab _selectedTab = NeighborTab.followers;

  // 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();

  // 표시 중인 아이템 수 (초기값 10개, 무한 스크롤 때문에 필요)
  int _displayCount = 10;

  @override
  void initState() {
    super.initState();

    // 스크롤 리스너 등록 (무한 스크롤)
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 스크롤 리스너 - 무한 스크롤 구현
  void _scrollListener() {
    // 스크롤이 80% 이상 내려갔을 때 추가 아이템 로드
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent * 0.8) {
      // 현재 탭에 따라 표시할 전체 아이템 수 확인
      final currentItems = _getCurrentItems();

      // 더 표시할 아이템이 있으면 표시 개수 증가
      if (currentItems != null && _displayCount < currentItems.length) {
        setState(() {
          // 한 번에 5개씩 더 표시
          _displayCount += 5;
        });
      }
    }
  }

  /// 현재 탭에 따른 이웃 목록 반환
  List<Neighbor>? _getCurrentItems() {
    final channelState = ref.read(myChannelProvider);

    switch (_selectedTab) {
      case NeighborTab.followers:
        return channelState.followers?.followers;
      case NeighborTab.followings:
        return channelState.followings?.followings;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 채널 상태
    final channelState = ref.watch(myChannelProvider);
    final followers = channelState.followers;
    final followings = channelState.followings;

    // 로딩 상태 확인
    final isFollowersLoading =
        channelState.followersStatus == MyChannelStatus.loading;
    final isFollowingsLoading =
        channelState.followingsStatus == MyChannelStatus.loading;

    // 에러 상태 확인
    final hasFollowersError =
        channelState.followersStatus == MyChannelStatus.error;
    final hasFollowingsError =
        channelState.followingsStatus == MyChannelStatus.error;

    // 팔로워와 팔로잉이 모두 없는 경우
    if (!isFollowersLoading &&
        !isFollowingsLoading &&
        ((followers == null || followers.followers.isEmpty) &&
            (followings == null || followings.followings.isEmpty)) &&
        !hasFollowersError &&
        !hasFollowingsError) {
      // 없다는 메시지 표시
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 16),
              child: Text(
                '팔로워 & 팔로잉',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      '팔로워 목록이 없습니다',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '팔로잉 목록이 없습니다',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더 (팔로워/팔로잉 탭)
          _buildSectionHeader(followers, followings),

          const SizedBox(height: 16),

          // 선택된 탭에 따른 컨텐츠 표시
          _buildTabContent(
            followers,
            followings,
            isFollowersLoading,
            isFollowingsLoading,
            hasFollowersError,
            hasFollowingsError,
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더 위젯 (팔로워/팔로잉 탭 포함)
  Widget _buildSectionHeader(
    FollowerResponse? followers,
    FollowingResponse? followings,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 팔로워 탭
          _buildTabButton(
            title: '팔로워',
            count: followers?.followerCount ?? 0,
            isSelected: _selectedTab == NeighborTab.followers,
            onTap: () {
              setState(() {
                _selectedTab = NeighborTab.followers;
                // 탭 전환 시 표시 개수 초기화
                _displayCount = 10;
              });
            },
          ),

          const SizedBox(width: 24),

          // 팔로잉 탭
          _buildTabButton(
            title: '팔로잉',
            count: followings?.followingCount ?? 0,
            isSelected: _selectedTab == NeighborTab.followings,
            onTap: () {
              setState(() {
                _selectedTab = NeighborTab.followings;
                // 탭 전환 시 표시 개수 초기화
                _displayCount = 10;
              });
            },
          ),
        ],
      ),
    );
  }

  /// 탭 버튼 위젯
  Widget _buildTabButton({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // 탭 제목과 카운트
          Text(
            '$title / $count',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          const SizedBox(height: 4),

          // 선택된 탭 밑에 표시
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 선택된 탭에 따른 컨텐츠 표시
  Widget _buildTabContent(
    FollowerResponse? followers,
    FollowingResponse? followings,
    bool isFollowersLoading,
    bool isFollowingsLoading,
    bool hasFollowersError,
    bool hasFollowingsError,
  ) {
    // 현재 탭에 따른 로딩 상태
    final isLoading =
        _selectedTab == NeighborTab.followers
            ? isFollowersLoading
            : isFollowingsLoading;

    // 현재 탭에 따른 에러 상태
    final hasError =
        _selectedTab == NeighborTab.followers
            ? hasFollowersError
            : hasFollowingsError;

    // 현재 탭에 따른 이웃 목록
    final neighbors =
        _selectedTab == NeighborTab.followers
            ? followers?.followers
            : followings?.followings;

    // 로딩 중 표시
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    // 에러 표시
    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            '목록을 불러오는데 실패했습니다.\n다시 시도해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[300], fontSize: 14),
          ),
        ),
      );
    }

    // 이웃이 없을 경우
    if (neighbors == null || neighbors.isEmpty) {
      final message =
          _selectedTab == NeighborTab.followers
              ? '아직 팔로워가 없습니다.'
              : '아직 팔로잉하는 사용자가 없습니다.';

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            message,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ),
      );
    }

    // 그리드 형태로 이웃 목록 표시 (2열)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 가로 2개 항목
          childAspectRatio: 2.5, // 가로:세로 비율
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount:
            _displayCount <= neighbors.length
                ? _displayCount
                : neighbors.length,
        itemBuilder: (context, index) {
          // 표시할 개수보다 인덱스가 크면 로딩 표시
          if (index >= neighbors.length) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              ),
            );
          }

          final neighbor = neighbors[index];
          return _buildNeighborItem(context, neighbor);
        },
      ),
    );
  }

  /// 개별 이웃 아이템 위젯
  Widget _buildNeighborItem(BuildContext context, Neighbor neighbor) {
    return GestureDetector(
      onTap: () {
        // TODO: 사용자 채널 페이지로 이동
        print('이웃 클릭: ${neighbor.memberName}');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 프로필 이미지
            CircleAvatar(
              radius: 24,
              backgroundImage:
                  neighbor.profileImageUrl.isNotEmpty
                      ? NetworkImage(neighbor.profileImageUrl)
                      : null,
              child:
                  neighbor.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 24, color: Colors.white)
                      : null,
            ),

            const SizedBox(width: 12),

            // 사용자 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 이름
                  Text(
                    neighbor.memberName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // 팔로워 수
                  Text(
                    '${neighbor.followerCount} Followers',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
