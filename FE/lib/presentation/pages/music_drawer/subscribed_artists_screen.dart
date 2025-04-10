import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/music_drawer/artist_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/music_drawer/music_drawer_providers.dart';

/// 구독 중인 아티스트 목록 화면
class SubscribedArtistsScreen extends ConsumerWidget {
  const SubscribedArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 구독 중인 아티스트 상태 감시
    final artistsState = ref.watch(subscribedArtistsViewModelProvider);

    // 로딩 중일 때 표시할 위젯
    if (artistsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러가 있거나 데이터가 비어있을 때 표시할 위젯
    if (artistsState.artists.isEmpty || artistsState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '구독 중인 아티스트가 없습니다',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (artistsState.errorMessage != null)
              ElevatedButton(
                onPressed: () => _retryLoading(ref),
                child: Text('다시 시도'),
              ),
          ],
        ),
      );
    }

    // 아티스트 목록을 표시
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('구독 중인 아티스트'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: artistsState.artists.length,
        itemBuilder: (context, index) {
          final artist = artistsState.artists[index];
          // 각 아티스트에 대한 라우트 이름 생성
          final routeName = AppRoutes.myChannel;
          
          return ArtistItem(
            title: artist.artistNickname,
            routeName: routeName,
            onTap: () {
              // 아티스트 상세 페이지로 네비게이션
              Navigator.pushNamed(
                context,
                AppRoutes.myChannel,
                arguments: {'memberId': artist.artistId.toString()},
              );
            },
          );
        },
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