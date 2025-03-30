import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/entities/album_comment.dart';

class AlbumDetailModel extends Album {
  AlbumDetailModel({
    required super.albumId,
    required super.albumTitle,
    required super.artist,
    required super.description,
    required super.albumLikeCount,
    required super.genre,
    required super.commentCount,
    required super.rating,
    required super.createdAt,
    required super.coverImageUrl,
    required super.comments,
    required super.tracks,
  });

  factory AlbumDetailModel.fromJson(Map<String, dynamic> json) {
    return AlbumDetailModel(
      albumId: json['albumId'],
      albumTitle: json['albumTitle'],
      artist: json['artist'],
      description: json['discription'] ?? '',
      albumLikeCount: json['albumLikeCount'] ?? 0,
      genre: json['genre'] ?? '',
      commentCount: json['commentCount'] ?? 0,
      rating: json['rating'],
      createdAt: json['createdAt'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      comments: json['comments'] != null
          ? List<AlbumCommentModel>.from(
              json['comments'].map((comment) => AlbumCommentModel.fromJson(comment)))
          : [],
      tracks: json['track'] != null
          ? List<TrackModel>.from(
              json['track'].map((track) => TrackModel.fromJson(track, json['albumId'])))
          : [],
    );
  }
}


class AlbumCommentModel extends AlbumComment {
  final int memberId;
  final int commentId;
  final String nickname;
  final String content;
  final String createdAt;

  AlbumCommentModel({
    required this.memberId,
    required this.commentId,
    required this.nickname,
    required this.content,
    required this.createdAt,
  }): super(
    id: commentId,  // 부모 클래스의 id에 commentId 값 전달
    memberId: memberId,
    nickname: nickname,
    content: content,
    createdAt: createdAt,
    userAvatar: "",
  );

  factory AlbumCommentModel.fromJson(Map<String, dynamic> json) {
    return AlbumCommentModel(
      memberId: json['memberId'],
      commentId: json['commentId'],
      nickname: json['nickname'],
      content: json['content'],
      createdAt: json['createdAt'],
    );
  }
}

class TrackModel extends Track {
  TrackModel({
    required int trackId,
    required int albumId,
    required String title,
  }) : super(
    trackId: trackId,
    albumId: albumId,
    trackTitle: title,
    trackNumber: 0,
    artistName: '',        // 누락된 필수 매개변수 추가
    lyric: '',             // 누락된 필수 매개변수 추가
    playTime: 0,           // 누락된 필수 매개변수 추가
    comments: const [],    // 누락된 필수 매개변수 추가
    commentCount: 0,       // 필요한 경우 추가
    lyricist: const [],    // 필요한 경우 추가
    composer: const [],    // 필요한 경우 추가
    createdAt: '',         // 필요한 경우 추가
  );

  factory TrackModel.fromJson(Map<String, dynamic> json, int albumId) {
    return TrackModel(
      trackId: json['trackId'],
      albumId: albumId,
      title: json['trackTitle'],
    );
  }
}