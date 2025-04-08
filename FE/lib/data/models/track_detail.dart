import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/entities/track_comment.dart';

class TrackDetailModel {
  final int trackId;
  final String albumTitle;
  final String trackTitle;
  final String artist;
  final int artistId;
  final String composer;
  final String lyricist;
  final int trackLikeCount;
  final int trackCommentCount;
  final String createdAt;
  final String lyric;
  final String trackFileUrl;
  final String genreName;
  final List<TrackCommentModel> trackComments;

  TrackDetailModel({
    required this.trackId,
    required this.albumTitle,
    required this.trackTitle,
    required this.artist,
    required this.artistId,
    required this.composer,
    required this.lyricist,
    required this.trackLikeCount,
    required this.trackCommentCount,
    required this.createdAt,
    required this.lyric,
    required this.trackFileUrl,
    required this.genreName,
    required this.trackComments,
  });

  // JSON에서 모델로 변환하는 팩토리 생성자
  factory TrackDetailModel.fromJson(Map<String, dynamic> json) {
    // 댓글 리스트 파싱
    List<TrackCommentModel> commentsList = [];
    if (json['trackComments'] != null) {
      commentsList = List<TrackCommentModel>.from(
        (json['trackComments'] as List).map(
          (comment) => TrackCommentModel.fromJson(comment),
        ),
      );
    }
    return TrackDetailModel(
      trackId: json['trackId'] ?? 0,
      albumTitle: json['albumTitle'] ?? '',
      trackTitle: json['trackTitle'] ?? '',
      artist: json['artist'] ?? '',
      composer: json['composer'] ?? '',
      lyricist: json['lyricist'] ?? '',
      genreName: json['genreName'] ?? '',
      trackLikeCount: json['trackLikeCount'] ?? 0,
      trackCommentCount: json['trackCommentCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      lyric: json['lyric'] ?? '',
      trackFileUrl: json['trackFileUrl'] ?? '',
      trackComments: commentsList,
      artistId: json['artistId'] ?? 0,
    );
  }

  // Entity로 변환하는 메서드
  Track toEntity(int albumId) {
    // lyricist와 composer가 문자열로 저장되어 있으므로 리스트로 변환
    List<String> lyricistList =
        lyricist.isEmpty
            ? []
            : lyricist.split(',').map((item) => item.trim()).toList();

    List<String> composerList =
        composer.isEmpty
            ? []
            : composer.split(',').map((item) => item.trim()).toList();

    // 댓글 변환
    List<TrackComment> comments =
        trackComments
            .map(
              (comment) => TrackComment(
                memberId: comment.memberId,
                commentId: comment.commentId,
                nickname: comment.nickname,
                content: comment.content,
                timestamp: comment.timestamp,
                createdAt: comment.createdAt,
              ),
            )
            .toList();

    const int defaultTrackNumber = 1; // 적절한 기본값으로 변경

    return Track(
      albumId: albumId,
      trackId: trackId,
      trackTitle: trackTitle,
      albumTitle: albumTitle,
      genreName: genreName,
      artistName: artist,
      lyric: lyric,
      trackNumber: defaultTrackNumber,
      commentCount: trackCommentCount,
      lyricist: lyricistList,
      composer: composerList,
      comments: comments,
      createdAt: createdAt,
      coverUrl: null,
      trackFileUrl: trackFileUrl,
      trackLikeCount: trackLikeCount,
      artistId: artistId,
    );
  }
}

// 트랙 댓글에 대한 데이터 모델
class TrackCommentModel {
  final int memberId;
  final int commentId;
  final String nickname;
  final String content;
  final String timestamp;
  final String createdAt;

  TrackCommentModel({
    required this.memberId,
    required this.commentId,
    required this.nickname,
    required this.content,
    required this.timestamp,
    required this.createdAt,
  });

  // JSON에서 모델로 변환하는 팩토리 생성자
  factory TrackCommentModel.fromJson(Map<String, dynamic> json) {
    return TrackCommentModel(
      memberId: json['memberId'] ?? 0,
      commentId: json['commentId'] ?? 0,
      nickname: json['nickname'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? '00:00',
      createdAt: json['createdAt'] ?? '',
    );
  }

  TrackComment toEntity() {
    return TrackComment(
      memberId: memberId,
      commentId: commentId,
      nickname: nickname,
      content: content,
      timestamp: timestamp,
      createdAt: createdAt,
    );
  }
}
