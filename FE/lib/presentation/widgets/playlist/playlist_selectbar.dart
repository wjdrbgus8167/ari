import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ari/data/models/playlist.dart';

class PlaylistSelectbar extends StatefulWidget {
  const PlaylistSelectbar({Key? key}) : super(key: key);

  @override
  _PlaylistSelectbarState createState() => _PlaylistSelectbarState();
}

class _PlaylistSelectbarState extends State<PlaylistSelectbar> {
  List<Playlist> playlists = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    try {
      final dio = Dio();
      // baseUrl 설정이 필요하다면 dio.options.baseUrl = 'https://your.api.url';
      final response = await dio.get('api/v1/playlists');
      // 응답 구조에 따라 'data' 필드 사용 (예시)
      final List<dynamic> data = response.data['data'];
      setState(() {
        playlists = data.map((json) => Playlist.fromJson(json)).toList();
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

  // 밑에서 위로 나오는 모달 디자인 (예시)
  void _showPlaylistModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                            return Container(
                              width: double.infinity,
                              height: 60,
                              clipBehavior: Clip.antiAlias,
                              child: Row(
                                children: [
                                  // 이미지 예시, 실제 이미지 URL로 교체
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
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
                                          playlist.playlistTitle,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${playlist.tracks.length}곡',
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
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 버튼 디자인: 누르면 모달이 나타남
    return GestureDetector(
      onTap: _showPlaylistModal,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: const [
            Text(
              '나의 플레이리스트 보기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.keyboard_arrow_up, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
