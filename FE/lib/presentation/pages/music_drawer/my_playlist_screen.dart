import 'package:ari/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/widgets/playlist/public_playlist/playlist_card.dart';

class MyPlaylistScreen extends ConsumerStatefulWidget {
  const MyPlaylistScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyPlaylistScreen> createState() => _MyPlaylistScreenState();
}

class _MyPlaylistScreenState extends ConsumerState<MyPlaylistScreen> {
  @override
  void initState() {
    super.initState();
    // 페이지가 로드될 때 fetchPlaylists() 호출
    Future.microtask(() {
      ref.read(playlistViewModelProvider.notifier).fetchPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistViewModelProvider);
    final playlists = playlistState.playlists;

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 플레이리스트'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(playlistViewModelProvider.notifier).fetchPlaylists();
        },
        child:
            playlists.isEmpty
                ? const Center(
                  child: Text(
                    '플레이리스트가 없습니다.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: GridView.builder(
                    itemCount: playlists.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 한 줄에 2개씩
                          crossAxisSpacing: 16, // 카드 사이 가로 간격
                          mainAxisSpacing: 16, // 카드 사이 세로 간격
                          childAspectRatio: 0.75, // 카드 가로:세로 비율 (필요에 따라 조절)
                        ),
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return PlaylistCard(playlist: playlist);
                    },
                  ),
                ),
      ),
    );
  }
}
