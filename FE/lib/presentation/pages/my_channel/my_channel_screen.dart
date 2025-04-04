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
import '../../widgets/common/custom_dialog.dart';

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
  bool _loginCheckPerformed = false; // 로그인 체크 여부 플래그

  // JWT 테스트용 상태
  bool _showJwtTest = true; // 테스트 완료 후 false로 위젯 숨기기

  @override
  void initState() {
    super.initState();

    // 초기 설정
    _isMyProfile = widget.memberId == null;

    // 위젯 빌드 완료 후 데이터 로드 요청
    Future.microtask(() {
      _checkLoginAndLoadData();
    });
  }

  // 로그인 상태 확인 후 데이터 로드 또는 로그인 다이얼로그 표시
  void _checkLoginAndLoadData() async {
    if (_loginCheckPerformed) return; // 이미 체크한 경우 중복 실행 방지

    _loginCheckPerformed = true;

    // 로그인 상태 확인
    final authState = ref.read(authStateProvider);

    bool isLoggedIn = false;
    authState.whenData((value) {
      isLoggedIn = value;
    });

    // 특정 채널 보기가 아니고 로그인하지 않은 경우 로그인 다이얼로그 표시
    if (widget.memberId == null && !isLoggedIn) {
      // 위젯이 마운트된 상태인지 확인 후 다이얼로그 표시
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;

        _showLoginDialog();
      });
    } else {
      // 로그인 상태이거나 특정 채널 보기인 경우 데이터 로드
      _updateUserIdFromToken();
    }
  }

  // 로그인 다이얼로그 표시
  void _showLoginDialog() {
    if (!mounted) return;

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CustomDialog(
          title: '로그인 필요',
          content: '나의 채널을 보려면 로그인이 필요합니다.\n로그인 페이지로 이동하시겠습니까?',
          confirmText: '로그인하기',
          cancelText: '취소',
          confirmButtonColor: Colors.blue,
          cancelButtonColor: Colors.grey,
          onConfirm: null, // 내부 동작만 실행하도록 null 설정
          onCancel: null, // 내부 동작만 실행하도록 null 설정
        );
      },
    ).then((result) {
      // 다이얼로그에서 확인 버튼 눌렀을 때
      if (result == true) {
        // 로그인 페이지로 이동하고 redirect 정보 추가
        Navigator.of(context).pushNamed(
          AppRoutes.login,
          arguments: {'redirectRoute': AppRoutes.myChannel},
        );
      } else {
        // 취소 버튼 눌렀을 때 홈 화면으로 이동
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    });
  }

  // 토큰에서 사용자 ID 업데이트 및 데이터 로드
  void _updateUserIdFromToken() {
    // 로그인된 상태라면 토큰에서 사용자 ID 가져오기
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

    // ID가 설정된 후 데이터 로드
    if (_currentUserId.isNotEmpty) {
      // 위젯 빌드 완료 후 provider 상태 변경
      Future.microtask(() {
        // 상태를 로딩 상태로 직접 설정
        ref.read(myChannelProvider.notifier).setLoadingState();
        // 데이터 로드 시작
        ref
            .read(myChannelProvider.notifier)
            .loadMyChannelData(_currentUserId, 'fantalk-channel-id');
      });
    } else {
      print('사용자 ID가 설정되지 않았습니다. 채널 데이터를 로드할 수 없습니다.');
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
        ref
            .read(myChannelProvider.notifier)
            .loadMyChannelData(_currentUserId, 'fantalk-channel-id');
      });
    } else {
      print('사용자 ID가 설정되지 않았습니다. 채널 데이터를 로드할 수 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 상태 구독 - 페이지 내에서도 로그인 상태 변경 감지
    final authState = ref.watch(authStateProvider);

    // 로그인 상태가 변경된 경우 데이터 다시 로드
    authState.whenData((isLoggedIn) {
      if (isLoggedIn && !_loginCheckPerformed) {
        Future.microtask(() => _checkLoginAndLoadData());
      }
    });

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
