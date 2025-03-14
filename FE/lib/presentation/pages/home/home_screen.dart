import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import '../../widgets/album_section_header.dart';
import '../../widgets/album_horizontal_list.dart';
import '../../widgets/playlist_horizontal_list.dart';
import '../../widgets/hot_chart_list.dart';
import '../../../dummy_data/mock_data.dart';
import '../../../core/utils/genre_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> genres = ["전체", "힙합", "재즈", "밴드", "알앤비", "어쿠스틱"];

  String selectedGenreLatest = "전체";
  String selectedGenrePopular = "전체";

  @override
  Widget build(BuildContext context) {
    final allLatestAlbums = MockData.getLatestAlbums();
    final allPopularAlbums = MockData.getPopularAlbums();
    final popularPlaylists = MockData.getPopularPlaylists();
    final hot20Songs = MockData.getHot20Songs();

    // 유틸 함수 filterAlbumsByGenre 사용
    final filteredLatestAlbums = filterAlbumsByGenre(
      allLatestAlbums,
      selectedGenreLatest,
    );
    final filteredPopularAlbums = filterAlbumsByGenre(
      allPopularAlbums,
      selectedGenrePopular,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', height: 40),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "로그인해주세요 >" 버튼
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '로그인해주세요 >',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600, // semibold
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 최신 앨범 섹션
            AlbumSectionHeader(
              title: "최신 앨범",
              currentGenre: selectedGenreLatest,
              genres: genres,
              onGenreSelected: (genre) {
                setState(() {
                  selectedGenreLatest = genre;
                });
              },
            ),
            AlbumHorizontalList(albums: filteredLatestAlbums),
            const SizedBox(height: 20),
            // 인기 앨범 섹션
            AlbumSectionHeader(
              title: "인기 앨범",
              currentGenre: selectedGenrePopular,
              genres: genres,
              onGenreSelected: (genre) {
                setState(() {
                  selectedGenrePopular = genre;
                });
              },
            ),
            AlbumHorizontalList(albums: filteredPopularAlbums),
            const SizedBox(height: 20),
            // 인기 플레이리스트 섹션
            _buildSectionHeader("인기 플레이리스트"),
            PlaylistHorizontalList(playlists: popularPlaylists),
            const SizedBox(height: 20),
            // HOT 50 섹션
            _buildSectionHeader("HOT 50"),
            SizedBox(height: 410, child: HotChartList(songs: hot20Songs)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
