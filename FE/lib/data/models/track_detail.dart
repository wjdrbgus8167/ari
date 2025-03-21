class TrackDetailModel {
  final int albumId;
  final int trackId;
  final String albumTitle;
  final String trackTitle;
  final String artist;
  final String composer;
  final String lylist;
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
    required this.lylist,
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
      lylist: json['lylist'] ?? '',
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
}