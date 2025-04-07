library;

import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/core/utils/genre_utils.dart';
import 'package:ari/data/models/album.dart' as data_model;
import 'package:ari/data/models/track.dart';
import 'package:ari/domain/entities/chart_item.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/genre/genre_viewmodel.dart';
import 'package:ari/presentation/widgets/common/carousel_container.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/providers/genre/genre_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenrePage extends ConsumerWidget {
  final Genre genre;

  const GenrePage({super.key, required this.genre});

  // 장르에 따른 표시 이름 얻기
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
        // 기본값으로 장르 enum 값을 문자열로 변환
        return genre.toString().split('.').last;
    }
  }

  // 장르에 따른 그라디언트 얻기
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
        // 기본 그라디언트
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
            // 커스텀 헤더
            Container(
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
                  // 뒤로가기 버튼
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  const SizedBox(width: 2),

                  // 그라디언트 적용된 장르 제목
                  ShaderMask(
                    shaderCallback:
                        (bounds) => genreGradient.createShader(bounds),
                    child: Text(
                      '$displayGenreName Page',
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 메인 콘텐츠
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

  /// 오류 상태 UI
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
              state.errorMessage ??
                  '데이터를 불러오는 중 오류가 발생했습니다.\n(해당 장르의 데이터가 없을 수 있습니다)',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => viewModel.refresh(),
                child: const Text('다시 시도'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                ),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 메인 콘텐츠 UI
  Widget _buildContent(
    BuildContext context,
    GenreState state,
    GenreViewModel viewModel,
  ) {
    // 모든 데이터가 비어있는 경우 안내 메시지
    if (state.newAlbums.isEmpty &&
        state.popularAlbums.isEmpty &&
        state.monthlyCharts.isEmpty &&
        state.weeklyTracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.album_outlined, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            Text(
              '${state.genreName} 장르의 데이터가 없습니다',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mediumPurple,
              ),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 최신 앨범 섹션
            if (state.newAlbums.isNotEmpty) ...[
              _buildSectionHeader('최신 앨범'),
              CarouselContainer(
                title: "",
                children: _buildAlbumItems(context, state.newAlbums),
              ),
              const SizedBox(height: 24),
            ],

            // 인기 앨범 섹션
            if (state.popularAlbums.isNotEmpty) ...[
              _buildSectionHeader('인기 앨범'),
              CarouselContainer(
                title: "",
                children: _buildAlbumItems(context, state.popularAlbums),
              ),
              const SizedBox(height: 24),
            ],

            // 차트 섹션 (차트 데이터가 있는 경우만 표시)
            if (state.monthlyCharts.isNotEmpty || state.weeklyTracks.isNotEmpty)
              _buildChartSection(context, state, viewModel),
          ],
        ),
      ),
    );
  }

  /// 앨범 아이템 위젯 목록 생성
  List<Widget> _buildAlbumItems(
    BuildContext context,
    List<data_model.Album> albums,
  ) {
    return albums.map((album) {
      return GestureDetector(
        onTap:
            () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.album, arguments: {'albumId': album.id}),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앨범 커버 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                album.coverUrl,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, _, __) => Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.album,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 8),
            // 앨범 제목
            Text(
              album.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // 아티스트 이름
            Text(
              album.artist,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }).toList();
  }

  /// 섹션 헤더 위젯
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 차트 섹션 위젯
  Widget _buildChartSection(
    BuildContext context,
    GenreState state,
    GenreViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 차트 헤더와 필터 옵션
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
              // 커스텀 토글 버튼
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 월간 버튼
                    GestureDetector(
                      onTap:
                          () => viewModel.selectChartPeriodType(
                            ChartPeriodType.monthly,
                          ),
                      child: Container(
                        width: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              state.selectedChartType == ChartPeriodType.monthly
                                  ? AppColors.mediumPurple
                                  : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '월간',
                          style: TextStyle(
                            color:
                                state.selectedChartType ==
                                        ChartPeriodType.monthly
                                    ? Colors.white
                                    : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    // 주간 버튼
                    GestureDetector(
                      onTap:
                          () => viewModel.selectChartPeriodType(
                            ChartPeriodType.weekly,
                          ),
                      child: Container(
                        width: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              state.selectedChartType == ChartPeriodType.weekly
                                  ? AppColors.mediumPurple
                                  : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '주간',
                          style: TextStyle(
                            color:
                                state.selectedChartType ==
                                        ChartPeriodType.weekly
                                    ? Colors.white
                                    : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 차트 리스트
        if (state.currentChartItems.isNotEmpty)
          _buildChartList(context, state)
        else
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '차트 데이터가 없습니다',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

        // 여백 추가
        const SizedBox(height: 32),
      ],
    );
  }

  /// 차트 리스트 위젯
  Widget _buildChartList(BuildContext context, GenreState state) {
    final items = state.currentChartItems;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            if (state.selectedChartType == ChartPeriodType.monthly) {
              // 월간 차트 아이템 (ChartItem)
              final chartItem = items[index] as ChartItem;
              return _buildMonthlyChartItem(context, chartItem, index);
            } else {
              // 주간 차트 아이템 (Track)
              final track = items[index] as Track;
              return _buildWeeklyChartItem(context, track, index);
            }
          },
        ),
        // 차트 리스트 아래에 여백 추가
        const SizedBox(height: 20),
      ],
    );
  }

  /// 월간 차트 아이템 위젯
  Widget _buildMonthlyChartItem(
    BuildContext context,
    ChartItem chartItem,
    int index,
  ) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 순위 표시
          SizedBox(
            width: 24,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 앨범 커버
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              chartItem.coverImageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, _, __) => Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
            ),
          ),
        ],
      ),
      title: Text(
        chartItem.trackTitle,
        style: const TextStyle(color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        chartItem.artist,
        style: const TextStyle(color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.track,
          arguments: {
            'trackId': chartItem.trackId,
            'albumCoverUrl': chartItem.coverImageUrl,
          },
        );
      },
    );
  }

  /// 주간 차트 아이템 위젯
  Widget _buildWeeklyChartItem(BuildContext context, Track track, int index) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 순위 표시
          SizedBox(
            width: 24,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 앨범 커버
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              track.coverUrl ?? '',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, _, __) => Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
            ),
          ),
        ],
      ),
      title: Text(
        track.trackTitle,
        style: const TextStyle(color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artist,
        style: const TextStyle(color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.track,
          arguments: {'trackId': track.id, 'albumCoverUrl': track.coverUrl},
        );
      },
    );
  }
}
