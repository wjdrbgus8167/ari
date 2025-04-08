import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/presentation/viewmodels/search/search_viewmodel.dart';
import 'package:ari/providers/search/search_providers.dart';
import '../../widgets/search/search_input.dart';

/// 팬톡 작성할 때 첨부할 트랙 검색하고 선택하는 화면
/// 검색 화면 기반, 트랙만 검색 및 선택
class TrackSelectionScreen extends ConsumerStatefulWidget {
  const TrackSelectionScreen({super.key});

  @override
  ConsumerState<TrackSelectionScreen> createState() =>
      _TrackSelectionScreenState();
}

class _TrackSelectionScreenState extends ConsumerState<TrackSelectionScreen> {
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          '트랙 선택',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    child: CircularProgressIndicator(
                      color: AppColors.mediumPurple,
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
              ),

            Expanded(
              child:
                  shouldShowResults
                      ? _buildSearchResults(searchState)
                      : _buildHelpText(),
            ),
          ],
        ),
      ),
    );
  }

  /// 검색 도움말 텍스트 표시
  Widget _buildHelpText() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, color: Colors.grey[600], size: 48),
          const SizedBox(height: 16),
          Text(
            '추천하고 싶은 트랙이 있다면 검색해보세요',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '트랙의 제목으로 검색할 수 있습니다',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 검색 결과: 트랙만 표시
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mediumPurple,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.tracks.isEmpty) {
      return Center(
        child: Text(
          '검색 결과가 없습니다',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 트랙 검색 결과만 표시
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
                  trailing: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.mediumPurple,
                  ),
                  onTap: () {
                    // 선택한 트랙 정보를 결과로 반환
                    Navigator.of(context).pop({
                      'trackId': track.trackId,
                      'trackTitle': track.trackTitle,
                      'artist': track.artist,
                      'coverImageUrl': track.coverImageUrl,
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
