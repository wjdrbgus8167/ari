import 'package:flutter/material.dart';
// 로그인 화면 import 필요 (예: login_screen.dart)
import '../login/login_screen.dart';
import '../../widgets/album_section_header.dart';
import '../../widgets/album_horizontal_list.dart';
import '../../widgets/playlist_horizontal_list.dart';
import '../../widgets/hot_chart_list.dart';
import '../../../dummy_data/mock_data.dart';
import '../../../data/models/album.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> genres = ["전체", "힙합", "재즈", "밴드", "알앤비", "어쿠스틱"];

  String selectedGenreLatest = "전체";
  String selectedGenrePopular = "전체";
  int _selectedIndex = 0;

  String _mapGenre(String genre) {
    switch (genre) {
      case "재즈":
        return "jazz";
      case "힙합":
        return "hiphop";
      case "밴드":
        return "band";
      case "알앤비":
        return "rnb";
      case "어쿠스틱":
        return "acoustic";
      case "전체":
        return "전체";
      default:
        return genre;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allLatestAlbums = MockData.getLatestAlbums();
    final allPopularAlbums = MockData.getPopularAlbums();
    final popularPlaylists = MockData.getPopularPlaylists();
    final hot20Songs = MockData.getHot20Songs();

    List<Album> filteredLatestAlbums =
        selectedGenreLatest == "전체"
            ? allLatestAlbums
            : allLatestAlbums
                .where(
                  (album) =>
                      album.genre.toLowerCase() ==
                      _mapGenre(selectedGenreLatest).toLowerCase(),
                )
                .toList();

    List<Album> filteredPopularAlbums =
        selectedGenrePopular == "전체"
            ? allPopularAlbums
            : allPopularAlbums
                .where(
                  (album) =>
                      album.genre.toLowerCase() ==
                      _mapGenre(selectedGenrePopular).toLowerCase(),
                )
                .toList();

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
              padding: const EdgeInsets.only(left: 16), // 왼쪽에 16px 패딩 추가
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    // 로그인 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '로그인해주세요 >',
                    style: TextStyle(color: Colors.white, fontSize: 20),
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

            // HOT 20 섹션
            _buildSectionHeader("HOT 20"),
            SizedBox(height: 330, child: HotChartList(songs: hot20Songs)),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: '서랍'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
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
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}

// // 예시용 로그인 화면
// class LoginScreen extends StatelessWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // 배경색, 앱바 등은 자유롭게 수정 가능
//       backgroundColor: Colors.black,
//       appBar: AppBar(backgroundColor: Colors.black, title: const Text('로그인')),
//       body: Center(
//         child: Text('로그인 화면', style: TextStyle(color: Colors.white)),
//       ),
//     );
//   }
// }
