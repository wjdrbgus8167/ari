import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/entities/album_comment.dart';
import 'package:ari/domain/entities/track_comment.dart';

class AlbumDetailModel extends Album {
  AlbumDetailModel({
    required super.albumLikedYn,
    required super.albumId,
    required super.albumTitle,
    required super.artist,
    required super.artistId,
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
    try {
      return AlbumDetailModel(
        albumLikedYn: json['albumLikedYn'] ?? false,
        albumId: json['albumId'],
        albumTitle: json['albumTitle'],
        artist: json['artist'],
        artistId: json['artistId'] ?? 0,
        description: json['description'] ?? '',
        albumLikeCount: json['albumLikeCount'] ?? 0,
        genre: json['genreName'] ?? '',
        commentCount: json['albumCommentCount'] ?? 0,
        rating: json['albumRating']?.toString() ?? '0.0', // ✅ 요기!
        createdAt: json['releasedAt'].toString().substring(0, 10) ?? '',
        coverImageUrl: json['coverImageUrl'],
        comments:
            json['albumComments'] != null
                ? List<AlbumCommentModel>.from(
                  json['albumComments'].map(
                    (comment) => AlbumCommentModel.fromJson(comment),
                  ),
                )
                : [],
        tracks:
            json['tracks'] != null
                ? List<TrackModel>.from(
                  json['tracks'].map(
                    (track) => TrackModel.fromJson(track, json['albumId']),
                  ),
                )
                : [],
      );
    } catch (e) {
      rethrow;
    }
  }
}

class AlbumCommentModel extends AlbumComment {
  @override
  final int memberId;
  final int commentId;
  @override
  final String nickname;
  @override
  final String content;
  @override
  final String createdAt;

  AlbumCommentModel({
    required this.memberId,
    required this.commentId,
    required this.nickname,
    required this.content,
    required this.createdAt,
  }) : super(
         id: commentId, // 부모 클래스의 id에 commentId 값 전달
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
    required super.trackId,
    required super.albumId,
    required super.albumTitle,
    required super.genreName,
    required super.trackTitle,
    required super.artistName,
    required super.lyric,
    required super.trackNumber,
    required super.commentCount,
    required super.lyricist,
    required super.composer,
    required super.comments,
    required super.createdAt,
    required super.trackFileUrl,
    required super.coverUrl,
    required super.trackLikeCount,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json, int albumId) {
    return TrackModel(
      trackId: json['trackId'] ?? 0,
      albumId: albumId,
      albumTitle: json['albumTitle'] ?? '',
      genreName: json['genreName'] ?? '',
      trackTitle: json['trackTitle'] ?? '',
      artistName: json['artist'] ?? '',
      lyric: json['lyrics'] ?? '',
      trackNumber: json['trackNumber'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      lyricist: const [], // 필수 아님
      composer: const [],
      comments: const [],
      createdAt: '', // 필수 아님
      trackFileUrl: json['trackFileUrl'] ?? '', // ✅ 핵심 필드
      coverUrl: json['coverImageUrl'] ?? '',
      trackLikeCount: json['trackLikeCount'] ?? 0,
    );
  }
}
