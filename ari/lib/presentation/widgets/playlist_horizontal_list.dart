import 'package:flutter/material.dart';
import '../../data/models/playlist.dart';

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
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return PlaylistCard(playlist: playlist);
        },
      ),
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  const PlaylistCard({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // 플레이리스트 커버 이미지
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(playlist.coverUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(playlist.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
