import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ari/providers/global_providers.dart';

import 'package:ari/core/utils/genre_utils.dart';

import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/album/album_section_header.dart';
import 'package:ari/presentation/widgets/album/album_card.dart';
import 'package:ari/presentation/widgets/common/carousel_container.dart';
import 'package:ari/presentation/widgets/playlist/public_playlist/playlist_card.dart';
import 'package:ari/presentation/widgets/hot_chart_list.dart';
import 'package:ari/presentation/widgets/home_section.dart';
import 'package:ari/presentation/widgets/login_prompt.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: HeaderWidget(
                type: HeaderType.main,
              ),
            ),
            const SizedBox(height: 8),
            const LoginPrompt(),
            const SizedBox(height: 16),

            /// ✅ 최신 앨범 섹션
            AlbumSectionHeader(
              title: "최신 앨범",
              currentGenre: homeState.selectedGenreLatest.displayName,
              genres: Genre.values.map((g) => g.displayName).toList(),
              onGenreSelected: homeViewModel.updateGenreLatest,
            ),
            CarouselContainer(
              title: "",
              children:
                  homeState.filteredLatestAlbums
                      .map((album) => AlbumCard(album: album))
                      .toList(),
            ),

            /// ✅ 인기 앨범 섹션
            AlbumSectionHeader(
              title: "인기 앨범",
              currentGenre: homeState.selectedGenrePopular.displayName,
              genres: Genre.values.map((g) => g.displayName).toList(),
              onGenreSelected: homeViewModel.updateGenrePopular,
            ),
            CarouselContainer(
              title: "",
              children:
                  homeState.filteredPopularAlbums
                      .map((album) => AlbumCard(album: album))
                      .toList(),
            ),

            /// ✅ 인기 플레이리스트
            const HomeSectionHeader(title: "인기 플레이리스트"),
            CarouselContainer(
              title: "",
              height: 190,
              itemWidth: 150,
              children:
                  homeState.popularPlaylists
                      .map((playlist) => PlaylistCard(playlist: playlist))
                      .toList(),
            ),

            /// ✅ HOT 20 섹션
            const HomeSectionHeader(title: "HOT 20"),
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
