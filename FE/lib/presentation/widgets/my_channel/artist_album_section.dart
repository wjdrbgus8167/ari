import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../data/models/my_channel/artist_album.dart';
import '../../viewmodels/my_channel/my_channel_viewmodel.dart';
import '../common/carousel_container.dart';
import '../../routes/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../pages/mypage/album_upload_screen.dart';

/// 아티스트 앨범 섹션 위젯
/// 아티스트가 발매한 앨범 목록을 표시
class ArtistAlbumSection extends ConsumerStatefulWidget {
  final String memberId;
  final bool isMyProfile; // 내 프로필인지

  const ArtistAlbumSection({
    super.key,
    required this.memberId,
    required this.isMyProfile,
  });

  @override
  ConsumerState<ArtistAlbumSection> createState() => _ArtistAlbumSectionState();
}

class _ArtistAlbumSectionState extends ConsumerState<ArtistAlbumSection> {
  @override
  void initState() {
    super.initState();
    // 위젯이 초기화될 때 앨범 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlbums();
    });
  }

  @override
  void didUpdateWidget(ArtistAlbumSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // memberId가 변경되면 데이터 다시 로드
    if (oldWidget.memberId != widget.memberId) {
      _loadAlbums();
    }
  }

  void _loadAlbums() {
    // 채널 뷰모델에서 앨범 목록 로드 함수 호출
    ref.read(myChannelProvider.notifier).loadArtistAlbums(widget.memberId);
  }

  @override
  Widget build(BuildContext context) {
    // 아티스트 앨범 상태
    final channelState = ref.watch(myChannelProvider);
    final artistAlbums = channelState.artistAlbums;
    final isLoading =
        channelState.artistAlbumsStatus == MyChannelStatus.loading;
    final hasError = channelState.artistAlbumsStatus == MyChannelStatus.error;

    // 로딩 중이면 로딩 표시
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: AppColors.darkGreen),
        ),
      );
    }
    // 에러 발생 시 에러 메시지 표시 (아래 'TODO' 참고)
    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Text(
                '앨범을 불러오는데 실패했습니다.\n다시 시도해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[300], fontSize: 14),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadAlbums,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }
    // TODO: 에러 발생 시 에러 메시지 표시
    // if (hasError) {
    //   return Center(
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 24),
    //       child: Text(
    //         '앨범을 불러오는데 실패했습니다.\n다시 시도해주세요.',
    //         textAlign: TextAlign.center,
    //         style: TextStyle(color: Colors.red[300], fontSize: 14),
    //       ),
    //     ),
    //   );
    // }

    // 앨범이 없거나 에러 발생 시 안내 메시지 표시
    if (artistAlbums == null || artistAlbums.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '나의 앨범',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 내 프로필인 경우에만 업로드 안내 UI 표시
            if (widget.isMyProfile)
              // 탭 가능한 컨테이너 (아무데나 클릭해도 라우팅됨)
              Material(
                // InkWell을 Material로 감싸 ripple 효과 개선
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // ripple 효과는 기본적으로 적용됨
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                const AlbumUploadScreen(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  splashColor: AppColors.lightGreen.withValues(
                    alpha: 0.3,
                  ), // 스플래시 색상 설정
                  highlightColor: AppColors.lightGreen.withValues(
                    alpha: 0.1,
                  ), // 하이라이트 색상 설정
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // InkWell에 borderRadius 추가
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      // 그라데이션 대신 단색 배경에 투명도 적용
                      color: AppColors.lightGreen.withValues(
                        alpha: 0.15,
                      ), // 초록색
                      // color: AppColors.lightPurple.withValues(alpha: 0.15),  // 보라색
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.darkGreen.withValues(
                          alpha: 0.3,
                        ), // 초록색
                        // color: AppColors.mediumPurple.withValues(alpha: 0.3),  // 보라색
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '앨범을 업로드하세요! 누구나 아티스트가 될 수 있습니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        // 업로드 버튼
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient:
                                AppColors.greenGradientVertical, // 초록색 그라데이션
                            // gradient: AppColors.purpleGradient, // 보라색 그라데이션
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: 180, // 버튼 가로 길이 지정
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // 가운데 정렬
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.upload,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '앨범 업로드',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // 다른 사용자의 채널에서는 간단한 메시지만 표시
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  '업로드한 앨범이 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
          ],
        ),
      );
    }

    // 앨범이 있는 경우 CarouselContainer 위젯 사용 (아티스트로 간주)
    return CarouselContainer(
      title: '나의 앨범',
      height: 220,
      itemWidth: 160,
      itemSpacing: 12.0, // 앨범 사이 간격을 PublicPlaylistSection과 동일하게 조정
      children:
          artistAlbums.map((album) => _buildAlbumItem(context, album)).toList(),
    );
  }

  /// 개별 앨범 아이템
  Widget _buildAlbumItem(BuildContext context, ArtistAlbum album) {
    return GestureDetector(
      onTap: () {
        // 앨범 상세 페이지로
        Navigator.pushNamed(
          context,
          AppRoutes.album,
          arguments: {'albumId': album.albumId},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 앨범 커버 이미지
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(album.coverImageUrl),
                fit: BoxFit.cover,
                // 이미지 로드 실패 시 대체 이미지 표시
                // errorBuilder: (context, error, stackTrace) {
                //   return Container(
                //     color: Colors.grey.withValues(alpha: 0.2),
                //     child: const Icon(
                //       Icons.broken_image,
                //       color: Colors.white54,
                //       size: 48,
                //     ),
                //   );
                // },
              ),
            ),
          ),
          const SizedBox(height: 8), // 앨범 제목과 가수명 사이 간격
          // 앨범 제목
          Text(
            album.albumTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          // 아티스트 이름 - 회색
          Text(
            album.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 2),
          // 수록곡 수
          Row(
            children: [
              Icon(Icons.music_note, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                '${album.trackCount}곡',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
