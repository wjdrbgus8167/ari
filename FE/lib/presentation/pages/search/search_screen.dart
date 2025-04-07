import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/presentation/widgets/search/genre_card.dart';
import 'package:ari/presentation/widgets/search/search_input.dart';
import 'package:ari/presentation/viewmodels/search/search_viewmodel.dart';
import 'package:ari/providers/search/search_providers.dart';
import '../../routes/app_router.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 검색어로 판단
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);

    // 검색어가 있는지 여부로 결과/카테고리 표시 결정
    final bool shouldShowResults = searchState.query.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 검색 페이지 제목
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
            // 검색 입력 필드
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
                  // 실시간 검색 - 즉시 검색 상태 업데이트
                  ref.read(searchViewModelProvider.notifier).search(query);
                },
                onClear: () {
                  _searchController.clear();
                  ref.read(searchViewModelProvider.notifier).clearSearch();
                },
              ),
            ),
            const SizedBox(height: 20),

            // 검색 중 로딩 인디케이터
            if (searchState.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: SizedBox(
                    width: 24, // 크기 줄임
                    height: 24, // 크기 줄임
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0, // 선 두께 줄임
                    ),
                  ),
                ),
              ),

            // 검색 결과 or 장르 카테고리 표시
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

  /// 장르 카테고리 섹션 구성
  Widget _buildGenreCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
        children: [
          // Hip Hop & Rap 장르 카드
          GenreCard(
            title: 'Hip Hop & Rap',
            gradient: AppColors.purpleGradient,
            onTap: () {
              // TODO: Hip Hop & Rap 장르 페이지로 이동
            },
          ),

          // Band 장르 카드
          GenreCard(
            title: 'Band',
            gradient: AppColors.blueToMintGradient,
            onTap: () {
              // TODO: Band 장르 페이지로 이동
            },
          ),

          // R&B 장르 카드
          GenreCard(
            title: 'R & B',
            gradient: AppColors.greenGradientHorizontal,
            onTap: () {
              // TODO: R&B 장르 페이지로 이동
            },
          ),

          // Jazz 장르 카드
          GenreCard(
            title: 'Jazz',
            gradient: AppColors.purpleGradientHorizontal,
            onTap: () {
              // TODO: Jazz 장르 페이지로 이동
            },
          ),

          // Acoustic 장르 카드
          GenreCard(
            title: 'Acoustic',
            gradient: const LinearGradient(
              colors: [Color(0xFFE5BCFF), Color(0xFF7DDCFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {
              // TODO: Acoustic 장르 페이지로 이동
            },
          ),
        ],
      ),
    );
  }

  /// 검색 결과 섹션 구성
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
                // 검색 재시도
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
                      // 이미지 로딩 에러 처리
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
                      // 아티스트 채널 페이지로 이동
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
                      // 트랙 상세 페이지로 이동
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
