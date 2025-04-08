import 'package:ari/presentation/widgets/common/bottom_nav.dart';
import 'package:ari/presentation/widgets/common/listeningqueue_container.dart';
import 'package:ari/presentation/widgets/common/playback_bar.dart';
import 'package:ari/presentation/widgets/playlist/my_playlist/playlist_track_controls.dart';
import 'package:ari/presentation/widgets/playlist/my_playlist/playlist_track_list.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/widgets/common/listening_queue_appbar.dart';
import 'package:ari/presentation/widgets/playlist/my_playlist/playlist_selectbar.dart';
import 'package:ari/presentation/widgets/common/search_bar.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  final ValueChanged<ListeningSubTab>? onTabChanged;

  const PlaylistScreen({super.key, this.onTabChanged});

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playlistViewModelProvider.notifier).fetchPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistViewModel = ref.read(playlistViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            ListeningQueueAppBar(
              onBack: () => Navigator.pop(context),
              onSearch: () {
                setState(() {
                  isSearchVisible = !isSearchVisible;
                });
              },
              selectedTab: ListeningTab.playlist,
              onTabChanged: (tab) {
                if (tab == ListeningTab.listeningQueue) {
                  widget.onTabChanged?.call(ListeningSubTab.queue);
                }
              },
            ),
            if (isSearchVisible)
              SearchBarWidget(
                controller: searchController,
                hintText: "곡 제목 또는 아티스트 검색",
                onChanged: playlistViewModel.searchTracks,
                onSubmitted: playlistViewModel.searchTracks,
              ),
            const SizedBox(height: 10),
            PlaylistSelectbar(
              onPlaylistSelected: playlistViewModel.setPlaylist,
            ),
            const SizedBox(height: 10),
            PlaylistTrackControls(),
            const SizedBox(height: 10),
            const Expanded(child: PlaylistTrackList()),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PlaybackBar(),
          CommonBottomNav(
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/');
              } else if (index == 1) {
                Navigator.pushReplacementNamed(context, '/search');
              } else if (index == 2) {
                // 현재 탭
              } else if (index == 3) {
                Navigator.pushReplacementNamed(context, '/mychannel');
              }
            },
          ),
        ],
      ),
    );
  }
}
