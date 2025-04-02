import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../data/models/my_channel/artist_album.dart';
import '../../viewmodels/my_channel/my_channel_viewmodel.dart';
import '../common/carousel_container.dart';
import '../../routes/app_router.dart';

/// 아티스트 앨범 섹션 위젯
/// 아티스트가 발매한 앨범 목록을 표시
class ArtistAlbumSection extends ConsumerWidget {
  final String memberId;

  const ArtistAlbumSection({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: CircularProgressIndicator(color: Colors.blue),
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

    // 앨범이 없는 경우 안내 메시지 표시 (빈 위젯 대신)
    // if (artistAlbums.isEmpty) {
    //   return Padding(
    //     padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         const Text(
    //           '나의 앨범',
    //           style: TextStyle(
    //             color: Colors.white,
    //             fontSize: 18,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //         const SizedBox(height: 12),
    //         Container(
    //           width: double.infinity,
    //           padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    //           decoration: BoxDecoration(
    //             color: Colors.blue.withValues(alpha: 0.1),
    //             borderRadius: BorderRadius.circular(8),
    //             border: Border.all(
    //               color: Colors.blue.withValues(alpha: 0.3),
    //               width: 1,
    //             ),
    //           ),
    //           child: const Text(
    //             '앨범을 업로드해보세요. 누구나 아티스트가 될 수 있습니다.',
    //             textAlign: TextAlign.center,
    //             style: TextStyle(color: Colors.white, fontSize: 14),
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    // 앨범이 없거나 에러 발생 시 안내 메시지 표시
    if (artistAlbums == null || artistAlbums.isEmpty || hasError) {
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
            // 탭 가능한 컨테이너로 변경
            InkWell(
              onTap: () {
                // 앨범 업로드 페이지로 라우팅
                Navigator.pushNamed(context, AppRoutes.albumUpload);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '앨범을 업로드해보세요. 누구나 아티스트가 될 수 있습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    // 업로드 버튼 추가
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.upload, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            '앨범 업로드하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
      itemSpacing: 12.0,
      children:
          artistAlbums.map((album) => _buildAlbumItem(context, album)).toList(),
    );
  }

  /// 개별 앨범 아이템 위젯
  Widget _buildAlbumItem(BuildContext context, ArtistAlbum album) {
    return GestureDetector(
      onTap: () {
        // 앨범 상세 페이지로 이동 구현
        Navigator.pushNamed(
          context,
          '/album/detail',
          arguments: {'albumId': album.albumId},
        ); // TODO 대신 실제 구현 추가
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
              ),
            ),
          ),
          const SizedBox(height: 8),
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
          // 아티스트 이름
          Text(
            album.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          // 수록곡 수
          Text(
            '${album.trackCount}곡',
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
