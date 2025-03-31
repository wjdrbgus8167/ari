import 'package:flutter/material.dart';
import 'package:ari/domain/entities/playlist.dart';

class PlaylistSelectionBottomSheet extends StatelessWidget {
  final List<Playlist> playlists;
  final Function(Playlist) onPlaylistSelected;
  final VoidCallback onCreatePlaylist;

  const PlaylistSelectionBottomSheet({
    Key? key,
    required this.playlists,
    required this.onPlaylistSelected,
    required this.onCreatePlaylist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // 플레이리스트 목록
          Expanded(
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  title: Text(
                    playlist.title.isNotEmpty
                        ? playlist.title
                        : '플레이리스트 ${index + 1}',
                  ),
                  trailing:
                      playlist.isPublic
                          ? const Icon(Icons.public, color: Colors.green)
                          : const Icon(Icons.lock, color: Colors.grey),
                  onTap: () {
                    onPlaylistSelected(playlist);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          // 새 플레이리스트 만들기 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: onCreatePlaylist,
              child: const Text('새 플레이리스트 만들기'),
            ),
          ),
        ],
      ),
    );
  }
}
