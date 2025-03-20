import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/entities/album_comment.dart';

class AlbumDetailModel extends Album {
  AlbumDetailModel({
    required int id,
    required String title,
    required String artist,
    required String description,
    required int likeCount,
    required String genre,
    required int commentCount,
    required double rating,
    required String releaseDate,
    required String coverImageUrl,
    required List<AlbumCommentModel> comments,
    required List<TrackModel> tracks,
  }):super(
    id: id,
    title: title,
    artist: artist,
    description: description,
    likeCount: likeCount,
    genre: genre,
    commentCount: commentCount,
    rating: rating,
    releaseDate: releaseDate,
    coverImageUrl: coverImageUrl,
    comments: comments,
    tracks: tracks,
  );

  factory AlbumDetailModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return AlbumDetailModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      description: json['description'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      genre: json['genre'] ?? '',
      commentCount: json['commentCount'] ?? 0,
      rating: (json['rating'] is String) 
        ? double.parse(json['rating']) 
        : (json['rating'] ?? 0.0).toDouble(),
      releaseDate: json['releaseDate'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      comments: json['comments'] != null
          ? List<AlbumCommentModel>.from(
              json['comments'].map((comment) => AlbumCommentModel.fromJson(comment)))
          : [],
      tracks: json['tracks'] != null
          ? List<TrackModel>.from(
              json['tracks'].map((track) => TrackModel.fromJson(track)))
          : [],
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'artist': artist,
  //     'composer': composer,
  //     'description': description,
  //     'likeCount': likeCount,
  //     'genre': genre,
  //     'commentCount': commentCount,
  //     'rating': rating,
  //     'releaseDate': releaseDate,
  //     'coverImageUrl': coverImageUrl,
  //     'comments': comments.map((comment) => 
  //       (comment as AlbumCommentModel).toJson()).toList(),
  //     'tracks': tracks.map((track) => 
  //       (track as TrackModel).toJson()).toList(),
  //   };
  // }
}


class AlbumCommentModel extends AlbumComment {
  final int albumId;
  final int commentId;
  final String nickname;
  final String content;
  final String contentTimestamp;
  final String createdAt;

  AlbumCommentModel({
    required this.albumId,
    required this.commentId,
    required this.nickname,
    required this.content,
    required this.contentTimestamp,
    required this.createdAt,
  }): super(
    id: commentId,  // 부모 클래스의 id에 commentId 값 전달
    albumId: albumId,
    nickname: nickname,
    content: content,
    contentTimestamp: contentTimestamp,
    createdAt: createdAt,
    userAvatar: "",
  );

  factory AlbumCommentModel.fromJson(Map<String, dynamic> json) {
    return AlbumCommentModel(
      albumId: json['albumId'],
      commentId: json['id'],
      nickname: json['nickname'],
      content: json['content'],
      contentTimestamp: json['contentTimestamp'],
      createdAt: json['createdAt'],
    );
  }
}

class TrackModel extends Track {
  TrackModel({
    required int id,
    required int albumId,
    required String title,
  }) : super(
    id: id,
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

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'],
      albumId: json['albumId'],
      title: json['trackTitle'],
    );
  }
}