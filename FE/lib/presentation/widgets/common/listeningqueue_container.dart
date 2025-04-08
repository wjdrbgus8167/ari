import 'package:flutter/material.dart';
import 'package:ari/presentation/pages/listeningqueue/listening_queue_screen.dart';
import 'package:ari/presentation/pages/playlist/playlist_screen.dart';

enum ListeningSubTab { queue, playlist }

class ListeningQueueTabContainer extends StatefulWidget {
  const ListeningQueueTabContainer({super.key});

  @override
  State<ListeningQueueTabContainer> createState() =>
      _ListeningQueueTabContainerState();
}

class _ListeningQueueTabContainerState
    extends State<ListeningQueueTabContainer> {
  ListeningSubTab _currentTab = ListeningSubTab.queue;

  void _onTabChanged(ListeningSubTab tab) {
    // if (_currentTab == tab) return; // ✅ 같은 탭이면 무시

    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _currentTab == ListeningSubTab.queue
              ? ListeningQueueScreen(onTabChanged: _onTabChanged)
              : PlaylistScreen(onTabChanged: _onTabChanged),
    );
  }
}
