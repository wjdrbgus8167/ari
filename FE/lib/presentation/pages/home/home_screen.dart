import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/album_section_header.dart';
import '../../widgets/album_horizontal_list.dart';
import '../../widgets/playlist_horizontal_list.dart';
import '../../widgets/hot_chart_list.dart';
import '../../../core/utils/genre_utils.dart';
import '../../widgets/home_section.dart';
import '../../widgets/login_prompt.dart';
import '../../../providers/global_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

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
            const SizedBox(height: 8),
            const LoginPrompt(),
            const SizedBox(height: 16),

            // ✅ 최신 앨범 섹션
            AlbumSectionHeader(
              title: "최신 앨범",
              currentGenre: homeState.selectedGenreLatest.displayName,
              genres: Genre.values.map((g) => g.displayName).toList(),
              onGenreSelected: homeViewModel.updateGenreLatest,
            ),
            AlbumHorizontalList(albums: homeState.filteredLatestAlbums),
            const SizedBox(height: 20),

            // ✅ 인기 앨범 섹션
            AlbumSectionHeader(
              title: "인기 앨범",
              currentGenre: homeState.selectedGenrePopular.displayName,
              genres: Genre.values.map((g) => g.displayName).toList(),
              onGenreSelected: homeViewModel.updateGenrePopular,
            ),
            AlbumHorizontalList(albums: homeState.filteredPopularAlbums),
            const SizedBox(height: 20),

            // ✅ 인기 플레이리스트 섹션
            const HomeSectionHeader(title: "인기 플레이리스트"),
            PlaylistHorizontalList(playlists: homeState.popularPlaylists),
            const SizedBox(height: 20),

            // ✅ HOT 50 섹션
            const HomeSectionHeader(title: "HOT 50"),
            SizedBox(
              height: 410,
              child: HotChartList(songs: homeState.hot50Titles),
            ),
          ],
        ),
      ),
    );
  }
}
