import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/track_detail/track_comment_header.dart';
import 'package:ari/presentation/widgets/track_detail/track_comments.dart';
import 'package:ari/presentation/widgets/track_detail/track_credit.dart';
import 'package:ari/presentation/widgets/track_detail/track_header.dart';
import 'package:ari/presentation/widgets/track_detail/track_lyrics.dart';
import 'package:ari/providers/track/streaming_log_providers.dart';
import 'package:ari/providers/track/track_detail_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackDetailScreen extends ConsumerStatefulWidget {
  final int albumId;
  final int trackId;
  final String? albumCoverUrl; // 앨범 커버 URL을 받을 수 있도록 수정

  const TrackDetailScreen({
    super.key,
    required this.albumId,
    required this.trackId,
    required this.albumCoverUrl,
  });

  @override
  _TrackDetailScreenState createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends ConsumerState<TrackDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 트랙 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(trackDetailViewModelProvider.notifier)
          .loadTrackDetail(widget.albumId, widget.trackId);
      ref
          .read(streamingLogViewModelProvider.notifier)
          .loadAlbumDetail(widget.albumId, widget.trackId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackDetailState = ref.watch(trackDetailViewModelProvider);
    final streamingLogState = ref.watch(streamingLogViewModelProvider);
    final track = trackDetailState.track; // null일 수 있는 track
    final albumCoverUrl = widget.albumCoverUrl; // 앨범 커버 URL

    // 스트리밍 로그 기반으로 재생 횟수 계산
    final int playCount = streamingLogState.logs.length;
    final bool isLoadingPlayCount = streamingLogState.isLoading;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.black),
          child: Column(
            children: [
              // 트랙 헤더 위젯
              SafeArea(
                child: HeaderWidget(
                  type: HeaderType.backWithTitle,
                  onBackPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              // 트랙 데이터가 로드되었는지 확인
              if (track != null) ...[
                // 트랙 정보가 있는 경우에만 위젯 표시
                TrackHeader(
                  albumId: track.albumId,
                  trackId: track.trackId,
                  albumName: track.albumTitle,
                  trackTitle: track.trackTitle,
                  artistName: track.artistName,
                  likeCount: track.trackLikeCount,
                  commentCount: track.commentCount,
                  playCount:
                      isLoadingPlayCount ? null : playCount, // 로딩 중인 경우 null 전달
                  albumImageUrl: albumCoverUrl ?? '',
                  artistImageUrl: track.trackFileUrl ?? '',
                  trackFileUrl: track.trackFileUrl ?? '',
                ),

                // 이하 동일
                TrackCredit(
                  title: '크레딧',
                  trackName: track.trackTitle,
                  lyricists: track.lyricist,
                  composers: track.composer,
                  genres: [track.genreName],
                ),

                TrackLyrics(title: '가사', lyrics: track.lyric),

                TrackDetailCommentHeader(commentCount: track.commentCount),

                if (track.comments.isNotEmpty) ...[
                  TrackDetailComments(comment: track.comments[0]),
                  if (track.comments.length > 1)
                    TrackDetailComments(comment: track.comments[1]),
                ],
              ] else ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
