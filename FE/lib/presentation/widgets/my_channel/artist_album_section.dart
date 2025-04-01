import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../data/models/my_channel/artist_album.dart';
import '../../../presentation/viewmodels/my_channel_viewmodel.dart';
import '../common/carousel_container.dart';

/// 아티스트 앨범 섹션 위젯
/// 아티스트가 발매한 앨범 목록을 표시
class ArtistAlbumSection extends ConsumerWidget {
  final String memberId;

  const ArtistAlbumSection({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 아티스트 앨범 상태
    final channelState = ref.watch(myChannelProvider);
    final albums = channelState.artistAlbums;
    final isLoading =
        channelState.artistAlbumsStatus == MyChannelStatus.loading;
    final hasError = channelState.artistAlbumsStatus == MyChannelStatus.error;

    // 앨범이 없는 경우(아티스트가 아님) 위젯을 표시하지 않음
    if (!isLoading && (albums == null || albums.isEmpty) && !hasError) {
      return const SizedBox.shrink();
    }

    // 로딩 중이면 로딩 표시
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    // 에러 발생 시 에러 메시지 표시
    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            '앨범을 불러오는데 실패했습니다.\n다시 시도해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[300], fontSize: 14),
          ),
        ),
      );
    }

    // 앨범이 없는 경우 위젯을 표시하지 않음 (일반 회원으로 간주)
    if (albums == null || albums.isEmpty) {
      return const SizedBox.shrink();
    }

    // 앨범이 있는 경우 CarouselContainer 위젯 사용 (아티스트로 간주)
    return CarouselContainer(
      title: '나의 앨범',
      height: 220,
      itemWidth: 160,
      itemSpacing: 12.0,
      children: albums.map((album) => _buildAlbumItem(context, album)).toList(),
    );
  }

  /// 개별 앨범 아이템 위젯
  Widget _buildAlbumItem(BuildContext context, ArtistAlbum album) {
    return GestureDetector(
      onTap: () {
        // TODO: 앨범 상세 페이지로 이동
        print('앨범 클릭: ${album.albumTitle}');
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
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 2),
          // 수록곡 수
          Text(
            '${album.trackCount}곡',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
