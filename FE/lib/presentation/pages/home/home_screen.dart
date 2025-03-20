import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/album/album_section_header.dart';
import '../../widgets/album/album_horizontal_list.dart';
import '../../widgets/playlist/playlist_horizontal_list.dart';
import '../../widgets/hot_chart_list.dart';
import '../../../core/utils/genre_utils.dart';
import '../../widgets/home_section.dart';
import '../../widgets/login_prompt.dart';
import '../../../providers/global_providers.dart';
import '../../widgets/common/header_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 메인 페이지 헤더 적용
            //SafeArea 위젯으로 감싸기(모바일 환경에서 맨위의 바와 겹치는거 방지지)
            SafeArea(
              child: HeaderWidget(
                type: HeaderType.main,
                onMyPagePressed: () {
                  // 마이페이지 이동
                  Navigator.of(context).pushNamed(AppRoutes.myPage);
                },
              ),
            ),
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
              child: HotChartList(tracks: homeState.hot50Titles),
            ),
          ],
        ),
      ),
    );
  }
}
