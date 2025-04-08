import 'package:ari/domain/entities/album_comment.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_comment_header.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_comments.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_cover.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_description.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_title.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_track_list.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/providers/album/album_detail_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlbumDetailScreen extends ConsumerStatefulWidget {
  final int albumId;

  const AlbumDetailScreen({super.key, required this.albumId});

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
          .read(albumDetailViewModelProvider(widget.albumId).notifier)
          .loadAlbumDetail(widget.albumId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 앨범 데이터 상태 가져오기
    final albumDetailState = ref.watch(
      albumDetailViewModelProvider(widget.albumId),
    );
    print(albumDetailState.album?.coverImageUrl);
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
                        title: albumDetailState.album!.albumTitle,
                        artist: albumDetailState.album!.artist,
                        artistId: albumDetailState.album!.artistId,
                        viewCount: albumDetailState.album!.albumLikeCount,
                        commentCount: albumDetailState.album!.commentCount,
                        rating: albumDetailState.album!.rating,
                        genre: albumDetailState.album!.genre,
                        releaseDate: albumDetailState.album!.createdAt,
                        albumId: widget.albumId,
                      ),
                      AlbumDetailTrackList(
                        tracks: albumDetailState.album!.tracks,
                        albumCoverUrl:
                            albumDetailState.album?.coverImageUrl ?? '',
                      ),
                      AlbumDetailDescription(
                        description: albumDetailState.album!.description,
                      ),
                      AlbumDetailCommentHeader(
                        commentCount: albumDetailState.album!.commentCount,
                      ),
                      // 댓글 목록 처리
                      if (albumDetailState.album!.comments.isNotEmpty) ...[
                        // 댓글 작성
                        AlbumDetailComments(
                          comment:
                              albumDetailState.album!.comments.isNotEmpty
                                  ? albumDetailState
                                      .album!
                                      .comments[0] // 첫 번째 댓글 정보 전달 (또는 빈 댓글 객체)
                                  : AlbumComment(
                                    id: 0,
                                    memberId: 0,
                                    nickname: "",
                                    content: "",
                                    createdAt: "",
                                    userAvatar: "",
                                  ),
                          isCommentInput: true, // 댓글 작성 위젯임을 명시
                        ),

                        // 그 다음 댓글 목록 표시
                        if (albumDetailState.album!.comments.isNotEmpty) ...[
                          ...albumDetailState.album!.comments.map(
                            (comment) => AlbumDetailComments(
                              comment: comment,
                              isCommentInput:
                                  false, // 명시적으로 일반 댓글 위젯임을 표시 (기본값이라 생략 가능)
                            ),
                          ),
                        ],
                      ],
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
