import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/entities/track_comment.dart';

class TrackDetailModel {
  final int albumId;
  final int trackId;
  final String albumTitle;
  final String trackTitle;
  final String artist;
  final String composer;
  final String lyricist;
  final String description;
  final int albumLikeCount;
  final String genre;
  final int trackLikeCount;
  final int commentCount;
  final String createdAt;
  final String lyric;
  final String coverImageUrl;
  final List<TrackCommentModel> comments;

  TrackDetailModel({
    required this.albumId,
    required this.trackId,
    required this.albumTitle,
    required this.trackTitle,
    required this.artist,
    required this.composer,
    required this.lyricist,
    required this.description,
    required this.albumLikeCount,
    required this.genre,
    required this.trackLikeCount,
    required this.commentCount,
    required this.createdAt,
    required this.lyric,
    required this.coverImageUrl,
    required this.comments,
  });

  // JSON에서 모델로 변환하는 팩토리 생성자
  factory TrackDetailModel.fromJson(Map<String, dynamic> json) {
    // 댓글 리스트 파싱
    List<TrackCommentModel> commentsList = [];
    if (json['comments'] != null) {
      commentsList = List<TrackCommentModel>.from(
        (json['comments'] as List).map(
          (comment) => TrackCommentModel.fromJson(comment),
        ),
      );
    }
    return TrackDetailModel(
      albumId: json['albumId'] ?? 0,
      trackId: json['trackId'] ?? 0,
      albumTitle: json['albumTitle'] ?? '',
      trackTitle: json['trackTitle'] ?? '',
      artist: json['artist'] ?? '',
      composer: json['composer'] ?? '',
      lyricist: json['lylist'] ?? '',
      description: json['discription'] ?? '', // 오타 주의 (API에서 'discription'으로 오고 있음)
      albumLikeCount: json['albumLikeCount'] ?? 0,
      genre: json['genre'] ?? '',
      trackLikeCount: json['trackLikeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      createdAt: json['createdAt'],
      lyric: json['lyric'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      comments: commentsList,
    );
  }

    // Entity로 변환하는 메서드
  Track toEntity() {
    // lyricist와 composer가 문자열로 저장되어 있으므로 리스트로 변환
    // 쉼표로 구분되어 있다고 가정
    List<String> lyricistList = lyricist.isEmpty 
        ? [] 
        : lyricist.split(',').map((item) => item.trim()).toList();
    
    List<String> composerList = composer.isEmpty 
        ? [] 
        : composer.split(',').map((item) => item.trim()).toList();
    
    // 댓글 변환
    List<TrackComment> trackComments = comments.map((comment) => 
      TrackComment(
        trackId: comment.trackId,
        commentId: comment.commentId,
        nickname: comment.nickname,
        content: comment.content,
        timestamp: comment.contentTimestamp,
        createdAt: comment.createdAt
      )
    ).toList();
    
    // playTime과 trackNumber 정보가 모델에 없으므로 기본값 설정
    // 실제 구현에서는 이 값들이 어떻게 제공되는지에 따라 수정 필요
    const int defaultPlayTime = 0; // 적절한 기본값으로 변경
    const int defaultTrackNumber = 1; // 적절한 기본값으로 변경
    
    return Track(
      albumId: albumId,
      trackId: trackId,
      trackTitle: trackTitle,
      artistName: artist,
      lyric: lyric,
      playTime: defaultPlayTime,
      trackNumber: defaultTrackNumber,
      commentCount: commentCount,
      lyricist: lyricistList,
      composer: composerList,
      comments: trackComments,
      createdAt: createdAt,
    );
  }
}

  // 트랙 댓글에 대한 데이터 모델
class TrackCommentModel {
  final int trackId;
  final int commentId;
  final String nickname;
  final String content;
  final String contentTimestamp;
  final String createdAt;

  TrackCommentModel({
    required this.trackId,
    required this.commentId,
    required this.nickname,
    required this.content,
    required this.contentTimestamp,
    required this.createdAt,
  });

  // JSON에서 모델로 변환하는 팩토리 생성자
  factory TrackCommentModel.fromJson(Map<String, dynamic> json) {

    return TrackCommentModel(
      trackId: json['trackId'] ?? 0,
      commentId: json['commentId'] ?? 0,
      nickname: json['nickname'] ?? '',
      content: json['content'] ?? '',
      contentTimestamp: json['contentTimestamp'] ?? '00:00',
      createdAt: json['createdAt'],
    );
  }

  TrackComment toEntity() {
    return TrackComment(
      trackId: trackId,
      commentId: commentId,
      nickname: nickname,
      content: content,
      timestamp: contentTimestamp,
      createdAt: createdAt
    );
  }
}