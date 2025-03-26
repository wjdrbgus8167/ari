import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel_providers.dart';
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

  /// 생성자
  /// [memberId] : 표시할 채널의 회원 ID (null이면 로그인한 사용자 본인의 채널)
  const MyChannelScreen({super.key, this.memberId});

  @override
  ConsumerState<MyChannelScreen> createState() => _MyChannelScreenState();
}

class _MyChannelScreenState extends ConsumerState<MyChannelScreen> {
  // 스크롤 컨트롤러 (나의 채널 프로필 헤더 애니메이션용)
  final ScrollController _scrollController = ScrollController();
  late String _memberId;
  late bool _isMyProfile;

  @override
  void initState() {
    super.initState();

    // TODO: 실제 인증 구현 후 -> 현재 사용자 ID를 가져오도록 수정
    _memberId = widget.memberId ?? 'current-user-id';

    // TODO: 본인 프로필인지 여부 (인증 구현 시 실제 비교로 수정)
    _isMyProfile = widget.memberId == null;

    // 화면 렌더링 후 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyChannelData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 나의 채널 데이터 로드
  void _loadMyChannelData() {
    // 채널 데이터 로드
    final notifier = ref.read(myChannelProvider.notifier);

    // TODO: 팬톡 채널 ID 구현 시 실제 ID로 수정
    notifier.loadMyChannelData(_memberId, 'fantalk-channel-id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: Colors.blue,
        backgroundColor: Colors.grey[900],
        onRefresh: () async {
          // 당겨서 새로고침 시 데이터 다시 로드
          _loadMyChannelData();
        },
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 프로필 헤더
              SliverToBoxAdapter(
                child: ProfileHeader(
                  memberId: _memberId,
                  isMyProfile: _isMyProfile,
                  scrollController: _scrollController,
                ),
              ),

              // 배지 목록
              SliverToBoxAdapter(child: BadgeList(memberId: _memberId)),

              // 아티스트 앨범 (아티스트인 경우에만 표시)
              SliverToBoxAdapter(
                child: ArtistAlbumSection(memberId: _memberId),
              ),

              // 아티스트 공지사항 (아티스트인 경우에만 표시)
              SliverToBoxAdapter(
                child: ArtistNoticeSection(memberId: _memberId),
              ),

              // 팬톡 (아티스트인 경우에만 표시)
              SliverToBoxAdapter(child: FanTalkSection(memberId: _memberId)),

              // 공개된 플레이리스트
              SliverToBoxAdapter(
                child: PublicPlaylistSection(memberId: _memberId),
              ),

              // 이웃(팔로워/팔로잉) 섹션
              SliverToBoxAdapter(child: NeighborsSection(memberId: _memberId)),

              // 하단 여백
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}
