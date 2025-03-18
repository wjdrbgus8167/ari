import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dummy_data/mock_data.dart';
import '../../../data/models/track.dart';

class ListeningQueueScreen extends ConsumerStatefulWidget {
  const ListeningQueueScreen({Key? key}) : super(key: key);

  @override
  _ListeningQueueScreenState createState() => _ListeningQueueScreenState();
}

class _ListeningQueueScreenState extends ConsumerState<ListeningQueueScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Track> _filteredPlaylist = [];
  late List<Track> _playlist;

  @override
  void initState() {
    super.initState();
    _playlist = MockData.getListeningQueue();
    _filteredPlaylist = _playlist;
  }

  /// ✅ **검색 기능**
  void _filterTracks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPlaylist = _playlist;
      } else {
        _filteredPlaylist =
            _playlist
                .where(
                  (track) =>
                      track.trackTitle.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      track.artist.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ✅ AppBar 커스텀 (검색 버튼 추가)
          _buildCustomAppBar(),

          // ✅ 위쪽 간격 추가
          const SizedBox(height: 20),

          // ✅ AppBar 아래 곡 개수 표시
          _buildTrackCountBar(_filteredPlaylist.length),

          // ✅ 재생목록 리스트
          Expanded(
            child:
                _filteredPlaylist.isEmpty
                    ? const Center(
                      child: Text(
                        "재생목록이 없습니다.",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredPlaylist.length,
                      itemBuilder: (context, index) {
                        final track = _filteredPlaylist[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              track.coverUrl ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/default_album_cover.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          title: Text(
                            track.trackTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            track.artist,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(
                            Icons.drag_handle, // 🔄 선 세 개짜리 아이콘
                            color: Colors.white70,
                          ),
                          onTap: () {
                            print("${track.trackTitle} 선택됨!");
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  /// ✅ **커스텀 AppBar (검색 버튼 추가)**
  Widget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        width: double.infinity,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 0.5, color: Color(0xFFD9D9D9)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // ✅ 긴 글자가 잘리지 않도록 `FittedBox` 적용
                SizedBox(
                  width: 80, // 충분한 공간 확보
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      '재생목록',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 20), // 간격 추가
                SizedBox(
                  width: 110,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      '플레이리스트',
                      style: TextStyle(
                        color: Color(0xFF989595), // 회색 (비활성화)
                        fontSize: 20,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            // 🔍 검색 버튼 추가
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                _showSearchDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ **트랙 개수 표시 바**
  Widget _buildTrackCountBar(int trackCount) {
    return Container(
      width: double.infinity,
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: ShapeDecoration(
              shape: const OvalBorder(
                side: BorderSide(width: 1, color: Color(0xFF989595)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$trackCount곡',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ **검색 다이얼로그**
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text("곡 검색", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "곡 제목 또는 아티스트 입력",
              hintStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white70),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: _filterTracks,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _searchController.clear();
                _filterTracks('');
                Navigator.pop(context);
              },
              child: const Text(
                "닫기",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
