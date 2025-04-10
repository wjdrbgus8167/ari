import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/common/custom_dialog.dart';
import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/providers/music_drawer/music_drawer_providers.dart';

/// 음악 서랍 화면 - 플레이리스트, 구독 중인 아티스트, 좋아요 누른 콘텐츠를 확인할 수 있는 페이지
class MusicDrawerScreen extends ConsumerStatefulWidget {
  const MusicDrawerScreen({super.key});

  @override
  ConsumerState<MusicDrawerScreen> createState() => _MusicDrawerScreenState();
}

class _MusicDrawerScreenState extends ConsumerState<MusicDrawerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '나의 서랍',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 스크롤 가능한 콘텐츠 영역
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // 플레이리스트 섹션
                      _buildSectionTitle('나의 플레이리스트'),
                      const SizedBox(height: 16),

                      // TODO: 플레이리스트 캐러셀 위젯 구현 필요
                      Container(
                        height: 220,
                        width: double.infinity,
                        color: Colors.grey.shade900,
                        child: const Center(child: Text('플레이리스트 캐러셀 (구현 예정)')),
                      ),

                      const SizedBox(height: 32),

                      // 구독 중인 아티스트 섹션
                      Consumer(
                        builder: (context, ref, child) {
                          final artistsCountAsync = ref.watch(
                            subscribedArtistsCountProvider,
                          );

                          return artistsCountAsync.when(
                            data:
                                (count) => _buildNavigationItem(
                                  icon: Icons.people_outline,
                                  title: '구독 중인 아티스트',
                                  subtitle: '$count명',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.subscribedArtists,
                                    );
                                  },
                                ),
                            loading:
                                () => _buildNavigationItem(
                                  icon: Icons.people_outline,
                                  title: '구독 중인 아티스트',
                                  subtitle: '로딩 중...',
                                  onTap: () {
                                    // 로딩 중에는 클릭 비활성화 또는 별도 처리
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '데이터를 불러오는 중입니다. 잠시만 기다려주세요.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            error: (error, stackTrace) {
                              // 에러 메시지 파싱
                              String errorMessage = '구독 중인 아티스트를 불러올 수 없습니다.';

                              if (error.toString().contains('구독권이 존재하지 않습니다')) {
                                errorMessage = '구독권이 존재하지 않습니다.';
                              }

                              return _buildNavigationItem(
                                icon: Icons.people_outline,
                                title: '구독 중인 아티스트',
                                subtitle: '0명',
                                onTap: () {
                                  // 구독권 없음 다이얼로그 표시
                                  context.showConfirmDialog(
                                    title: '구독권 필요',
                                    content:
                                        '구독 중인 아티스트를 보려면 구독권이 필요합니다.\n구독 페이지로 이동하시겠습니까?',
                                    confirmText: '구독하러 가기',
                                    cancelText: '취소',
                                    confirmButtonColor: AppColors.lightPurple,
                                    onConfirm: () {
                                      // 구독 페이지로 이동
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.subscribedArtists,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // 좋아요 누른 섹션
                      _buildNavigationItem(
                        icon: Icons.favorite_border,
                        title: '좋아요 누른 앨범',
                        subtitle: '',
                        onTap: () {
                          // TODO: 좋아요 누른 콘텐츠 페이지로 이동
                          Navigator.pushNamed(
                                        context,
                                        AppRoutes.likeyAlbum,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildNavigationItem(
                        icon: Icons.favorite_border,
                        title: '좋아요 누른 트랙',
                        subtitle: '',
                        onTap: () {
                          // TODO: 좋아요 누른 콘텐츠 페이지로 이동
                          Navigator.pushNamed(
                                        context,
                                        AppRoutes.likeyTrack,
                          );
                        },
                      ),

                      const SizedBox(height: 100), // 하단 여백
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 제목 위젯
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // 네비게이션 아이템 위젯 (구독 중인 아티스트, 좋아요 누른 등)
  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // 아이콘
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),

            // 텍스트 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 화살표 아이콘
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
