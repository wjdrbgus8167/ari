import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/global_providers.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider); // 현재 재생 상태
    final playlist = ref.watch(playlistProvider); // 재생 목록

    return Scaffold(
      appBar: AppBar(title: const Text("재생목록"), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: playlist.length,
        itemBuilder: (context, index) {
          final track = playlist[index]; // ✅ `song` → `track`으로 변경
          final isPlaying =
              track.id ==
              playbackState
                  .currentTrackId; // ✅ `currentSongId` → `currentTrackId`로 변경

          return ListTile(
            leading: Image.network(
              track.coverUrl ??
                  '../assets', // ✅ `song.coverUrl` → `track.coverUrl`
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(
              track.trackTitle, // ✅ `song.trackTitle` → `track.trackTitle`
              style: TextStyle(
                color: isPlaying ? Colors.blueAccent : Colors.white,
                fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              track.artist, // ✅ `song.artist` → `track.artist`
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // 옵션 메뉴 (삭제, 상세보기 등)
              },
            ),
            onTap: () {
              ref
                  .read(playbackProvider.notifier)
                  .play(track.id); // ✅ `song.id` → `track.id`
            },
          );
        },
      ),
    );
  }
}
