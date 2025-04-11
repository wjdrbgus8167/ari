import 'package:ari/data/mappers/track_mapper.dart';

import 'album_comment.dart';
import 'package:ari/data/models/album.dart' as data;
import 'package:ari/data/models/track.dart' as data;
import 'package:ari/domain/entities/track.dart' as domain;

class Album {
  final int albumId;
  final String albumTitle;
  final String artist;
  final int artistId;
  final String description;
  final int albumLikeCount;
  final String genre;
  final int commentCount;
  final String rating;
  final String createdAt;
  final String coverImageUrl;
  final List<AlbumComment> comments;
  final List<domain.Track> tracks; // ✅ 도메인 모델 타입으로!
  final bool? albumLikedYn;

  Album({
    required this.albumId,
    required this.albumTitle,
    required this.artist,
    required this.artistId,
    required this.description,
    required this.albumLikeCount,
    required this.genre,
    required this.commentCount,
    required this.rating,
    required this.createdAt,
    required this.coverImageUrl,
    required this.comments,
    required this.tracks,
    required this.albumLikedYn,
  });

  Album copyWith({
    int? albumId,
    String? albumTitle,
    String? artist,
    int? artistId,
    String? description,
    int? albumLikeCount,
    String? genre,
    int? commentCount,
    String? rating,
    String? createdAt,
    String? coverImageUrl,
    List<AlbumComment>? comments,
    List<domain.Track>? tracks,
    bool? albumLikedYn,
  }) {
    return Album(
      albumId: albumId ?? this.albumId,
      albumTitle: albumTitle ?? this.albumTitle,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      description: description ?? this.description,
      albumLikeCount: albumLikeCount ?? this.albumLikeCount,
      genre: genre ?? this.genre,
      commentCount: commentCount ?? this.commentCount,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      comments: comments ?? this.comments,
      tracks: tracks ?? this.tracks,
      albumLikedYn: albumLikedYn ?? this.albumLikedYn,
    );
  }

  factory Album.fromDataModel(data.Album model) {
    print('🎯 [AlbumMapper] albumTitle: ${model.title}');
    print(
      '🎯 [AlbumMapper] model.tracks runtimeType: ${model.tracks.runtimeType}',
    );
    print('🎯 [AlbumMapper] model.tracks: ${model.tracks}');

    List<domain.Track> domainTracks = [];

    try {
      final rawTracks = model.tracks ?? [];
      domainTracks =
          rawTracks.map((t) {
            print('🔁 toDomainTrack 실행 전: $t');
            return (t as data.Track).toDomainTrack();
          }).toList();
    } catch (e, stack) {
      print('❌ [AlbumMapper] track 변환 실패: $e');
      print('🪵 Stacktrace: $stack');
    }

    return Album(
      albumId: model.id,
      albumTitle: model.title,
      artist: model.artist,
      artistId: model.artistId,
      description: '',
      albumLikeCount: 0,
      genre: model.genre,
      commentCount: 0,
      rating: '',
      createdAt: model.releaseDate.toString(),
      coverImageUrl: model.coverUrl,
      comments: [],
      tracks: domainTracks,
      albumLikedYn: false,
    );
  }
}
