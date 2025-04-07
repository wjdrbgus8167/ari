import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/presentation/viewmodels/search/search_viewmodel.dart';
import 'package:ari/providers/search/search_providers.dart';
import '../../routes/app_router.dart';
import 'package:ari/core/utils/genre_utils.dart';
import 'package:ari/presentation/widgets/search/search_input.dart';

// 향상된 색상 순환 효과 애니메이션 위젯 임포트
import '../../widgets/search/enhanced_color_shift_genre_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final bool shouldShowResults = searchState.query.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '검색',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchInput(
                controller: _searchController,
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    ref.read(searchViewModelProvider.notifier).search(query);
                  }
                },
                onChanged: (query) {
                  ref.read(searchViewModelProvider.notifier).search(query);
                },
                onClear: () {
                  _searchController.clear();
                  ref.read(searchViewModelProvider.notifier).clearSearch();
                },
              ),
            ),
            const SizedBox(height: 20),

            if (searchState.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                ),
              ),

            Expanded(
              child:
                  shouldShowResults
                      ? _buildSearchResults(searchState)
                      : _buildGenreCategories(),
            ),
          ],
        ),
      ),
    );
  }

  /// 장르 카테고리 섹션 - 모든 카드에 향상된 색상 순환 효과 적용
  Widget _buildGenreCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final itemSpacing = 12.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              spacing: itemSpacing,
              runSpacing: itemSpacing,
              children: [
                // Hip Hop & Rap
                EnhancedColorShiftGenreCard(
                  title: 'HipHop & Rap',
                  gradient: AppColors.purpleGradient,
                  width: (maxWidth - itemSpacing) * 0.6, // 60% 너비
                  height: 180,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(20),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.genre,
                      arguments: {'genre': Genre.hiphop},
                    );
                  },
                ),

                // Band
                EnhancedColorShiftGenreCard(
                  title: 'Band',
                  gradient: AppColors.blueToMintGradient,
                  width: (maxWidth - itemSpacing) * 0.4, // 40% 너비
                  height: 180,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(8),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.genre,
                      arguments: {'genre': Genre.band},
                    );
                  },
                ),

                // R&B
                EnhancedColorShiftGenreCard(
                  title: 'R&B',
                  gradient: AppColors.greenGradientHorizontal,
                  width: (maxWidth - itemSpacing) * 0.5, // 50% 너비
                  height: 160,
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.genre,
                      arguments: {'genre': Genre.rnb},
                    );
                  },
                ),

                // Jazz
                EnhancedColorShiftGenreCard(
                  title: 'Jazz',
                  gradient: AppColors.purpleGradientHorizontal,
                  width: (maxWidth - itemSpacing) * 0.5, // 50% 너비
                  height: 160,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(24),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.genre,
                      arguments: {'genre': Genre.jazz},
                    );
                  },
                ),

                // Acoustic
                EnhancedColorShiftGenreCard(
                  title: 'Acoustic',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE5BCFF), Color(0xFF7DDCFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  width: maxWidth,
                  height: 140,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.genre,
                      arguments: {'genre': Genre.acoustic},
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 검색 결과 섹션 구성 (기존 코드 유지)
  Widget _buildSearchResults(SearchState state) {
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (state.query.isNotEmpty) {
                  ref
                      .read(searchViewModelProvider.notifier)
                      .search(state.query);
                }
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.artists.isEmpty && state.tracks.isEmpty) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아티스트 검색 결과
            if (state.artists.isNotEmpty) ...[
              const Text(
                '아티스트',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.artists.length,
                itemBuilder: (context, index) {
                  final artist = state.artists[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(artist.profileImageUrl),
                      radius: 24,
                      onBackgroundImageError: (_, __) {},
                      backgroundColor: Colors.grey[800],
                      child:
                          artist.profileImageUrl.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                    ),
                    title: Text(
                      artist.nickname,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.myChannel,
                        arguments: {'memberId': artist.memberId.toString()},
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // 트랙 검색 결과
            if (state.tracks.isNotEmpty) ...[
              const Text(
                '트랙',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.tracks.length,
                itemBuilder: (context, index) {
                  final track = state.tracks[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child:
                          track.coverImageUrl.isEmpty
                              ? Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                ),
                              )
                              : Image.network(
                                track.coverImageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 48,
                                    height: 48,
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                    ),
                    title: Text(
                      track.trackTitle,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      track.artist,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.track,
                        arguments: {
                          'trackId': track.trackId,
                          'albumCoverUrl': track.coverImageUrl,
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
