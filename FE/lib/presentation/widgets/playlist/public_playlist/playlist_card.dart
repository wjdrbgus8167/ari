import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/presentation/widgets/common/media_card.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  const PlaylistCard({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaCard(
      imageUrl:
          playlist.coverImageUrl.isNotEmpty
              ? playlist.coverImageUrl
              : 'assets/images/default_playlist_cover.png',
      title: playlist.title,
      onTap: () {
        // 플레이리스트 상세 페이지로 이동
        Navigator.pushNamed(
          context,
          AppRoutes.playlistDetail,
          arguments: {'playlistId': playlist.id},
        );
      },
    );
  }
}
