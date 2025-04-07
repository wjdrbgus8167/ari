import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/entities/album_comment.dart';

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
  final List<Track> tracks;

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
  });
}
