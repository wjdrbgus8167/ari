import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/track_detail/track_comment_header.dart';
import 'package:ari/presentation/widgets/track_detail/track_comments.dart';
import 'package:ari/presentation/widgets/track_detail/track_credit.dart';
import 'package:ari/presentation/widgets/track_detail/track_header.dart';
import 'package:ari/presentation/widgets/track_detail/track_lyrics.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class TrackDetailScreen extends ConsumerStatefulWidget {
  final int trackId;
  
  const TrackDetailScreen({
    Key? key,
    required this.trackId,
  }) : super(key: key);

  @override
  _TrackDetailScreenState createState() => _TrackDetailScreenState();
}
 
class _TrackDetailScreenState extends ConsumerState<TrackDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 트랙 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trackDetailViewModelProvider.notifier).loadTrackDetail(widget.trackId);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final trackDetailState = ref.watch(trackDetailViewModelProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.black),
          child: Column(
            children: [
              // 트랙 헤더 위젯
              SafeArea(
                child: HeaderWidget(type: HeaderType.backWithTitle, onBackPressed: () { Navigator.pop(context); }),
              ),
              const TrackHeader(
                albumName: 'AFTER HOURS',
                trackTitle: 'ALONE AGAIN',
                artistName: 'THE WEEKEND',
                likeCount: '2,040',
                commentCount: '188',
                playCount: '100회 재생',
                albumImageUrl: "assets/images/default_album_cover.png",
                artistImageUrl: 'assets/images/default_album_cover.png',
              ),
              // 트랙 크레딧 위젯
              const TrackCredit(
                title: '크레딧',
                trackName: 'ALONE AGAIN',
                lyricists: ['JS KIM', 'JS KIM'],
                composers: ['JS KIM', 'JS KIM'],
                genres: ['재즈'],
              ),
              // 트랙 가사 위젯
              TrackLyrics(
                title: '가사',
                lyrics: 'TAKE OFF MY DISGUISE\nI\'M LIVING SOMEONE ELSE\'S LIFE\nSUPPRESSING WHO I WAS INSIDE\nSO I THROW TWO-THOUSAND ONES IN THE SKY\nTOGETHER WE\'RE ALONE (TOGETHER WE\'RE ALONE)\nIN VEGAS I FEEL SO AT HOME (IN VEGAS I FEEL AT HOME)           FALLING ONLY FOR THE NIGHT\nSO I THROW TWO-THOUSAND ONES IN THE SKY (THE SKY)\nHOW, HOW MUCH TO LIGHT UP MY STAR AGAIN\nAND REWIRE ALL MY THOUGHTS?\nOH BABY, WON\'T YOU REMIND ME WHAT I AM?\nAND BREAK, BREAK MY LITTLE COLD HEART',
              ),
              
              
              TrackDetailCommentHeader(commentCount: trackDetailState.track!.commentCount),
              // 댓글 목록 처리
              if (trackDetailState.track!.comments.isNotEmpty) ...[
                // 첫 번째 댓글
                TrackDetailComments(comment: trackDetailState.track!.comments[0]),
                // 두 번째 댓글 (있는 경우)
              if (trackDetailState.track!.comments.length > 1)
                TrackDetailComments(comment: trackDetailState.track!.comments[1]),
              ],
            ]
          )
        )
      )
    );
  }
}