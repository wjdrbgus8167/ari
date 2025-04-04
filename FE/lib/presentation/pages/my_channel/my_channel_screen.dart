// lib/presentation/pages/my_channel/my_channel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth/auth_providers.dart';
import '../../../presentation/routes/app_router.dart';
import '../../widgets/my_channel/profile_header.dart';
import '../../widgets/my_channel/badge_list.dart';
import '../../widgets/my_channel/artist_album_section.dart';
import '../../widgets/my_channel/artist_notice_section.dart';
import '../../widgets/my_channel/fantalk_section.dart';
import '../../widgets/my_channel/public_playlist_section.dart';
import '../../widgets/my_channel/neighbors_section.dart';
import '../../widgets/test/jwt_user_test_widget.dart';

/// 나의 채널 화면
/// 사용자 프로필, 뱃지, (앨범, 공지사항, 팬톡), 플레이리스트, 이웃 정보 표시
/// 로그인이 필요한 화면으로, 로그인되지 않은 사용자에게는 로그인 다이얼로그 표시
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
  bool _showJwtTest = true; // 테스트 완료 후 false로 위젯 숨기기

  // 페이지 초기화 상태
  bool _initialized = false;

  // 로그인 다이얼로그 표시 여부
  bool _shouldShowLoginDialog = false;

  @override
  void initState() {
    super.initState();

    // 초기 설정
    _isMyProfile = widget.memberId == null;

    // 페이지 로드 후 (첫 렌더링 후) 로그인 체크 수행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  // 화면 초기화 및 로그인 체크
  void _initializeScreen() {
    if (_initialized) return;
    _initialized = true;

    // 로그인 여부 확인
    final authState = ref.read(authStateProvider);
    bool isLoggedIn = false;

    authState.whenData((value) {
      isLoggedIn = value;
    });

    // 내 채널 보기이고 로그인이 필요한 경우
    if (widget.memberId == null && !isLoggedIn) {
      setState(() {
        _shouldShowLoginDialog = true;
      });
    } else {
      // 로그인 되어 있거나 특정 사용자 채널 보기인 경우 데이터 로드
      _loadChannelData();
    }
  }

  // 채널 데이터 로드
  void _loadChannelData() {
    final userId = ref.read(userIdProvider);

    setState(() {
      if (widget.memberId != null) {
        // 특정 사용자 채널 보기
        _currentUserId = widget.memberId!;
      } else if (userId != null) {
        // 내 채널 보기 (로그인한 경우)
        _currentUserId = userId;
      } else {
        // 로그인하지 않았고 특정 채널도 아닌 경우
        _currentUserId = '0'; // 임시 ID
        print('로그인하지 않았습니다. 사용자 ID를 가져올 수 없습니다.');
      }
    });

    // 데이터 로드 시작
    if (_currentUserId.isNotEmpty) {
      ref.read(myChannelProvider.notifier).setLoadingState();
      ref
          .read(myChannelProvider.notifier)
          .loadMyChannelData(_currentUserId, 'fantalk-channel-id');
    }
  }

  // 로그인 다이얼로그 표시 (build 메서드의 일부로 처리)
  Widget _buildLoginDialog() {
    return Center(
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '로그인 필요',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '나의 채널을 보려면 로그인이 필요합니다.\n로그인 페이지로 이동하시겠습니까?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // 취소 버튼 - 홈 화면으로 이동
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.home);
                    },
                    child: const Text('취소'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // 로그인 화면으로 이동
                      Navigator.of(context).pushNamed(
                        AppRoutes.login,
                        arguments: {'redirectRoute': AppRoutes.myChannel},
                      );
                    },
                    child: const Text('로그인하기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 다이얼로그가 필요한 경우
    if (_shouldShowLoginDialog) {
      return PopScope(
        canPop: false, // 뒤로가기 버튼 기본 동작 방지
        onPopInvoked: (didPop) {
          if (!didPop) {
            // 뒤로가기 버튼 눌렀을 때 홈 화면으로 이동
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.8),
          body: _buildLoginDialog(),
        ),
      );
    }

    // 정상적인 채널 페이지 표시
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: Colors.blue,
        backgroundColor: Colors.grey[900],
        onRefresh: () async {
          // 당겨서 새로고침 시 데이터 다시 로드
          _loadChannelData();

          // JWT 사용자 정보도 새로고침
          await ref.read(userProvider.notifier).refreshUserInfo();
        },
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // JWT 테스트 위젯 (테스트 완료 후 제거 예정)
              if (_showJwtTest)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showJwtTest = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const JwtUserTestWidget(),
                      const Divider(color: Colors.grey),
                    ],
                  ),
                ),

              // 프로필 헤더
              SliverToBoxAdapter(
                child: ProfileHeader(
                  memberId: _currentUserId,
                  isMyProfile: _isMyProfile,
                  scrollController: _scrollController,
                ),
              ),

              // 배지 목록
              SliverToBoxAdapter(child: BadgeList(memberId: _currentUserId)),

              // 아티스트 앨범 (아티스트인 경우에만 표시)
              SliverToBoxAdapter(
                child: ArtistAlbumSection(memberId: _currentUserId),
              ),

              // 아티스트 공지사항 (아티스트인 경우에만 표시)
              SliverToBoxAdapter(
                child: ArtistNoticeSection(memberId: _currentUserId),
              ),

              // 팬톡 (아티스트인 경우에만 표시)
              SliverToBoxAdapter(
                child: FanTalkSection(memberId: _currentUserId),
              ),

              // 공개된 플레이리스트
              SliverToBoxAdapter(
                child: PublicPlaylistSection(memberId: _currentUserId),
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
