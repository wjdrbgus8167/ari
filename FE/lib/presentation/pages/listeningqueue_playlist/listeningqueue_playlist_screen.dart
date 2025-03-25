import 'package:flutter/material.dart';
import 'package:ari/presentation/widgets/listening_queue/listening_queue_screen.dart';
import 'package:ari/presentation/widgets/playlist/playlist_screen.dart';
import 'package:ari/presentation/widgets/common/listening_queue_appbar.dart';

class ListeningQueuePlaylistScreen extends StatefulWidget {
  const ListeningQueuePlaylistScreen({Key? key}) : super(key: key);

  @override
  _ListeningQueuePlaylistScreenState createState() =>
      _ListeningQueuePlaylistScreenState();
}

class _ListeningQueuePlaylistScreenState
    extends State<ListeningQueuePlaylistScreen> {
  ListeningTab selectedTab = ListeningTab.listeningQueue; // 기본값: 재생목록

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ListeningQueueAppBar(
          onBack: () => Navigator.pop(context),
          onSearch: () {
            // 검색 동작 구현
          },
          selectedTab: selectedTab,
          onTabChanged: (ListeningTab tab) {
            setState(() {
              selectedTab = tab;
            });
          },
        ),
      ),
      body: IndexedStack(
        index: selectedTab == ListeningTab.listeningQueue ? 0 : 1,
        children: const [ListeningQueueScreen(), PlaylistScreen()],
      ),
    );
  }
}
