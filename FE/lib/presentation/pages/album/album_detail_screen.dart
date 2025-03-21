import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/entities/album_comment.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_comment_header.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_comments.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_cover.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_description.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_title.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_track_list.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlbumDetailScreen extends ConsumerStatefulWidget {
  final int albumId;

  const AlbumDetailScreen({Key? key, required this.albumId}) : super(key: key);

  @override
  _AlbumDetailScreenState createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends ConsumerState<AlbumDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 앨범 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(albumDetailViewModelProvider.notifier)
          .loadAlbumDetail(widget.albumId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 앨범 데이터 상태 가져오기
    final albumDetailState = ref.watch(albumDetailViewModelProvider);
    print(albumDetailState.album?.artist);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.black),
          child:
              albumDetailState.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : albumDetailState.errorMessage != null
                  ? (() {
                    return Center(
                      child: Text(
                        'Error: ${albumDetailState.errorMessage}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  })()
                  : albumDetailState.album != null
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      SafeArea(
                        child: HeaderWidget(
                          type: HeaderType.backWithTitle,
                          onBackPressed: () => Navigator.pop(context),
                        ),
                      ),

                      AlbumDetailCover(
                        coverImage:
                            albumDetailState.album?.coverImageUrl ??
                            '기본 이미지 URL',
                      ),
                      AlbumDetailTitle(
                        title: albumDetailState.album!.title,
                        artist: albumDetailState.album!.artist,
                        viewCount: albumDetailState.album!.likeCount,
                        commentCount: albumDetailState.album!.commentCount,
                        rating: albumDetailState.album!.rating,
                        genre: albumDetailState.album!.genre,
                        releaseDate: albumDetailState.album!.releaseDate,
                      ),
                      AlbumDetailTrackList(
                        tracks:
                            albumDetailState.album!.tracks
                                .map((track) => track)
                                .toList(),
                      ),
                      AlbumDetailDescription(
                        description: albumDetailState.album!.description,
                      ),
                      AlbumDetailCommentHeader(
                        commentCount: albumDetailState.album!.commentCount,
                      ),
                      // 댓글 목록 처리
                      if (albumDetailState.album!.comments.isNotEmpty) ...[
                        // 첫 번째 댓글
                        AlbumDetailComments(
                          comment: albumDetailState.album!.comments[0],
                        ),
                        // 두 번째 댓글 (있는 경우)
                        if (albumDetailState.album!.comments.length > 1)
                          AlbumDetailComments(
                            comment: albumDetailState.album!.comments[1],
                          ),
                      ],
                      // AlbumDetailBottomNavigation(),
                    ],
                  )
                  : const Center(
                    child: Text(
                      '앨범 정보가 없습니다',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
        ),
      ),
    );
  }
}
