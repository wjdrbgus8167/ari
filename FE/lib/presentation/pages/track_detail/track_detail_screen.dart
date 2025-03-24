import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/track_detail/track_comment_header.dart';
import 'package:ari/presentation/widgets/track_detail/track_comments.dart';
import 'package:ari/presentation/widgets/track_detail/track_credit.dart';
import 'package:ari/presentation/widgets/track_detail/track_header.dart';
import 'package:ari/presentation/widgets/track_detail/track_lyrics.dart';
import 'package:ari/providers/track/track_detail_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class TrackDetailScreen extends ConsumerStatefulWidget {
  final int albumId;
  final int trackId;
  
  const TrackDetailScreen({
    super.key,
    required this.albumId,
    required this.trackId,
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
      ref.read(trackDetailViewModelProvider.notifier).loadTrackDetail(widget.albumId, widget.trackId);
    });
  }
  
@override
  Widget build(BuildContext context) {
    final trackDetailState = ref.watch(trackDetailViewModelProvider);
    final track = trackDetailState.track; // null일 수 있는 track
    
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
                  onBackPressed: () { Navigator.pop(context); }
                ),
              ),
              
              // 트랙 데이터가 로드되었는지 확인
              if (track != null) ...[
                // 트랙 정보가 있는 경우에만 위젯 표시
                TrackHeader(
                  albumId: track.albumId,
                  trackId: track.trackId,
                  albumName: 'AFTER HOURS', // 실제 값으로 교체 필요
                  trackTitle: track.trackTitle,
                  artistName: track.artistName,
                  likeCount: '2,040', // 실제 값으로 교체 필요
                  commentCount: '${track.commentCount}',
                  playCount: '100회 재생', // 실제 값으로 교체 필요
                  albumImageUrl: "assets/images/default_album_cover.png",
                  artistImageUrl: 'assets/images/default_album_cover.png',
                ),
                
                // 트랙 크레딧 위젯
                TrackCredit(
                  title: '크레딧',
                  trackName: track.trackTitle,
                  lyricists: track.lyricist,
                  composers: track.composer,
                  genres: ['재즈'], // 실제 값으로 교체 필요
                ),
                
                // 트랙 가사 위젯
                TrackLyrics(
                  title: '가사',
                  lyrics: track.lyric,
                ),
                
                TrackDetailCommentHeader(commentCount: track.commentCount),
                
                // 댓글 목록 처리
                if (track.comments.isNotEmpty) ...[
                  // 첫 번째 댓글
                  TrackDetailComments(comment: track.comments[0]),
                  // 두 번째 댓글 (있는 경우)
                  if (track.comments.length > 1)
                    TrackDetailComments(comment: track.comments[1]),
                ],
              ] else ...[
                // 로딩 중이거나 데이터가 없는 경우 표시할 UI
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
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