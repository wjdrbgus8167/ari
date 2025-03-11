import 'package:flutter/material.dart';
import '../../widgets/album_horizontal_list.dart';
import '../../widgets/playlist_horizontal_list.dart';
import '../../widgets/hot_chart_list.dart';
import '../../../dummy_data/mock_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 더미 데이터를 각 섹션에 맞게 불러옵니다.
    final latestAlbums = MockData.getLatestAlbums();
    final popularAlbums = MockData.getPopularAlbums();
    final popularPlaylists = MockData.getPopularPlaylists();
    final hot20Songs = MockData.getHot20Songs();

    return Scaffold(
      appBar: AppBar(title: Text('메인페이지')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 최신 앨범 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '최신 앨범',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            AlbumHorizontalList(albums: latestAlbums),

            // 인기 앨범 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '인기 앨범',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            AlbumHorizontalList(albums: popularAlbums),

            // 인기 플레이리스트 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '인기 플레이리스트',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            PlaylistHorizontalList(playlists: popularPlaylists),

            // HOT 20 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'HOT 20',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            HotChartList(songs: hot20Songs),
          ],
        ),
      ),
    );
  }
}
