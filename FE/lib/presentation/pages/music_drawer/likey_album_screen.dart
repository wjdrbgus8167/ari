import 'package:ari/data/models/music_drawer/likey_albums_model.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/music_drawer/likey_album_viewmodel.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/common/media_card.dart';
import 'package:ari/providers/music_drawer/music_drawer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LikeyAlbumsScreen extends ConsumerWidget {
  const LikeyAlbumsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 좋아요 누른 앨범 상태 감시
    final likeyAlbumsState = ref.watch(likeyAlbumsViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _buildContent(context, ref, likeyAlbumsState)),
    );
  }

  /// 화면 컨텐츠 빌드
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    LikeyAlbumsState state,
  ) {
    if (state.isLoading) {
      return Column(
        children: [
          HeaderWidget(
            type: HeaderType.backWithTitle, 
            title: '좋아요 누른 앨범', 
            onBackPressed: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    // 앨범이 없는 경우 처리
    if (state.likeyAlbumsCount == 0) {
      return Column(
        children: [
          HeaderWidget(
            type: HeaderType.backWithTitle, 
            title: '좋아요 누른 앨범', 
            onBackPressed: () {
              Navigator.pop(context);
            },
          ),
          const Expanded(
            child: Center(
              child: Text(
                '좋아요 표시한 앨범이 없습니다',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    // 화면 너비 계산
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 카드 사이즈 계산 (여백 및 간격 고려)
    final cardWidth = (screenWidth - 48) / 2; // 좌우 패딩 16씩, 중간 간격 16
    final cardHeight = cardWidth + 60; // 이미지 + 텍스트 공간 (조정 가능)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderWidget(
          type: HeaderType.backWithTitle, 
          title: '좋아요 누른 앨범', 
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: (state.likeyAlbumsCount / 2).ceil(), // 행의 개수
              itemBuilder: (context, rowIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    children: [
                      // 첫 번째 열
                      Expanded(
                        child: rowIndex * 2 < state.likeyAlbumsCount
                            ? _buildAlbumCard(
                                context,
                                ref,
                                state.likeyAlbums[rowIndex * 2],
                                cardHeight,
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 16), // 열 사이 간격
                      // 두 번째 열
                      Expanded(
                        child: rowIndex * 2 + 1 < state.likeyAlbumsCount
                            ? _buildAlbumCard(
                                context,
                                ref,
                                state.likeyAlbums[rowIndex * 2 + 1],
                                cardHeight,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAlbumCard(
    BuildContext context,
    WidgetRef ref,
    LikeyAlbum album,
    double cardHeight,
  ) {
    return SizedBox(
      height: cardHeight,
      child: MediaCard(
        imageUrl: album.coverImageUrl,
        title: album.albumTitle,
        subtitle: album.artist,
        onTap: () {
          // 앨범 상세 페이지로 이동
          Navigator.pushNamed(context, AppRoutes.album, arguments: album.albumId);
        },
      ),
    );
  }
}