import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/presentation/widgets/search/genre_card.dart';
import 'package:ari/presentation/widgets/search/search_input.dart';
import 'package:ari/presentation/viewmodels/search/search_viewmodel.dart';
import 'package:ari/providers/search/search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);

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
                    setState(() {
                      _showResults = true;
                    });
                  }
                },
                onClear: () {
                  _searchController.clear();
                  ref.read(searchViewModelProvider.notifier).clearSearch();
                  setState(() {
                    _showResults = false;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // 검색 결과 or 장르 카테고리 표시
            Expanded(
              child:
                  _showResults && searchState.query.isNotEmpty
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
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Text(
          state.errorMessage!,
          style: const TextStyle(color: Colors.white),
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
                    ),
                    title: Text(
                      artist.nickname,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // TODO: 아티스트 프로필 페이지로 이동
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
                      child: Image.network(
                        track.coverImageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
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
                      // TODO: 트랙 상세 페이지로 이동
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
