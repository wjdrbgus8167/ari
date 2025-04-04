import 'package:flutter/material.dart';
import '../common/media_card.dart';
import '../../../data/models/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  const PlaylistCard({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaCard(
      //이미지는 추후 해당 플리 안 트랙 이미지로 변경
      imageUrl: 'assets/images/default_playlist_cover.png',
      title: playlist.title,
      onTap: () {
        // 플레이리스트 상세 페이지로 이동하는 로직 구현
      },
    );
  }
}
