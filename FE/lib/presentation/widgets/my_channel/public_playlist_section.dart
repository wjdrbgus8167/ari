import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../data/models/my_channel/public_playlist.dart';
import '../../viewmodels/my_channel/my_channel_viewmodel.dart';
import '../common/carousel_container.dart';

/// 공개된 플레이리스트 섹션 위젯
/// 사용자가 공개한 플레이리스트 목록 표시
class PublicPlaylistSection extends ConsumerWidget {
  final String memberId;

  /// [memberId] : 채널 소유자의 회원 ID
  const PublicPlaylistSection({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 플레이리스트 상태 가져오기
    final channelState = ref.watch(myChannelProvider);
    final playlistResponse = channelState.publicPlaylists;
    final isLoading =
        channelState.publicPlaylistsStatus == MyChannelStatus.loading;
    final hasError =
        channelState.publicPlaylistsStatus == MyChannelStatus.error;

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
            '플레이리스트를 불러오는데 실패했습니다.\n다시 시도해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[300], fontSize: 14),
          ),
        ),
      );
    }

    // 플레이리스트가 없는 경우에도 타이틀, 안내 메시지 표시
    if (playlistResponse == null || playlistResponse.playlists.isEmpty) {
      // 아티스트 이름 표시 추가
      final artistName = playlistResponse?.artist ?? '';
      final titleText =
          artistName.isNotEmpty ? '$artistName님의 공개된 플레이리스트' : '공개된 플레이리스트';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
            child: Text(
              titleText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Text(
              '공개된 플레이리스트가 없습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      );
    }

    // 플레이리스트가 있는 경우
    // 아티스트 이름이 있으면 타이틀에 반영
    final titleText =
        playlistResponse.artist.isNotEmpty
            ? '${playlistResponse.artist}님의 공개된 플레이리스트'
            : '공개된 플레이리스트';

    return CarouselContainer(
      title: titleText,
      height: 220, // 앨범 섹션과 동일한 높이
      itemWidth: 160, // 앨범 섹션과 동일한 너비
      itemSpacing: 12.0,
      children:
          playlistResponse.playlists
              .map((playlist) => _buildPlaylistItem(context, playlist))
              .toList(),
    );
  }

  /// 개별 플레이리스트 아이템 위젯
  Widget _buildPlaylistItem(BuildContext context, PublicPlaylist playlist) {
    // 기본 커버 이미지 URL (NULL인 경우 기본 이미지 사용)
    final imageUrl =
        playlist.coverImageUrl ??
        'https://via.placeholder.com/160?text=No+Cover';

    // 트랙 수를 표시하는 문자열
    final trackCountText = '${playlist.trackCount}곡';

    return GestureDetector(
      onTap: () {
        // TODO: 플레이리스트 상세 페이지로 이동
        print(
          '플레이리스트 클릭: ${playlist.playlistTitle} (ID: ${playlist.playlistId})',
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 플레이리스트 커버 이미지
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
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 플레이리스트 제목
          Text(
            playlist.playlistTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          // 트랙 수 표시
          Row(
            children: [
              Icon(Icons.music_note, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                trackCountText,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
