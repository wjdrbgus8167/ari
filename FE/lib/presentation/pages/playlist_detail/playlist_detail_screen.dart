import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/presentation/widgets/common/global_bottom_widget.dart';
import 'package:ari/presentation/widgets/playlist/my_playlist/playlist_track_controls.dart';
import 'package:ari/presentation/widgets/playlist/my_playlist/playlist_track_list.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final int playlistId;

  const PlaylistDetailScreen({Key? key, required this.playlistId})
    : super(key: key);

  @override
  ConsumerState<PlaylistDetailScreen> createState() =>
      _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = ref.read(playlistViewModelProvider.notifier);

      final existingPlaylist =
          ref.read(playlistViewModelProvider).selectedPlaylist;

      if (existingPlaylist == null ||
          existingPlaylist.id != widget.playlistId) {
        final basePlaylist = Playlist(
          id: widget.playlistId,
          title: '', // 빈 값으로 초기화
          coverImageUrl: '',
          isPublic: false,
          trackCount: 0,
          shareCount: 0,
          tracks: [],
        );

        await viewModel.setPlaylist(basePlaylist);
      } else {
        await viewModel.setPlaylist(existingPlaylist);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistViewModelProvider);
    final playlist = playlistState.selectedPlaylist;

    return GlobalBottomWidget(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            (playlist != null && playlist.title.isNotEmpty)
                ? playlist.title
                : '플레이리스트',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                print('공유 버튼 클릭됨: ${playlist?.title}');
              },
            ),
          ],
        ),
        body:
            playlist == null || playlist.tracks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: const [
                    PlaylistTrackControls(),
                    Expanded(child: PlaylistTrackList()),
                  ],
                ),
      ),
    );
  }
}
