import 'package:flutter/material.dart';
import '../common/media_card.dart';
import '../../../data/models/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  const PlaylistCard({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaCard(
      imageUrl: playlist.coverUrl,
      title: playlist.title,
      onTap: () {
        // 플레이리스트 상세 페이지로 이동하는 로직 구현
      },
    );
  }
}
