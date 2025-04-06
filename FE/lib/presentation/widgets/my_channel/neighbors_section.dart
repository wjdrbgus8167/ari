import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../data/models/my_channel/neighbor.dart';
import '../../viewmodels/my_channel/my_channel_viewmodel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../presentation/routes/app_router.dart'; // TODO: 라우팅 용
import '../../../presentation/widgets/common/custom_toast.dart';
import '../../../presentation/widgets/common/custom_dialog.dart';

/// 이웃(팔로워/팔로잉) 섹션 탭 인덱스
enum NeighborTab { followers, followings }

/// 이웃(팔로워/팔로잉) 섹션 위젯
/// 팔로워/팔로잉 목록을 탭으로 전환
class NeighborsSection extends ConsumerStatefulWidget {
  final String memberId;

  /// [memberId] : 채널 주인 회원ID
  const NeighborsSection({super.key, required this.memberId});

  @override
  ConsumerState<NeighborsSection> createState() => _NeighborsSectionState();
}

class _NeighborsSectionState extends ConsumerState<NeighborsSection> {
  // 현재 선택된 탭
  NeighborTab _selectedTab = NeighborTab.followers;

  // 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();

  // 표시 중인 아이템 수 (초기값 10개, 무한 스크롤!!!)
  int _displayCount = 10;

  // 데이터 더 로드 중인지 여부
  bool _isLoadingMore = false;

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
    // 이미 로딩 중이면 중복 요청X
    if (_isLoadingMore) return;

    // 스크롤이 80% 이상 내려갔을 때 추가 아이템 로드
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent * 0.8) {
      // 현재 탭에 따라 표시할 전체 아이템 수 확인
      final currentItems = _getCurrentItems();

      // 더 표시할 아이템이 있으면 표시 개수 증가
      if (currentItems != null && _displayCount < currentItems.length) {
        setState(() {
          _isLoadingMore = true;
          // 한 번에 10개씩 더 표시 (기존 5개에서 증가)
          _displayCount += 10;

          // 로딩 상태 해제 (실제 API 페이징 구현 시 응답 후 해제해야 함)
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isLoadingMore = false;
              });
            }
          });
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

  /// 탭 변경 시 호출
  void _onTabChanged(NeighborTab tab) {
    if (_selectedTab != tab) {
      setState(() {
        _selectedTab = tab;
        // 탭 전환 시 표시 개수 초기화
        _displayCount = 10;
        _isLoadingMore = false;

        // 스크롤 위치 초기화
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
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

    // 초기 상태 확인 - 처음 진입 시 자동으로 데이터 로드
    final isFollowersInitial =
        channelState.followersStatus == MyChannelStatus.initial;
    final isFollowingsInitial =
        channelState.followingsStatus == MyChannelStatus.initial;

    // 초기 상태이면 데이터 로드 요청
    if (isFollowersInitial || isFollowingsInitial) {
      // 약간의 지연 추가 (UI가 먼저 그려진 후 데이터 요청하도록)
      Future.microtask(() {
        final notifier = ref.read(myChannelProvider.notifier);
        if (isFollowersInitial) {
          notifier.loadFollowers(widget.memberId);
        }
        if (isFollowingsInitial) {
          notifier.loadFollowings(widget.memberId);
        }
      });
    }

    // 팔로워와 팔로잉이 모두 없는 경우
    if (!isFollowersLoading &&
        !isFollowingsLoading &&
        !isFollowersInitial &&
        !isFollowingsInitial &&
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
                '팔로워 / 0    팔로잉 / 0',
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
                      '팔로워 / 팔로잉 목록이 없습니다',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // 팔로워 탭
              _buildTabButton(
                title: '팔로워',
                count: followers?.followerCount ?? 0,
                isSelected: _selectedTab == NeighborTab.followers,
                onTap: () => _onTabChanged(NeighborTab.followers),
              ),

              const SizedBox(width: 24),

              // 팔로잉 탭
              _buildTabButton(
                title: '팔로잉',
                count: followings?.followingCount ?? 0,
                isSelected: _selectedTab == NeighborTab.followings,
                onTap: () => _onTabChanged(NeighborTab.followings),
              ),
            ],
          ),

          // 전체보기 버튼 (TODO: 선택)
          // _buildViewAllButton(),
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
          // 탭 제목, 카운트
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
              color: isSelected ? AppColors.mediumGreen : Colors.transparent,
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
          child: CircularProgressIndicator(color: AppColors.mediumGreen),
        ),
      );
    }

    // 에러 표시 (다시 시도 버튼 있었는데 제거)
    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            '목록을 불러오는데 실패했습니다.\n당겨서 새로고침해 주세요.',
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
    return Column(
      children: [
        Padding(
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
              // 배열 범위 체크
              if (index >= neighbors.length) {
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.mediumPurple,
                    ),
                  ),
                );
              }

              final neighbor = neighbors[index];
              return _buildNeighborItem(context, neighbor);
            },
          ),
        ),

        // 더 로드 중일 때 하단에 로딩 인디케이터 표시
        if (_isLoadingMore && _displayCount < (neighbors.length))
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.mediumGreen,
                ),
              ),
            ),
          ),

        // 모든 항목을 표시했을 때 메시지
        if (_displayCount >= neighbors.length && neighbors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '모든 ${_selectedTab == NeighborTab.followers ? '팔로워' : '팔로잉'}를 확인했습니다',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
      ],
    );
  }

  /// 각각 개별 이웃 아이템 위젯
  Widget _buildNeighborItem(BuildContext context, Neighbor neighbor) {
    return GestureDetector(
      onTap: () {
        // 사용자 채널 페이지로 이동
        print('이웃 클릭: ${neighbor.memberName} (ID: ${neighbor.memberId})');

        // 토스트 메시지
        // context.showToast('${neighbor.memberName}님의 채널로 이동합니다');

        // 라우터를 통해 다른 사용자의 채널 페이지로 이동
        AppRouter.navigateTo(context, ref, AppRoutes.myChannel, {
          'memberId': neighbor.memberId.toString(),
        });
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
              backgroundColor: Colors.grey[800],
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
                    '${neighbor.followerCount} followers',
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
