library;

import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/core/utils/genre_utils.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/entities/track.dart' as domain;
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/genre/genre_viewmodel.dart';
import 'package:ari/presentation/widgets/album/album_section_header.dart';
import 'package:ari/presentation/widgets/common/carousel_container.dart';
import 'package:ari/presentation/widgets/common/media_card.dart';
import 'package:ari/presentation/widgets/hot_chart_list.dart';
import 'package:ari/providers/genre/genre_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenrePage extends ConsumerWidget {
  final Genre genre;

  const GenrePage({super.key, required this.genre});

  String _getDisplayGenreName(Genre genre) {
    switch (genre) {
      case Genre.hiphop:
        return 'HipHop & Rap';
      case Genre.band:
        return 'Band';
      case Genre.rnb:
        return 'R&B';
      case Genre.jazz:
        return 'Jazz';
      case Genre.acoustic:
        return 'Acoustic';
      default:
        return genre.toString().split('.').last;
    }
  }

  Gradient _getGenreGradient(Genre genre) {
    switch (genre) {
      case Genre.hiphop:
        return AppColors.purpleGradient;
      case Genre.band:
        return AppColors.blueToMintGradient;
      case Genre.rnb:
        return AppColors.greenGradientHorizontal;
      case Genre.jazz:
        return AppColors.purpleGradientHorizontal;
      case Genre.acoustic:
        return const LinearGradient(
          colors: [Color(0xFFE5BCFF), Color(0xFF7DDCFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppColors.purpleGradient;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genreState = ref.watch(genreViewModelProvider(genre));
    final genreViewModel = ref.read(genreViewModelProvider(genre).notifier);
    final displayGenreName = _getDisplayGenreName(genre);
    final genreGradient = _getGenreGradient(genre);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(displayGenreName, genreGradient, context),
            Expanded(
              child:
                  genreState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : genreState.errorMessage != null
                      ? _buildErrorState(context, genreState, genreViewModel)
                      : _buildContent(context, genreState, genreViewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    String displayGenreName,
    Gradient genreGradient,
    BuildContext context,
  ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 2),
          ShaderMask(
            shaderCallback: (bounds) => genreGradient.createShader(bounds),
            child: Text(
              '$displayGenreName ',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    GenreState state,
    GenreViewModel viewModel,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              state.errorMessage ?? '데이터를 불러오는 중 오류가 발생했습니다.',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.refresh(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GenreState state,
    GenreViewModel viewModel,
  ) {
    print('[GenrePage] 📦 newAlbums: ${state.newAlbums.length}');
    print('[GenrePage] 🔥 popularAlbums: ${state.popularAlbums.length}');
    print('[GenrePage] 📈 charts: ${state.monthlyCharts.length}');
    print('[GenrePage] 🎵 weeklyTracks: ${state.weeklyTracks.length}');

    if (state.newAlbums.isEmpty &&
        state.popularAlbums.isEmpty &&
        state.monthlyCharts.isEmpty &&
        state.weeklyTracks.isEmpty) {
      return const Center(
        child: Text('해당 장르의 데이터가 없습니다.', style: TextStyle(color: Colors.white)),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            if (state.newAlbums.isNotEmpty) ...[
              Builder(
                builder: (_) {
                  print('[🎯 GenrePage] ✅ 최신 앨범 위젯 렌더링 시작');
                  return const SizedBox(); // 실제 화면엔 아무것도 안 보임
                },
              ),

              AlbumSectionHeader(
                title: '최신 앨범',
                currentGenre: genre.displayName,
                genres: const [],
                onGenreSelected: (_) {},
              ),
              CarouselContainer(
                title: '',
                children: _buildAlbumItems(context, state.newAlbums),
              ),
              const SizedBox(height: 24),
            ],
            if (state.popularAlbums.isNotEmpty) ...[
              AlbumSectionHeader(
                title: '인기 앨범',
                currentGenre: genre.displayName,
                genres: const [],
                onGenreSelected: (_) {},
              ),
              CarouselContainer(
                title: '',
                children: _buildAlbumItems(context, state.popularAlbums),
              ),
              const SizedBox(height: 24),
            ],
            if (state.monthlyCharts.isNotEmpty || state.weeklyTracks.isNotEmpty)
              _buildChartSection(context, state, viewModel),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAlbumItems(BuildContext context, List<Album> albums) {
    print('[🧱 buildAlbumItems] 앨범 수: ${albums.length}');
    return albums.map((album) {
      print('[🧱 album]: ${album.albumTitle}');

      return MediaCard(
        imageUrl: album.coverImageUrl,
        title: album.albumTitle,
        subtitle: album.artist,
        onTap:
            () => Navigator.pushNamed(
              context,
              AppRoutes.album,
              arguments: {'albumId': album.albumId},
            ),
      );
    }).toList();
  }

  Widget _buildChartSection(
    BuildContext context,
    GenreState state,
    GenreViewModel viewModel,
  ) {
    List<domain.Track> getConvertedTracks(GenreState state) {
      if (state.selectedChartType == ChartPeriodType.weekly) {
        return state.weeklyTracks;
      }

      return state.monthlyCharts.map((item) {
        return domain.Track(
          trackId: item.trackId,
          trackTitle: item.trackTitle,
          artistName: item.artist,
          albumId: item.albumId,
          coverUrl: item.coverImageUrl,
          albumTitle: '',
          genreName: '',
          lyric: '',
          trackNumber: 0,
          commentCount: 0,
          lyricist: [],
          composer: [],
          comments: [],
          createdAt: '',
          trackFileUrl: '',
          trackLikeCount: 0,
        );
      }).toList();
    }

    final List<domain.Track> tracks = getConvertedTracks(state);

    if (tracks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('차트 데이터가 없습니다', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '차트',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildChartToggleButton(
                      label: '월간',
                      isSelected:
                          state.selectedChartType == ChartPeriodType.monthly,
                      onTap:
                          () => viewModel.selectChartPeriodType(
                            ChartPeriodType.monthly,
                          ),
                    ),
                    _buildChartToggleButton(
                      label: '주간',
                      isSelected:
                          state.selectedChartType == ChartPeriodType.weekly,
                      onTap:
                          () => viewModel.selectChartPeriodType(
                            ChartPeriodType.weekly,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 420, child: HotChartList(tracks: tracks)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildChartToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mediumPurple : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: label == '월간' ? const Radius.circular(8) : Radius.zero,
            right: label == '주간' ? const Radius.circular(8) : Radius.zero,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
