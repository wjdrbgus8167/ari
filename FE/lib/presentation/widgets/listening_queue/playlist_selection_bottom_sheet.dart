import 'package:flutter/material.dart';
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/presentation/widgets/common/button_large.dart'; // 이 부분 추가

class PlaylistSelectionBottomSheet extends StatelessWidget {
  final List<Playlist> playlists;
  final Function(Playlist) onPlaylistSelected;
  final VoidCallback onCreatePlaylist;

  const PlaylistSelectionBottomSheet({
    super.key,
    required this.playlists,
    required this.onPlaylistSelected,
    required this.onCreatePlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF282828),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            '나의 플레이리스트',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              letterSpacing: -0.16,
            ),
          ),
          const SizedBox(height: 20),
          // 플레이리스트 목록
          Expanded(
            child:
                playlists.isEmpty
                    ? const Center(
                      child: Text(
                        '플레이리스트가 없습니다',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : ListView.separated(
                      itemCount: playlists.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        return InkWell(
                          onTap: () {
                            onPlaylistSelected(playlist);
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            height: 60,
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        "assets/images/default_album_cover.png",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        playlist.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${playlist.trackCount}곡',
                                        style: const TextStyle(
                                          color: Color(0xFF989595),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  playlist.isPublic ? Icons.public : Icons.lock,
                                  size: 18,
                                  color:
                                      playlist.isPublic
                                          ? Colors.green
                                          : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          const SizedBox(height: 16),
          PrimaryButtonLarge(
            text: '새 플레이리스트 만들기',
            onPressed: onCreatePlaylist,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
