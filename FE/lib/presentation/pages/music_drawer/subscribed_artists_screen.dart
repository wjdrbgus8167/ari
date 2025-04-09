import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/models/music_drawer/subscribed_artist_model.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/providers/music_drawer/music_drawer_providers.dart';
import 'package:ari/presentation/viewmodels/music_drawer/subscribed_artists_viewmodel.dart';
import 'package:ari/presentation/routes/app_router.dart';

/// 구독 중인 아티스트 목록 화면
class SubscribedArtistsScreen extends ConsumerWidget {
  const SubscribedArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 구독 중인 아티스트 상태 감시
    final artistsState = ref.watch(subscribedArtistsViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: HeaderWidget(
          type: HeaderType.backWithTitle,
          title: '구독 중인 아티스트',
          onBackPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(child: _buildContent(context, ref, artistsState)),
    );
  }

  /// 화면 컨텐츠 빌드
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SubscribedArtistsState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '데이터를 불러올 수 없습니다',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _retryLoading(ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.artists.isEmpty) {
      return const Center(
        child: Text(
          '구독 중인 아티스트가 없습니다',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    // 아티스트 그리드 목록
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            '구독 중인 아티스트',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.artists.length,
              itemBuilder: (context, index) {
                return _buildArtistCard(context, ref, state.artists[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 아티스트 카드 위젯
  Widget _buildArtistCard(
    BuildContext context,
    WidgetRef ref,
    SubscribedArtistModel artist,
  ) {
    return InkWell(
      onTap: () {
        // 라우터를 통해 다른 사용자의 채널 페이지로 이동
        AppRouter.navigateTo(context, ref, AppRoutes.myChannel, {
          'memberId': artist.artistId.toString(),
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아티스트 프로필 이미지 (원형)
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              // 이미지 URL이 있을 경우 NetworkImage로 대체
              // 현재는 임시로 흰색 원으로 표시
            ),
            const SizedBox(height: 16),

            // 아티스트 이름
            Text(
              artist.artistNickname,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 팔로워 수와 구독자 수 정보
            Text(
              '4.3K Followers / 구독자 4.2만명',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 데이터 다시 로드
  void _retryLoading(WidgetRef ref) {
    ref
        .read(subscribedArtistsViewModelProvider.notifier)
        .loadSubscribedArtists();
  }
}
