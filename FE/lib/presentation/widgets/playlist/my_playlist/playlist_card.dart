import 'package:flutter/material.dart';
import 'package:ari/presentation/widgets/common/media_card.dart';
import 'package:ari/domain/entities/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  const PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return MediaCard(
      imageUrl:
          playlist.coverImageUrl.isNotEmpty
              ? playlist.coverImageUrl
              : 'assets/images/default_playlist_cover.png',
      title: playlist.title,
      onTap: () {
        // 플레이리스트 상세 페이지로 이동하는 로직 구현
      },
    );
  }
}
