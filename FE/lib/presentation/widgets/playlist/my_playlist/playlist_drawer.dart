// import 'package:ari/providers/global_providers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ari/presentation/widgets/common/media_card.dart';
// import 'package:ari/presentation/widgets/playlist/public_playlist/playlist_card.dart';
// import 'package:ari/presentation/viewmodels/playlist/playlist_viewmodel.dart';
// import 'package:ari/presentation/viewmodels/playlist/playlist_state.dart';

// // 만약 아래와 같이 playlistViewModelProvider, playlistStateProvider가 이미 정의되어 있다면
// // final playlistViewModelProvider = StateNotifierProvider<PlaylistViewModel, PlaylistState>((ref) => PlaylistViewModel(...));
// // final playlistStateProvider = ... (PlaylistState)

// // 나의 플레이리스트를 카드 형태로 조회하는 페이지
// class MyPlaylistScreen extends ConsumerWidget {
//   const MyPlaylistScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 플레이리스트 상태를 구독
//     final playlistState = ref.watch(playlistStateProvider);
//     final playlists = playlistState.playlists;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('나의 플레이리스트'),
//         backgroundColor: Colors.black,
//       ),
//       backgroundColor: Colors.black,
//       // 당겨서 새로고침 기능 (옵션)
//       body: RefreshIndicator(
//         onRefresh: () async {
//           // 플레이리스트 목록 새로고침 (fetchPlaylists 메서드가 플레이리스트 목록을 불러오는 API 호출을 포함)
//           await ref.read(playlistViewModelProvider.notifier).fetchPlaylists();
//         },
//         child:
//             playlists.isEmpty
//                 ? const Center(
//                   child: Text(
//                     '플레이리스트가 없습니다.',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 )
//                 : ListView.builder(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   itemCount: playlists.length,
//                   itemBuilder: (context, index) {
//                     final playlist = playlists[index];
//                     // PlaylistCard 내부에 onTap, onPlayPressed 등 처리되어 있으므로 그대로 사용
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       child: PlaylistCard(playlist: playlist),
//                     );
//                   },
//                 ),
//       ),
//     );
//   }
// }
