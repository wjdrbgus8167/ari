import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/entities/album_comment.dart';
import 'package:ari/domain/entities/track_comment.dart';

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
    try {
      return AlbumDetailModel(
        albumId: json['albumId'],
        albumTitle: json['albumTitle'],
        artist: json['artist'],
        description: json['description'] ?? '',
        albumLikeCount: json['albumLikeCount'] ?? 0,
        genre: json['genreName'] ?? '',
        commentCount: json['albumCommentCount'] ?? 0,
        rating: "0",
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
      throw e;
    }
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
    required int trackId,
    required int albumId,
    required String albumTitle,
    required String genreName,
    required String trackTitle,
    required String artistName,
    required String lyric,
    required int trackNumber,
    required int commentCount,
    required List<String> lyricist,
    required List<String> composer,
    required List<TrackComment> comments,
    required String createdAt,
    required String? trackFileUrl,
    required String? coverUrl,
    required int trackLikeCount,
  }) : super(
         trackId: trackId,
         albumId: albumId,
         albumTitle: albumTitle,
         genreName: genreName,
         trackTitle: trackTitle,
         artistName: artistName,
         lyric: lyric,
         trackNumber: trackNumber,
         commentCount: commentCount,
         lyricist: lyricist,
         composer: composer,
         comments: comments,
         createdAt: createdAt,
         trackFileUrl: trackFileUrl,
         coverUrl: coverUrl,
         trackLikeCount: trackLikeCount,
       );

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
