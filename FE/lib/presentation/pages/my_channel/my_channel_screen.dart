import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/my_channel/profile_header.dart';
import '../../widgets/my_channel/badge_list.dart';
import '../../widgets/my_channel/artist_album_section.dart';
import '../../widgets/my_channel/artist_notice_section.dart';
import '../../widgets/my_channel/fantalk_section.dart';
import '../../widgets/my_channel/public_playlist_section.dart';
import '../../widgets/my_channel/neighbors_section.dart';

/// 나의 채널 화면
/// 사용자 프로필, 뱃지, (앨범, 공지사항, 팬톡), 플레이리스트, 이웃 정보 표시
class MyChannelScreen extends ConsumerStatefulWidget {
  final String? memberId; // null이면 내 채널 표시

  /// [memberId] : 표시할 채널의 회원 ID (null이면 로그인한 사용자 본인의 채널)
  const MyChannelScreen({super.key, this.memberId});

  @override
  ConsumerState<MyChannelScreen> createState() => _MyChannelScreenState();
}

class _MyChannelScreenState extends ConsumerState<MyChannelScreen> {
  // 스크롤 컨트롤러 (나의 채널 프로필 헤더 애니메이션용)
  final ScrollController _scrollController = ScrollController();
  String _currentUserId = ''; // 실제 사용자 ID 저장
  late bool _isMyProfile;

  // JWT 테스트용 상태
  final bool _showJwtTest = true; // 테스트 완료 후 false로 위젯 숨기기

  @override
  void initState() {
    super.initState();

    // 초기 설정
    _isMyProfile = widget.memberId == null;

    // 위젯 빌드 완료 후 데이터 로드 요청
    Future.microtask(() {
      // 화면 진입 시 상태 리셋 (이전 채널 데이터 제거)
      ref.read(myChannelProvider.notifier).resetState();
      _updateUserIdFromToken();
    });
  }

  @override
  void didUpdateWidget(MyChannelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 위젯이 업데이트되고 memberId가 변경된 경우 (다른 채널로 이동)
    if (oldWidget.memberId != widget.memberId) {
      _isMyProfile = widget.memberId == null;

      // 상태 초기화 후 데이터 다시 로드
      ref.read(myChannelProvider.notifier).resetState();
      _updateUserIdFromToken();
    }
  }

  // 토큰에서 사용자 ID 업데이트 및 데이터 로드
  void _updateUserIdFromToken() {
    // 로그인된 상태라면 토큰에서 사용자 ID 가져오기
    final userId = ref.read(userIdProvider);

    setState(() {
      if (widget.memberId != null) {
        _currentUserId = widget.memberId!;
      } else if (userId != null) {
        _currentUserId = userId;
      } else {
        _currentUserId = '0';
        print('로그인하지 않았습니다. 사용자 ID를 가져올 수 없습니다.');
      }
    });

    // ID가 설정된 후 데이터 로드 (실제 fantalkChannelId는 로드할 때 얻어옴)
    if (_currentUserId.isNotEmpty) {
      Future.microtask(() {
        // 채널 데이터 로드 시작 (두 번째 파라미터를 null로 설정)
        ref
            .read(myChannelProvider.notifier)
            .loadMyChannelData(_currentUserId, null);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 나의 채널 데이터 로드 (새로고침용)
  void _loadMyChannelData() {
    if (_currentUserId.isNotEmpty) {
      // 위젯 빌드 완료 후 provider 상태 변경
      Future.microtask(() {
        // 상태를 로딩 상태로 직접 설정
        ref.read(myChannelProvider.notifier).setLoadingState();
        // 데이터 로드 시작
        // 데이터 로드 시작
        ref
            .read(myChannelProvider.notifier)
            .loadMyChannelData(_currentUserId, _currentUserId);
      });
    } else {
      print('사용자 ID가 설정되지 않았습니다. 채널 데이터를 로드할 수 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // userIdProvider 변경 감지를 위한 watch
    final userId = ref.read(userIdProvider);

    final channelState = ref.watch(myChannelProvider);
    final fantalkChannelId = channelState.channelInfo?.fantalkChannelId;

    // 내 채널 모드에서 userId가 변경되면 데이터 다시 로드
    if (widget.memberId == null && userId != null && userId != _currentUserId) {
      // 로그인 상태가 변경된 경우 데이터 다시 로드
      Future.microtask(() => _updateUserIdFromToken());
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: Colors.blue,
        backgroundColor: Colors.grey[900],
        onRefresh: () async {
          // 당겨서 새로고침 시 데이터 다시 로드
          _loadMyChannelData();

          // JWT 사용자 정보도 새로고침
          await ref.read(userProvider.notifier).refreshUserInfo();
          _updateUserIdFromToken();
        },
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 프로필 헤더
              SliverToBoxAdapter(
                child: ProfileHeader(
                  memberId: _currentUserId,
                  isMyProfile: _isMyProfile,
                  scrollController: _scrollController,
                ),
              ),

              // 배지 목록
              // SliverToBoxAdapter(child: BadgeList(memberId: _currentUserId)),

              // 섹션 간 여백 (배지와 앨범 사이)
              // const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 아티스트 앨범 (아티스트인 경우에만 표시)
              SliverToBoxAdapter(
                child: ArtistAlbumSection(
                  memberId: _currentUserId,
                  isMyProfile: _isMyProfile,
                ),
              ),

              // 섹션 간 여백 (앨범과 공지 사이)
              const SliverToBoxAdapter(
                child: SizedBox(height: 24), // 앨범과 공지 사이 간격
              ),

              // 아티스트 공지사항 (아티스트인 경우에만 표시)
              SliverToBoxAdapter(
                child: ArtistNoticeSection(memberId: _currentUserId),
              ),

              // 섹션 간 여백 (공지와 팬톡 사이)
              const SliverToBoxAdapter(
                child: SizedBox(height: 24), // 공지와 팬톡 사이 간격
              ),

              // 팬톡 (아티스트인 경우에만 표시)
              SliverToBoxAdapter(
                child: FanTalkSection(
                  memberId: _currentUserId,
                  fantalkChannelId:
                      fantalkChannelId?.toString(), // 채널 정보에서 가져온 팬톡 채널 ID
                ),
              ),

              // 섹션 간 여백 (팬톡과 플레이리스트 사이)
              const SliverToBoxAdapter(
                child: SizedBox(height: 24), // 팬톡과 플레이리스트 사이 간격
              ),

              // 공개된 플레이리스트
              SliverToBoxAdapter(
                child: PublicPlaylistSection(memberId: _currentUserId),
              ),

              // 섹션 간 여백 (플레이리스트와 이웃 사이)
              const SliverToBoxAdapter(
                child: SizedBox(height: 24), // 플레이리스트와 이웃 사이 간격
              ),

              // 이웃(팔로워/팔로잉) 섹션
              SliverToBoxAdapter(
                child: NeighborsSection(memberId: _currentUserId),
              ),

              // 하단 여백
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}
