import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:ari/presentation/widgets/playlist/public_playlist/track_count_bar.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/presentation/widgets/playlist/my_playlist/playlist_track_list.dart';
import 'package:ari/presentation/widgets/listening_queue/playlist_selection_bottom_sheet.dart';
import 'package:ari/presentation/widgets/listening_queue/create_playlist_modal.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final int playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

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
          title: '',
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
    final userId = ref.watch(authUserIdProvider); // 여기서 userId 가져옴

    final playlistState = ref.watch(playlistViewModelProvider);
    final playlist = playlistState.selectedPlaylist;
    final listeningQueueState = ref.watch(
      listeningQueueProvider,
    ); // ✅ userId 전달!

    return Scaffold(
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
            icon: const Icon(Icons.ios_share_outlined, color: Colors.white),
            onPressed: () async {
              final playlist =
                  ref.read(playlistViewModelProvider).selectedPlaylist;
              if (playlist == null) return;

              try {
                await ref
                    .read(playlistRepositoryProvider)
                    .sharePlaylist(playlist.id);

                // 복사 완료 후 사용자에게 알림
                if (!mounted) return;
                context.showToast('🎉 플레이리스트가 내 플레이리스트로 복사되었어요!');
              } catch (e) {
                if (!mounted) return;
                context.showToast('😢 퍼가기에 실패했어요. 다시 시도해 주세요.');
              }
            },
          ),
        ],
      ),
      body:
          playlist == null || playlist.tracks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  TrackCountBar(
                    trackCount: playlist.tracks.length,
                    selectedTracks: playlistState.selectedTracks,
                    onToggleSelectAll: () {
                      ref
                          .read(playlistViewModelProvider.notifier)
                          .toggleSelectAll();
                    },
                    onAddToPlaylist: () {
                      final selectedTracks =
                          playlistState.selectedTracks.toList();
                      if (selectedTracks.isEmpty) return;

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder:
                            (_) => PlaylistSelectionBottomSheet(
                              playlists: listeningQueueState.playlists,
                              onPlaylistSelected: (selectedPlaylist) {
                                for (var item in selectedTracks) {
                                  ref
                                      .read(playlistRepositoryProvider)
                                      .addTrack(
                                        selectedPlaylist.id,
                                        item.trackId,
                                      );
                                }
                                ref
                                    .read(playlistViewModelProvider.notifier)
                                    .deselectAllTracks();
                              },
                              onCreatePlaylist: () {
                                Navigator.pop(context); // 이전 BottomSheet 닫기
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder:
                                      (_) => CreatePlaylistModal(
                                        onCreate: (title, publicYn) {
                                          ref
                                              .read(
                                                playlistViewModelProvider
                                                    .notifier,
                                              )
                                              .createPlaylistAndAddTracks(
                                                title,
                                                publicYn,
                                                selectedTracks,
                                              );
                                        },
                                      ),
                                );
                              },
                            ),
                      );
                    },
                  ),
                  const Expanded(child: PlaylistTrackList()),
                ],
              ),
    );
  }
}
