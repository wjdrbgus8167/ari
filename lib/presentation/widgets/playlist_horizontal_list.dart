import 'package:flutter/material.dart';
import '../../data/models/playlist.dart';
import 'playlist_card.dart';

class PlaylistHorizontalList extends StatelessWidget {
  final List<Playlist> playlists;
  const PlaylistHorizontalList({Key? key, required this.playlists})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // 플레이리스트 커버 이미지가 들어갈 정도의 높이
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 10), // 헤더와 동일한 왼쪽(및 오른쪽) 간격 적용

        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return PlaylistCard(playlist: playlist);
        },
      ),
    );
  }
}
