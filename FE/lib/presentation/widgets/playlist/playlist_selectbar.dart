// lib/presentation/widgets/playlist/playlist_selectbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/providers/global_providers.dart';

class PlaylistSelectbar extends ConsumerStatefulWidget {
  final ValueChanged<Playlist> onPlaylistSelected;
  const PlaylistSelectbar({Key? key, required this.onPlaylistSelected})
    : super(key: key);

  @override
  _PlaylistSelectbarState createState() => _PlaylistSelectbarState();
}

class _PlaylistSelectbarState extends ConsumerState<PlaylistSelectbar> {
  List<Playlist> playlists = [];
  bool isLoading = true;
  String? errorMessage;
  bool isModalOpen = false;
  Playlist? selectedPlaylist;

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
  }

  Future<void> _fetchPlaylists() async {
    // 글로벌 provider를 통해 Repository 인스턴스 가져오기
    final repository = ref.read(playlistRepositoryProvider);
    try {
      final result = await repository.fetchPlaylists();
      setState(() {
        playlists = result;
        if (playlists.isNotEmpty) {
          selectedPlaylist = playlists.first;
          widget.onPlaylistSelected(selectedPlaylist!);
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPlaylistModal() {
    setState(() {
      isModalOpen = true;
      isLoading = true;
    });
    // 최신 데이터 조회 후 모달 열기
    _fetchPlaylists().then((_) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            width: double.infinity,
            height: 491,
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: 10,
            ),
            clipBehavior: Clip.antiAlias,
            decoration: const ShapeDecoration(
              color: Color(0xFF282828),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(
                      child: Text(
                        'Error: $errorMessage',
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                        Expanded(
                          child: ListView.separated(
                            itemCount: playlists.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              final playlist = playlists[index];
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedPlaylist = playlist;
                                  });
                                  widget.onPlaylistSelected(playlist);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  child: Row(
                                    children: [
                                      // 예시 이미지, 실제 이미지 URL로 교체
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
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              playlist.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: 'Pretendard',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '${playlist.trackCount}곡',
                                              style: const TextStyle(
                                                color: Color(0xFF989595),
                                                fontSize: 12,
                                                fontFamily: 'Pretendard',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
          );
        },
      ).whenComplete(() {
        setState(() {
          isModalOpen = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = selectedPlaylist?.title ?? '나의 플레이리스트 보기';
    return GestureDetector(
      onTap: _showPlaylistModal,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              isModalOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
