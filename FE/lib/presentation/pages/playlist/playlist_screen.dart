import 'package:ari/presentation/widgets/playlist/playlist_track_controls.dart';
import 'package:ari/presentation/widgets/playlist/playlist_track_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/widgets/common/listening_queue_appbar.dart';
import 'package:ari/presentation/widgets/playlist/playlist_selectbar.dart';
import 'package:ari/presentation/viewmodels/playlist/playlist_viewmodel.dart';
import 'package:ari/presentation/widgets/common/global_bottom_widget.dart';
import 'package:ari/presentation/widgets/common/search_bar.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistViewModelProvider);
    final playlistViewModel = ref.read(playlistViewModelProvider.notifier);

    // 전체 선택 여부 판단
    bool allSelected = false;
    if (playlistState.selectedPlaylist != null &&
        playlistState.selectedPlaylist!.tracks.isNotEmpty) {
      allSelected = playlistState.selectedPlaylist!.tracks.every(
        (item) => playlistState.selectedTracks.contains(item),
      );
    }

    return GlobalBottomWidget(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            // 상단 앱바
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
                  Navigator.pushReplacementNamed(context, '/listeningqueue');
                }
              },
            ),

            // 검색창
            if (isSearchVisible)
              SearchBarWidget(
                controller: searchController,
                hintText: "곡 제목 또는 아티스트 검색",
                onChanged: (query) {
                  playlistViewModel.searchTracks(query);
                },
                onSubmitted: (query) {
                  playlistViewModel.searchTracks(query);
                },
              ),

            const SizedBox(height: 10),

            // 플레이리스트 선택 바
            PlaylistSelectbar(
              onPlaylistSelected: (playlist) {
                playlistViewModel.setPlaylist(playlist);
              },
            ),

            const SizedBox(height: 10),

            // 전체 선택 / 삭제 컨트롤 바
            PlaylistTrackControls(),

            const SizedBox(height: 10),

            // 트랙 리스트
            const Expanded(child: PlaylistTrackList()),
          ],
        ),
      ),
    );
  }
}
